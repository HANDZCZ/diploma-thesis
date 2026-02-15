
# Tok SequentialFlow {#sec:sequential_flow}

Tok `SequentialFlow` spouští uzly postupně ve stejném pořadí,
jako při vkládání uzlů do builderu.
Funguje jako pipeline, kde výstup předchozího uzlu je použit jako vstup do dalšího uzlu.

Tok vrací zpracovanou vstupní hodnotu, pouze když všechny uzly úspěšně skončí.
V tomto případě je výstup z posledního uzlu vrácen jako výstup toku.
V ostatních případech výstup tohoto toku záleží na výstupu uzlů a zní takto:

1. Pokud uzel vrátí `NodeOutput::Ok`, tak je výstupní hodnota poslána do dalšího uzlu.
1. Pokud uzel vrátí `NodeOutput::SoftFail`, tak tok končí a vrací soft-fail.
1. Pokud uzel vrátí chybu, tak tok končí a vrací chybu.

## Definice toku

```{.rust .linenos}
define_flow!(
    SequentialFlow,
    ChainRunSequential,
    |self| {
        let node_count = <NodeTypes as ChainDescribe<Context, NodeIOETypes>>::COUNT;
        let mut node_descriptions = Vec::with_capacity(node_count);
        self.nodes.describe(&mut node_descriptions);

        let mut edges = Vec::with_capacity(node_count + 1);
        edges.push(Edge::flow_to_node(0));
        for i in 0..node_count - 1 {
            edges.push(Edge::node_to_node(i, i + 1));
        }
        edges.push(Edge::node_to_flow(node_count - 1));

        Description::new_flow(self, node_descriptions, edges).modify_name(remove_generics_from_name)
    },
    Input: Send, Error: Send, Context: Send,
    ..
);
```

: Implementace toku `SequentialFlow` - definice toku {#lst:sequential_flow_def_impl}

Pro definici toku je použito makro `define_flow`,
ve kterém lze vidět, že běh toku je obstaráván `ChainRunSequential` traitem.
Dále lze vidět jak je definováno tělo pro metodu `describe`
a jaké dodatečné požadavky jsou kladeny na generické parametry.

```{.include}
builder.md
chain_run.md
```

