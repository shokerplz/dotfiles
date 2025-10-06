{ lib }:
let
  inherit (lib)
    attrsets
    lists
    strings
    warn
    ;

  ensureList = value: if builtins.isList value then value else [ value ];

  ensureAttrPath = value:
    if builtins.isList value then
      value
    else if builtins.isString value then
      let
        cleaned = builtins.filter (segment: segment != "") (strings.splitString "." value);
      in
      cleaned
    else
      throw "customPackages: expected name or attrPath as string or list of attribute names.";

  formatAttrPath = path: strings.concatStringsSep "." path;

  getAttrByPath = path: set:
    lists.foldl'
      (
        acc: key:
        if acc == null || !(acc ? key) then
          null
        else
          acc.${key}
      )
      set
      path;

  normalizePackages = { value, system, allowUnfree }:
    if value ? packages && value.packages ? ${system} then
      value.packages.${system}
    else if value ? legacyPackages && value.legacyPackages ? ${system} then
      value.legacyPackages.${system}
    else if value ? packages then
      throw "customPackages: packages set has no packages for system ${system}."
    else if value ? legacyPackages then
      throw "customPackages: legacyPackages set has no packages for system ${system}."
    else
      value;

  importPkgs = { source, system, allowUnfree }:
    import source {
      inherit system;
      config.allowUnfree = allowUnfree;
    };

  normalizeSet = { source, system, allowUnfree }:
    let
      evaluated =
        if builtins.isFunction source then
          source system
        else if builtins.isAttrs source && source ? path then
          importPkgs {
            inherit system allowUnfree;
            source = source.path;
          }
        else if builtins.isString source || builtins.isPath source then
          importPkgs {
            inherit system allowUnfree;
            source = source;
          }
        else if builtins.isAttrs source && source ? url then
          importPkgs {
            inherit system allowUnfree;
            source = source.url;
          }
        else if builtins.isAttrs source && source ? flake then
          builtins.getFlake source.flake
        else if builtins.isAttrs source && source ? packages then
          source
        else
          throw "customPackages: unsupported source specification.";
    in
    if builtins.isAttrs evaluated && (evaluated ? packages || evaluated ? legacyPackages) then
      normalizePackages {
        value = evaluated;
        inherit system allowUnfree;
      }
    else
      evaluated;

  applyOverrides = { spec, pkg, attrPathStr }:
    let
      pkgAfterOverrideArgs =
        if spec ? overrideArgs then
          if builtins.hasAttr "override" pkg then
            pkg.override spec.overrideArgs
          else
            warn "customPackages: package '${attrPathStr}' does not support overrideArgs." pkg
        else
          pkg;
      pkgAfterOverrideAttrs =
        if spec ? overrideAttrs then
          if builtins.hasAttr "overrideAttrs" pkgAfterOverrideArgs then
            pkgAfterOverrideArgs.overrideAttrs spec.overrideAttrs
          else
            warn "customPackages: package '${attrPathStr}' does not support overrideAttrs." pkgAfterOverrideArgs
        else
          pkgAfterOverrideArgs;
      pkgAfterPostProcess =
        if spec ? postProcess then
          spec.postProcess pkgAfterOverrideAttrs
        else
          pkgAfterOverrideAttrs;
    in
    pkgAfterPostProcess;

  renderChannelList = channelNames: strings.concatStringsSep ", " channelNames;

in
{
  mkSelector =
    {
      pkgs,
      channels ? {},
      system ? (pkgs.stdenv.system or builtins.currentSystem),
      allowUnfree ? (pkgs.config.allowUnfree or false),
    }:
    let
      normalizedChannels =
        attrsets.mapAttrs (
          _: channelInput:
          normalizeSet {
            inherit system allowUnfree;
            source = channelInput;
          }
        ) channels;

      allChannels = normalizedChannels // { current = pkgs; };
      channelNames = builtins.attrNames allChannels;

      resolveChannel = channelName:
        if builtins.hasAttr channelName allChannels then
          allChannels.${channelName}
        else
          throw "customPackages: unknown channel '${channelName}'. Available channels: ${renderChannelList channelNames}.";

      resolveAttrSpec = spec:
        let
          attrPath =
            if spec ? attrPath then ensureAttrPath spec.attrPath
            else if spec ? name then ensureAttrPath spec.name
            else throw "customPackages: specification must include 'name' (string) or 'attrPath' (list or string).";
          attrPathStr = formatAttrPath attrPath;
          requestedChannels = ensureList (spec.channel or []);
          sourceDescriptors =
            if spec ? source then
              [
                {
                  channelName = spec.channelName or "source";
                  packages = normalizeSet {
                    inherit system allowUnfree;
                    source = spec.source;
                  };
                }
              ]
            else
              [];
          channelOrder = lists.unique (requestedChannels ++ channelNames);
          channelDescriptors =
            map
              (channelName: {
                inherit channelName;
                packages = resolveChannel channelName;
              })
              channelOrder;
          candidateSets = sourceDescriptors ++ channelDescriptors;
          resolved =
            lists.foldl'
              (
                acc:
                descriptor:
                if acc != null then
                  acc
                else
                  let
                    candidate = getAttrByPath attrPath descriptor.packages;
                  in
                  if candidate == null then
                    null
                  else
                    {
                      inherit candidate descriptor;
                    }
              )
              null
              candidateSets;
        in
        if resolved == null then
          throw "customPackages: package '${attrPathStr}' not found in configured channels (${renderChannelList channelNames})."
        else
          applyOverrides {
            inherit spec attrPathStr;
            pkg = resolved.candidate;
          };

      resolveValue = value:
        if lib.isDerivation value then
          value
        else if builtins.isList value then
          map resolveValue value
        else if builtins.isString value then
          resolveAttrSpec { name = value; }
        else if builtins.isAttrs value then
          if value ? package then
            applyOverrides {
              spec = value;
              attrPathStr = value.name or "<anonymous>";
              pkg = value.package;
            }
          else
            resolveAttrSpec value
        else
          throw "customPackages: unsupported package specification type.";

    in
    {
      inherit channelNames;
      channels = allChannels;
      pkg = name:
        let
          mk = opts:
            let
              extras =
                if opts == null then
                  {}
                else if builtins.isAttrs opts then
                  opts
                else
                  throw "customPackages: pkg options must be an attribute set.";
            in
            resolveAttrSpec (extras // { inherit name; });
          base = mk {};
        in
        base // {
          __functor = _: opts: mk opts;
        };
      byAttrPath = attrPath:
        let
          normalizedPath = ensureAttrPath attrPath;
          mk = opts:
            let
              extras =
                if opts == null then
                  {}
                else if builtins.isAttrs opts then
                  opts
                else
                  throw "customPackages: byAttrPath options must be an attribute set.";
            in
            resolveAttrSpec (extras // { attrPath = normalizedPath; });
          base = mk {};
        in
        base // {
          __functor = _: opts: mk opts;
        };
      resolve = resolveValue;
      resolveList = list: map resolveValue list;
    };
}
