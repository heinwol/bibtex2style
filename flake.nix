{
  description = "bibtex2style is a script that takes .bib file as an input and produces an .xlsx file with entries processed by biblatex with an according style (like `gost`). It also respects bold an italics fonts!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, mach-nix }: let

    system = "x86_64-linux";
  
    pkgs = nixpkgs.legacyPackages.${system};

    python-with-pkgs = (pkgs.poetry2nix.mkPoetryEnv {
      # python = pkgs.python310;
      projectDir = ./.;
      preferWheels = true; # else it fails
    });

    buildInputs = with pkgs; [
      python-with-pkgs
      poetry
    ];

    devShells.default = pkgs.mkShell {
      # nativeBuildInputs = buildInputs;
      packages = buildInputs;
      shellHook = ''
        # echo "lalala"
        # echo "${python-with-pkgs}"
        eval fish || true
      '';
    };
    
  in {
    devShells.${system} = devShells;
    # packages.x86_64-linux.bibtex2style = 1;
    # packages.x86_64-linux.default = self.packages.x86_64-linux.bibtex2style;
  };
}
