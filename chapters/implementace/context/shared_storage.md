
# Sdílené úložiště

Sdílené úložiště podobně jako lokální úložiště
je navrženo pro správu dat, která by měla být sdílena mezi uzly,
ale na rozdíl od lokálního úložiště data jsou sdílena jak mezi uzly ve stejné větvi,
tak i napříč větvemi.
Každá instance sdíleného úložiště je tedy závislá na ostatních instancích se stejným kořenem.
Pro každou instanci také platí, že může existovat samostatně,
ale práce s ní ovlivňuje i ostatní instance.

## Trait SharedStorage

```{.rust .linenos}
pub trait SharedStorage {
    fn get<T>(&self) -> impl Future<Output = Option<impl Deref<Target = T>>> + Send
    where
        T: 'static;

    fn get_mut<T>(&mut self) -> impl Future<Output = Option<impl DerefMut<Target = T>>> + Send
    where
        T: 'static;

    fn insert<T>(&mut self, val: T) -> impl Future<Output = Option<T>> + Send
    where
        T: Send + Sync + 'static;

    fn insert_with_if_absent<T, E>(
        &self,
        fut: impl Future<Output = Result<T, E>> + Send,
    ) -> impl Future<Output = Result<(), E>> + Send
    where
        T: Send + Sync + 'static,
        E: Send;

    fn remove<T>(&mut self) -> impl Future<Output = Option<T>> + Send
    where
        T: 'static;
}

```

