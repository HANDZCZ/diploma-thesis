#!/bin/sh

# Function to display script usage
usage() {
    echo "Usage: $0 [--count-words-only] [--count-codeblocks]"
    exit 1
}

# Check if the script was called with the --help flag
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
fi

# Check if the script was called with the --count-words-only flag
if [ "$1" == "--count-words-only" ]; then
    wordcount_flag=""
    shift   # Remove the flag from the arguments
else
    wordcount_flag="process-anyway"
fi

# Check if the script was called with the --codeblocks flag
if [ "$1" == "--count-codeblocks" ]; then
    codeblocks_flag=true
    shift   # Remove the flag from the arguments
else
    codeblocks_flag=false
fi




if [ "$wordcount_flag" != "" ]; then
    echo 'Started conversion.'
    echo ''
fi

mkdir -p /tmp/thesis
pandoc --standalone --listings --no-highlight --lua-filter ./filters/include-files.lua --lua-filter ./filters/include-code-files.lua --pdf-engine-opt=--shell-escape --pdf-engine-opt=--output-directory=/tmp/thesis --lua-filter ./filters/linebreaks.lua --filter pandoc-plot --lua-filter ./filters/fix-codeblock-headings.lua --filter pandoc-crossref --lua-filter ./filters/add-links-to-footnotes.lua --lua-filter ./filters/add-missing-source.lua -M wordcount-codeblocks=$codeblocks_flag -M wordcount=$wordcount_flag --lua-filter ./filters/wordcount.lua --lua-filter ./filters/minted.lua --lua-filter ./filters/pandoc-plot-fix-figures.lua --template template.latex --pdf-engine lualatex --bibliography bib.yaml --citeproc --csl iso690-numeric-brackets-cs.csl --lua-filter ./filters/remove-citation-brackets.lua -o 'thesis.pdf' main.md

if [ "$wordcount_flag" != "" ]; then
    mv /tmp/thesis/input.pdf ./thesis.pdf

    echo ''
    echo 'Finished.'
fi

