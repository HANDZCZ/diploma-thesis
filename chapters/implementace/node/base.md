
# Trait Node

```{.rust .linenos}
pub trait Node<Input, Output, Error, Context> {
    fn run(
        &mut self,
        input: Input,
        context: &mut Context,
    ) -> impl Future<Output = Result<Output, Error>> + Send;

    fn describe(&self) -> Description
    where
        Self: Sized,
    {
        let mut base = DescriptionBase::from::<Self, Input, Output, Error, Context>();

        // remove NodeOutput<> from output name
        let output_name = &mut base.output.name;
        if let Some(b_pos) = output_name.find('<')
            && output_name[..b_pos].contains("NodeOutput")
        {
            // remove `..::NodeOutput<`
            output_name.replace_range(0..=b_pos, "");
            // remove ending `>`
            output_name.pop();
        }

        Description::Node { base }
    }
}
```

: Implementace traitu `Node` {#lst:node_trait_impl}

Tento trait slouží jako základní stavební blok pro definici uzlů a toků.
Vychází z návrhu pro tento trait s generickým kontextem ([@lst:node_trait_with_context_design])
a rozšiřuje ho o generický parametr `Error` a metodu `describe`.

Dále se liší v definici metody `run` explicitní definicí výstupního typu,
který musí implementovat trait `Future` ([@sec:future_trait])
a tento typ také musí implementovat auto trait `Send`.
Auto trait `Send` je vyžadován proto, aby bylo možno vzniklou asynchronní úlohu odeslat do jiného vlákna
a docílit, tak mnohem větší konkurence.

Bylo také nutno do tohoto traitu přidat metodu `describe`, která slouží k popisu uzlu.
Vrací informace jak o vstupních a výstupních typech, tak i dodatečné informace jako je popis uzlu.
Tato metoda se nachází v tomto traitu, protože bylo nutno definovat výchozí implementaci pro všechny uzly.
Původně tato metoda měla být ve vlastním traitu,
ale Rust zatím nedovoluje vytvořit výchozí implementaci pro všechny datové typy implementující trait `Node`,
kterou by poté uživatel mohl přepsat.

Výchozí implementace metody `describe` vrací pouze název typu uzlu,
vstupního, výstupního, chybového a kontextového typu.
Z názvu výstupního typu odstraňuje `NodeOutput<>`, aby výsledný popis byl více přehledný.
Pro získání takzvané `DescriptionBase` se používá pomocná metoda, která je popsána ve vlastní kapitole
([@sec:node_describe_chapter; @sec:description_base_struct]).

