
## Smart pointery {#sec:smart_pointers}

Smart pointery jsou datové struktury, které fungují jako normální ukazatele,
ale oproti normálním ukazatelům obsahují dodatečná metadata a funkce.
Ve standardní knihovně jazyka Rust je definováno mnoho typů smart pointerů,
které poskytují řadu funkcí navíc oproti běžným ukazatelům.
[@rust_book_smart_pointers]

### Box\<T\> {#sec:box}

Box je nejspíše ten nejjednodušší typ smart pointeru.
Jediné co dělá je, že umožňuje ručně alokovat paměť na heap (haldu).
[@smart_pointers_devto; @smart_pointers_codecamp; @smart_pointers_medium]

Funguje skoro stejně jako `malloc` v C, s tím rozdílem,
že Box automaticky uvolní paměť, když opustí rozsah bloku či funkce,
nebo když je ukončen běh programu.
[@smart_pointers_devto; @smart_pointers_codecamp; @smart_pointers_medium]

```{.rust .linenos}
// hodnota u32 na haldě (heap)
let u32_heap = Box::new(1u32);
// hodnota u32 na zásobníku (stack)
let u32_stack = 1u32;
```

: Příklad použití smart pointeru `Box<T>` {#lst:box_example}

### Pin\<Ptr\> {#sec:pin}

Pin je jednoduchý obal kolem nějakého ukazatele `Ptr` a zajišťuje,
že se hodnota ukazatele zafixuje na daném místě v paměti,
čímž se zabrání přesunutí hodnoty, na kterou ukazatel odkazuje, nebo jejímu zneplatnění.
Toto chování, ale platí jen pro typ neimplementující auto trait `Unpin`,
který říká, že s hodnotou můžeme bezpečně hýbat.
[@rust_docs_pin_module]

```{.rust .linenos}
struct AddrTracker { .. }

impl AddrTracker {
    fn check_for_move(self: Pin<&mut Self>) { .. }
}

// vytvoření instance se kterou, ještě můžeme bezpečně hýbat
let tracker = AddrTracker::default();

// vytvoření obalené měnitelné reference na instanci pomocí makra
let mut ptr_to_pinned_tracker: Pin<&mut AddrTracker> = pin!(tracker);
// s instancí již nelze hýbat a může se bezpečně inicializovat
ptr_to_pinned_tracker.as_mut().check_for_move();

// díky pinu jakékoli následující volání funkce `check_for_move` by nikdy nemělo selhat
ptr_to_pinned_tracker.as_mut().check_for_move();
```

: Příklad použití smart pointeru `Pin<T>` [@rust_docs_pin_module] {#lst:pin_example}

### Arc\<T\> {#sec:arc}

Arc je ukazatel s atomicky počítanými referencemi,
což umožňuje, že alokovaná paměť může mít více vlastníků.
Podobně jako Box se paměť alokuje na heap,
ale oproti Boxu tato paměť může být bezpečné sdílena mezi vlákny programu.
[@smart_pointers_devto; @smart_pointers_codecamp; @smart_pointers_medium]

```{.rust .linenos}
use std::sync::Arc;

fn main() {
    let sdilena_hodnota = Arc::new("Sdílený řetězec".to_string());

    let sdilena_hodnota_pro_vlakno1 = Arc::clone(&sdilena_hodnota);
    let vlakno1 = std::thread::spawn(move || {
        println!("{}", *sdilena_hodnota_pro_vlakno1);
    });

    let sdilena_hodnota_pro_vlakno2 = Arc::clone(&sdilena_hodnota);
    let vlakno2 = std::thread::spawn(move || {
        println!("{}", *sdilena_hodnota_pro_vlakno2);
    });

    println!("{}", *sdilena_hodnota);
    vlakno1.join().unwrap();
    vlakno2.join().unwrap();
}
```

: Příklad použití smart pointeru `Arc<T>` {#lst:arc_example}

### Mutex\<T\> {#sec:mutex}

Mutex se používá pro sdílená data,
která je třeba bezpečně upravovat ve více vláknech.
Každé vlákno může zamknout tuto sdílenou hodnotu.
Zamknutím sdílené hodnoty a držením zámku vlákno zabraňuje
ostatním vláknům v zamknutí a upravě sdílené hodnoty.
[@smart_pointers_devto; @smart_pointers_codecamp; @smart_pointers_medium]

Ostatní vlákna mohou zamknout sdílenou hodnotu jen po tom, co vlákno,
které drží zámek, odemkne sdílenou hodnotu.
Odemknutí sdílené hodnoty nastane, když zámek opustí rozsah bloku či funkce,
nebo když uživatel zámek odemkne ručně.
[@smart_pointers_devto; @smart_pointers_codecamp; @smart_pointers_medium]

```{.rust .linenos}
use std::sync::Mutex;

fn main() {
    let sdilena_hodnota = Mutex::new(0u8);

    {
        // získání zámku pro hodnotu
        let mut guard = sdilena_hodnota.lock().unwrap();
        // dereference zámku na měnitelnou referenci
        // a přidání 1 k existující hodnotě
        *guard += 1;
        // zámek je na konci tohoto bloku odemčen
    }

    {
        // získání zámku pro hodnotu
        let mut guard = sdilena_hodnota.lock().unwrap();
        // dereference zámku na měnitelnou referenci
        // a přidání 25 k existující hodnotě
        *guard += 25;
        // zámek je odemčen zde ručně
        drop(guard);
        // tento blok poté může pokračovat dále,
        // aniž by zbytečně držel zámek
    }

    let guard = sdilena_hodnota.lock().unwrap();
    assert_eq!(*guard, 26);
}
```

: Příklad použití smart pointeru `Mutex<T>` {#lst:mutex_example}

### RwLock\<T\> {#sec:rwlock}

RwLock je zámek používaný pro sdílená data.
Tento zámek umožňuje držet libovolní počet referencí pro čtení sdílené hodnoty,
nebo maximálně jednu měnitelnou referenci pro úpravu sdílené hodnoty.
[@smart_pointers_devto; @smart_pointers_codecamp; @smart_pointers_medium]

Ve srovnání Mutex nerozlišuje mezi čtenáři a zapisovateli,
kteří zámek získávají a blokuje tak všechna vlákna čekající na uvolnění zámku.
RwLock umožňuje libovolnému počtu čtenářů získat zámek, pokud zámek již nedrží zapisovatel.
[@smart_pointers_devto; @smart_pointers_codecamp; @smart_pointers_medium]

```{.rust .linenos}
use std::sync::RwLock;

fn main() {
    let sdilena_hodnota = RwLock::new(5u8);

    {
        // získání zámků pro čtení
        let guard1 = sdilena_hodnota.read().unwrap();
        let guard2 = sdilena_hodnota.read().unwrap();
        let guard3 = sdilena_hodnota.read().unwrap();
        // dereference zámků na reference
        // a kontrola, že je součet správný
        assert_eq!(*guard1 + *guard2 + *guard3, 15);
        // zámky jsou na konci tohoto bloku odemčeny
    }

    {
        // získání zámku pro zápis
        let mut guard = sdilena_hodnota.write().unwrap();
        // dereference zámku na měnitelnou referenci
        // a přidání 25 k existující hodnotě
        *guard += 25;
        // zámek je odemčen zde ručně
        drop(guard);
        // tento blok poté může pokračovat dále,
        // aniž by zbytečně držel zámek
        // a blokoval čtenáře či zapisovatele
    }

    let guard = sdilena_hodnota.read().unwrap();
    assert_eq!(*guard, 30);
}
```

: Příklad použití smart pointeru `RwLock<T>` {#lst:rwlock_example}

