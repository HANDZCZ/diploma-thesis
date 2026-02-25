
## Makro define_flow

```{.rust .linenos}
macro_rules! define_flow {
    ($flow_name:ident, $builder:ident, $chain_run:ident, |$self:ident| $describe_code:block $(,$param:ident: $bound0:ident $(+$bound:ident)*)* $(,)? $(#[doc = $doc:expr])*) => { .. };
}
```

: Implementace makra `define_flow` {#lst:macro_define_flow_impl}

Makro `define_flow` slouží k usnadnění definice toků,
které mají stejnou strukturu.
Toto makro bere název datového typu toku, který se má definovat,
datový typ builderu pro tento tok,
datový typ takzvaného "chainrunu," který definuje běh toku,
definici těla funkce pro metodu `describe` z traitu `Node` ([@sec:trait_node]),
dodatečné nepovinné omezení typů pomocí traitů při definici `builder` metody
a nepovinnou dokumentaci pro definovaný tok.

Toky definované tímto makrem mají implementovány traity `Debug`,
pomocí pomocného makra, a `Clone`.
Dále je také vytvořena funkce `builder`,
která vrací instanci builderu vytvořenou funkcí `new` implementovanou v builderu.
Implementace této funkce může být omezena pomocí dodatečných traitů,
tyto traity většinou pochází ze samotné implementace builderu.
Pro funkci `builder` je také automaticky vygenerována dokumentace s ukázkou použití.

Toto makro také implementuje trait `Node` ([@sec:trait_node]) pro každý tok co definuje.
Implementace metody `run` jen volá takzvaný "chainrun,"
který musí být implementován pro tuple list uzlů v toku,
s parametry, které jsou do funkce poslány a vrací výstupní asynchronní úlohu.
Implementace metody `describe` je velice triviální, protože jediné co dělá je,
že do těla této funkce vloží kód, který byl poskytnut tomuto makru pro přesně tento účel.

