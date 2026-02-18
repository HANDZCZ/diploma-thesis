
# Tok ParallelFlow {#sec:parallel_flow}

Tok `ParallelFlow` spouští všechny uzly najednou
a vrací výsledek sloučení všech výstupů uzlů takzvaným "joinerem."

Tok vrací zpracovanou vstupní hodnotu, pouze když všechny uzly úspěšně skončí.
V tomto případě je výstup ze všech uzlů zpracován uživatelem definovanou strukturou či funkcí,
která se nazývá "Joiner," a výsledek z této struktury je použit jako výsledek toku.
V ostatních případech výstup tohoto toku záleží na výstupu uzlů a zní takto:

1. Pokud uzel vrátí `NodeOutput::Ok` nebo `NodeOutput::SoftFail`,
   tak tok čeká dále na dokončení ostatních uzlů (větví toku).
1. Pokud uzel vrátí chybu, tak tok končí a vrací chybu.

## Definice toku

```{.rust .linenos}
pub struct ParallelFlow<Input, Output, Error, Context, ChainOutput = (), Joiner = (), NodeTypes = (), NodeIOETypes = ()> {
    ..
    pub(super) nodes: std::sync::Arc<NodeTypes>,
    pub(super) joiner: Joiner,
}
```

: Implementace toku `ParallelFlow` - definice toku {#lst:parallel_flow_def_impl}

Pro definici toku nemohlo být použito makro `define_flow`,
protože tento tok navíc obsahuje takzvaný "joiner."
Běh toku je obstaráván `ChainRunParallel` traitem
a tělo `describe` metody vytváří acyklický orientovaný graf,
kde každý uzel má jednu hranu vycházející z toku mířící do uzlu a jednu hranu vycházející z uzlu mířící do "joineru."
Tento graf má ještě jednu hranu vycházející z "joineru" a mířící do toku.

```{.d2 #fig:parallel_flow_visualization caption="Vizializace toku ParallelFlow" height=22%}
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
Uzel* -> Joiner
Joiner -> Konec
```

```{.include}
joiner.md
builder.md
chain_run.md
```

