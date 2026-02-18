
## Definice builderu

```{.rust .linenos}
pub struct Builder<Input, Output, Error, Context, NodeTypes = (), NodeIOETypes = ()>
where
    Input: Send + Clone, Error: Send, Context: Fork + Join + Send,
{
    ..
    nodes: NodeTypes,
}

impl_debug_for_builder!("ParallelFlow", Builder, Input: Send + Clone, Error: Send, Context: Fork + Join + Send);
```

: Implementace toku `ParallelFlow` - definice builderu {#lst:parallel_flow_builder_def_impl}

Definice builderu má stejnou základní strukturu,
jako builder vytvořený makrem `define_builder`,
ale liší se v požadavcích na uzly vkládané do builderu
a v konečném sestavení toku.

Implementace metody `add_node` je rozdělena do dvou případů,
metoda pro první uzel a metoda pro ostatní uzly,
ale oba tyto případy dělají funkcionálně to samé.
Toto rozdělení je nutno pro kompatibilitu s traity `ChainDebug` a `ChainDescribe`,
které očekávají specifickou strukturu tuple listu.
Dále bylo toto rozdělení ponecháno proto,
aby bylo možno implementovat nové traity jen pro jeden typ tuple listu.

Implementace metody `add_node` zajišťuje,
že vstup do toku lze převést na vstup vkládaného uzlu
a chyba z vkládaného uzlu lze převést na chybu toku.

Implementace metody `build`, bere nějakou strukturu implementující trait `Joiner` a zajišťuje,
že vstup "joineru" je stejný s výstupem všech uzlů, a že výstup "joineru" je stejný jako výstup toku.

Implementace metody `build` se nachází v přílohách ([@lst:parallel_flow_builder_build_def_impl]).
Metodu `build` lze volat pouze po vložení prvního uzlu do builderu.
Tímto se zajistí, že konečný tok není prázdný.

