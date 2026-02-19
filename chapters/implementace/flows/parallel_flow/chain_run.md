
## Privátní trait ChainRunParallel

```{.rust .linenos}
pub trait ChainRunParallel<Input, Output, Context, T> {
    fn run(&self, input: Input, context: &mut Context) -> impl Future<Output = Output> + Send;
}
```

: Implementace toku `ParallelFlow` - definice traitu `ChainRunParallel` {#lst:parallel_flow_chain_run_def_impl}

Trait `ChainRunParallel` spravuje privátní traity pro vytváření, spouštění a čekání na asynchroní úlohy
a z pohledu uživatele obsahuje veškerou logiku pro běh toku a správu asynchronních úloh.
Generický typ `T` v definici traitu je použit pro uložení vstupních, výstupních
a chybových datových typů uzlů.

Implementace traitu `ChainRunParallel` pro tuple list
definuje souběžné vykonávání uzlů toku.
Běh je implementován za pomocí rekurzivní dekompozice tuple listu na hlavu a ocas.
Dále jsou definovány a použity traity `ChainSpawn`,
sloužící k vytvoření asynchronních úloh za pomocí `SpawnAsync` traitu ([@sec:trait_spawn_async]),
a `ChainPollParallel`,
sloužící k čekání na dokončení asynchronních úloh, zpracování a správu jejich výstupů.
Definice traitů `ChainSpawn` a `ChainRunParallel` se nachází v přílohách ([@lst:parallel_flow_chain_run_sub_impl]).

Tok končí úspěšně, jen když všechny uzly a "joiner" skončí úspěšně.
Při jakékoli chybě, buď z uzlů či "joineru" je tok ukončen a chyba je vrácena.

Tato implementace zajišťuje, že uzly jsou prováděny souběžně a nezávisle na sobě.
K docílení této implementace jsou také použity traity `Fork` ([@sec:trait_fork]) a `Join` ([@sec:trait_join]),
které zajišťují, že každá větev toku dostane nezávislou instanci kontextu,
a že kontexty je na konci toku možno sloučit do originálního kontextu.

