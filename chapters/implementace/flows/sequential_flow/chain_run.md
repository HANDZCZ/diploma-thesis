
## Privátní trait ChainRunSequential

```{.rust .linenos}
pub trait ChainRunSequential<Input, Output, Context, T> {
    fn run(&self, input: Input, context: &mut Context) -> impl Future<Output = Output> + Send;
}
```

: Implementace toku `SequentialFlow` - definice traitu `ChainRunSequential` {#lst:sequential_flow_chain_run_def_impl}

Trait `ChainRunSequential` obsahuje veškerou logiku pro běh toku
a správu asynchronních úloh.
Chování tohoto traitu je popsáno v hlavní kapitole [@sec:sequential_flow].
Generický typ `T` v definici traitu je použit pro uložení vstupních, výstupních
a chybových datových typů uzlů.

```{.rust .linenos}
impl<..> ChainRunSequential<
  Input, NodeResult<Output, Error>, Context,
  ChainLink<HeadIOETypes, NodeIOE<TailNodeInType, TailNodeOutType, TailNodeErrType>>,
> for (Head, Tail)
where
  Head: ChainRunSequential<Input, NodeResult<TailNodeInType, Error>, Context, HeadIOETypes>,
  Tail: Node<TailNodeInType, NodeOutputStruct<TailNodeOutType>, TailNodeErrType, Context> + Clone,
  TailNodeErrType: Into<Error>,
  TailNodeOutType: Into<Output>,
  ..
{
  async fn run(&self, input: Input, context: &mut Context) -> NodeResult<Output, Error> {
    let (head, tail) = self;
    if let NodeOutputStruct::Ok(input) = head.run(input, context).await? {
      let output = tail.clone().run(input, context).await.map_err(Into::into)?;
      return Ok(match output {
        NodeOutputStruct::SoftFail => NodeOutputStruct::SoftFail,
        NodeOutputStruct::Ok(output) => NodeOutputStruct::Ok(output.into()),
      });
    }
    Ok(NodeOutputStruct::SoftFail)
  }
}
```

: Implementace toku `SequentialFlow` - implementace traitu `ChainRunSequential` pro tuple list {#lst:sequential_flow_chain_run_tuple_list_impl}

Implementace traitu `ChainRunSequential` pro tuple list nejprve získá hlavu a ocas listu,
poté na hlavě rekurzivně volá metodu `run` z `ChainRunSequential` traitu.
Tímto způsobem se dojde na začátek listu, kde se zavolá metoda `run` z `Node` traitu
a získá se výsledek, který je zkontrolován zda je úspěšný a pokračuje se dále tím,
že je tento výsledek poslán do následujícího uzlu.
Tento proces se opakuje do té doby, dokud se nedosáhne posledního uzlu v tuple listu.
Po dosažení posledního uzlu je výsledek posledního uzlu vrácen jako výsledek toku.

Implementace traitu `ChainRunSequential` jen pro hlavu tuple listu je v kódu vynechána,
protože dělá skoro to same, akorát neřeší získání hlavy tuple listu.

