
## Konstrukce toku

Při konstrukci toku je nutno zajistit aby uzly na sebe mohly navazovat, bez jakýchkoliv potíží.
Dále je nutno zajistit, že vstup do toku lze poslat do prvního uzlu
a výstup z posledního uzlu lze vrátit jako výstup z posledního uzlu.

Kvůli těmto požadavkům je nutné měnit datové typy co tyto toky definují při konstrukci.
Za běhu, ale už tyto typy nejsou tak důležité a proto by konstrukce měla být provedena přes tzv. "builder".
Tento styl konstrukce zajistí, že lze měnit datové typy definice toku a na konci je ukončen metodou,
která může vracet úplně jiný typ a tak se například zbavit nadbytečných datových typů v definici,
nebo i polí v objektu.

```{.d2 #fig:flow_builder_design caption="Návrh builderu pro toky" width=75%}
vars: {
  d2-config: {
    pad: 0
  }
}

Builder\<Vstup, Vystup, TypyUzlu\>: {
  shape: class

  -uzly: TypyUzlu

  pridej_uzel(Uzel): Self
  sestav_tok(): TypToku<Vstup, Vystup>
}
```

## Uložení uzlů v toku

Uložení uzlů v toku může být provedeno dvěma hlavními způsoby.
První z možností je použití homogenních polí, kde každý uzel by musel mít stejný typ.
Druhá možnost je použití heterogenních polí za pomocí trait objektů (`Vec<dyn Node>` nebo `Vec<dyn Any>`).
Pak ještě existuje možnost použití tuple listů (@sec:tuple_lists),
které umožňují vytváření heterogenních polí s konkrétními typy.

Použití homogenních polí nepřipadá v úvahu, protože by v toku mohl být použit jen jeden typ uzlu,
což je pro účely této knihovny nepřípustné.

Použití trait objektu `dyn Node` by znamenalo použití dynamické výběru ([@sec:dynamic_dispatch]),
který způsobí, že kompilátor nemůže kód pořádně optimalizovat.
Zároveň aktuální návrh `Node` traitu není možně použít jako trait objekt,
protože není dyn kompatibilní ([@sec:dyn_compatibility]).

Použití trait objektu `dyn Any` přidá režii díky tomu,
že se musí každý trait objekt převést na konkrétní typ ([@sec:any_chapter]).
Typy na které je potřeba trait objekty převést, je nutno znát předem,
což znamená, že musí být v definici toku.
Dále při tomto procesu také probíhá kontrola typu
a trait objekt `dyn Any` musí být obalen např. v boxu ([@sec:box]), což přidává indirekci a režii.
Mohly by se použít tzv. "unchecked downcast" metody ([@sec:downcast_methods]),
ale ty jsou bohužel nedostupné na stabilním kanálu a neřeší problém režie boxu.

Metodou eliminace už zbývají jen tuple listy.
Jejich hlavní nevýhodou je, že se s nimi pracuje hůře než s normálními listy
a vyžadují definici nových traitů pro specifické použití,
což není až takový problém, protože každý tok by měl plnit jinou funkci.
Dále je také nutno uložit datový typ tuple listu do definice toku.

```{.rust .linenos}
struct NazevToku<Vstup, Vystup, TupleListTyp> {
    uzly: TupleListTyp,
}
```

: Návrh struktury objektu toku {#lst:flow_struct_design}

## Definice běhu toku

Běh toku lze zhruba rozdělit do čtyř částí.
První část je vytvoření asynchronních úloh.
Druhá část je spuštění asynchronní úloh.
Třetí část je čekání na dokončení asynchronní úloh.
Poslední čtvrtá část je zpracování výstupů asynchronních úloh.

Toto rozdělení běhu toků do částí s největší pravděpodobností není možno dodržet pro všechny toky.
Z tohoto důvodu při implementaci mohou být nějaké nebo všechny tyto části spojeny do jedné.
Dále nad těmito částmi by už měla být jen samotná implementace traitu pro toky.

```{.rust .linenos}
// pseudokód implementace běhu toku
impl Node for ParallelFlow {
    async fn run(&mut self, input: Input) -> Output {
        // vytvoření asynchronních úloh.
        let futures: Vec<NodeFuture> = self.create_futures(input);
        // spuštění asynchronní úloh.
        futures.iter().for_each(runtime::spawn);
        // čekání na dokončení asynchronní úloh.
        let outputs: Vec<_> = futures.into_stream().map(NodeFuture::await).await;
        // zpracování výstupů asynchronních úloh.
        let result = self.handle_outputs(outputs);
        return result;
    }
}
```

: Ukázka návrhu implementace běhu toku pro paralelní tok {#lst:flow_run_design_example}

