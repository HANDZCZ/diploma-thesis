
# Lokální úložiště

Lokální úložiště je navrženo pro správu dat,
která by měla být sdílena mezi uzly ve stejné větvi,
ale ne napříč větvemi v tocích.
Instance lokálního úložiště jsou tedy na sobě nezávislé a unikátní.
Každá instance tohoto úložiště může existovat samostatně
a práce s ní neovlivňuje ostatní instance.

## Enum MergeResult

```{.rust .linenos}
#[derive(Debug)]
pub enum MergeResult<T> {
    KeepParent,
    ReplaceOrInsert(T),
    Remove,
}
```

: Implementace enumu `MergeResult` {#lst:merge_result_enum_impl}

Enum `MergeResult` reprezentuje výsledek sloučení
více instancí určitého datového typu během slučování kontextů.
Tento enum se používá v traitu `Merge` k určení,
jak by mělo sloučení ovlivnit originální hodnotu.
Rozhodnutí zda originální hodnota bude ponechána,
nahrazena nebo vložena či odstraněna záleží na implementaci uživatele této knihovny.

## Trait Merge

```{.rust .linenos}
pub trait Merge: Sized {
    fn merge(parent: Option<&Self>, others: Box<[Self]>) -> MergeResult<Self>;
}
```

: Implementace traitu `Merge` {#lst:merge_trait_impl}

Trait `Merge` slouží k definici, jak mají být instance stejného typu sloučeny.
Obsahuje pouze jednu funkci `merge`, která bere neměnnou referenci na originální instanci,
pokud existuje, a pole ostatních instancí stejného typu.
Implementace této funkce definuje co se má stát s instancí,
která se momentálně nachází v úložišti.
Toto rozhodnutí je ponecháno na uživateli knihovny.

## Trait LocalStorage

```{.rust .linenos}
pub trait LocalStorage {
    fn get<T>(&self) -> Option<&T>
    where
        T: 'static;

    fn get_mut<T>(&mut self) -> Option<&mut T>
    where
        T: 'static;

    fn insert<T>(&mut self, val: T) -> Option<T>
    where
        T: Merge + Clone + Send + 'static;

    fn remove<T>(&mut self) -> Option<T>
    where
        T: 'static;
}
```

: Implementace traitu `LocalStorage` {#lst:local_storage_trait_impl}

Trait `LocalStorage` definuje typové lokální úložiště,
které není sdíleno s žádnou jinou větví v toku
a vychází z návrhu pro úložiště typu klíč-hodnota ([@sec:key-val_storage; @fig:kv_storage_design_for_node_trait]).
Umožňuje ukládání a získávání hodnot podle jejich datového typu.
Tato implementace umožňuje mít pro každý datový typ `T` uloženou pouze jednu instanci v úložišti.

Obsahuje metody pro získání reference na instanci datového typu,
jak měnitelnou (`get_mut`), tak neměnitelnou (`get`),
odstranění instance (`remove`) z úložiště a vložení (`insert`).
Instance které mají být vloženy do tohoto úložiště musí implementovat trait `Merge`.

