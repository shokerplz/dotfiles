{config, pkgs, ... }:

{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;     # if you still need Pulse clients
    # wireplumber is pulled in automatically
  };

  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/main.lua.d/51-hdmi-buffer-rate.lua" ''
      --  ░██  HDMI/DP: bigger ALSA buffer + fixed 48 kHz
      --  tweak #2 → api.alsa.period-size/headroom
      --  tweak #3 → audio.rate + (optional) resample.disable
      --
      --  Adjust the node.pattern until the output of
      --     pw-dump | grep -F node.name | grep -i hdmi
      --  matches at least one sink on your box.
      --
      local rule = {
        matches = {
          { { "node.name", "matches", "alsa_output.pci-.*hdmi.*" } },
        },
        apply_properties = {
          ["api.alsa.period-size"] = 128,   -- ~2.7 ms @ 48 kHz
          ["api.alsa.headroom"]    = 1024,  -- safety buffer :contentReference[oaicite:1]{index=1}
          ["audio.rate"]           = 48000,
          ["resample.disable"]     = true,  -- keep it locked
        },
      }

      table.insert (alsa_monitor.rules, rule)
    '')
  ];
}
