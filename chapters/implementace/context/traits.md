
# Základní traity pro práci s kontextem

Tato kapitola obsahuje základní traity,
které by měly být implementovány pro jakýkoliv datový typ,
který lze použít jako kontext v uzlu.
Tyto traity slouží jako základ pro vytváření komplexnějších toků.

## Trait Fork {#sec:trait_fork}

```{.rust .linenos}
pub trait Fork {
    #[must_use]
    fn fork(&self) -> Self;
}
```

: Implementace traitu `Fork` {#lst:fork_trait_impl}

Trait `Fork` slouží k vytvoření nové instance kontextu z již existující instance,
která byla uzlu předána.
Hlavní využití tohoto traitu je vytvoření na sobě nezávislých instancí kontextu, které
poté mohou být použity ve větvích toků.
Tento trait umožňuje například "fallback vodopády,"
kde pokud by nějaká větev toku selhala "soft chybou,"
tak tok může pokračovat další větví vytvořením nové instance kontextu z originálu.
Tímto se zajistí, že větev co selhala nezpůsobí selhání dalších větví tím,
že nějakým nevratným způsobem upravila kontext.

## Trait Update {#sec:trait_update}

```{.rust .linenos}
pub trait Update {
    fn update_from(&mut self, other: Self);
}
```

: Implementace traitu `Update` {#lst:update_trait_impl}

Trait `Update` komplementuje trait `Fork` tím,
že umožňuje aktualizaci nějaké instance kontextu z jiné instance kontextu stejného typu.
Díky tomuto traitu je možno v tocích,
které například vrací výsledek první úspěšné větve,
aktualizovat originální kontext z kontextu vytvořeného pomocí `Fork` traitu. 

## Trait Join {#sec:trait_join}

```{.rust .linenos}
pub trait Join: Sized {
    fn join(&mut self, others: Box<[Self]>);
}
```

: Implementace traitu `Join` {#lst:join_trait_impl}

Trait `Join` komplementuje trait `Fork` tím,
že umožňuje aktualizaci jedné instance kontextu z mnoha instancí kontextu stejného typu.
Tento trait umožňuje tokům,
které například vrací výsledek všech úspěšných či neúspěšných větví,
sloučit kontexty vytvořené pomocí `Fork` traitu do originálního kontextu. 

Zde by samozřejmě šlo použít trait `Update` vícekrát, ale tento přístup by způsobil,
že sloučení kontextů by bylo závislé na pořadí.
Pokud by tento přístup byl použit, tak by jistě nastal případ,
kdy by několik větví vkládalo nějaká data se stejným klíčem do úložiště
a při slučování by v tomto případě v úložišti s největší pravděpodobností zůstaly ty data,
která byla sloučena jako poslední.
Mnohem lepší přístup je rozlišit tyto případy
a řešení jak bude slučování probíhat v těchto případech ponechat na uživatele.

# Práce se synchronními a asynchronními úlohami

V této kapitole jsou definovány a popsány traity potřebné pro vytváření
a práci se synchronními a asynchronními úlohami.
Tyto traity slouží hlavně k abstrakci konkrétních implementací v asynchronních runtimech ([@sec:async_runtime]).

## Trait Task

```{.rust .linenos}
pub trait Task<T>: Future<Output = T> {
    fn is_finished(&self) -> bool;
    fn cancel(self);
}
```

: Implementace traitu `Task` {#lst:task_trait_impl}

Trait `Task` je nástavba nad traitem `Future` ([@sec:future_trait]),
která přidává dvě velmi důležité metody a slouží k reprezentaci vzniklé asynchronní úlohy.
Tento trait hlavně slouží jako abstrakce nad konkrétními implementacemi asynchronních úloh
v různých asynchronní runtimech ([@sec:async_runtime]).
Metoda `is_finished` vrací zda úloha byla dokončena,
bez ohledu na to jestli úspěšně či neúspěšně.
Metoda `cancel` konzumuje instanci úlohy a signalizuje úloze,
že byla zrušena.
V případě signalizace zrušení úlohy by úloha měla přerušit jakékoli právě běžící úkony a zastavit se.

## Trait SpawnAsync {#sec:trait_spawn_async}

```{.rust .linenos}
pub trait SpawnAsync {
    fn spawn<F>(fut: F) -> impl Task<F::Output>
    where
        F: Future + Send + 'static,
        F::Output: Send + 'static;
}
```

: Implementace traitu `SpawnAsync` {#lst:spawn_async_trait_impl}

Trait `SpawnAsync` poskytuje rozhraní pro vytváření asynchronních úloh.
Tento trait je abstrakcí nad různými asynchronními runtimy ([@sec:async_runtime])
pro vytváření a práci s asynchronními úlohami.
Obsahuje pouze jednu metodu `spawn`, která bere asynchronní úlohu
a vrací nějaký datový typ implementující trait `Task`.
Tato asynchronní úloha musí být `Send + 'static`,
aby bylo možno tuto úlohu poslat do jiných vláken pro zpracování.

## Trait SpawnSync

```{.rust .linenos}
pub trait SpawnSync {
    fn spawn_blocking<F, O>(func: F) -> impl Task<O>
    where
        F: Fn() -> O + Send + 'static,
        O: Send + 'static;
}
```

: Implementace traitu `SpawnSync` {#lst:spawn_sync_trait_impl}

Trait `SpawnSync` poskytuje rozhraní pro vytváření synchronních úloh.
Tento trait je synchronní verze `SpawnAsync` traitu
a poskytuje možnost vytváření potenciálně časově či výpočetně náročných úloh,
bez blokování asynchronních runtimu ([@sec:async_runtime]).
Stejně jako trait `SpawnAsync` obsahuje pouze jednu metodu se jménem `spawn_blocking`,
která bere synchronní úlohu a vrací nějaký datový typ implementující trait `Task`.
Pro tuto synchronní úlohu také platí, že musí být `Send + 'static`,
aby bylo možno tuto úlohu poslat do jiných vláken.

