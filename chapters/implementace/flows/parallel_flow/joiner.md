
## Trait Joiner

```{.rust .linenos}
pub trait Joiner<'a, Input, Output, Error, Context>: Send + Sync {
    fn join(
        &self,
        input: Input,
        context: &'a mut Context,
    ) -> impl Future<Output = NodeResult<Output, Error>> + Send;
}
```

: Implementace toku `ParallelFlow` - trait `Joiner` {#lst:parallel_flow_joiner_trait_impl}

Trait `Joiner` obsahuje pouze jednu metodu `join`
a jeho účel je definovat, jak má být sloučen výstup ze všech uzlů `ParallelFlow` toku.
Díky tomuto traitu je uživatel schopen definovat jak mají být výstupy uzlů sloučeny.
Je také možno s výstupy provést nějakou další operaci díky tomu,
že metoda `join` je asynchronní a má velice podobnou definici jako trait `Node`.

Trait `Node` zde nemohl být použit, protože docházelo k problémům s lifetimy.
Z tohoto důvodu byl vytvořen trait `Joiner`, který tento problém řeší.

Pro trait `Joiner` byla také vytvořena výchozí implementace pro jakýkoli datový typ implementující trait `Fn`.
Díky této implementaci je možno použít jednoduchou asynchronní funkci pro sloučení výstupů uzlů ([@sec:async_await_syntax; @lst:async_function_example]).

