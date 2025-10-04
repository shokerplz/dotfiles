{ lib, ... }:

let
  nzbBaseDir = "/mnt/ssd/kino/nzbget";
in

{
  config = {
    services.nzbget = {
      enable = true;
      user = lib.mkDefault "nzbget";
      group = lib.mkDefault "arr";
      settings = lib.mkDefault {
        MainDir = nzbBaseDir;
        DestDir = "${nzbBaseDir}/completed";
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
        UMask = 1000;
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
        Category1.DestDir = "${nzbBaseDir}/completed/movies";
        Category1.Unpack = "yes";
        Category1.Extensions = "";
        Category1.Aliases = "";
        Category2.Name = "Series";
        Category2.DestDir = "${nzbBaseDir}/completed/shows";
        Category2.Unpack = "yes";
        Category2.Extensions = "";
        Category2.Aliases = "";
        Category3.Name = "Readarr";
        Category3.DestDir = "${nzbBaseDir}/completed/books";
        Category3.Unpack = "yes";
        Category3.Extensions = "";
        Category3.Aliases = "";
      };
    };

    systemd.tmpfiles.rules = [
      "d ${nzbBaseDir} 0770 nzbget arr -"
      "d ${nzbBaseDir}/completed 2770 nzbget arr -"
      "d ${nzbBaseDir}/queue 2770 nzbget arr -"
      "d ${nzbBaseDir}/nzb 0770 nzbget arr -"
      "d ${nzbBaseDir}/tmp 2770 nzbget arr -"
      "d ${nzbBaseDir}/scripts 2770 nzbget arr -"
      "d ${nzbBaseDir}/intermediate 2770 nzbget arr -"
    ];
  };
}
