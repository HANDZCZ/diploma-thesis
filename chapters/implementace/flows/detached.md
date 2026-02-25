
# Tok Detached {#sec:detached_flow}

```{.rust .linenos}
pub struct Detached<Input, Error, Context, NodeType = (), NodeOutput = (), NodeError = ()> {
    ..
    node: NodeType,
}
```

: Implementace toku `Detached` {#lst:detached_flow_def_impl}

Tok `Detached` je obal, který vytvoří a spustí samostatnou asynchronní úlohu na jejíž dokončení nečeká
a vrací vstup do tohoto obalu, jako výstup, bez jakékoli úpravy.

Je implementován za pomocí traitu `SpawnAsync` ([@sec:trait_spawn_async]),
pro vytvoření a spuštění asynchronní úlohy,
a traitu `Fork` ([@sec:trait_fork]), pro získání nezávislé instance kontextu.
V implementaci není použit žádný trait na synchronizaci kontextu,
protože obalený uzel je spuštěn nezávisle na toku ve kterém byl definován.
Tělo `describe` metody vytváří acyklický orientovaný graf,
kde jedna hrana míří z toku do uzlu a další hrana míří ze začátku toku na konec toku.

```{.d2 #fig:detached_flow_visualization caption="Vizializace toku `Detached`" height=15%}
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

Start -> Konec
Start -> Uzel
```

Tento tok umožňuje vytvářet a spouštět uzly, které jsou vedlejší a nepotřebné k běhu toku,
běžících na pozadí bez toho, aby ovlivnily výsledek či průběh toku.

