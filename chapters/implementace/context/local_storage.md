
# Lokální úložiště

Lokální úložiště je navrženo pro správu dat,
která by měla být sdílena mezi uzly ve stejné větvi,
ale ne napříč větvemi v tocích.
Instance lokálního úložiště jsou tedy na sobě nezávislé a unikátní.
Každá instance tohoto úložiště může existovat samostatně
a práce s ní neovlivňuje ostatní instance.

## Enum MergeResult

```{.rust .linenos}
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

## Implementace lokálního úložiště

```{.rust .linenos}
pub struct LocalStorageImpl {
    inner: HashMap<TypeId, Box<dyn StorageItem>>,
    changed: HashSet<TypeId>,
}
```

: Implementace lokálního úložiště - struct `LocalStorageImpl` {#lst:local_storage_impl_struct_locals_torage_impl}

Implementace lokálního úložiště vychází z návrhu pro úložiště typu klíč-hodnota ([@fig:kv_storage_design_for_node_trait]).
Tento návrh je rozšířen o atribut `changed`, který značí jaké hodnoty byly změněny, vloženy či odstraněny
a je využit při slučování kontextů.
Dále je namísto trait objektu `dyn Any` využit privátní trait objekt `dyn StorageItem`,
který není dostupny uživateli knihovny, ale pouze této implementaci lokálního úložiště.

### Trait StorageItem {.unlisted .unnumbered}

```{.rust .linenos}
trait StorageItem: Any + Send {
    fn duplicate(&self) -> Box<dyn StorageItem>;
    fn merge(
        &self,
        parent: Option<&dyn StorageItem>,
        others: Box<[Box<dyn StorageItem>]>,
    ) -> MergeResult<Box<dyn StorageItem>>;
}
```

: Implementace lokálního úložiště - trait `StorageItem` {#lst:local_storage_impl_trait_storage_item}

Trait `StorageItem` je nástavba nad traitem `Any`
a slouží jako dyn kompatibilní ([@sec:dyn_compatibility]) verze kombinace traitů `Merge + Clone`.
Metoda `duplicate` slouží k naklonování hodnoty, stejně jako trait `Clone`,
ale vrací `Box<dyn StorageItem>` místo `Self` typu.
Metoda `merge` slouží ke sloučení vícero hodnot stejného typu, stejně jako trait `Merge`,
ale bere a vrací nějakou verzi trait objektu `dyn StorageItem` místo `Self` typu.

U metody `merge` je důležité zajistit,
že všechny trait objekty `dyn StorageItem` mají vnitřně stejný datový typ,
aby bylo možno tento trait považovat za ekvivalentní ve funkčnosti jako trait `Merge`.
Dále do originální funkce `merge` byla přidána reference na sama sebe,
která je nutná aby trait `StorageItem` mohl být dyn kompatibilní ([@lst:not_dyn_compatible_trait_example] - funkce `ziskej_typ`).

Trait `StorageItem` je implementován pro jakýkoli typ `T`,
který implementuje `Merge + Any + Send + Clone`.
Metoda `duplicate` pouze volá metodu `clone` z traitu `Clone`
a výslednou hodnotu obalí do boxu a vrátí ji,
koerce na trait objekt `dyn StorageItem` probíhá automaticky.
Metoda `merge` nejprve převádí všechny vstupní hodnoty trait objektů `dyn StorageItem`
na konkrétní datový typ `T` ([@sec:downcast_methods]) a poté volá funkci `merge` z `Merge` traitu s těmito hodnotami.
Výsledná hodnota je vrácena nepozměněná, akorát u `MergeResult::ReplaceOrInsert` je potřeba tuto hodnotu obalit do boxu,
aby koerce mohla převést konkrétní datový typ `T` na trait objekt `dyn StorageItem`.

### Implementace základních traitů {.unlisted .unnumbered}

Trait `Fork` je implementován, tak že type mapa obsahující data je naklonována
a pro atribut `changed` je vytvořen nový hashset.
Tímto se docílí toho, že instance lokálního úložiště jsou na sobě nezávislé
a při slučování kontextů proběhne sloučení pouze změněných hodnot.

K naklonování type mapy je nutno aby hodnoty implementovaly trait `Clone` pro `Box<dyn StorageItem>`
a z tohoto důvodu byla přidána implementace, která volá metodu `duplicate` a vrací její výsledek.

Trait `Update` má velmi jednoduchou implementaci,
protože stačí jen originální type mapu nahradit type mapou z instance,
která má aktualizovat originální,
a rozšířit originální hashset změněných hodnot.

Trait `Join` je implementován, tak že nejprve získá všechny typy (klíče type mapy) změněných hodnot
a pak pro každý změněný typ získá hodnoty tohoto typu ze všech úložišť, včetně originálního.
Poté pro každý typ zavolá metodu `merge` a podle vrácené hodnoty upraví hodnotu v originálním úložišti.
Implementace traitu `Join` má jednoduchou myšlenku,
ale samotná implementace je velmi zdlouhavá a řeší se v ní plno krajních případů.

### Implementace traitu LocalStorage {.unlisted .unnumbered}

```{.rust .linenos}
fn get_mut<T>(&mut self) -> Option<&mut T> where T: 'static {
    self.inner.get_mut(&TypeId::of::<T>()).map(|val| {
        self.changed.insert(TypeId::of::<T>());
        let any_debug_ref: &mut dyn Any = &mut **val;
        any_debug_ref.downcast_mut::<T>().unwrap()
    })
}
```

: Implementace lokálního úložiště - implementace traitu `LocalStorage` - metoda `get_mut` {#lst:local_storage_impl_trait_local_storage_get_mut_impl}

Implementace traitu `LocalStorage` je oproti implementaci traitu `Merge` pro datové typy,
které mohou byt uloženy v úložišti, a traitu `Join` pro toto úložiště velmi triviální.
Všechny metody pracují s type mapou a downcast metodami ([@sec:downcast_methods]),
aby získaly hodnotu konkrétního typu v úložišti.
Metody `get_mut` a `remove` navíc ještě, oproti metodě `get`,
označují datový typ v úložišti za změněný, pokud se v úložišti nachází,
a metoda `insert` označuje datový typ za změněný vždy.

