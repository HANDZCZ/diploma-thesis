
## Definice builderu

V uvedených kódech lze vidět jak jsou definovány požadavky na vkládané uzly
a jak se změní datový typ builderu po zavolání metod `add_node`.
V kódu metody `build` je poté vidět jak je konečný tok sestaven z builderu.

```{.rust .linenos}
pub struct Builder<Input, Output, Error, Context, NodeTypes = (), NodeIOETypes = ()>
where
    Input: Send, Error: Send, Context: Send,
{
    ..,
    nodes: NodeTypes
}

impl_debug_for_builder!("SequentialFlow", Builder, Input: Send, Error: Send, Context: Send);
```

: Implementace toku `SequentialFlow` - definice builderu {#lst:sequential_flow_builder_def_impl}

Definice builderu má stejnou základní strukturu,
jako builder vytvořený makrem `define_builder`,
ale liší se v požadavcích na uzly vkládané do builderu
a v konečném sestavení toku.

Implementace metody `add_node` je rozdělena do dvou případů.
Prvním je, že se vkládá první uzel do toku je nutno zajistit,
že vstup do toku lze převést na vstup do prvního uzlu
a chyba z uzlu lze převést na chybu toku.
Tato verze metody `add_node` je implementována
jen pro specifický typ builderu, který má generické parametry `NodeTypes`
a `NodeIOETypes` nastaveny na unit typ, což je výchozí typ.
Definice výchozích typů je vidět v definici builder structu ([@lst:sequential_flow_builder_def_impl]).
Tento typ buidleru lze vytvořit jen pomocí funkcí `new` a `default`,
a nelze ho získat jiným způsobem.
Tímto se zajistí, že tato verze metody `add_node`
je volána pouze jednou pro první uzen na novém builderu.

Implementace metody `add_node`, pro ostatní uzly, zajišťuje,
že výstup předchozího uzlu lze převést na vstup vkládaného uzlu
a chyba z vkládaného uzlu lze převést na chybu toku.

Implementace metody `build` zajišťuje,
že výstup z posledního uzlu lze převést na výstup z toku.
V této metodě není nutno kontrolovat zda chyba posledního uzlu lze převést
na chybu toku, protože tato podmínka je již řešena metodami `add_node`.

Implementace metod `add_node`, pro ostatní uzly,
a `build` se nachází v přílohách ([@lst:sequential_flow_builder_oadd_node_build_def_impl]).
Tyto metody lze volat pouze po vložení prvního uzlu do builderu.
Tímto se zajistí, že konečný tok není prázdný a umožňuje definovat
jiné požadavky na uzly podle jejich pozice v toku.

