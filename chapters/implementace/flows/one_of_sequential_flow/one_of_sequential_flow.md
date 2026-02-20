
# Tok OneOfSequentialFlow {#sec:one_of_sequential_flow}

Tok `OneOfSequentialFlow` spouští uzly postupně ve stejném pořadí,
jako při vkládání uzlů do builderu.
Funguje jako "fallback vodopád," kde stačí jen aby jeden uzel úspěšně zpracoval vstup.

Tok vrací zpracovanou vstupní hodnotu, pouze když nějaký z uzlů úspěšně skončí.
V tomto případě je výstup z prvního úspěšného uzlu vrácen jako výstup toku.
Všechny případy výstupu tohoto toku záleží na výstupu uzlů a zní takto:

1. Pokud uzel vrátí `NodeOutput::Ok`, tak je výstupní hodnota tohoto uzlu vrácena tokem.
1. Pokud uzel vrátí `NodeOutput::SoftFail`, tak tok zkusí další uzel (větev toku).
1. Pokud uzel vrátí chybu, tak tok končí a vrací chybu.
1. Pokud všechny uzly vrátí `NodeOutput::SoftFail`, tak tok končí a také vrací soft-fail.

## Definice toku a builderu

```{.rust .linenos}
define_flow_and_ioe_conv_builder!(
    OneOfSequentialFlow,
    ChainRunOneOfSequential,
    |self| { .. },
    >Input: Send + Clone,
    >Context: Fork + Update + Send,
    #NodeType: Send + Sync + Clone
    ..
);
```

: Implementace toku `OneOfSequentialFlow` - definice toku a builderu {#lst:one_of_sequential_flow_def_impl}

Pro definici toku a builderu je použito makro `define_flow_and_ioe_conv_builder`
a běh toku je obstaráván `ChainRunOneOfSequential` traitem.
Tělo `describe` metody vytváří acyklický orientovaný graf,
kde každý uzel má jednu hranu z toku mířící do uzlu a jednu hranu vycházející z uzlu a mířící do toku.

```{.d2 #fig:one_of_sequential_flow_visualization caption="Vizializace toku `OneOfSequentialFlow`" height=22%}
vars: {
  d2-config: {
    layout-engine: tala
    pad: 0
  }
}
direction: right

Start: {
  shape: oval
  style.stroke-dash: 3
}
Konec: {
  shape: oval
  style.stroke-dash: 3
}
Uzel*: {
  style.border-radius: 8
}

Uzel1
Uzel2
Uzel3

Start -> Uzel*
Uzel* -> Konec
```

```{.include}
chain_run.md
```

