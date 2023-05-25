# bibtex2style

Imagine you're an organized person and you manage all your bibliography with some bibliography manager like [jabref](https://www.jabref.org/). The manager you prefer stores all the data inside `.bib` files, hence it's straightforward to use it in latex. Now imagine that for whatever reason you need to have your bibliography in text format. Maybe your institution wants a report in `.docx` format from you, or you want to include references in a presentation, or send them via email... who knows why. The point where you convert `.bib` file to text is the tricky one. There are solutions like [CSL](https://github.com/citation-style-language/styles#readme), but they don't have good support for some citation styles. The script presented here utilizes latex to create citations, so if your citation style is supported in latex this script also supports it.

bibtex2style is a script that takes .bib file as an input and produces an .xlsx file with entries processed by biblatex with an according style (like `gost`). It also respects bold an italics fonts!

bibtex2style also adds cite keys to .xlsx file (see [example](#Example)), so it should be easy to find and manage citations.

By default bibtex2style uses [biblatex-gost](https://ctan.org/pkg/biblatex-gost) style. One can modify [tex source](https://github.com/heinwol/bibtex2style/blob/main/bibtex2style/process_bib_file.tex#L15) to change the style (temporary solution). 

## Usage

Using the script is simple:
```console
$ bibtex2style test.bib [styled_result.xlsx]
```

If you use docker then this command should do the trick:
```console
$ docker run -it -v $(pwd):/temp --rm bibtex2style:latest bibtex2style test.bib [styled_result.xlsx]
```

Beware though:
1. The line above works for linux, if you run it on windows use the windows `$(pwd)` alternative, idk what it is;
2. At least on linux, modifying files with docker the issue when whatever file it creates becomes owned by root. To avoid this you can either perform some nontrivial steps as described in e.g. [here](https://vsupalov.com/docker-shared-permissions/) or use podman.

### Example

#### Input

`test.bib` contents:

```tex
@article{Безверхний2014,
    author = {Безверхний, Н. В.},
    journal = {Научное издание МГТУ им. Н.Э.Баумана},
    title = {Кольцевые диаграммы с периодическими метками и проблема степенной
             сопряжённости в группах с условиями C(3)-T(6)},
    year = {2014},
    language = {ru},
    pages = {238--256},
    volume = {No11},
}

@article{Shpilrain2004,
    author = {Shpilrain, Vladimir and Zapata, Gabriel},
    title = {Combinatorial group theory and public key cryptography},
    year = {2004},
    month = oct,
    archiveprefix = {arXiv},
    copyright = {Assumed arXiv.org perpetual, non-exclusive license to
                 distribute this article for submissions made before January 2004
                 },
    doi = {10.48550/ARXIV.MATH/0410068},
    eprint = {math/0410068},
    file = {:http\://arxiv.org/pdf/math/0410068v1:PDF},
    keywords = {Group Theory (math.GR), Cryptography and Security (cs.CR), FOS:
                Mathematics, FOS: Computer and information sciences},
    primaryclass = {math.GR},
    publisher = {arXiv},
}

@article{Anshel1999,
    author = {Iris Anshel and Michael Anshel and Dorian Goldfeld},
    journal = {Mathematical Research Letters},
    title = {An algebraic method for public-key cryptography},
    year = {1999},
    number = {3},
    pages = {287--291},
    volume = {6},
    doi = {10.4310/mrl.1999.v6.n3.a3},
    priority = {prio2},
    publisher = {International Press of Boston},
}
```

#### Output

`styled_result.xlsx` contents:

![result](./example/styled_result.png)

## Installation

### Nix

If you happen to use [nix](https://nixos.org/learn.html) with flakes you can build it with:
```console
$ nix build github:heinwol/bibtex2style#default
```
Or install directly to your profile:
```console
$ nix profile install github:heinwol/bibtex2style#default
```

All the dependencies are already there, it's plug&play.

### Docker

Provided you have docker installed on your system just load the downloaded image:
```console
$ docker load -i docker-image-bibtex2style-0.1.0.tar.gz 
```
then run the container as described above.

### Manual

```console
git clone https://github.com/heinwol/bibtex2style
cd bibtex2style
pip install poetry
poetry build
pip install dist/bibtex2style-0.1.0-py3-none-any.whl
```

Along with lines above you are expected to have some programs installed, see [Requirements](#Requirements).

## Requirements

- `python` with `pip` installed. I used 3.10, in theory it should work with several prior releases
- `perl`. Required by latexmk
- `LaTeX`. Whatever distribution and version of latex you can find **with the following packages** (this list is made for texlive, package names for MiKTeX may differ):
  - `biber`
  - `biblatex`
  - `cm-unicode` -- fonts. Maybe you'll need to install `cm-super` if your language is not supported.
  - `latexmk`
  - `luatex`
  - `luatex85`
  - `luatexbase`
  - `polyglossia`
  - `standalone`
  - `varwidth`
  - language package for the according language, by default it is `collection-langcyrillic`
  - style package you want to use with `biblatex`, by default it is `biblatex-gost`
