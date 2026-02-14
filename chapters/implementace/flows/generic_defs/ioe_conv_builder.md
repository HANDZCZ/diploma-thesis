
## Makro define_builder

```{.rust .linenos}
macro_rules! define_builder {
  ($flow_type:ident $(,>$global_param:ident: $global_bound0:ident $(+$global_bound:ident)*)* $(,#$fn_param:ident: $fn_bound0:ident $(+$fn_bound:ident)*)*) => {
    pub struct Builder<Input, Output, Error, Context, NodeTypes = (), NodeIOETypes = ()>
    where
      $($global_param: $global_bound0 $(+$global_bound)*,)*
    {
        _ioec: std::marker::PhantomData<fn() -> (Input, Output, Error, Context)>,
        _nodes_io: std::marker::PhantomData<fn() -> NodeIOETypes>,
        nodes: NodeTypes,
    }

    $crate::flows::generic_defs::debug::impl_debug_for_builder!(
        stringify!($flow_type),
        Builder
        $(,$global_param: $global_bound0 $(+$global_bound)*)*
    );
    ..
  };
}
pub(crate) use define_builder;
```

: Implementace makra `define_builder` - definice structu a implementace traitu `Debug` {#lst:macro_define_builder_struct_def_impl}

Makro `define_builder` slouží k usnadnění definice builderu pro toky,
které mají stejné požadavky na uzly.
Toto makro bere název datového typu toku, pro který se má builder definovat,
nepovinné omezení typů pomocí traitů pro definici builder typu
a pro definici požadavků na uzly.

Požadavky, které jsou kladeny na uzly vkládané do builderu vytvořeného tímto makrem, zní takto:

1. Datový typ vstupu toku musí být převoditelný na datový typ vstupu vkládaného uzlu.
1. Datový typ výstupu vkládaného uzlu musí být převoditelný na výstupní datový typ toku.
1. Datový typ chyby vkládaného uzlu musí být převoditelný na chybový datový typ toku.

V kódu výše lze vidět strukturu definovaného builderu
a jak je pro tento builder implementován trait `Debug` za použití pomocného makra.
Pro definovaný builder je také implementován trait `Default`,
který jen volá funkci `new` a vrací její hodnotu.
Funkce `new` je také definována pro builder a jediné co dělá je,
že vrací novou instanci builderu, kde hodnota atributu `nodes` je unit typ - `()`.

```{.rust .linenos}
impl<Input, Output, Error, Context, NodeTypes, LastNodeIOETypes, OtherNodeIOETypes>
    Builder<Input, Output, Error, Context, NodeTypes, $crate::flows::ChainLink<OtherNodeIOETypes, LastNodeIOETypes>>
where
    $($global_param: $global_bound0 $(+$global_bound)*,)*
{
    pub fn add_node<NodeType, NodeInput, NodeOutput, NodeError>(
        self,
        node: NodeType,
    ) -> Builder<Input, Output, Error, Context,
        $crate::flows::ChainLink<NodeTypes, NodeType>,
        $crate::flows::ChainLink<
            $crate::flows::ChainLink<OtherNodeIOETypes, LastNodeIOETypes>,
            $crate::flows::NodeIOE<NodeInput, NodeOutput, NodeError>,
        >,
    >
    where
        Input: Into<NodeInput>, NodeOutput: Into<Output>, NodeError: Into<Error>,
        NodeType: $crate::node::Node<NodeInput, $crate::node::NodeOutput<NodeOutput>, NodeError, Context>,
        $($fn_param: $fn_bound0 $(+$fn_bound)*,)*
    {
        Builder {
            _ioec: std::marker::PhantomData,
            _nodes_io: std::marker::PhantomData,
            nodes: (self.nodes, node),
        }
    }

    pub fn build(self) -> $flow_type<..> {
        $flow_type {
            _ioec: std::marker::PhantomData,
            _nodes_io: std::marker::PhantomData,
            nodes: std::sync::Arc::new(self.nodes),
        }
    }
}
```

: Implementace makra `define_builder` - implementace `add_node` a `build` metod {#lst:macro_define_builder_methods_impl}

Builder definovaný tímto makrem dále obsahuje metody pro přidání uzlu a sestavení konečného toku.
Metody `add_node` a `build` jsou definovány pro builder splňující základní omezení pro builder,
definovány pomocí vstupů s předponou `global_` a značením `>`.
Metoda `add_node` navíc vyžaduje po vkládaném uzlu,
aby splňoval požadavky na něj kladeny builderem spolu s dodatečnými požadavky,
definovanými pomocí vstupů s předponou `fn_` a značením `#`.

Kód výše ukazuje jak probíhá práce s typový systémem,
kde builder s uzly `NodeTypes` a jejich vstupními, výstupními a chybovými datovými typy
je po volání metody `add_node` převeden na builder s přidaným uzlem `NodeType`
a jeho vstupním, výstupním a chybovým datovým typem.
V kódu není uvedena verze metody `add_node`,
která se stará o přidání prvního uzlu do toku a řeší požadavky na první uzel,
protože je skoro totožná uvedené verzi a dělá prakticky to samé.

