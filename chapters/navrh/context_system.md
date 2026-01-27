
## Kontextový systém

Hlavní funkcí kontextového systému je poskytnutí prostředků
pro získání hodnot potřebných pro běh uzlů.

### Úložiště typu klíč-hodnota

Prvním návrhem pro kontext bylo úložiště typu klíč-hodnota.
Toto úložiště by sloužilo ke sdílení dat mezi uzly
nebo k zachování dat ze vstupu pro následující uzly.

```{.d2 #fig:storage_usage_ilustration caption="Ilustrace použití úložiště"}
vars: {
  d2-config: {
    layout-engine: tala
    pad: 0
  }
}
classes: {
  conn: {
    style: {
      stroke-dash: 3
      font-size: 18
    }
  }
}
direction: right

storage: Úložiště

Start: {
  shape: oval
  style.stroke-dash: 3
}
Konec: {
  shape: oval
  style.stroke-dash: 3
}
Uzel*: {
  style.border-radius: 8
}

Start -> Uzel1 -> Uzel2 -> Uzel3 -> Uzel4 -> Konec
Uzel1 -> storage: vlož(klíč="id", hodnota=5u32) {
  class: conn
}
Uzel2 -> storage: vlož(klíč="jmeno", hodnota="pepa") {
  class: conn
}
storage -> Uzel4: získej(klíč="id")\nzískej(klíč="jmeno") {
  class: conn
}
```

Tento přístup by byl velmi jednoduchý na implementaci,
protože by stačilo jen implementovat úložiště typu klíč-hodnota,
což může být provedeno pomocí hašovací tabulky,
použitím nějaké existující knihovny,
nebo i napojením na externí databázi jako je například redis.

```{.rust .linenos}
use node_flow::storage::Storage;

trait Node<Input, Output> {
    async fn run(&mut self, input: Input, storage: &mut Storage) -> Output;
}
```

