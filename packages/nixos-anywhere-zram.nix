{
  runCommand,
  gnused,
  gawk,
  upstream,
}:
runCommand "nixos-anywhere-zram" {} ''
      mkdir -p "$out/bin" "$out/libexec"

      cp ${upstream}/bin/nixos-anywhere "$out/bin/nixos-anywhere-zram"
      cp -r ${upstream}/libexec/nixos-anywhere "$out/libexec/nixos-anywhere"
      chmod -R u+w "$out/libexec/nixos-anywhere"
      chmod u+w "$out/bin/nixos-anywhere-zram"

      cat > extra-fns <<'EOF'
  setupZram() {
    step "Setting up zram swap for low-memory VPS"
    runSsh bash <<'ZRAM'
      modprobe zram num_devices=1 2>/dev/null || true
      if [ -b /dev/zram0 ]; then
        echo 1 > /sys/block/zram0/reset 2>/dev/null || true
        mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
        zram_size=$((mem_total * 1024))
        echo zstd > /sys/block/zram0/comp_algorithm 2>/dev/null || true
        echo "$zram_size" > /sys/block/zram0/disksize
        mkswap -f /dev/zram0
        swapon -p 150 /dev/zram0
        echo "zram swap enabled:"
        grep zram /proc/swaps || true
      else
        echo "zram module not available, skipping"
      fi
  ZRAM
  }
  EOF

      ${gawk}/bin/awk '
        /runDisko\(\) {/ && !insertedFns {
          while ((getline line < "extra-fns") > 0) print line;
          close("extra-fns");
          insertedFns = 1;
        }
        /^    runKexec$/ && !patchedRunKexec {
          print;
          print "    setupZram";
          patchedRunKexec = 1;
          next;
        }
        { print }
      ' "$out/libexec/nixos-anywhere/nixos-anywhere.sh" > "$out/libexec/nixos-anywhere/nixos-anywhere.sh.tmp"
      mv "$out/libexec/nixos-anywhere/nixos-anywhere.sh.tmp" "$out/libexec/nixos-anywhere/nixos-anywhere.sh"

      ${gnused}/bin/sed -i 's|exec ".*libexec/nixos-anywhere/nixos-anywhere.sh"|exec "'$out'/libexec/nixos-anywhere/nixos-anywhere.sh"|' "$out/bin/nixos-anywhere-zram"
      chmod +x "$out/bin/nixos-anywhere-zram" "$out/libexec/nixos-anywhere/nixos-anywhere.sh"
''
