
# Privátní pomocné typové aliasy

```{.rust .linenos}
type NodeIOE<Input, Output, Error> = (Input, NodeOutput<Output>, Error);
type ChainLink<Head, Tail> = (Head, Tail);
type NodeResult<Output, Error> = Result<NodeOutput<Output>, Error>;
```

: Implementace typových aliasů `NodeIOE`, `ChainLink` a `NodeResult` {#lst:flows_type_aliases_impl}

Typový alias `NodeIOE` slouží k definici typu reprezentující vstupní,
výstupní a chybový datový typ uzlu obsaženého v toku.
Je také důležité zmínit, že uvedený výstupní typ je tomto aliasu obalen do enumu `NodeOutput` ([@sec:enum_node_output]).

Typový alias `ChainLink` reprezentuje jednoduchou vazbu v řetězu a jediné co dělá je,
že určuje jak má být tato vazba reprezentována.
Tento typový alias je použit při vytváření a přístupu k datovým typům elementů v tuple listech ([@sec:tuple_lists]).

Typový alias `NodeResult` definuje reprezentaci výstupního a chybového typu uzlu.
Díky tomuto type aliasu je definice výstupu uzlu v tocích výrazně zjednodušena
a možnost nesprávné definice snížena.

# Privátní pomocná struktura enum SoftFailPoll

```{.rust .linenos}
#[derive(Debug)]
pub enum SoftFailPoll<T> {
    Pending,
    Ready(T),
    SoftFail,
}
```

: Implementace struktury enum `SoftFailPoll` {#lst:enum_soft_fail_poll_impl}

Enum `SoftFailPoll` složí k zjednodušení reprezentace výstupu z asynchronní úlohy.
Přidává navíc oproti enumu `Poll` ([@sec:enum_poll]) možnost vrátit `SoftFail`,
který má stejný význam jako v enumu `NodeOutput` ([@sec:enum_node_output]).

