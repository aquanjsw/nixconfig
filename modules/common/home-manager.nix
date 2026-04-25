{ inputs, ... }: {
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.rag = { pkgs, lib, ... }: {
    home.activation = {
      initDotfiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
        DIR="$HOME/.dotfiles"
        TMP_SCRIPT="/tmp/dotfiles"

        if [ ! -d "$DIR" ]; then
          ${pkgs.git}/bin/git clone --bare https://github.com/aquanjsw/dotfiles "$DIR"

          dotfiles() {
            ${pkgs.git}/bin/git --git-dir="$DIR" --work-tree="$HOME" "$@"
          }

          if ! ${pkgs.git}/bin/git --git-dir="$DIR" --work-tree="$HOME" checkout; then
            echo "dotfiles checkout failed, please resolve by yourself"

            cat << 'EOF' > "$TMP_SCRIPT"
#!/usr/bin/env bash
git --git-dir="$DIR" --work-tree="$HOME" "$@"
EOF

            chmod +x "$TMP_SCRIPT"
          fi
        fi
      '';
    };
    home.stateVersion = "25.11";
  };
}