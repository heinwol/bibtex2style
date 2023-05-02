{
  description = "bibtex2style is a script that takes .bib file as an input and produces an .xlsx file with entries processed by biblatex with an according style (like `gost`). It also respects bold an italics fonts!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # pypi-deps-db = {
    #   url = "github:DavHau/pypi-deps-db";
    #   flake = false;
    # };
    mach-nix = {
      url = "github:DavHau/mach-nix/master";
      # inputs = {
        # nixpkgs.follows = "nixpkgs";
        # pypi-deps-db.follows = "pypi-deps-db";
      # };
    };
    # mach-nix.python = "python310";
  };

  outputs = { self, nixpkgs, mach-nix }: let

    system = "x86_64-linux";
  
    pkgs = nixpkgs.legacyPackages.${system};

    pyEnv = mach-nix.lib.${system}.mkPython {
      requirements = ''
        PyMuPDF
        fitz
        toolz
        openpyxl==3.1
        lenses
        glom
      '';
    };
    
    buildInputs = with pkgs; [
      pyEnv
    ];

    devShells.default = pkgs.mkShell {
      inherit buildInputs;
      shellHook = ''
        echo "lalala"
      '';
    };
    
  in {
    devShells.${system} = devShells;
    # packages.x86_64-linux.bibtex2style = 1;
    # packages.x86_64-linux.default = self.packages.x86_64-linux.bibtex2style;
  };
}
