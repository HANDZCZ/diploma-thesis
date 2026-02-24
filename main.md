---
papersize: a4
author:
  - Jan Najman
# open bookmarks tab
bookmarksopen: true
# bookmarks tab expand level
bookmarkopenlevel: 6
pdfcreator: LaTeX via pandoc, made with care and extra sugar on top
title-meta: Návrh a implementace asynchronní knihovny pro tvorbu toků dat
keywords:
  - rust
  - tok
  - toky
  - flow
  - composition
  - composable
  - inspectable
  - visualizable
  - asynchronous
  - async
  - node
  - pipeline
  - workflow
  - runtime
  - framework
  - crate
  - library
  - type-safe
subject: Diplomová práce na téma Návrh a implementace asynchronní knihovny pro tvorbu toků dat
colorlinks: true
# default: Maroon
linkcolor: Maroon
# default: Maroon
filecolor: Maroon
# default: Blue
citecolor: Blue
# default: Blue
urlcolor: Blue
# Defaults to linkcolor
toccolor: Black

header-includes: |
    ```{=latex}
    % force figures to be placed exactly where they are defined
    \usepackage{float}
    \let\origfigure\figure
    \let\endorigfigure\endfigure
    \renewenvironment{figure}[1][2] {
        \expandafter\origfigure\expandafter[H]
    } {
        \endorigfigure
    }

    % include pdfs
    \usepackage{pdfpages}

    % indent first line of paragraph
    \usepackage{indentfirst}

    % break long lines that would overflow
    \usepackage{fvextra}
    \DefineVerbatimEnvironment{Highlighting}{Verbatim}{breaklines,commandchars=\\\{\}}

    % get rid of single letters at the end of line
    \usepackage[nosingleletter]{impnattypo}

    % support for emoji
    \newfontfamily\emojifont[Renderer=Harfbuzz]{Noto Color Emoji}
    \DeclareTextFontCommand{\emoji}{\emojifont}

    % color every other row
    \usepackage{etoolbox}
    \AtBeginEnvironment{longtable}{\rowcolors{2}{gray!15}{}}
    \apptocmd{\toprule}{\hiderowcolors}{}{}
    \apptocmd{\endhead}{\showrowcolors}{}{}
    \apptocmd{\endfirsthead}{\showrowcolors}{}{}
    % set the color to stick out
    \setlength{\tabcolsep}{3pt}

    % landscape pages
    \usepackage{pdflscape}
    \newcommand{\blandscape}{\begin{landscape}}
    \newcommand{\elandscape}{\end{landscape}}

    % put footnotes at the bottom of the page
    % and number the from one on each page
    \usepackage[bottom,perpage]{footmisc}

    % fix 4th and 5th level headings
    \usepackage{titlesec}
    \titlespacing*{\paragraph}{0pt}{3.25ex plus 1ex minus .2ex}{1em}
    \titleformat{\paragraph}[hang]
        {\normalfont\normalsize\bfseries}
        {\theparagraph}
        {1em}
        {\phantomsection}
    \titlespacing*{\subparagraph}{0pt}{3.25ex plus 1ex minus .2ex}{1em}
    \titleformat{\subparagraph}[hang]
        {\normalfont\normalsize\bfseries}
        {\thesubparagraph}
        {1em}
        {\phantomsection}
    ```

includes-before-document: |
    ```{=latex}
    % set minted style
    \usemintedstyle{tomorrow}
    % prevent italics in the `minted` environment.
    %\AtBeginEnvironment{minted}{\let\itshape\relax}
    % prevent italics in the `\mintinline` command.
    %\usepackage{xpatch}
    %\xpatchcmd{\mintinline}{\begingroup}{\begingroup\let\itshape\relax}{}{}
    % set line numbers size
    \renewcommand{\theFancyVerbLine}{\sffamily \textcolor[rgb]{0.0,0.0,0.0}{\tiny \oldstylenums{\arabic{FancyVerbLine}}}}
    ```

lang: cs-CZ
pagestyle: empty
plot-configuration: plot-config.yaml

fontsize: 12pt
mainfont: DejaVu Serif Condensed
mainfontoptions:
- Scale=1.0
- BoldFont=* Bold
- ItalicFont=* Italic
- BoldItalicFont=* BoldItalic
monofont: JetBrainsMono Nerd Font
monofontoptions:
- Scale=1.0
sansfont: DejaVu Sans Condensed
sansfontoptions:
- Scale=1.0
- BoldFont=* Bold
- ItalicFont=* Oblique
- BoldItalicFont=* BoldOblique
#mathfont: TeXGyreDejaVuMath-Regular
mathfont: DejaVu Serif Condensed
mathfontoptions:
- Scale=1.0

geometry:
- top=20mm
- right=20mm
- left=35mm
- bottom=20mm
toc-depth: 6
# add all bib
#nocite: '@*'
# add hyperinks to citations
link-citations: true
csquotes: true

figure-source: "[Vlastní tvorba]"
table-source: "[Vlastní tvorba]"
listings-source: "[Vlastní tvorba]"

numbersections: true
autoEqnLabels: true
codeBlockCaptions: true
figPrefix:
  - "obrázek"
  - "obrázky"
tblPrefix:
  - "tabulka"
  - "tabulky"
lstPrefix:
  - "kód"
  - "kódy"
secPrefix:
  - "sekce"
  - "sekce"

lofTitle: Seznam obrázků
lotTitle: Seznam tabulek
lolTitle: Seznam kódů
listingTitle: Kód
tableTitle: Tabulka
figureTitle: Obrázek
# Defaults to linkcolor
lotcolor: Black
# Defaults to linkcolor
lofcolor: Black
# Defaults to linkcolor
lolcolor: Black
# enables coloring \hyperlink (citation) links in list of ...
locolorlinks: true
linestretch: 1.5
# don't use mintinline, because it fails to break long words properly
# these are the default settings, uncomment for changing
minted:
  no_mintinline:
    enable: true
    hyphenation:
      length_threshold: 18
      after: ["_"]
