
# Základní traity pro práci s kontextem

## Trait Fork

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

## Trait Update

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

## Trait Join

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

