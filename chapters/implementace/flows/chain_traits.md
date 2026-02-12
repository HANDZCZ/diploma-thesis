
# Privátní pomocný trait ChainDebug

```{.rust .linenos}
pub trait ChainDebug {
    fn fmt_as_list(&self, f: &mut std::fmt::DebugList<'_, '_>);
    fn as_list(&self) -> ChainDebugAsList<&Self> {
        ChainDebugAsList(self)
    }
}

pub struct ChainDebugAsList<T>(T);

impl<T> Debug for ChainDebugAsList<&T>
where
    T: ChainDebug,
{
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let mut debug_list = f.debug_list();
        self.0.fmt_as_list(&mut debug_list);
        debug_list.finish()
    }
}
```

: Implementace traitu `ChainDebug` {#lst:trait_chain_debug_impl}

Trait `ChainDebug` slouží k vytištění všech uzlů v toku.
Tohoto cíle je samozřejmě možno dosáhnout pomocí výchozí implementace traitu `Debug` pro tuply,
ale vyprodukovaný výsledek není intuitivní a záleží na vnitřní reprezentaci uzlů v toku.
Díky tomuto traitu jsou tuple listy tištěny jako heterogenní pole i když jsou vnitřně reprezentovány jinak.

Například pro heterogenní pole obsahující hodnoty `A` až `C`
by výchozí implementace mohla mít výstup `((((), A), B), C)`,
ale při použití tratu `ChainDebug` by výstup byl `[A, B, C]`.

Tento trait má výchozí implementaci pro tuple listy,
které mají strukturu takovou, že první element je na první pozici a poslední vrstvě
`((((), A), B), C)` ([@lst:tuple_lists_represented_in_code]).

