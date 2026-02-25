
# Tok FnFlow {#sec:fn_flow}

```{.rust .linenos}
pub struct FnFlow<Input, Output, Error, Context, InnerData = (), R = ()> {
    ..
    inner_data: InnerData,
    runner_description: Option<Description>,
    runner: R,
}
```

: Implementace toku `FnFlow` - definice toku {#lst:fn_flow_def_impl}

Tok `FnFlow` je obal, který vytváří z nějaké synchronní funkce uzel implementující trait `Node`.

Tento obal přijímá asynchronní funkci či strukturu implementující trait `Runner`,
dodatečná data, která mají být funkci poskytnuta spolu se vstupem
a nepovinný popis pro vytvořený uzel.

Implementace tohoto obalu je velice jednoduchá, protože jen volá poskytnutou funkci se stupem
a poskytnutými dodatečnými daty.
Tělo `describe` metody vytváří acyklický orientovaný graf,
kde dvě hrany míří do funkce, jedna z toku a druhá z dodatečných dat, a jedna hrana míří z funkce do toku.

```{.d2 #fig:fn_flow_visualization caption="Vizializace toku `FnFlow`" height=15%}
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
Funkce: {
  style.border-radius: 8
}
Data: Dodatečná data {
  style.border-radius: 8
}


Data -> Funkce
Start -> Funkce -> Konec
```

## Trait Runner

```{.rust .linenos}
pub trait Runner<'a, Input, Output, Error, Context, InnerData>: Send + Sync {
    fn run(
        &self,
        data: InnerData,
        input: Input,
        context: &'a mut Context,
    ) -> impl Future<Output = NodeResult<Output, Error>> + Send;
}
```

: Implementace toku `FnFlow` - definice traitu `Runner` {#lst:fn_flow_trait_runner_def_impl}

Trait `Runner` obsahuje pouze jednu metodu `run`
a jeho účel je definovat, jak má být vstup a dodatečná data zpracována do nějakého výstupu.

Trait `Node` zde nemohl být použit kvůli limitaci jazyka.
Rust zatím nedovoluje vytvořit výchozí implementaci
pro jakýkoli datový typ, kterou by poté uživatel mohl přepsat.
Dále také definice traitu `Runner` umožňuje lépe rozlišit,
zda implementace je zamýšlena pro definici uzlu,
nebo pro použití v `FnNode` toku.

Pro trait `Runner` byla také vytvořena výchozí implementace pro jakýkoli datový typ implementující trait `Fn`.
Díky této implementaci je možno použít jakoukoli asynchronní funkci ([@sec:async_await_syntax; @lst:async_function_example]).

