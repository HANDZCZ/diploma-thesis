
## Definice builderu

V uvedených kódech lze vidět jak jsou definovány požadavky na vkládané uzly
a jak se změní datový typ builderu po zavolání metod `add_node`.
V kódu metody `build` je poté vidět jak je konečný tok sestaven z builderu.

```{.rust .linenos}
pub struct Builder<Input, Output, Error, Context, NodeTypes = (), NodeIOETypes = ()>
where
    Input: Send, Error: Send, Context: Send,
{
    #[expect(clippy::type_complexity)]
    _ioec: PhantomData<fn() -> (Input, Output, Error, Context)>,
    _nodes_io: PhantomData<fn() -> NodeIOETypes>,
    nodes: NodeTypes,
}

impl_debug_for_builder!(
    "SequentialFlow",
    Builder,
    Input: Send, Error: Send, Context: Send
);
```

: Implementace toku `SequentialFlow` - definice builderu {#lst:sequential_flow_builder_def_impl}

Definice builderu má stejnou základní strukturu,
jako builder vytvořený makrem `define_builder`,
ale liší se v požadavcích na uzly vkládané do builderu
a v konečném sestavení toku.

```{.rust .linenos}
impl<..> Builder<Input, Output, Error, Context, (), ()> where .. {
    pub fn add_node<NodeType, NodeInput, NodeOutput, NodeError>(self, node: NodeType) -> Builder<
        Input, Output, Error, Context,
        (NodeType,),
        ChainLink<(), NodeIOE<NodeInput, NodeOutput, NodeError>>,
    > where
        Input: Into<NodeInput>,
        NodeError: Into<Error>,
        NodeType: Node<NodeInput, NodeOutputStruct<NodeOutput>, NodeError, Context>,
        ..
    {
        Builder { ..,  nodes: (node,) }
    }
}
```

: Implementace toku `SequentialFlow` - definice builderu - metoda `add_node` pro první uzel {#lst:sequential_flow_builder_fadd_node_def_impl}

Implementace metody `add_node` pro první uzel musí zajistit,
že vstup do toku lze převést na vstup do prvního uzlu
a chyba z uzlu lze převést na chybu toku.

V kódu výše si lze všimnout toho, že tato metoda je implementována
jen pro specifický typ builderu, který má generické parametry `NodeTypes`
a `NodeIOETypes` nastaveny na unit typ, což je výchozí typ.
Definice výchozích typů je vidět v definici builder structu ([@lst:sequential_flow_builder_def_impl]).
Tento typ buidleru lze vytvořit jen pomocí funkcí `new` a `default`,
a nelze ho získat jiným způsobem.
Tímto se zajistí, že tato verze metody `add_node`
je volána pouze jednou pro první uzen na novém builderu.

```{.rust .linenos}
impl<..> Builder<
    Input, Output, Error, Context, NodeTypes,
    ChainLink<OtherNodeIOETypes, NodeIOE<LastNodeInType, LastNodeOutType, LastNodeErrType>>,
> where .. {
    pub fn add_node<NodeType, NodeInput, NodeOutput, NodeError>(self, node: NodeType) -> Builder<
        Input, Output, Error, Context,
        ChainLink<NodeTypes, NodeType>,
        ChainLink<
            ChainLink<OtherNodeIOETypes, NodeIOE<LastNodeInType, LastNodeOutType, LastNodeErrType>>,
            NodeIOE<NodeInput, NodeOutput, NodeError>,
        >,
    > where
        LastNodeOutType: Into<NodeInput>,
        NodeError: Into<Error>,
        NodeType: Node<NodeInput, NodeOutputStruct<NodeOutput>, NodeError, Context>,
        ..
    {
        Builder { .., nodes: (self.nodes, node) }
    }

    pub fn build(self) -> SequentialFlow<
        Input, Output, Error, Context, NodeTypes,
        ChainLink<OtherNodeIOETypes, NodeIOE<LastNodeInType, LastNodeOutType, LastNodeErrType>>,
    > where
        LastNodeOutType: Into<Output>,
    {
        Flow { .., nodes: Arc::new(self.nodes) }
    }
}
```

: Implementace toku `SequentialFlow` - definice builderu - metoda `add_node`, pro ostatní uzly, a metoda `build` {#lst:sequential_flow_builder_oadd_node_build_def_impl}

Implementace metody `add_node`, pro ostatní uzly, zajišťuje,
že výstup předchozího uzlu lze převést na vstup vkládaného uzlu
a chyba z vkládaného uzlu lze převést na chybu toku.

Implementace metody `build` zajišťuje,
že výstup z posledního uzlu lze převést na výstup z toku.
V této metodě není nutno kontrolovat zda chyba posledního uzlu lze převést
na chybu toku, protože tato podmínka je již řešena metodami `add_node`.

V kódu výše lze vidět, že metod `add_node`, pro ostatní uzly,
a metoda `build` lze volat pouze po vložení prvního uzlu do builderu.
Tímto se zajistí, že konečný tok není prázdný a umožňuje definovat
jiné požadavky na uzly podle jejich pozice v toku.

