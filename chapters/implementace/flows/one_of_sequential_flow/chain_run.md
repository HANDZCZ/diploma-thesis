
## Privátní trait ChainRunOneOfSequential

```{.rust .linenos}
pub trait ChainRunOneOfSequential<Input, Output, Context, T> {
    fn run(&self, input: Input, context: &mut Context) -> impl Future<Output = Output> + Send;
}
```

: Implementace toku `OneOfSequentialFlow` - definice traitu `ChainRunOneOfSequential` {#lst:one_of_sequential_flow_chain_run_def_impl}

Trait `ChainRunOneOfSequential` je skoro totožný v definici traitu `ChainRunSequential`
a obsahuje veškerou logiku pro běh toku a správu asynchronních úloh.
Generický typ `T` v definici traitu je použit pro uložení vstupních, výstupních
a chybových datových typů uzlů.

Implementace traitu `ChainRunOneOfSequential` pro tuple list
je také velmi podobná v tom, že definuje sekvenční vykonávání jednotlivých uzlů toku.
Běh je implementován rekurzivní dekompozicí seznamu tuple na hlavu a ocas,
kde metoda `run`, z `Node` traitu, je vyvolána nejprve na prvním uzlu v toku.
Ale liší se funkcionalitou od `ChainRunSequential` traitu tím,
že úspěšný výstup uzlu je použit jako vstup toku
a v případě chyby je běh toku ukončen a chyba je vrácena jako výsledek toku.

Tato implementace zajišťuje, že uzly (větve toku) jsou spouštěny ve stejném pořadí,
v jakém byly vloženy do builderu,
a že výsledek toku je první úspěšný nebo chybový výsledek nějaké větve tohoto toku.

