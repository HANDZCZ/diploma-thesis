
# Experimenty

Pro generování kódů je použit nástroj [cargo-show-asm](https://github.com/pacak/cargo-show-asm).
Tento nástroj je využit pro získání assembly, LLVM a MIR (**M**id-level **I**ntermediate **R**epresentation) kódů.

Všechny zdrojové kódy byly obaleny do takzvaného "polleru,"
jehož jediným úkonem je volat metodu `Future::poll` ([@sec:future_trait])
do té doby, dokud asynchronní úloha neskončí nějakým výsledkem.
Tato funkce byla použita namísto asynchronního runtimu ([@sec:async_runtime]),
protože hlavním cílem je zjistit, jaký kód je generován
a asynchronní runtime je příliš komplexní pro tyto experimenty.
Funkce `poller` také umožňuje izolovat generovaný kód, pouze na ten,
který se vztahuje k testovanému případu.

Dále byl využit takzvaný [`black_box`](https://doc.rust-lang.org/beta/std/hint/fn.black_box.html),
který značí kompilátoru, že má být co nejpesimističtější o tom, co `black_box`
je a umí.
Díky této funkci je možné zabránit, aby kompilátor odoptimalizoval části kódu.

```{.include}
single_node.md
flows.md
max_depth_width.md
```

## Shrnutí výsledků

Z experimentů lze zjistit, že implementace statických toků byla úspěšná
a kompilátor je schopen odoptimalizovat await body nejen napříč uzly toku,
ale i napříč sloučenými toky a jejich uzly.

Bohužel bylo také zjištěno, že tento jev není nekonečný a existují limity,
a při jejich překročení je generován kód pro asynchronní zpracování.
Tomuto jevu se však nedá vyhnout při práci s asynchronními úlohami
a nikdy to nebyl ani cíl této knihovny.

Dále také byly zjištěny praktické limity pro tyto statické toky,
při kterých je program úspěšné zkompilován a běží, tak jak má.
Tyto limity by měly být dostačující pro jakékoli použití těchto statických toků.
Pokud tyto limity, ale nejsou dostačující,
tak budou řešeny budoucími verzemi této knihovny.

\newpage

```{.include shift-heading-level-by=-1}
similar_libs.md
```

\newpage

```{.include shift-heading-level-by=-1}
budouci_vyvoj.md
```

\newpage

