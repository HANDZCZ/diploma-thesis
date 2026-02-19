
## Privátní trait ChainRunOneOfParallel

```{.rust .linenos}
pub trait ChainRunOneOfParallel<Input, Output, Context, T> {
    fn run(&self, input: Input, context: &mut Context) -> impl Future<Output = Output> + Send;
}
```

: Implementace toku `OneOfParallelFlow` - definice traitu `ChainRunOneOfParallel` {#lst:one_of_parallel_flow_chain_run_def_impl}

Trait `ChainRunOneOfParallel`, stejně jako trait `ChainRunParallel`,
spravuje privátní traity pro vytváření, spouštění a čekání na asynchroní úlohy
a z pohledu uživatele obsahuje veškerou logiku pro běh toku a správu asynchronních úloh.
Generický typ `T` v definici traitu je použit pro uložení vstupních, výstupních
a chybových datových typů uzlů.

Implementace traitu `ChainRunOneOfParallel` pro tuple list je také velmi podobná traitu `ChainRunParallel`
v tom, že běh je implementován za pomocí rekurzivní dekompozice tuple listu na hlavu a ocas,
používají se traity `ChainSpawn`,
sloužící k vytvoření asynchronních úloh za pomocí `SpawnAsync` traitu ([@sec:trait_spawn_async]),
a `ChainPollOneOfParallel`,
sloužící k čekání na dokončení asynchronních úloh, zpracování a správu jejich výstupů.
Definice podobných traitů pro `ChainRunParallel` se nachází v přílohách ([@lst:parallel_flow_chain_run_sub_impl]).

Ale liší se funkcionalitou od `ChainRunParallel` traitu tím,
že úspěšný výstup uzlu je použit jako výstup toku
a v případě chyby je běh toku ukončen a chyba je vrácena jako výsledek toku.
Dále se liší tím, že ke správě kontextu využívá traity `Fork` ([@sec:trait_fork]),
sloužící k poskytnutí nezávislé instance kontextu uzlu,
a `Update` ([@sec:trait_update]), sloužící k aktualizaci originálního kontextu.

Tato implementace zajišťuje, že uzly jsou prováděny souběžně a nezávisle na sobě,
a že výsledek toku je první úspěšný nebo chybový výsledek nějaké větve tohoto toku.

