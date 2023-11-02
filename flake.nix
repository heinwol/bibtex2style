rec {
  description = "bibtex2style is a script that takes .bib file as an input and produces an .xlsx file with entries processed by biblatex with an according style (like `gost`). It also respects bold an italics fonts!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let

      system = "x86_64-linux";

      pkgs = nixpkgs.legacyPackages.${system};
      # poetry2nix = inputs.poetry2nix.packages.${system}.default;
      inherit (inputs.poetry2nix.lib.mkPoetry2Nix { inherit pkgs; })
        mkPoetryApplication
        mkPoetryEnv;

      tex-with-pkgs = (pkgs.texlive.combine {
        inherit (pkgs.texlive)
          scheme-basic
          biber
          biblatex
          biblatex-gost
          collection-langcyrillic
          cm-unicode
          latexmk
          luatex
          luatex85
          luatexbase
          polyglossia
          standalone
          varwidth
          ;
      });

      buildInputs = [
        tex-with-pkgs
      ];

      devShells.default = pkgs.mkShell {
        packages = buildInputs ++ [
          pkgs.poetry
          (mkPoetryEnv {
            projectDir = ./.;
            preferWheels = true; # else it fails

            # for development;
            # TODO: remove runtime dependency
            extraPackages = (p: [ p.python-lsp-server ]);
          })
        ];
        shellHook = ''
          echo "entering dev shell..."
          eval fish || true
        '';
      };

      package-env = mkPoetryApplication {
        projectDir = ./.;
        preferWheels = true; # else it fails
      };

      bibtex2style = pkgs.stdenvNoCC.mkDerivation {

        name = "bibtex2style";

        src = ./.;

        buildInputs = buildInputs ++ [
          pkgs.makeWrapper
        ];

        installPhase = ''
          mkdir -p $out/bin
          ln -s "${package-env.dependencyEnv}/bin/bibtex2style" "$out/bin/"
        '';

        postFixup = ''
          wrapProgram $out/bin/bibtex2style \
            --set PATH ${pkgs.lib.makeBinPath buildInputs}
        '';

        meta = {
          inherit description;
        };
      };

      dockerImage = pkgs.dockerTools.buildImage {
        name = "bibtex2style";
        tag = "latest";
        copyToRoot = pkgs.buildEnv {
          name = "image-root";
          paths = [ bibtex2style pkgs.bash ];
          pathsToLink = [ "/bin" ];
        };
        config = {
          WorkingDir = "/temp";
          Cmd = [ "${bibtex2style}/bin/bibtex2style" ];
        };
      };

    in
    {
      devShells.${system} = devShells;
      packages.${system} = {
        inherit bibtex2style dockerImage;
        default = bibtex2style;
        package-env = package-env.dependencyEnv;
      };
    };
}
