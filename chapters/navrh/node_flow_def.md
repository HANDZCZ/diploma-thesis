
## Traity pro uzly a toky

Základním stavebním blokem by měl být nějaký trait `Node`,
který obsahuje metodu `run`.
Tato metoda musí být asynchronní a brát měnitelnou referenci na typ,
který tento trait implementuje, poté musí brát nějaký vstupní typ a vracet nějaký výstupní typ.

```{.rust .linenos}
trait Node<Input, Output> {
    async fn run(&mut self, input: Input) -> Output;
}
```

: Návrh traitu `Node` {#lst:node_trait_design}

Dále by také mohl existovat trait `Flow`, který by obsahoval specifické metody pro toky.
Jednou z takových metod by mohla být metoda `nodes`, která by brala referenci na sama sebe,
a vracela by referenci na uzly obsažené v toku.

Zde ale nastává problém - Jaký typ by měla tato metoda vracet?
Při přidání uzlu do tohoto toku by se výstupní typ musel změnit,
nebo by tato metoda musela vracet list trait objektů `Node`,
což není možné protože trait `Node` není dyn kompatibilní ([@sec:dyn_compatibility]).

```{.rust .linenos}
trait Flow<Input, Output, Nodes>: Node<Input, Output> {
    fn nodes(&self) -> &Nodes
}
```

: Návrh traitu `Flow` {#lst:flow_trait_design}

