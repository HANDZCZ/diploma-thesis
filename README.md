
# Thesis template

The template should comply with [UHK requirements](https://www.uhk.cz/cs/fakulta-informatiky-a-managementu/studium/statni-zaverecne-zkousky-a-kvalifikacni-prace/kvalifikacni-prace-bakalarska-diplomova)
([2023 version](https://www.uhk.cz/file/edee/fakulta-informatiky-a-managementu/uredni-deska/ridici-akty/vynosy-dekana/2023/metodicke-pokyny-pro-vypracovani-bakalarskych-a-diplomovych-praci.pdf))
for bachelor's thesis.

> Wayback Machine links:
> [UHK requirements](https://web.archive.org/web/20250620220130/https://www.uhk.cz/cs/fakulta-informatiky-a-managementu/studium/statni-zaverecne-zkousky-a-kvalifikacni-prace/kvalifikacni-prace-bakalarska-diplomova)
> ([2023 version](https://web.archive.org/web/20250620220404/https://www.uhk.cz/file/edee/fakulta-informatiky-a-managementu/uredni-deska/ridici-akty/vynosy-dekana/2023/metodicke-pokyny-pro-vypracovani-bakalarskych-a-diplomovych-praci.pdf))

You can use these files for your own bachelor's thesis with some small or minimal changes.
In the filters folder are some modified filters and some filters made by me.
Chapters and pictures folder store all chapters and pictures respectively.

## Running without docker

As of writing this readme pandoc and other tools already updated and broke things.
This thesis was written with pandoc 3.1.2, pandoc-crossref 0.3.16.0 and pandoc-plot 1.7.0.

Apart from needing to install pandoc, texlive (it's recommended to install most of the packages), and lualatex.
You will also need to install d2 for diagrams and some backend for it (I use tala) or use a different toolkit offered by pandoc-plot.
Next, you will need to install pygments for code highlighting (pygments are used by minted) and plotly for plots or some other toolkit supported by pandoc-plot.
You will also need to download missing fonts.

## With docker

If you want to use this as is, without adding new things then you can use my [docker image](https://hub.docker.com/r/handz/pandoc-toolkit).

You just need to mount this folder with md files, template and other stuff to ``/home/user/thesis``.
If you don't run it with your build script it will drop you into bash (in this case don't forget to run it with the flags ``-it``).

example usage - mount current directory and run conversion:
```bash
$ docker run -it --rm -v "$(pwd):/home/user/thesis" handz/pandoc-toolkit:3.1.2 "./create_thesis.sh"
```

## Example usages

- [My bachelor's thesis](https://github.com/HANDZCZ/bc/tree/main/thesis) ([generated pdf](https://github.com/HANDZCZ/bc/releases/download/Done/thesis.pdf)) - most of the files for this template come from here (you can also find the [Dockerfile here](https://github.com/HANDZCZ/bc/blob/main/thesis/Dockerfile))
- Applied Game Theory projects (not versioned and not available) - improved create_thesis.sh script and Makefile
- [NoSQL project](https://gitlab.com/HANDZCZ/nosql/-/tree/main/thesis) ([generated pdf](https://gitlab.com/-/project/67153182/uploads/fd275fb43b3c98cc1405e30b439738f2/thesis.pdf)) - edited plot-config.yaml, updated pandoc-plot filter and fixed 4th and 5th level headings

