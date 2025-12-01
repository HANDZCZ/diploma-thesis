
## Tuple listy {#sec:tuple_lists}

Tuple list je technika používaná pro vytváření heterogenních polí za pomocí skládání tuplů.
Tato technika se používá, protože v Rustu zatím nelze iterovat přes hodnoty nebo definovat trait pro tuply,
které mají libovolný počet elementů.
Jejich definice je velmi jednoduchá, ale práce s nimi může být matoucí.

Obvykle ve používají tuply o velikosti 2, kde prvnímu elementu se říká hlava (head) a druhému se říká osac (tail).
Tyto tuply se poté dají skládat tak, že vzniknou 4 hlavní variace tuple listů.
Typy těchto tuple listů vznikají podle toho zda má být první element jako první v tuple listu,
nebo zda má být první element na první vrstvě tuple listu.
Dále ještě musí existovat nějaký typ, který značí konec tuple listu.

```{.rust .linenos}
// heterogenní pole za pomocí tuplu
let tuple = (A, B, C, D);
// jako konec tuple listu je zde použit unit typ ()
// první element je na první pozici a první vsrvě
let tuple_list = (A, (B, (C, (D, ()))));
// první element je na první pozici a poslední vsrvě
let tuple_list = (((((), A), B), C), D);
// první element je na poslední pozici a poslední vsrvě
let tuple_list = (D, (C, (B, (A, ()))));
// první element je na poslední pozici a první vsrvě
let tuple_list = (((((), D), C), B), A);
```

: Tuple listy reprezentované kódem {#lst:tuple_lists_represented_in_code}

```{.rust .linenos}
// definice traitu pro vytištění sama sebe
trait Tiskni {
    fn tiskni(&self);
}

// implementace traitu pro všechny elementy,
// které se nachází v tuple listu
impl Tiskni for &'static str {
    fn tiskni(&self) { println!("{self}"); }
}

// implementace traitu pro typ značící konec tuple listu
impl Tiskni for () {
    fn tiskni(&self) {}
}

// implementace traitu pro tuple list
impl<Hlava, Ocas> Tiskni for (Hlava, Ocas)
where
    Hlava: Tiskni,
    Ocas: Tiskni,
{
    fn tiskni(&self) {
        let (hlava, ocas) = self;
        hlava.tiskni();
        ocas.tiskni();
    }
}

fn main() {
    // sestavení tuple listu
    let tuple_list = ("A", ("B", ("C", ("D", ()))));
    // zavolání traitu na tuple listu
    Tiskni::tiskni(&tuple_list);
}
```

: Příklad vytištění elementů v tuple listu {#lst:tuple_list_example}

