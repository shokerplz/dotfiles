{...}: {
  sops.secrets.grafana_secret_key = {
    sopsFile = ./grafana.yaml;
    key = "secret_key";
    owner = "grafana";
    group = "grafana";
    mode = "0400";
    restartUnits = ["grafana.service"];
  };
}
