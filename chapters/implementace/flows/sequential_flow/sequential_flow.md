
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
    |self| { .. },
    Input: Send, Error: Send, Context: Send,
    ..
);
```

: Implementace toku `SequentialFlow` - definice toku {#lst:sequential_flow_def_impl}

Pro definici toku je použito makro `define_flow`
a běh toku je obstaráván `ChainRunSequential` traitem.
Tělo `describe` metody vytváří acyklický orientovaný graf,
kde každý uzel má jednu hranu mířící do uzlu a jednu hranu vycházející z uzlu.
Vycházející hrana je vždy, až na poslední uzel, spojena s následujícím uzlem v toku.

```{.d2 #fig:sequential_flow_visualization caption="Vizializace toku `SequentialFlow`"}
vars: {
  d2-config: {
    layout-engine: elk
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

Start -> Uzel1 -> Uzel2 -> Uzel3 -> Konec
```

```{.include}
builder.md
chain_run.md
```

