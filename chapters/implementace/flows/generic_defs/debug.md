
## Makra impl_debug_for_builder a impl_debug_for_flow

```{.rust .linenos}
macro_rules! impl_debug_for_builder {
    ($flow_name:expr, $builder:tt $(,$param:ident: $bound0:ident $(+$bound:ident)*)*) => { .. };
}
macro_rules! impl_debug_for_flow {
    ($flow_name:expr, $flow_type:tt $(,$param:ident: $bound0:ident $(+$bound:ident)*)*) => { .. };
}
```

: Implementace makra `impl_debug_for_builder` {#lst:macro_impl_debug_for_builder_impl}

Makra `impl_debug_for_builder` a `impl_debug_for_flow`
slouží pro jednoduchou implementaci `Debug` traitů
pro builder a tok.
Berou název toku, datový typ pro který má být `Debug` implementován
a dodatečné nepovinné omezení typů pomocí traitů.

Řetězec pro tisk je vytvořen pomocí metody `debug_struct`,
která je definována standardní knihovnou,
jejíž parametr je název datového typu struktury.
Do této struktury jsou přidány atributy pomocí metody `field`.
Hodnota pro atribut "nodes," který obsahuje uzly toku či builderu,
je získána pomocí traitu `ChainDebug` ([@sec:chain_debug]).

