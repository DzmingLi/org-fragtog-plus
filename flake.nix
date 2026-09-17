{
  description = "Automatic Org formula preview toggling with pluggable backends";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      packages = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.runCommand "org-fragtog-plus-archive" {
            nativeBuildInputs = [ pkgs.gnutar ];
          } ''
            name=org-fragtog-plus
            version=$(sed -n 's/^;; Version: //p' ${./org-fragtog-plus.el})
            dependencies=$(sed -n 's/^;; Package-Requires: //p' ${./org-fragtog-plus.el})
            directory="$name-$version"
            mkdir -p "$out" "$directory"
            cp ${./org-fragtog-plus.el} "$directory/$name.el"
            cat > "$directory/$name-pkg.el" <<EOF
            ;;; -*- no-byte-compile: t; lexical-binding: t; -*-
            (define-package "$name" "$version" "Automatic Org formula previews" '$dependencies)
            EOF
            tar --sort=name --mtime=@1 --owner=0 --group=0 --numeric-owner \
              -cf "$out/$directory.tar" "$directory"
          '';
        });
      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in { default = pkgs.mkShell { packages = [ pkgs.emacs pkgs.git ]; }; });
    };
}
