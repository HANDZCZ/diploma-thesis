
## Vliv inliningu a monomorfizace na toky

Pro experimenty s toky byl použit stejný uzel a kontext jako při experimentech s jedním uzlem.
V této kapitole je hlavně testováno kolik uzlů, pouze se synchronním tělem metody `Node::run`,
je schopen kompilátor odoptimalizovat, bez vytváření struktur pro asynchronní úlohy
nebo jiných nadbytečných instrukcí.

| Tok | Počet uzlů |
|---|---:|
|`SequentialFlow`|6
|`OneOfSequentialFlow`|59$^*$
|`ParallelFlow`|0$^*$
|`OneOfParallelFlow`|11

: Počet uzlů úspěšně odoptimalizovaných kompilátorem pro každý tok {#tbl:max_node_collapsed_by_compiler_for_flow}

V tabulce výše je vidět, že pro každý tok existuje různý limit počtu uzlů,
které kompilátor dokáže odoptimalizovat.
U toku `OneOfSequentialFlow` bylo potřeba navýšit tzv. "recursion_limit" na 301
a u toku `ParallelFlow` jsou generovány dodatečné instrukce vždy, protože alokuje paměť na heap.
Bez tohoto omezení by tok `ParallelFlow` dokázal odoptimalizovat aspoň 1 uzel,
což bylo možno vidět ve vygenerovaném assembly kódu.

Tyto limity jsou také nižší, díky tomu, že tato knihovna je asynchronní,
což způsobuje, že existují dodatečné hranice a přidaná komplexita způsobena asynchronním zpracováním.
Když jsou tyto hranice překročeny, tak se kompilátor dále nesnaží,
nebo již nedokáže odoptimalizovat asynchronní kód.

Překročení těchto hranic způsobuje, že je vytvářen dodatečný kód pro asynchronní zpracování.
Bohužel bez dalších nových funkcí jazyka, jako jsou variadické argumenty či funkce,
specializace a nebo explicitní "tail call" (koncové rekurze/volání) optimalizace,
tato knihovna už naráží na limitace jazyka.

Výsledek tohoto experimentu se může zdát, jako selhání této knihovny.
Ale tato knihovna nikdy neměla zamezit kompilátoru vytvářet asynchronní kód,
při plně synchronních tělech uzlů.
Toto nikdy nebyl účel této knihovny a dosažení tohoto cíle je prakticky nemožné,
kvůli různým limitacím a heuristikám kompilátoru.
To, že je tato knihovna schopna poskytnout tuto možnost v nějaké kapacitě,
akorát potvrzuje, že návrh a implementace umožňuje tohoto jevu dosáhnout,
a že kompilátor je schopen odoptimalizovat části kódu napříč uzly a await body.

### Vliv na skládání toků

Jedním z důvodů proč tato knihovna nepoužívá trait objekty je,
že bez jejich použití by měl být kompilátor schopen sloučit,
nebo i odstranit nějaké await body napříč skládanými toky.
Tím tak docílit, že výsledný kód bude rychlejší, více optimalizován
a nemusí se zabývat zbytečnou dereferencí na konkrétní datové typy.

Pro otestování zda se toto povedlo byl vytvořen experiment,
který skládá 3 `SequentialFlow` toky do sebe,
kde každý tok obsahuje aspoň 2 jednoduché uzly.
Vizualizaci tohoto toku lze nalézt v ukázkách ([@fig:flow_composition_experiment_visualization]).

```{.asm .linenos}
node_flow_testing::poller:
    mov al, 52
    ret
```

: Vygenerovaný assembly kód pro kompozici uzlů {#lst:flow_composition_experiment_assembly}

Jak je možno vidět z kódu výše, tak kompilátor dokázal odoptimalizovat celý složený tok.
Tohoto výsledku byl kompilátor schopen docílit, jen díky tomu,
že znal všechny konkrétní datové typy obsažené v toku a operandy použité při výpočtech.

V tomto experimentu si lze povšimnout toho,
že i když se tok skládá z 8 uzlů a 4 toků,
tak je tento celý tok odoptimalizován.
Zajímavé na tomto jevu je, že kdyby se použil jen jeden tok `SequentialFlow`,
tak by k odoptimalizování nedošlo.
Jak je vidět v tabulce [-@tbl:max_node_collapsed_by_compiler_for_flow], tak limit pro tento tok je 6 uzlů.
Dále je potřeba zmínit, že pro tento experiment
i experiment pro maximální počet uzlu bylo použito úplně stejné prostředí -
stejný uzel, kontext, verze jazyka a nastavení optimalizací kompilátoru.
Což nejspíše znamená, že kompilátor byl schopen postupně odoptimalizovat vnitřní toky
a postupovat ke vnějšímu toku a ten poté taky odoptimalizovat.

```{.asm .linenos}
node_flow_testing::poller:
    mov byte ptr [rsp - 2], 5
    lea rax, [rsp - 2]
    lea rcx, [rsp - 1]
    mov byte ptr [rsp - 1], 12
    movzx eax, byte ptr [rsp - 2]
    shl al, 3
    add al, byte ptr [rsp - 1]
    ret
```

: Vygenerovaný assembly kód pro kompozici uzelů s `black_boxem` {#lst:flow_composition_bbox_experiment_assembly}


Podobně jako u experimentu s jedním uzlem byl použit `black_box`,
aby kompilátor vygeneroval kód, jako kdyby hodnoty operandů byly neznámé.

Z assembly kódu výše je vidět, že kompilátor odoptimalizoval veškerý asynchronní kód
a nahradil jej instrukcemi `add` a `shl`.
Celý tok byl tedy redukován jen na bitový posun sčítané hodnoty
a k výsledku byl poté přičten vstup.

