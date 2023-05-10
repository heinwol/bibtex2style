rec {
  description = "bibtex2style is a script that takes .bib file as an input and produces an .xlsx file with entries processed by biblatex with an according style (like `gost`). It also respects bold an italics fonts!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: let

    system = "x86_64-linux";
  
    pkgs = nixpkgs.legacyPackages.${system};

    tex-with-pkgs = (pkgs.texlive.combine {
      inherit (pkgs.texlive)
        scheme-basic
        biber
        biblatex
        biblatex-gost
        collection-langcyrillic
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
        (pkgs.poetry2nix.mkPoetryEnv {
          projectDir = ./.;
          preferWheels = true; # else it fails

          # for development;
          # TODO: remove runtime dependency
          extraPackages = (p: [p.python-lsp-server]);
        })];
      shellHook = ''
        echo "entering dev shell..."
        eval fish || true
      '';
    };

    package-env = pkgs.poetry2nix.mkPoetryApplication {
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
    
  in {
    devShells.${system} = devShells;
    packages.${system} = {
      bibtex2style = bibtex2style;
      default = bibtex2style;
      package-env = package-env.dependencyEnv;
    };
  };
}
