
# Tok OneOfParallelFlow {#sec:one_of_parallel_flow}

Tok `OneOfParallelFlow` spouští všechny uzly najednou
a vrací výsledek uzlu, který skončí nejdříve.

Tok vrací zpracovanou vstupní hodnotu, pouze když nějaký z uzlů úspěšně skončí.
V tomto případě je výstup z prvního úspěšného uzlu vrácen jako výstup toku.
Všechny případy výstupu tohoto toku záleží na výstupu uzlů a zní takto:

1. Pokud uzel vrátí `NodeOutput::Ok`, tak je výstupní hodnota tohoto uzlu vrácena tokem.
1. Pokud uzel vrátí `NodeOutput::SoftFail`, tak tok čeká na dokončení dalšího uzlu (větve toku).
1. Pokud uzel vrátí chybu, tak tok končí a vrací chybu.
1. Pokud všechny uzly vrátí `NodeOutput::SoftFail`, tak tok končí a také vrací soft-fail.

## Definice toku a builderu

```{.rust .linenos}
define_flow_and_ioe_conv_builder!(
    OneOfParallelFlow,
    ChainRunOneOfParallel,
    |self| { .. },
    >Input: Send + Clone,
    >Output: Send,
    >Error: Send,
    >Context: Fork + Update + Send,
    #NodeType: Send + Sync + Clone
    ..
);
```

: Implementace toku `OneOfParallelFlow` - definice toku a builderu {#lst:one_of_parallel_flow_impl}

Pro definici toku a builderu je použito makro `define_flow_and_ioe_conv_builder`
a běh toku je obstaráván `ChainRunOneOfParallel` traitem.
Definice toku a builderu je velmi podobná `OneOfSequentialFlow` toku,
ale navíc od toku `OneOfSequentialFlow` tato definice klade dodatečné požadavky na generické parametry `Error` a `Output`.
Tělo `describe` metody vytváří stejný acyklický orientovaný graf ([@fig:one_of_sequential_flow_visualization]),
jako tok `OneOfSequentialFlow`, protože tyto toky mají stejnou strukturu, ale jinou funkcionalitu.

```{.include}
chain_run.md
```

