{config, ...}: let
  xraySecretFile = ./xray-role-exit.yaml;
in {
  sops.secrets.xray_relay_uuid.sopsFile = xraySecretFile;
  sops.secrets.xray_exit_reality_short_id.sopsFile = xraySecretFile;
  sops.secrets.xray_exit_reality_private_key.sopsFile = xraySecretFile;

  sops.templates.xray-role-exit-config = {
    restartUnits = ["xray.service"];
    content = ''
      {
        "log": {
          "loglevel": "warning"
        },
        "dns": {
          "hosts": {
            "ok.ru": "217.20.147.94"
          },
          "servers": [
            {
              "address": "https://8.8.8.8/dns-query",
              "skipFallback": true,
              "queryStrategy": "UseIPv4"
            }
          ],
          "queryStrategy": "UseIP",
          "tag": "dns-in"
        },
        "inbounds": [
          {
            "tag": "vless_tls",
            "listen": "127.0.0.1",
            "port": 7443,
            "protocol": "vless",
            "settings": {
              "clients": [
                {
                  "id": "${config.sops.placeholder.xray_relay_uuid}",
                  "email": "edge-relay",
                  "flow": "xtls-rprx-vision"
                }
              ],
              "decryption": "none"
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
                "privateKey": "${config.sops.placeholder.xray_exit_reality_private_key}",
                "shortIds": [
                  "${config.sops.placeholder.xray_exit_reality_short_id}"
                ]
              },
              "sockopt": {
                "acceptProxyProtocol": true
              }
            },
            "sniffing": {
              "enabled": true,
              "destOverride": [
                "http",
                "tls",
                "quic"
              ]
            }
          }
        ],
        "outbounds": [
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
          "domainStrategy": "AsIs",
          "rules": [
            {
              "type": "field",
              "inboundTag": [
                "dns-in"
              ],
              "outboundTag": "direct"
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
