
## Privátní trait ChainRunSequential

```{.rust .linenos}
pub trait ChainRunSequential<Input, Output, Context, T> {
    fn run(&self, input: Input, context: &mut Context) -> impl Future<Output = Output> + Send;
}
```

: Implementace toku `SequentialFlow` - definice traitu `ChainRunSequential` {#lst:sequential_flow_chain_run_def_impl}

Trait `ChainRunSequential` obsahuje veškerou logiku pro běh toku
a správu asynchronních úloh.
Generický typ `T` v definici traitu je použit pro uložení vstupních, výstupních
a chybových datových typů uzlů.

Implementace traitu `ChainRunSequential` pro tuple list
definuje sekvenční vykonávání jednotlivých uzlů toku.
Běh je implementován rekurzivní dekompozicí seznamu tuple na hlavu a ocas,
kde metoda `run`, z `Node` traitu, je vyvolána nejprve na prvním uzlu v toku.
Výstup uzlu je poté použit jako vstup do dalšího uzlu a v případě chyby
je běh toku ukončen a chyba je vrácena jako výsledek toku.

Tato implementace zajišťuje, že uzly jsou prováděny ve stejném pořadí,
v jakém byly vloženy do builderu,
a že výsledek posledního uzlu je vrácen jako výstup celého toku.

