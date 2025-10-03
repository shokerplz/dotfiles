{ lib, ... }:

let
  qbProfileDir = "/mnt/zfs-pool0/kino/qbittorrent";
  qbDefaultSavePath = "/mnt/zfs-pool0/kino/data";
  qbTempPath = "${qbDefaultSavePath}/intermediate";
in

{
  config = {
    services.qbittorrent = {
      enable = true;
      user = lib.mkDefault "qbittorrent";
      group = lib.mkDefault "arr";
      profileDir = lib.mkDefault qbProfileDir;
      webuiPort = lib.mkDefault 5080;
      serverConfig = lib.mkDefault {
        Application = {
          "FileLogger\\Age" = 1;
          "FileLogger\\AgeType" = 1;
          "FileLogger\\Backup" = true;
          "FileLogger\\DeleteOld" = true;
          "FileLogger\\Enabled" = false;
          "FileLogger\\MaxSizeBytes" = 66560;
          "FileLogger\\Path" = "/config/qBittorrent/logs";
        };
        AutoRun = {
          enabled = false;
          program = "";
        };
        BitTorrent = {
          "Session\\AddTorrentStopped" = false;
          "Session\\DefaultSavePath" = qbDefaultSavePath;
          "Session\\ExcludedFileNames" = "";
          "Session\\GlobalMaxRatio" = 0;
          "Session\\MaxActiveDownloads" = 6;
          "Session\\MaxActiveTorrents" = 15;
          "Session\\MaxActiveUploads" = 0;
          "Session\\MaxConnections" = -1;
          "Session\\MaxConnectionsPerTorrent" = -1;
          "Session\\MaxUploads" = -1;
          "Session\\MaxUploadsPerTorrent" = -1;
          "Session\\Port" = 6881;
          "Session\\QueueingSystemEnabled" = true;
          "Session\\SSL\\Port" = 29435;
          "Session\\ShareLimitAction" = "Stop";
          "Session\\TempPath" = qbTempPath;
          "Session\\TempPathEnabled" = true;
        };
        Core = {
          AutoDeleteAddedTorrentFile = "Never";
        };
        LegalNotice = {
          Accepted = true;
        };
        Meta = {
          MigrationVersion = 8;
        };
        Network = {
          PortForwardingEnabled = false;
          "Proxy\\HostnameLookupEnabled" = false;
          "Proxy\\Profiles\\BitTorrent" = true;
          "Proxy\\Profiles\\Misc" = true;
          "Proxy\\Profiles\\RSS" = true;
        };
        Preferences = {
          "Connection\\PortRangeMin" = 6881;
          "Connection\\UPnP" = false;
          "Downloads\\SavePath" = "/downloads/";
          "Downloads\\TempPath" = "/downloads/incomplete/";
          "Downloads\\TempPathEnabled" = true;
          "General\\Locale" = "en";
          "MailNotification\\req_auth" = true;
          "WebUI\\Address" = "*";
          "WebUI\\AuthSubnetWhitelist" = "@Invalid()";
          "WebUI\\LocalHostAuth" = false;
          "WebUI\\Port" = 5080;
          "WebUI\\ServerDomains" = "*";
        };
        RSS = {
          "AutoDownloader\\DownloadRepacks" = true;
          "AutoDownloader\\SmartEpisodeFilter" = ''s(\d+)e(\d+), (\d+)x(\d+), "(\d{4}[.\-]\d{1,2}[.\-]\d{1,2})", "(\d{1,2}[.\-]\d{1,2}[.\-]\d{4})"'';
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d ${qbProfileDir} 0770 qbittorrent arr -"
      "d ${qbTempPath} 2770 qbittorrent arr -"
    ];
  };
}
