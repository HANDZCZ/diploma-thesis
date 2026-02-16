
# Makro impl_node_output

Toto makro slouží k jednoduchému přidání implementace traitu `Node`,
která má úspěšný výstupní typ obalen v `NodeOutput` enumu.
Díky tomuto makru uživatel nemusí psát zbytečně opakující se kód.
Bere typ uzlu, vstupu, výstupu, chyby a možná dodatečná omezení pro generické typy
a pomocí těchto typů a omezení definuje novou implementaci `Node` traitu.

```{.rust .linenos}
use node_flow::{impl_node_output, node::{Node, NodeOutput}};

struct ExampleNode;

impl<Context: Send> Node<i32, i32, String, Context> for ExampleNode {
    async fn run(&mut self, input: i32, _context: &mut Context) -> Result<i32, String> {
        Ok(input + 1)
    }
}

// Přidá implementaci Node<i32, NodeOutput<i32>, String, _> pro ExampleNode.
impl_node_output!(ExampleNode, i32, i32, String);
```

: Příklad použití makra `impl_node_output` {#lst:impl_node_output_example}

# Makro node

```{.rust .linenos}
#[macro_export]
macro_rules! node {
    ($input:ty, !$output:ty, $error:ty, $context:ty) => {
        impl $crate::node::Node<$input, $output, $error, $context> + Clone + Send + Sync
    };
    ($input:ty, $output:ty, $error:ty, $context:ty) => {
        $crate::node!($input, !$crate::node::NodeOutput<$output>, $error, $context)
    };
}
```

: Implementace makra `node` {#lst:node_macro_impl}


Makro sloužící pro jednoduchou definici vstupního či výstupního typu, který implementuje `Node` trait.
Bere vstupní, výstupní, chybový a kontext typ pro uzel a vrací `impl Node<Vstup, NodeOutput<Výstup>, Error, Kontext> + Clone + Send + Sync`.
Typ výstupu může mít před sebou vykřičník a tím říká, že výstupní typ nemá být obalen do `NodeOutput` enumu.

```{.rust .linenos}
// Funkce vytvařející tok, který vrací nějaký typ implementující Node trait s vstupním typem u8, výstupním typem u64, chybovým typem String a generickým typem kontextu Context
fn build_flow<Context: Send>(..) -> node_flow::node!(u8, !u64, String, Context) {
    ..
}
```

: Příklad použití makra `impl_node_output` {#lst:impl_node_output_example}