---
\hyphenpenalty=10000
\widowpenalties 1 10000
\raggedbottom

<!--\includepdf[pages=-]{titlepage.pdf}-->

```{.include}
chapters/abstract.md
```

<!-- Table of contents -->
\toc
\newpage

<!-- Set page style -->
\pagestyle{plain}
\parindent 1,25cm
\parskip 12pt
\setcounter{page}{1}

```{.include}
chapters/uvod.md
chapters/teoreticka_cast/teoreticka_cast.md
chapters/analyza_pozadavku/analyza_pozadavku.md
chapters/navrh/navrh.md
chapters/implementace/implementace.md
chapters/vyhodnoceni_a_experimenty/vyhodnoceni_a_experimenty.md
chapters/zaver.md
```

# Seznam použité literatury

::: {#refs}
:::

\newpage

# Seznam obrázků, tabulek a kódů

\lof
\lot
\lol

\newpage

\pagestyle{empty}

# Přílohy

![Příklad vytvořené vizualizace pomocí formátovače `D2Describer`](./pictures/d2describer_output_example.png){#fig:d2describer_output_example height=88%}

```{.rust .linenos}
impl<..> Builder<
    Input, Output, Error, Context, NodeTypes,
    ChainLink<OtherNodeIOETypes, NodeIOE<LastNodeInType, LastNodeOutType, LastNodeErrType>>,
> where .. {
    pub fn add_node<NodeType, NodeInput, NodeOutput, NodeError>(self, node: NodeType) -> Builder<
        Input, Output, Error, Context,
        ChainLink<NodeTypes, NodeType>,
        ChainLink<
            ChainLink<OtherNodeIOETypes, NodeIOE<LastNodeInType, LastNodeOutType, LastNodeErrType>>,
            NodeIOE<NodeInput, NodeOutput, NodeError>,
        >,
    > where
        LastNodeOutType: Into<NodeInput>,
        NodeError: Into<Error>,
        NodeType: Node<NodeInput, NodeOutputStruct<NodeOutput>, NodeError, Context>,
        ..
    {
        Builder { .., nodes: (self.nodes, node) }
    }

    pub fn build(self) -> SequentialFlow<
        Input, Output, Error, Context, NodeTypes,
        ChainLink<OtherNodeIOETypes, NodeIOE<LastNodeInType, LastNodeOutType, LastNodeErrType>>,
    > where
        LastNodeOutType: Into<Output>,
    {
        Flow { .., nodes: Arc::new(self.nodes) }
    }
}
```

: Implementace toku `SequentialFlow` - definice builderu - metoda `add_node`, pro ostatní uzly, a metoda `build` {#lst:sequential_flow_builder_oadd_node_build_def_impl}

```{.rust .linenos}
impl<..> Builder<
    Input, Output, Error, Context, NodeTypes,
    ChainLink<OtherNodeIOETypes, LastNodeIOETypes>,
> where .. {
    pub fn build<J, ChainRunOutput>(self, joiner: J) -> Flow<
        Input, Output, Error, Context, ChainRunOutput, J, NodeTypes,
        ChainLink<OtherNodeIOETypes, LastNodeIOETypes>,
    > where
        for<'a> J: Joiner<'a, ChainRunOutput, Output, Error, Context>,
        NodeTypes: ChainRunParallel<
            Input,
            Result<ChainRunOutput, Error>,
            Context,
            ChainLink<OtherNodeIOETypes, LastNodeIOETypes>,
       >,
    {
        Flow { .., nodes: Arc::new(self.nodes), joiner }
    }
}
```

: Implementace toku `ParallelFlow` - definice builderu - metoda `build` {#lst:parallel_flow_builder_build_def_impl}

```{.rust .linenos}
pub trait ChainSpawn<Input, Error, Context, HeadOut, T> {
    type ChainOut;
    const NUM_FUTURES: usize;

    fn spawn(
        &self,
        input: Input,
        context: Context,
    ) -> impl ChainPollParallel<Self::ChainOut, Context>;
}

pub trait ChainPollParallel<Output, NodeContext>: Send {
    fn poll(
        self: Pin<&mut Self>,
        cx: &mut Context<'_>,
        tail_ready: bool,
        context_acc: &mut Vec<NodeContext>,
    ) -> Poll<Output>;
}
```

: Implementace toku `ParallelFlow` - definice traitů `ChainSpawnParallel` a `ChainPollParallel` {#lst:parallel_flow_chain_run_sub_impl}

```{.text .linenos escapeinside=||}
┌─« node-flow on  main is |\emoji{📦}| v0.2.0 via |\emoji{🦀}| v1.93.1
└─» cargo test --all-features
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.03s
     Running unittests src/lib.rs (target/debug/deps/node_flow-200139d2573f6e74)

running 22 tests
test flows::parallel_flow::flow::test::test_flow_storage ... ok
..
test flows::one_of_sequential_flow::test::test_flow ... ok
test flows::sequential_flow::test::test_chain ... ok

test result: ok. 22 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.46s
.
.
.
   Doc-tests node_flow

running 45 tests
test src/context/traits.rs - context::traits::SpawnSync (line 194) ... ok
test src/context/traits.rs - context::traits::Join (line 71) ... ok
..
test src/describe/d2.rs - describe::d2::D2Describer (line 9) ... ok

test result: ok. 45 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.01s

all doctests ran in 0.83s; merged doctests compilation took 0.82s
```

: Zkrácený výstup běhu testů {#lst:shortened_tests_run}

