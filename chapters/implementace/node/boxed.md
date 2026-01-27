
# Trait BoxedNode

```{.rust .linenos}
#[async_trait::async_trait]
pub trait BoxedNode<Input, Output, Error, Context> {
    async fn run_boxed(&mut self, input: Input, context: &mut Context) -> Result<Output, Error>
    where
        Input: 'async_trait,
        Output: 'async_trait,
        Error: 'async_trait;

    fn describe(&self) -> Description;
}

impl<Input, Output, Error, Context, T> BoxedNode<Input, Output, Error, Context> for T
where
    T: Node<Input, Output, Error, Context>,
{
    fn run_boxed<'life0, 'life1, 'async_trait>(
        &'life0 mut self,
        input: Input,
        context: &'life1 mut Context,
    ) -> Pin<Box<Future<Output = Result<Output, Error>> + Send + 'async_trait>>
    where
        Input: 'async_trait, Output: 'async_trait,
        Error: 'async_trait, 'life0: 'async_trait,
        'life1: 'async_trait, Self: 'async_trait,
    {
        Box::pin(<Self as Node<Input, Output, Error, Context>>::run(self, input, context))
    }

    fn describe(&self) -> Description {
        <Self as Node<Input, Output, Error, Context>>::describe(self)
    }
}
```

: Implementace traitu `BoxedNode` {#lst:boxed_node_trait_impl}

Trait `BoxedNode` je dyn kompatibilní obal ([@sec:dyn_compatibility]) pro trait `Node`,
který obsahuje veškeré metody, jako trait `Node`.
Díky tomuto obalu je možno pracovat s uzly ve stejném stylu, jako kdyby trait `Node` byl dyn kompatibilní.
Přidává tedy další stupeň volnosti pro uživatele této knihovny.
Tento obal hlavně existuje proto, aby si uživatel mohl vybrat, zda chce pracovat se statickým výběrem nebo s dynamickým.

Pro tento obal je také vytvořená výchozí implementace pro jakýkoli typ implementující trait `Node`.
Metoda `run` vypadá komplikovaně, ale jen obaluje vytvořenou asynchronní úlohu z `Node` traitu do pin-boxu (TODO: pib-box link)
a přemění typ této úlohy trait object `dyn Future + Send`.
Metoda `describe` volá metodu se stejným jménem z `Node` traitu a vrací tuto nepozměněnou hodnotu,
protože trait `BoxedNode` nemění chování ani vstupy či výstupy uzlu.

