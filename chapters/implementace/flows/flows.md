
# Implementace toků

Tato kapitola obsahuje nejen implementace všech toků poskytovaných touto knihovnou,
ale i implementace pomocných maker typových aliasů a struktur díky,
kterým je implementace umožněna či zjednodušena.

Implementace toků vychází z návrhu pro konstrukci toků,
uložení uzlů v toku a definice běhu toků
([@sec:flow_construction_design; @sec:flow_node_store_desing; @sec:flow_run_design]).
Každý tok implementuje trait `Node` ([@sec:trait_node]),
aby mohl být použit jako uzel v dalším toku,
a bere uzly implementující tento trait.
Díky tomuto návrhu je možno teoreticky vytvářet vnořené toky s nekonečnou hloubkou.
Avšak v realitě by uživatel jistě narazil na nějaký limit,
jako je například stack limit, který lze jednoduše vyřešit,
nebo nedostatek fyzické paměti.

```{.include shift-heading-level-by=1}
mod_future_utils.md
chain_traits.md
generic_defs/generic_defs.md
sequential_flow/sequential_flow.md
one_of_sequential_flow/one_of_sequential_flow.md
parallel_flow/parallel_flow.md
one_of_parallel_flow/one_of_parallel_flow.md
detached.md
```

