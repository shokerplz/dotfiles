{config, ...}: let
  xraySecretFile = ./xray-role-entry.yaml;
in {
  sops.secrets.xray_entry_clients_json.sopsFile = xraySecretFile;
  sops.secrets.xray_entry_inbound_decryption.sopsFile = xraySecretFile;
  sops.secrets.xray_entry_reality_private_key.sopsFile = xraySecretFile;
  sops.secrets.xray_entry_reality_short_ids_json.sopsFile = xraySecretFile;
  sops.secrets.xray_relay_uuid.sopsFile = xraySecretFile;
  sops.secrets.xray_exit_reality_public_key.sopsFile = xraySecretFile;
  sops.secrets.xray_exit_reality_short_id.sopsFile = xraySecretFile;

  sops.templates.xray-role-entry-config = {
    restartUnits = ["xray.service"];
    content = ''
      {
        "log": {
          "loglevel": "warning"
        },
        "dns": {
          "servers": [
            "1.1.1.1",
            "8.8.8.8",
            "localhost"
          ],
          "queryStrategy": "UseIP",
          "tag": "dns-in"
        },
        "inbounds": [
          {
            "listen": "127.0.0.1",
            "port": 7443,
            "protocol": "vless",
            "settings": {
              "clients": ${config.sops.placeholder.xray_entry_clients_json},
              "decryption": "${config.sops.placeholder.xray_entry_inbound_decryption}"
            },
            "streamSettings": {
              "network": "tcp",
              "security": "reality",
              "realitySettings": {
                "show": false,
                "target": "ok.ru:443",
                "xver": 0,
                "serverNames": [
                  "ok.ru"
                ],
                "privateKey": "${config.sops.placeholder.xray_entry_reality_private_key}",
                "shortIds": ${config.sops.placeholder.xray_entry_reality_short_ids_json}
              },
              "sockopt": {
                "acceptProxyProtocol": true
              }
            },
            "tag": "vless_tls"
          }
        ],
        "outbounds": [
          {
            "tag": "relay-exit",
            "protocol": "vless",
            "settings": {
              "vnext": [
                {
                  "address": "vm-de-0",
                  "port": 443,
                  "users": [
                    {
                      "id": "${config.sops.placeholder.xray_relay_uuid}",
                      "encryption": "none",
                      "flow": "xtls-rprx-vision"
                    }
                  ]
                }
              ]
            },
            "streamSettings": {
              "network": "tcp",
              "security": "reality",
              "realitySettings": {
                "fingerprint": "chrome",
                "serverName": "ok.ru",
                "publicKey": "${config.sops.placeholder.xray_exit_reality_public_key}",
                "shortId": "${config.sops.placeholder.xray_exit_reality_short_id}",
                "spiderX": "/"
              }
            }
          },
          {
            "tag": "direct",
            "protocol": "freedom"
          },
          {
            "tag": "block",
            "protocol": "blackhole"
          }
        ],
        "routing": {
          "domainStrategy": "IPIfNonMatch",
          "rules": [
            {
              "type": "field",
              "ip": [
                "geoip:private"
              ],
              "outboundTag": "block"
            },
            {
              "type": "field",
              "inboundTag": [
                "dns-in"
              ],
              "outboundTag": "direct"
            },
            {
              "type": "field",
              "inboundTag": [
                "vless_tls"
              ],
              "ip": [
                "geoip:ru"
              ],
              "outboundTag": "direct"
            },
            {
              "type": "field",
              "inboundTag": [
                "vless_tls"
              ],
              "outboundTag": "relay-exit"
            },
            {
              "type": "field",
              "ip": [
                "10.0.0.0/8",
                "192.168.0.0/16"
              ],
              "outboundTag": "block"
            }
          ]
        }
      }
    '';
  };
}
