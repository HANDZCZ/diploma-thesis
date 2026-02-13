
## Makra impl_debug_for_builder a impl_debug_for_flow

```{.rust .linenos}
macro_rules! impl_debug_for_builder {
    ($flow_name:expr, $builder:tt $(,$param:ident: $bound0:ident $(+$bound:ident)*)*) => {
        impl<Input, Output, Error, Context, NodeTypes, NodeIOETypes> std::fmt::Debug
            for $builder<Input, Output, Error, Context, NodeTypes, NodeIOETypes>
        where
            NodeTypes: $crate::flows::chain_debug::ChainDebug,
            $($param: $bound0 $(+$bound)*,)*
        {
            fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
                f.debug_struct(&format!("{}Builder", $flow_name))
                    .field("nodes", &self.nodes.as_list())
                    .finish_non_exhaustive()
            }
        }
    };
}

pub(crate) use impl_debug_for_builder;
```

: Implementace makra `impl_debug_for_builder` {#lst:macro_impl_debug_for_builder_impl}

Makra `impl_debug_for_builder` a `impl_debug_for_flow`
slouží pro jednoduchou implementaci `Debug` traitů
pro builder a tok.
Berou název toku, datový typ pro který má být `Debug` implementován
a dodatečné nepovinné omezení typů pomocí traitů.
V těle metody volají pomocnou metodu `debug_struct`,
která je definována standardní knihovnou pro struct `Formatter`,
jejíž parametr je název datového typu a na vrácené hodnotě volají
metodu `field`, která přiděluje structu atribut se jménem "nodes"
a hodnotu získanou z `ChainDebug` traitu ([@sec:chain_debug]).
Nakonec už je jen volána metoda `finish_non_exhaustive`,
která říká, že skončila definice, toho co má být vytištěno,
ale nebyly uvedeny všechny atributy tištěného structu.

Implementace makra `impl_debug_for_flow` není zde uvedena,
protože je skoro totožná s makrem `impl_debug_for_builder`.
Liší se akorát v tom, že místo parametru `builder` přijímá parametr `flow_type`
a nastavuje jméno structu jen na parametr `flow_name` bez `Builder` přípony.

