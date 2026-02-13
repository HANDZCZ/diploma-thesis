
## Makro define_flow

```{.rust .linenos}
macro_rules! define_flow {
    ..
    ($flow_name:ident, $builder:ident, $chain_run:ident, |$self:ident| $describe_code:block $(,$param:ident: $bound0:ident $(+$bound:ident)*)* $(,)? $(#[doc = $doc:expr])*) => {
        $(#[doc = $doc])*
        pub struct $flow_name<Input, Output, Error, Context, NodeTypes = (), NodeIOETypes = ()> {
            pub(super) _ioec: std::marker::PhantomData<fn() -> (Input, Output, Error, Context)>,
            pub(super) _nodes_io: std::marker::PhantomData<fn() -> NodeIOETypes>,
            pub(super) nodes: std::sync::Arc<NodeTypes>,
        }

        $crate::flows::generic_defs::debug::impl_debug_for_flow!(
            stringify!($flow_name),
            $flow_name
        );

        impl<Input, Output, Error, Context, NodeTypes, NodeIOETypes> Clone for $flow_name<Input, Output, Error, Context, NodeTypes, NodeIOETypes> { .. }
        ..
    };
}

pub(crate) use define_flow;
```

: Implementace makra `define_flow` - definice structu a implementace traitů `Debug` a `Clone` {#lst:macro_define_flow_struct_def_impl}

Makro `define_flow` slouží k usnadnění definice toků,
které mají stejnou strukturu.
Toto makro bere název datového typu toku, který se má definovat,
datový typ builderu pro tento tok,
datový typ takzvaného "chainrunu," který definuje běh toku,
definici těla funkce pro metodu `describe` z traitu `Node` ([@sec:trait_node]),
dodatečné nepovinné omezení typů pomocí traitů při definici `builder` metody
a nepovinnou dokumentaci pro definovaný tok.

V kódu výše lze vidět strukturu definovaného toku
a jak jsou pro tok implementovány traity `Debug`, pomocí pomocného makra,
a `Clone`, jehož implementace je triviální,
protože dochází jen k naklonování atomické reference ([@sec:arc]).

```{.rust .linenos}
impl<Input, Output, Error, Context> $flow_name<Input, Output, Error, Context> where $($param: $bound0 $(+$bound)*,)* {
    #[doc = concat!("Creates a new [`", stringify!($builder), "`] for constructing [`", stringify!($flow_name), "`].")]
    ///
    #[doc = concat!("See also [`", stringify!($flow_name), "`].")]
    ///
    /// # Examples
    /// ```
    /// # use node_flow::context::{Fork, Update};
    /// # struct Ctx;
    /// # impl Fork for Ctx { fn fork(&self) -> Self { Self } }
    /// # impl Update for Ctx { fn update_from(&mut self, other: Self) {} }
    /// #
    #[doc = concat!("use node_flow::flows::", stringify!($flow_name), ";")]
    ///
    #[doc = concat!("let builder = ", stringify!($flow_name), "::<u8, u16, (), Ctx>::builder();")]
    /// ```
    #[must_use]
    pub fn builder() -> $builder<Input, Output, Error, Context> {
        $builder::new()
    }
}
```

: Implementace makra `define_flow` - implementace `builder` funkce {#lst:macro_define_flow_builder_impl}

Pro každý definovaný tok tímto makrem je vytvořena funkce `builder`,
která vrací instanci builderu vytvořenou funkcí `new` implementovanou v builderu.
Implementace této funkce může být omezena pomocí dodatečných traitů,
tyto traity většinou pochází ze samotné implementace builderu.
Pro funkci `builder` je také automaticky vygenerována dokumentace s ukázkou použití.

```{.rust .linenos}
impl<Input, Output, Error, Context, NodeTypes, NodeIOETypes> $crate::node::Node<Input, $crate::node::NodeOutput<Output>, Error, Context> for $flow_name<Input, Output, Error, Context, NodeTypes, NodeIOETypes>
where
    NodeTypes: $chain_run<Input, $crate::flows::NodeResult<Output, Error>, Context, NodeIOETypes> + $crate::flows::chain_describe::ChainDescribe<Context, NodeIOETypes>,
{
    fn run(
        &mut self,
        input: Input,
        context: &mut Context,
    ) -> impl Future<Output = $crate::flows::NodeResult<Output, Error>> + Send {
        $chain_run::run(self.nodes.as_ref(), input, context)
    }

    fn describe(&$self) -> $crate::describe::Description {
        $describe_code
    }
}
```

: Implementace makra `define_flow` - implementace `builder` funkce {#lst:macro_define_flow_builder_impl}

Toto makro také implementuje trait `Node` ([@sec:trait_node]) pro každý tok co definuje.
Implementace metody `run` jen volá "chainrun,"
který musí být implementován pro tuple list uzlů v toku,
s parametry, které jsou do funkce poslány a vrací výstupní asynchronní úlohu.
Implementace metody `describe` je velice triviální, protože jediné co dělá je,
že do těla této funkce vloží kód, který byl poskytnut tomuto makru pro přesně tento účel.

