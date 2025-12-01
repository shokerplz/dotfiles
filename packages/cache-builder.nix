{pkgs, ...}:
pkgs.writeShellApplication {
  name = "cache-builder";

  runtimeInputs = with pkgs; [
    nix
    jq
    coreutils
    gnugrep
    gawk
  ];

  text = ''
    set -euo pipefail

    FLAKE_PATH="/home/ikovalev/projects/dotfiles"
    CACHE_DIR="/mnt/zfs-pool0/nix-cache/cache"
    LOG_DIR="/mnt/zfs-pool0/nix-cache/log"
    META_FILE="/mnt/zfs-pool0/nix-cache/metadata.json"

    mkdir -p "$CACHE_DIR" "$LOG_DIR"
    touch "$META_FILE"

    if [[ ! -f "$CACHE_DIR/nix-cache-info" ]]; then
      echo "StoreDir: /nix/store" > "$CACHE_DIR/nix-cache-info"
      echo "WantMassQuery: 1" >> "$CACHE_DIR/nix-cache-info"
      echo "Priority: 40" >> "$CACHE_DIR/nix-cache-info"
    fi

    hosts=$(nix eval --impure --raw --expr "
      let f = builtins.getFlake (toString $FLAKE_PATH);
      in builtins.concatStringsSep \" \" (builtins.attrNames f.nixosConfigurations)
    ")

    ulimit -n 65535

    retry() {
        local retries=15
        local wait=30
        local count=0
        until "$@"; do
            exit_code=$?
            count=$((count + 1))
            if [ $count -lt $retries ]; then
                echo "Command failed with exit code $exit_code. Retrying $count/$retries in ''${wait}s..." >&2
                sleep $wait
            else
                echo "Command failed after $retries attempts." >&2
                return $exit_code
            fi
        done
        return 0
    }

    if [[ -n "''${1:-}" ]]; then
        hosts="$1"
    else
        hosts=$(nix eval --impure --raw --expr "
          let f = builtins.getFlake (toString $FLAKE_PATH);
          in builtins.concatStringsSep \" \" (builtins.attrNames f.nixosConfigurations)
        ")
    fi

    echo "Found hosts: $hosts"

    for host in $hosts; do
        echo "==============================="
        echo "Building $host"
        echo "==============================="
        log_file="$LOG_DIR/$host-$(date +%F_%H-%M-%S.%3N).log"

        {
            echo "[$(date +%F_%H-%M-%S.%3N)] Building NixOS system for $host"
            build_args=()

            arch=$(nix eval --raw "$FLAKE_PATH#nixosConfigurations.$host.config.nixpkgs.system")
            if [[ "$arch" == "aarch64-linux" ]]; then
                build_args+=(--cores 1)
            fi

            result_path=$(retry nix build "''${build_args[@]}" \
                "$FLAKE_PATH#nixosConfigurations.$host.config.system.build.toplevel" \
                --print-out-paths)

            echo "[$(date +%F_%H-%M-%S.%3N)] Built system: $result_path"

            echo "[$(date +%F_%H-%M-%S.%3N)] Copying closure to cache..."
            retry nix copy --to "file://$CACHE_DIR" "$result_path"

            drv_path=$(nix eval --raw "$FLAKE_PATH#nixosConfigurations.$host.config.system.build.toplevel.drvPath")

            echo "[$(date +%F_%H-%M-%S.%3N)] calculating full closure..."
            requisites=$(nix-store --query --requisites --include-outputs "$drv_path")

            for path in $requisites; do
                input_hash=$(basename "$path" | cut -c1-32)

                if [[ ! -f "$CACHE_DIR/$input_hash.narinfo" ]]; then
                    echo "[$(date +%F_%H-%M-%S.%3N)] Caching input (drv/source): $path"
                    retry nix copy --to "file://$CACHE_DIR" "$path"
                fi

                if [[ "$path" == *.drv ]]; then
                    outputs=$(nix derivation show "$path" | jq -r '.[].outputs[].path')

                    for out in $outputs; do
                        out_hash=$(basename "$out" | cut -c1-32)

                        if [[ -f "$CACHE_DIR/$out_hash.narinfo" ]]; then
                             url=$(grep '^URL:' "$CACHE_DIR/$out_hash.narinfo" | awk '{print $2}')
                             if [[ -f "$CACHE_DIR/$url" ]]; then
                                 continue
                             fi
                        fi

                        echo "[$(date +%F_%H-%M-%S.%3N)] Caching output for $path -> $out"
                        retry nix-store --realise "$path" >/dev/null
                        retry nix copy --to "file://$CACHE_DIR" "$out"
                    done
                fi
            done

            store_path=$(readlink -f "$result_path")

            echo "[$(date +%F_%H-%M-%S.%3N)] Finished $host"

            jq -n \
                --arg host "$host" \
                --arg ts "$(date +%F_%H-%M-%S.%3N)" \
                --arg path "$store_path" \
                '{
                    host: $host,
                    timestamp: $ts,
                    storePath: $path
                }' >> "$META_FILE"

            echo >> "$META_FILE"

        } &> "$log_file"

        echo "Log saved: $log_file"
    done

    nix-collect-garbage -d

    echo "All builds complete."
  '';
}

