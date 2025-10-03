{ lib, ... }:

let
  qbProfileDir = "/mnt/zfs-pool0/kino/qbittorrent";
  qbLogDir = "${qbProfileDir}/logs";
  qbDefaultSavePath = "/mnt/zfs-pool0/kino/data";
  qbTempPath = "${qbDefaultSavePath}/intermediate";
in

{
  config = {
    systemd.tmpfiles.rules = [
      "d ${qbProfileDir} 0770 qbittorrent arr -"
      "d ${qbLogDir} 0770 qbittorrent arr -"
      "d ${qbTempPath} 2770 qbittorrent arr -"
    ];

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

  };
}
