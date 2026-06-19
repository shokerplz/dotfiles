{...}: {
  flake.nixosModules.serviceArr = {
    config,
    lib,
    pkgs,
    ...
  }: let
    arrBaseDir = "/mnt/zfs-pool0/kino";
    arrServices = [
      "bazarr"
      "prowlarr"
      "sonarr"
      "radarr"
    ];
    sonarrSearchScript = pkgs.writeShellScriptBin "sonarr-missing-search" ''
      set -euo pipefail
      export PATH="${pkgs.curl}/bin:${pkgs.jq}/bin:${pkgs.coreutils}/bin:$PATH"

      API_KEY=$(cat ${config.sops.secrets.sonarrApiKey.path})
      BASE_URL="http://127.0.0.1:8989/sonarr/api/v3"

      CUTOFF_DATE=$(date -d "7 days ago" -u +"%Y-%m-%dT%H:%M:%SZ")

      QUEUE_RESPONSE=$(curl -s -H "X-Api-Key: $API_KEY" "$BASE_URL/queue")
      QUEUED_IDS=$(echo "$QUEUE_RESPONSE" | jq -c '[.records[].episodeId] | unique')

      RESPONSE=$(curl -s -H "X-Api-Key: $API_KEY" "$BASE_URL/wanted/missing?pageSize=100&sortKey=airDateUtc&sortDirection=descending")

      EPISODE_IDS=$(echo "$RESPONSE" | jq -c --arg cutoff "$CUTOFF_DATE" --argjson queued "$QUEUED_IDS" '[.records[] | select(.airDateUtc >= $cutoff) | select(.id as $id | $queued | index($id) | not) | .id]')

      if [ "$EPISODE_IDS" != "[]" ]; then
         echo "Triggering search for recent missing episodes..."
         curl -s -X POST \
           -H "X-Api-Key: $API_KEY" \
           -H "Content-Type: application/json" \
           -d "{\"name\": \"EpisodeSearch\", \"episodeIds\": $EPISODE_IDS}" \
           "$BASE_URL/command" > /dev/null
      fi
    '';
    qbProfileDir = "/mnt/zfs-pool0/kino/qbittorrent";
    qbLogDir = "${qbProfileDir}/logs";
    qbDefaultSavePath = "/mnt/zfs-pool0/kino/data";
    qbTempPath = "${qbDefaultSavePath}/intermediate";
    nzbBaseDir = "/mnt/ssd/kino/nzbget";
    nzbCompletedDir = "${nzbBaseDir}/completed";
    nzbMoviesDir = "${nzbCompletedDir}/movies";
    nzbShowsDir = "${nzbCompletedDir}/shows";
    nzbBooksDir = "${nzbCompletedDir}/books";
    nzbManagedDirs = [
      nzbBaseDir
      nzbCompletedDir
      nzbMoviesDir
      nzbShowsDir
      nzbBooksDir
      "${nzbBaseDir}/queue"
      "${nzbBaseDir}/nzb"
      "${nzbBaseDir}/tmp"
      "${nzbBaseDir}/scripts"
      "${nzbBaseDir}/intermediate"
    ];
  in {
    imports = [
      ../../secrets/arr.nix
    ];

    system.activationScripts.createArrDirs = ''
      mkdir -p /mnt/zfs-pool0/kino/{${builtins.concatStringsSep "," arrServices}}/config
      chgrp -R arr /mnt/zfs-pool0/kino/{${builtins.concatStringsSep "," arrServices}}/config
      chgrp -R arr /mnt/zfs-pool0/kino/data
      find /mnt/zfs-pool0/kino/data -type d -exec chmod g+wx {} +
      chown sonarr /mnt/zfs-pool0/kino/sonarr/config
      chown radarr /mnt/zfs-pool0/kino/radarr/config
    '';

    users.groups.arr = {};

    services.radarr = {
      enable = true;
      group = "arr";
      dataDir = "${arrBaseDir}/radarr/config";
      environmentFiles = [
        config.sops.templates.radarr_env.path
      ];
    };

    services.sonarr = {
      enable = true;
      group = "arr";
      dataDir = "${arrBaseDir}/sonarr/config";
      environmentFiles = [
        config.sops.templates.sonarr_env.path
      ];
    };

    services.prowlarr.enable = true;

    services.bazarr = {
      enable = true;
      group = "arr";
    };

    services.seerr.enable = true;

    services.qbittorrent = {
      enable = true;
      user = lib.mkDefault "qbittorrent";
      group = lib.mkDefault "arr";
      profileDir = lib.mkDefault qbProfileDir;
      webuiPort = lib.mkDefault 5080;
      serverConfig = lib.mkDefault {
        Application.FileLogger = {
          Age = 1;
          AgeType = 1;
          Backup = true;
          DeleteOld = true;
          Enabled = false;
          MaxSizeBytes = 66560;
          Path = qbLogDir;
        };
        AutoRun = {
          enabled = false;
          program = "";
        };
        BitTorrent.Session = {
          AddTorrentStopped = false;
          DefaultSavePath = qbDefaultSavePath;
          ExcludedFileNames = "";
          GlobalMaxRatio = 0;
          MaxActiveDownloads = 6;
          MaxActiveTorrents = 15;
          MaxActiveUploads = 0;
          MaxConnections = -1;
          MaxConnectionsPerTorrent = -1;
          MaxUploads = -1;
          MaxUploadsPerTorrent = -1;
          Port = 6881;
          QueueingSystemEnabled = true;
          ShareLimitAction = "Stop";
          TempPath = qbTempPath;
          TempPathEnabled = true;
          SSL.Port = 29435;
        };
        Core.AutoDeleteAddedTorrentFile = "Never";
        LegalNotice.Accepted = true;
        Meta.MigrationVersion = 8;
        Network = {
          PortForwardingEnabled = false;
          Proxy = {
            HostnameLookupEnabled = false;
            Profiles = {
              BitTorrent = true;
              Misc = true;
              RSS = true;
            };
          };
        };
        Preferences = {
          Connection = {
            PortRangeMin = 6881;
            UPnP = false;
          };
          Downloads = {
            SavePath = qbDefaultSavePath;
            TempPath = qbTempPath;
            TempPathEnabled = true;
          };
          General.Locale = "en";
          MailNotification.req_auth = true;
          WebUI = {
            Address = "*";
            AuthSubnetWhitelist = "@Invalid()";
            LocalHostAuth = false;
            Port = 5080;
            ServerDomains = "*";
          };
        };
        RSS.AutoDownloader = {
          DownloadRepacks = true;
          SmartEpisodeFilter = ''s(\d+)e(\d+), (\d+)x(\d+), "(\d{4}[.\-]\d{1,2}[.\-]\d{1,2})", "(\d{1,2}[.\-]\d{1,2}[.\-]\d{4})"'';
        };
      };
    };

    services.nzbget = {
      enable = true;
      user = lib.mkDefault "nzbget";
      group = lib.mkDefault "arr";
      settings = lib.mkDefault {
        MainDir = nzbBaseDir;
        DestDir = nzbCompletedDir;
        QueueDir = "${nzbBaseDir}/queue";
        NzbDir = "${nzbBaseDir}/nzb";
        TempDir = "${nzbBaseDir}/tmp";
        ScriptDir = "${nzbBaseDir}/scripts";
        InterDir = "${nzbBaseDir}/intermediate";
        ControlIP = "0.0.0.0";
        ControlPort = 6789;
        WebDir = "\${AppDir}/webui";
        LockFile = "${nzbBaseDir}/nzbget.lock";
        LogFile = "${nzbBaseDir}/nzbget.log";
        CertStore = "/etc/ssl/certs/ca-bundle.crt";
        ConfigTemplate = "\${AppDir}/webui/nzbget.conf.template";
        RequiredDir = "";
        Server1.Active = "yes";
        Server1.Name = "Eweka";
        Server1.Level = 0;
        Server1.Optional = "no";
        Server1.Group = 0;
        Server1.Host = "news.eweka.nl";
        Server1.Encryption = "yes";
        Server1.Port = 563;
        Server1.Username = "";
        Server1.Password = "";
        Server1.JoinGroup = "no";
        Server1.Cipher = "MD5";
        Server1.Connections = 50;
        Server1.Retention = 0;
        Server1.CertVerification = "Strict";
        Server1.IpVersion = "auto";
        Server1.Notes = "";
        ControlUsername = "admin";
        ControlPassword = "";
        RestrictedUsername = "";
        RestrictedPassword = "";
        AddUsername = "admin";
        AddPassword = "";
        FormAuth = "yes";
        SecureControl = "no";
        SecurePort = 6791;
        SecureCert = "";
        SecureKey = "";
        AuthorizedIP = "";
        CertCheck = "yes";
        UpdateCheck = "stable";
        DaemonUsername = "root";
        UMask = "0002";
        AppendCategoryDir = "yes";
        NzbDirInterval = 5;
        NzbDirFileAge = 60;
        DupeCheck = "yes";
        FlushQueue = "no";
        ContinuePartial = "no";
        PropagationDelay = 0;
        ArticleCache = 350;
        DirectWrite = "yes";
        WriteBuffer = 1024;
        FileNaming = "auto";
        ReorderFiles = "yes";
        PostStrategy = "balanced";
        DiskSpace = 250;
        NzbCleanupDisk = "yes";
        KeepHistory = 30;
        FeedHistory = 7;
        SkipWrite = "no";
        RawArticle = "no";
        ArticleRetries = 3;
        ArticleInterval = 10;
        ArticleTimeout = 60;
        ArticleReadChunkSize = 4;
        UrlRetries = 3;
        UrlInterval = 10;
        UrlTimeout = 60;
        RemoteTimeout = 90;
        DownloadRate = 0;
        UrlConnections = 4;
        UrlForce = "yes";
        MonthlyQuota = 0;
        QuotaStartDay = 1;
        DailyQuota = 0;
        WriteLog = "append";
        RotateLog = 3;
        ErrorTarget = "both";
        WarningTarget = "both";
        InfoTarget = "both";
        DetailTarget = "log";
        DebugTarget = "log";
        LogBuffer = 1000;
        NzbLog = "yes";
        CrashTrace = "yes";
        CrashDump = "no";
        TimeCorrection = 0;
        OutputMode = "curses";
        CursesNzbName = "yes";
        CursesGroup = "no";
        CursesTime = "no";
        UpdateInterval = 200;
        CrcCheck = "yes";
        ParCheck = "auto";
        ParRepair = "yes";
        ParScan = "extended";
        ParQuick = "yes";
        ParBuffer = 16;
        ParThreads = 0;
        ParIgnoreExt = ".sfv, .nzb, .nfo";
        ParRename = "yes";
        RarRename = "yes";
        DirectRename = "yes";
        HealthCheck = "park";
        ParTimeLimit = 0;
        ParPauseQueue = "no";
        Unpack = "yes";
        DirectUnpack = "yes";
        UnpackPauseQueue = "no";
        UnpackCleanupDisk = "yes";
        UnrarCmd = "unrar";
        SevenZipCmd = "7z";
        ExtCleanupDisk = ".par2, .sfv";
        UnpackIgnoreExt = ".cbr";
        UnpackPassFile = "";
        Extensions = "FakeDetector, NotifyEmbyJellyfin";
        ScriptOrder = "";
        ScriptPauseQueue = "no";
        ShellOverride = "";
        EventInterval = 0;
        RenameAfterUnpack = "yes";
        RenameIgnoreExt = ".zip, .7z, .rar, .par2";
        Category1.Name = "Movies";
        Category1.DestDir = nzbMoviesDir;
        Category1.Unpack = "yes";
        Category1.Extensions = "";
        Category1.Aliases = "";
        Category2.Name = "Series";
        Category2.DestDir = nzbShowsDir;
        Category2.Unpack = "yes";
        Category2.Extensions = "";
        Category2.Aliases = "";
        Category3.Name = "Readarr";
        Category3.DestDir = nzbBooksDir;
        Category3.Unpack = "yes";
        Category3.Extensions = "";
        Category3.Aliases = "";
      };
    };

    system.activationScripts.fixNzbgetPermissions = ''
      mkdir -p ${lib.concatStringsSep " " nzbManagedDirs}
      chown nzbget:arr ${lib.concatStringsSep " " nzbManagedDirs}
      chmod 0770 ${nzbBaseDir} ${nzbBaseDir}/nzb
      chmod 2770 ${nzbBaseDir}/queue ${nzbBaseDir}/tmp ${nzbBaseDir}/scripts ${nzbBaseDir}/intermediate
      chmod 2775 ${nzbCompletedDir} ${nzbMoviesDir} ${nzbShowsDir} ${nzbBooksDir}
    '';

    systemd.tmpfiles.rules = [
      "d ${qbProfileDir} 0770 qbittorrent arr -"
      "d ${qbLogDir} 0770 qbittorrent arr -"
      "d ${qbTempPath} 2770 qbittorrent arr -"
      "d ${nzbBaseDir} 0770 nzbget arr -"
      "d ${nzbCompletedDir} 2775 nzbget arr -"
      "d ${nzbMoviesDir} 2775 nzbget arr -"
      "d ${nzbShowsDir} 2775 nzbget arr -"
      "d ${nzbBooksDir} 2775 nzbget arr -"
      "d ${nzbBaseDir}/queue 2770 nzbget arr -"
      "d ${nzbBaseDir}/nzb 0770 nzbget arr -"
      "d ${nzbBaseDir}/tmp 2770 nzbget arr -"
      "d ${nzbBaseDir}/scripts 2770 nzbget arr -"
      "d ${nzbBaseDir}/intermediate 2770 nzbget arr -"
      "z ${nzbBaseDir} 0770 nzbget arr -"
      "z ${nzbCompletedDir} 2775 nzbget arr -"
      "z ${nzbMoviesDir} 2775 nzbget arr -"
      "z ${nzbShowsDir} 2775 nzbget arr -"
      "z ${nzbBooksDir} 2775 nzbget arr -"
      "z ${nzbBaseDir}/queue 2770 nzbget arr -"
      "z ${nzbBaseDir}/nzb 0770 nzbget arr -"
      "z ${nzbBaseDir}/tmp 2770 nzbget arr -"
      "z ${nzbBaseDir}/scripts 2770 nzbget arr -"
      "z ${nzbBaseDir}/intermediate 2770 nzbget arr -"
    ];

    systemd.services.sonarr-missing-search = {
      description = "Trigger Sonarr Missing Episode Search";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${sonarrSearchScript}/bin/sonarr-missing-search";
      };
      wants = ["network-online.target"];
      after = ["network-online.target"];
    };

    systemd.timers.sonarr-missing-search = {
      description = "Run Sonarr Missing Episode Search every 30 minutes";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "30m";
      };
    };

    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 7878 -s 10.0.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 8989 -s 10.0.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 9696 -s 10.0.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 6767 -s 10.0.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 5080 -s 10.0.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 6789 -s 10.0.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 5055 -s 10.0.0.0/16 -j nixos-fw-accept
    '';

    networking.firewall.extraStopCommands = ''
      iptables -D nixos-fw -p tcp --dport 7878 -s 10.0.0.0/16 -j nixos-fw-accept || true
      iptables -D nixos-fw -p tcp --dport 8989 -s 10.0.0.0/16 -j nixos-fw-accept || true
      iptables -D nixos-fw -p tcp --dport 9696 -s 10.0.0.0/16 -j nixos-fw-accept || true
      iptables -D nixos-fw -p tcp --dport 6767 -s 10.0.0.0/16 -j nixos-fw-accept || true
      iptables -D nixos-fw -p tcp --dport 5080 -s 10.0.0.0/16 -j nixos-fw-accept || true
      iptables -D nixos-fw -p tcp --dport 6789 -s 10.0.0.0/16 -j nixos-fw-accept || true
      iptables -D nixos-fw -p tcp --dport 5055 -s 10.0.0.0/16 -j nixos-fw-accept || true
    '';
  };
}
