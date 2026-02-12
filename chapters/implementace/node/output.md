
# Enum NodeOutput {#sec:enum_node_output}

```{.rust .linenos}
#[derive(Debug, PartialEq, Eq)]
pub enum NodeOutput<T> {
    SoftFail,
    Ok(T),
}

impl<T> NodeOutput<T> {
    pub fn ok(self) -> Option<T> { .. }
    pub fn ok_or<E>(self, err: E) -> Result<T, E> { .. }
    pub fn ok_or_else<E>(self, err: impl Fn() -> E) -> Result<T, E> { .. }
}
```

: Implementace enumu `NodeOutput` {#lst:node_output_impl}

Enum `NodeOutput` slouží k signalizaci takzvané "soft chyby."
Tato chyba vyjadřuje, že operace selhala, ale ne katastrofálně.
Když nějaký uzel signalizuje tuto chybu, znamená to,
že tok může pokračovat dále (pokud je jak), jako kdyby se nic nedělo.
Uzel může signalizovat tuto chybu například při nesplnění vstupních požadavků,
kde vstup neodpovídá přesně požadavkům tohoto uzlu, ale může existovat nějaký další uzel,
který s těmito vstupními daty bude spokojen a dokáže je zpracovat.
Díky tomuto enumu lze definovat takzvané "fallback vodopády."
Tyto vodopády umožňují pokračovat další větví toku, když předchozí větev vrátí `SoftFail`.

Pro tento enum jsou také implementovány pomocné metody `ok`, `ok_or`
a `ok_or_else` pro jednoduchou konverzi do typů `Option` a `Result`.
Tyto metody jsou inspirovány metodami nacházejícími se ve standardní knihovně Rustu.

