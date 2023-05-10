rec {
  description = "bibtex2style is a script that takes .bib file as an input and produces an .xlsx file with entries processed by biblatex with an according style (like `gost`). It also respects bold an italics fonts!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: let

    system = "x86_64-linux";
  
    pkgs = nixpkgs.legacyPackages.${system};

    python-with-pkgs = (pkgs.poetry2nix.mkPoetryEnv {
      # python = pkgs.python310;
      projectDir = ./.;
      preferWheels = true; # else it fails

      # for development;
      # TODO: remove runtime dependency
      extraPackages = (p: [p.python-lsp-server]);
    });

    tex-with-pkgs = (pkgs.texlive.combine {
      inherit (pkgs.texlive)
        scheme-basic
        luatex
        polyglossia
        biblatex
        showkeys
        collection-langcyrillic
        biblatex-gost
        ;
    });

    buildInputs = [
      tex-with-pkgs
    ];

    devShells.default = pkgs.mkShell {
      packages = buildInputs ++ [python-with-pkgs pkgs.poetry];
      shellHook = ''
        echo "entering dev shell..."
        eval fish || true
      '';
    };

    bibtex2style = pkgs.poetry2nix.mkPoetryApplication {
      projectDir = ./.;
      preferWheels = true; # else it fails
      inherit buildInputs;
      meta = {
        inherit description;
      };
    };
    
  in {
    devShells.${system} = devShells;
    packages.${system}.bibtex2style = bibtex2style;
    packages.${system}.default = self.packages.x86_64-linux.bibtex2style;
  };
}
