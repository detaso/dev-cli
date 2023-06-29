{
  description = "dev cli for devenv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = inputs@{ flake-parts, flake-compat, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # debug = true;
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages = rec {
          dev =
            let
              getoptions = pkgs.getoptions.overrideAttrs (oldAttrs: {
                doCheck = false;
              });

              my-name = "dev";
              my-buildInputs = [ getoptions ];
              my-script = (pkgs.writeScriptBin my-name (builtins.readFile ./dev)).overrideAttrs(old: {
                buildCommand = "${old.buildCommand}\n patchShebangs $out";
              });
            in pkgs.symlinkJoin {
              name = my-name;
              paths = [ my-script ] ++ my-buildInputs;
              buildInputs = [ pkgs.makeWrapper ];
              postBuild = "wrapProgram $out/bin/${my-name} --prefix PATH : $out/bin";
            };

          default = dev;
        };
      };
    };
}