: Implementace traitu `SharedStorage` {#lst:shared_storage_trait_impl}

Trait `SharedStorage` definuje typové sdílené úložiště,
které je sdíleno napříč všemi větvemi v toku
a vychází z návrhu pro úložiště typu klíč-hodnota ([@sec:key-val_storage; @fig:kv_storage_design_for_node_trait]).
Tento trait je velmi podobný traitu `LocalStorage` ve funkcích co nabízí
a stejně jako trait `LocalStorage` umožňuje ukládání a získávání hodnot podle jejich datového typu.
Tato implementace také umožňuje mít pro každý datový typ `T` uloženou pouze jednu instanci v úložišti.

Stejně jako trait `LocalStorage`, tento trait obsahuje metody pro získání reference na instanci datového typu,
jak měnitelnou (`get_mut`), tak neměnitelnou (`get`),
odstranění instance (`remove`) z úložiště a vložení (`insert`),
ale oproti traitu `LocalStorage` má ještě navíc metodu `insert_with_if_absent`,
která vloží hodnotu do úložiště,
jen pokud se v úložišti pro daný datový typ nenachází žádná hodnota.
Dalším rozdílem je, že trait `SharedStorage` vrací asynchronní úlohy pro práci s úložištěm,
což je nutno, aby nebyl blokován asynchronní runtime ([@sec:async_runtime])
při přístupu k úložišti z vícero větví současně.
Instance datového typu, které mají být vloženy do tohoto úložiště musí implementovat trait `Send + Sync`,
aby je bylo možno sdílet mezi vlákny.

Od implementací tohoto traitu se očekává, že budou správně pracovat s paralelismem,
například za pomoci struktur jako je `RwLock` ([@sec:rwlock]) nebo `Mutex` ([@sec:mutex]),
a budou vracet zámky implementující traity `Deref` nebo `DerefMut` pro dočasný přístup.

## Implementace sdíleného úložiště

```{.rust .linenos}
type StorageItem = Arc<RwLock<Option<Box<dyn Any + Send + Sync>>>>;

pub struct SharedStorageImpl {
    inner: Arc<Mutex<HashMap<TypeId, StorageItem>>>,
}
```

: Implementace sdíleného úložiště - struct `SharedStorageImpl` {#lst:shared_storage_impl_struct_shared_storage_impl}

Implementace sdíleného úložiště, stejně jako implementace lokálního úložiště,
vychází z návrhu pro úložiště typu klíč-hodnota ([@fig:kv_storage_design_for_node_trait]),
ale oproti návrhu k trait objektu `dyn Any` jsou přidány auto traity `Send + Sync`
a tento trait objekt je ještě obalen v atomické referenci (`Arc` - [@sec:arc]) na zámek (`Rwlock` - [@sec:rwlock]) obsahující možná data
(`Arc<RwLock<Option<Box<dyn Any + Send + Sync>>>>`).
Tento obal umožňuje zamykání pro každý datový typ zvlášť, bez nutnosti držení zámku pro celou type mapu.
Dále je tato celá upravená type mapa obalena do atomické reference (`Arc` - [@sec:arc]) a zámku (`Mutex` - [@sec:mutex]),
pro souběžný přístup z více vláken.

### Implementace dočasných zámků {.unlisted .unnumbered}

```{.rust .linenos}
pub struct ReadGuard<T: 'static> {
    pub guard: async_lock::RwLockReadGuardArc<Option<Box<dyn Any + Send + Sync>>>,
    pub _item_type: std::marker::PhantomData<T>,
}

impl<T: 'static> Deref for ReadGuard<T> {
    type Target = T;

    fn deref(&self) -> &Self::Target {
        let any_ref: &dyn Any = &**self.guard.as_ref().unwrap();
        any_ref.downcast_ref::<T>().unwrap()
    }
}

pub struct WriteGuard<T: 'static> { .. }
impl<T: 'static> Deref for WriteGuard<T> { .. }
impl<T: 'static> DerefMut for WriteGuard<T> { .. }
```

: Implementace sdíleného úložiště - implementace dočasných zámku {#lst:shared_storage_impl_guards_impl}

Struktury dočasných zámků obsahují dočasný zámek na data obsažená v type mapě,
což jsou trait objekty, a jediné co dělají je,
že implementují `Deref` trait, a `DerefMut` trait u zámku pro čtení.
V těchto implementacích se získá reference na data v type mapě
a pomocí downcast metod ([@sec:downcast_methods]) se tato reference převede referenci konkrétního datové typu,
která je poté vrácena.

### Implementace základních traitů {.unlisted .unnumbered}

Implementace základních traitů `Update` a `Join` je velmi jednoduchá,
protože data jsou sdílena mezi instancemi,
tak není nutno nijak řešit aktualizaci a slučování kontextů.
Trait `Fork` je také velmi jednoduchý,
protože jen klonuje celou strukturu a vrací ji.
Při tomto klonování dochází jen k naklonování atomické reference (`Arc` - [@sec:arc]),
což je velmi rychlé a levné.

### Implementace traitu SharedStorage {.unlisted .unnumbered}

```{.rust .linenos}
fn get<T>(&self) -> impl Future<Output = Option<impl Deref<Target = T>>> + Send
where
    T: 'static,
{
    let rw_lock = {
        let guard = self.inner.lock().unwrap();
        guard.get(&TypeId::of::<T>()).cloned()
    };

    async move {
        let rw_lock = rw_lock?;
        let rw_lock_guard = rw_lock.read_arc().await;
        if rw_lock_guard.is_none() {
            return None;
        }
        let read_guard = guards::ReadGuard {
            guard: rw_lock_guard,
            _item_type: std::marker::PhantomData,
        };

        Some(read_guard)
    }
}
```

: Implementace sdíleného úložiště - implementace traitu `SharedStorage` - metoda `get` {#lst:shared_storage_impl_trait_shared_storage_get_impl}

Trait `SharedStorage` je implementován, tak že v každé metodě se nejprve zamkne type mapa
a získá se hodnota uložená v type mapě pro daný datový typ, tato hodnota se naklonuje
a poté je type mapa odemknuta, aby ostatní vlákna k ní měli přístup co nejdříve.
Klonování zde je velmi levné, protože se klonuje jen atomická reference (`Arc` - [@sec:arc]).
Z metod je poté vrácena asynchronní úloha, která obsahuje tuto naklonovanou hodnotu
a pokud v type mapě tato hodnota neexistuje, tak asynchronní úloha vrací `None`,
ale pokud tato hodnota existuje, tak se získá zámek pro tuto hodnotu
a ten je poté obalen do dočasného zámku, který implementuje `Deref` nebo `DerefMut`
a je vrácen asynchronní úlohou.
V kódu výše je uvedena pouze implementace metody `get`,
protože implementace ostatních metod jsou velmi podobné
a uvedení celé implementace traitu `SharedStorage` by bylo příliš dlouhé.