: Návrh traitu `Node` s úložištěm {#lst:node_trait_with_storage_design}

Zde ale už nastává problém - Jak má být toto úložiště tedy implementováno a co musí umět?
Pokud by se použila jakákoli implementace, která limituje co může být do úložiště vloženo,
tak uživatel knihovny na tuto limitaci určitě narazí a díky tomu, že definice traitu `Node` je neměnná,
tak není schopen tuto limitaci jednoduše obejít.
Jednou z možností jak by tuto limitaci mohl obejít je brát data, která chce sdílet mezi uzly,
při konstrukci uzlu.
Tato možnost je ale nepraktická, zbytečně komplikovaná a znamenalo by to,
že úložiště je tomuto uživateli spíše na potíž než k užitku.

Jednoduchý příklad je implementace pomocí hašovací tabulky, která má klíč `String` a hodnotu `String`.
Vše co do tohoto úložiště bude vloženo musí být převeditelné na řetězec a získatelné z řetězce.
Poté uživatel narazí na problém, že do tohoto úložiště nejde snadno vložit například `Mutex` ([@sec:mutex]),
protože ho nelze převést na řetězec.

Tento problém řeší tzv. type mapa, která může být implementována pomocí hašovací tabulky,
kde klíčem je `TypeId` ([@sec:typeid]) a hodnotou je `Box<dyn Any>` ([@sec:trait_any; @sec:downcast_methods]).
Type mapa řeší tento problém tak, že všechny objekty, které jsou do ní vloženy,
převádí na trait objekt `Box<dyn Any>` a když uživatel chce tyto data získat zpět z type mapy,
tak stačí jen znát datový typ těchto dat.
Bohužel i toto řešení má své omezení a to, že pro daný datový typ může type mapa obsahovat
pouze jednu instanci tohoto datového typu.

```{.d2 #fig:kv_storage_design_for_node_trait caption="Návrh úložiště pro trait `Node`" width=75%}
vars: {
  d2-config: {
    pad: 0
  }
}

Uloziste: {
  shape: class

  -hashovaci_tabulka: HashMap<TypeId, Box<dyn Any>>

  vloz_hodnotu\<T\>(T)
  ziskej_hodnotu\<T\>(): T
  odstran_hodnotu\<T\>()
}
```

### Kontext za pomocí generického typu

Implementace za pomocí type mapy řeší většinu, ne-li všechny, problémy s úložištěm,
ale neřeší problém kontextu.
Uzly by měly mít možnost vyžadovat, aby nějaká hodnota, potřebná k běhu uzlu, byla vždy dostupná.
Pro tento účel nelze použít jen jednoduché úložiště.
Pokud by se použilo jen úložiště, tak může nastat stav,
kde daná hodnota v úložišti nebude a uzel tento problém musí řešit za běhu programu.
Znamenalo by to, že uzel by musel vracet chybu, která musí být uživatelem řešena, za běhu
nebo v horším případě by mohl také celý program spadnout.

Tento problém lze jednoduše ilustrovat na uzlu,
který bude stahovat data z webu a potřebuje přihlašovací údaje.
Přihlašovací údaje by mohl tento uzel brát v konstruktoru, ale to by znamenalo,
že když je tento uzel použit v nějakém toku,
tak pro každý přihlašovací údaj je potřeba vytvořit nová instance uzlu,
která je poté použita k sestavení nového toku.

Řešením je přidáni stupně volnosti na kontext tím způsobem,
že místo konkrétního typu pro kontext se použije generický parametr,
který může být libovolně omezen.
Tímto způsobem se docílí toho, že uzly mohou definovat traity, které kontext musí implementovat.
Tyto traity poté obsahují metody, které souží k poskytnutí libovolné hodnoty potřebné k běhu uzlu.

```{.rust .linenos}
trait Node<Input, Output, Context> {
    async fn run(
        &mut self,
        input: Input,
        storage: &mut Context
    ) -> Output;
}
```

: Návrh traitu `Node` s generickým kontextem {#lst:node_trait_with_context_design}

```{.rust .linenos}
// trait pro omezení kontextu
trait HowMuch {
    fn how_much(&self) -> u8;
}

// definice kontextu, který bude použit
struct MyContext {
    by_how_much: u8,
}

// implementace omezovacího traitu pro kontext
impl HowMuch for MyContext {
    fn how_much(&self) -> u8 {
        return self.by_how_much;
    }
}

// definice uzlu
struct AddNode;

// implementace Node traitu pro uzel,
// kde kontext musí implementovat omezovací trait
impl<Context> Node<u8, u8, Context> for AddNode
where
    // omezení kontextu je definováno zde
    Context: HowMuch
{
    async fn run(
        &mut self,
        input: u8,
        context: &mut Context
    ) -> u8 {
        return input + context.how_much()
    }
}

async fn main() {
    // vytvoření instance uzlu a kontextu
    let mut node = AddNode;
    let mut context = MyContext {
        by_how_much: 5,
    };
    // definice vstupu
    let input = 12;

    // spuštění uzlu a čekání na výsledek
    let output = node.run(input, &mut context).await;
    // kontrola výsledku
    assert_eq!(output, input + context.by_how_much);
}
```

: Příklad použití traitu `Node` s generickým kontextem {#lst:node_trait_with_context_example_in_design}

```{.text .linenos}
error[E0277]: the trait bound `MyContext: HowMuch` is not satisfied
  --> src/main.rs:47:27
   |
47 |     let output = node.run(input, &mut context).await;
   |                       --- ^^^^^ unsatisfied trait bound
   |                       |
   |                       required by a bound introduced by this call
   |
help: the trait `HowMuch` is not implemented for `MyContext`
  --> src/main.rs:7:1
   |
 7 | struct MyContext {
   | ^^^^^^^^^^^^^^^^
help: this trait has no implementations, consider adding one
  --> src/main.rs:2:1
   |
 2 | trait HowMuch {
   | ^^^^^^^^^^^^^
note: required for `AddNode` to implement `Node<u8, u8, MyContext>`
  --> src/main.rs:23:15
   |
23 | impl<Context> Node<u8, u8, Context> for AddNode
   |               ^^^^^^^^^^^^^^^^^^^^^     ^^^^^^^
...
26 |     Context: HowMuch
   |              ------- unsatisfied trait bound introduced here
```

: Chyba, která nastane při kompilaci, když nejsou splněny požadavaky na kontext {#lst:node_trait_with_context_error_in_design}

