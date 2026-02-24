
## Vliv inliningu a monomorfizace na jediný a samotný uzel

V kapitole "Kontext za pomocí generického typu" ([@sec:generic_type_for_kontext])
je uveden kód "Příklad použití traitu `Node` s generickým kontextem" ([@lst:node_trait_with_storage_design]).
Tento kód lze využít skoro beze změny a poslouží k testu zda inlining ([@sec:inlining])
a monomorfizace ([@sec:monomorfizace]) fungují pro tento velmi jednoduchý příklad.

```{.asm .linenos}
node_flow_testing::poller:
    mov al, 17
    ret
```

: Vygenerovaný assembly kód pro jeden samostatný uzel {#lst:single_node_assembly_test}

V kódu výše je vidět, že celá asynchronní úloha byla odoptimalizována a nahrazena výsledkem.
Nedochází tedy za běhu k žádným výpočtům a výsledná hodnota je přímo vrácena.

Tento případ není ale moc realistický, protože vstupy jsou známy dopředu
a pro kompilátor je hračka celé tělo nahradit výsledkem.

```{.asm .linenos}
node_flow_testing::poller:
    mov byte ptr [rsp - 2], 5
    lea rax, [rsp - 2]
    lea rcx, [rsp - 1]
    mov byte ptr [rsp - 1], 12
    movzx eax, byte ptr [rsp - 2]
    add al, byte ptr [rsp - 1]
    ret
```

: Vygenerovaný assembly kód pro jeden samostatný uzel s `black_boxem` {#lst:single_node_assembly_bbox_test}

Pokud jsou hodnoty `5` a `12` obaleny do `black_boxu`, tak je vidět,
že už dochází ke sčítání operandů, ale nedochází k žádnému spouštění asynchronních úloh
díky tomu, že definovaný uzel neobsahuje žádný await bod.

Práce se stackem je vedlejší účinek `black_boxu`
a při použití argumentů do funkce `poller` místo `black_boxu`,
je generována pouze jedna instrukce sčítající argumenty.

```{.rust .linenos}
fn run(&mut self, input: u8, context: &mut Context) -> impl Future<Output = Result<u8, ()>> + Send {
    let fut: Pin<Box<dyn Future<Output = Result<u8, ()>> + Send>> = Box::pin(async move { Ok(input + context.how_much()) });
    fut
}
```

: Pozměněná implementace metody `Node::run` pro jeden samostatný uzel {#lst:single_node_dyn_change}

Byl také proveden jednoduchý test, kde originální kód příkladu byl pozměněn tak,
že implementace metody `Node::run` ([@sec:trait_node]) vracela trait objekt `Pin<Box<dyn Future>>`.

Vygenerovaný kód byl mnohem delší a věnoval se hlavně alokaci a dealokaci asynchronní úlohy na heap.
Získání výsledku byla jen malá část, ve které ani neproběhl žádný výpočet,
protože hodnota `input` a výstup metody `HowMuch::how_much` jsou známy při kompilaci.
Podobný fenomén také nastal, když byl místo konkrétního typu kontextu použit trait objekt `Box<dyn HowMuch>`.

