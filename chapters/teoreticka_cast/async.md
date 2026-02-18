
## Asynchronní programování

Asynchronní programování je efektivní přístup ke zlepšení výkonu systémů s vysokou zátěží,
jelikož umožňuje souběžné provádění úloh bez blokování provádění jiných úloh.
Na rozdíl od synchronního programování, kde jsou úlohy prováděny postupně,
asynchronní programování umožňuje systému zpracovávat více operací současně,
což vede k rychlejším odezvám a efektivnějšímu využití prostředků.
[@async_programming_techniques; @async_iot_embedded]

Ve srovnání se synchronním programováním nabízí asynchronní programování
lepší výkon v aplikacích závislých na I/O operacích,
protože umožňuje systému zpracovávat více operací,
a to bez nutnosti čekat na dokončení každé z nich.
U úloh náročných na výpočetní výkon však může být zlepšení výkonu méně patrné,
nebo může dojít ke zpomalení, protože úlohy je stále nutné zpracovávat postupně na jednom jádru procesoru.
[@async_programming_techniques; @async_iot_embedded]

![Porovnání asynchronního a synchronního zpracování [@async_picture]](../../pictures/sync_vs_async.png){#fig:async_comparison}

## Asynchronní programování v Rustu

Asynchronní programování v Rustu je provedeno jinak než v ostatních jazycích.
Hlavním rozdílem je, že standardní knihovna neposkytuje žádný runtime pro asynchronní úlohy
a asynchronní úlohy nejsou okamžitě spuštěny po vytvoření, ale pouze po zavolání `await`.
Standardní knihovna poskytuje pouze základní traity
a struktury pro vytvoření runtimů a asynchronních úloh.
Díky tomuto přístupu si uživatel může vybrat jaký runtime bude používat
a kdy budou asynchronní úlohy spuštěny.

### Enum Poll {#sec:enum_poll}

```{.rust .linenos}
pub enum Poll<T> {
    Ready(T),
    Pending,
}
```

: Definice enumu `Poll` ve standardní knihovně [@rust_docs_poll_enum] {#lst:poll_enum_def}

Enum `Poll` vyjadřuje zda asynchronní úloha skončila s nějakým výsledkem
nebo zda je potřeba na tuto úlohu ještě čekat a vzbudit ji později.
[@rust_docs_poll_enum; @async_in_rust_book]

### Trait Future {#sec:future_trait}

```{.rust .linenos}
pub trait Future {
    type Output;

    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output>;
}
```

: Definice trait `Future` ve standardní knihovně [@rust_docs_future_trait] {#lst:future_trait_def}

Trait `Future` je základem pro asynchronní programování v Rustu.
Reprezentuje asynchronní úlohu, která vrací nějakou výstupní hodnotu.
[@rust_docs_future_trait; @async_in_rust_book]

Hlavní metodou tohoto traitu je metoda `poll`,
která se snaží co nejvíce přiblížit asynchronní úlohu k jejímu dokončení.
Tato metoda neblokuje, pokud asynchronní úloha ještě není dokončena,
ale místo toho je tato úloha naplánována k probuzení.
Kontext předaný metodě `poll` poskytuje takzvaný `Waker`,
sloužící k signalizaci, že asynchronní úloha je připravena k probuzení.
[@rust_docs_future_trait; @async_in_rust_book]

### Runtime {#sec:async_runtime}

Runtime je systém, který umožňuje uživatelům spouštět asynchronní kód
a má na starost správu a vykonávání asynchronních úloh.
Kvůli tomu, že obvykle existuje více asynchronních úloh než je k dispozici jader procesoru,
tak runtime plánuje jaké úlohy budou spuštěny a jaké úlohy budou pozastaveny.
Je tedy vyžadováno, aby runtime spolupracoval s operačním systémem
a bylo tak možné efektivně zpracovat asynchronní I/O a časovače.
Obvykle se runtime skládá z reaktoru (nebo event loopu),
který komunikuje s operačním systémem,
a plánovače, který rozhoduje o tom, kdy a kde jsou úlohy prováděny.
[@async_in_rust_book]

### Syntaxe async/await a asynchronních úloh {#sec:async_await_syntax}

V Rustu je možno definovat asynchronní úlohu či funkci více způsoby.
Definice asynchronní úlohy může obsahovat klíčové slovo `async`
nebo vracet nějaký datový type implementující `Futute` trait.
Klíčové slovo `async` je možno si představit,
jako jednoduchý proces obalení vnitřního kódu bloku či funkce do nové asynchronní úlohy.

```{.rust .linenos}
// vytvoření asynchronního bloku pomocí klíčového slova, tento asynchronní blok může obsahovat více čekání asynchronní úlohy, protože je sám o sobě asynchronní úlohou
let blok1 = async {
    ..
    /*nějaká asynchronní úloha*/.await;
    ..
};

// vytvoření bloku bez klíčového slova, tento blok je synchronní a vrací právě jednu asynchronní úlohu a nemůže v něm být použito asynchronní volání
// vše co je obsaženo v tomto bloku bude spuštěno ihned synchronně bez čekání, čekat lze jen na vrácenou asynchronní úlohu
let blok2 = {
    ..
    /*nějaká asynchronní úloha*/
};

// spuštění a čekání na dokončení asynchronních úloh postupně
blok1.await;
blok2.await;
```

: Příklad definice bloku vracejícího asynchronní úlohu {#lst:async_block_example}

```{.rust .linenos}
// vytvoření asynchronní funkce pomocí klíčového slova
async fn func1() -> f32 {
    /*nějaká asynchronní úloha*/.await;
    return 0.1;
}

// vytvoření asynchronní funkce bez klíčového slova
fn func2() -> impl Future<Output = f32> {
    // zde lze využít toho, že volání této funkce je synchronní a vrací asynchronní úlohu, díky tomu lze provést nenáročné synchronní úkony a poté vrátit asynchronní úlohu, která závisí na těchto úkonech
    // vrácená asynchronní úloha může být jakákoli například i asynchronní blok
    return /*nějaká asynchronní úloha vracející datový typ f32*/;
    // nebo třeba
    async {
        return 0.1;
    }
}

// vytvoření anonymní asynchronní funkce přiřazené do proměnné func3
let func3 = async || {
    /*nějaká asynchronní úloha*/.await;
    return 0.1;
};

// spuštění a čekání na dokončení asynchronních úloh postupně
func1().await;
func2().await;
func3().await;
```

: Příklad definice asynchronní funkce {#lst:async_function_example}

Dále je také možno pro jakýkoli datový typ implementovat trait `Future`
a tím umožnit použití tohoto datového typu jako asynchronní úlohu.

```{.rust .linenos}
// definice vlastního datového typu
struct MojeAsynchronniUloha {
    hodnota: u8,
}

// implementace traitu Future
impl Future for MojeAsynchronniUloha {
    // definice výstupního typu asynchronní úlohy
    type Output = u8;

    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
        // zde je poté definováno co má asynchronní úloha dělat
        // v tomto případě jen vrací uloženou hodnotu
        return Poll::Ready(self.hodnota);
    }
}

// vytvoření instance
let instance = MojeAsynchronniUloha {
    hodnota: 26,
};
// spuštění a čekání na dokončení asynchronní úlohy
let res = instance.await;
// kontrola výsledku
assert_eq!(res, instance.hodnota);
```

: Příklad implementace traitu `Future` pro datový typ {#lst:async_function_example}

