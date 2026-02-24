
# Vyhodnocení a experimenty

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
který značí kompilátoru, že má být co nejpesimističtější o tom co `black_box`
je a umí.
Díky této funkci je možno zabránit, aby kompilátor odoptimalizoval části kódu.

```{.include}
single_node.md
```

\newpage

