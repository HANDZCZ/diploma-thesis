
## Polymorfismus

Polymorfismus v programovacích jazycích je schopnost prezentovat stejné "rozhraní" pro různé datové typy.
Zde je třeba zdůraznit, že pojem "rozhraní" se v tomto případě vztahuje ke způsobu použití třídy
a nemusí se tedy nutně jednat o konkrétní pojmenování,
které se vyskytuje v některých objektově orientovaných jazycích.
[@what_is_polymorphism; @rust_book_oop; @polymorphism_in_rust_oswalt]

Polymorfismus lze v Rustu používat dvěma hlavními způsoby,
a oba mají své výhody a nevýhody,
které je třeba zvážit z hlediska výkonu a velikosti souboru.
[@rust_for_c_programmers_trait_features; @polymorphism_in_rust_oswalt; @polymorphism_in_rust_brandon]

### Static dispatch

První způsob je tzv. "statický výběr", který využívá generické typy (tzv. parametrický polymorfismus),
monomorfizaci ([@sec:monomorfizace]) a omezení datového typu (pomocí "traitů", v jiných jazycích označovaných jako "rozhraní"),
které poskytují nezbytnou úroveň flexibility a zachovávají typovou bezpečnost,
bez nutnosti vytvářet velké množství duplicitního kódu.
[@rust_for_c_programmers_trait_features; @polymorphism_in_rust_brandon; @polymorphism_in_rust_oswalt]

```{.rust .linenos}
trait Update {
    fn update(&mut self)
}

fn update_val<T>(t: &mut T)
where
    T: Update
{
    t.update();
}

fn main() {
    let mut val1: TypeA = todo!();
    let mut val2: TypeB = todo!();

    update_val(&mut val1);
    update_val(&mut val2);
}
```

: Příklad statického výběru {#lst:static_dispatch_example}

V ukázce výše je vidět jak lze využít statického výběru.
Trait `Update` definuje co musí konkrétní typy umět.
Dále existuje funkce `update_val`, která bere jako parametr měnitelnou referenci na nějaký generický typ `T`, který implementuje trait `Update`.
Hlavní metoda poté volá funkci `update_val` na dvou hodnotách s různými typy (konkrétně `TypeA` a `TypeB`),
které musí implementovat `Update` trait.
V tomto případě by za pomocí monomorfizace ([@sec:monomorfizace]) byla vygenerována funkce pro každý konkrétní typ.


### Dynamic dispatch {#sec:dynamic_dispatch}

Druhý způsob je tzv. "dynamický výběr", který používá "trait objekty" k tomu,
aby odložil rozhodnutí o tom, který typ je potřebný k vyhovění nějakého polymorfního rozhraní na běh samotného programu.
Díky tomuto přístupu se zmenší velikost binárního souboru, protože není použita monomorfizace ([@sec:monomorfizace]),
ale způsobuje snížení výkonu kvůli dodatečnému vyhledávání během běhu programu.
Při tomto přístupu je také explicitně zakázáno používání generických typů.
[@rust_for_c_programmers_trait_features; @polymorphism_in_rust_brandon; @polymorphism_in_rust_oswalt]

Trait objekt je ukazatel na část paměti, kde lze najít nejen metody daného typu, ale také i další věci jako je například destruktor.
Obvykle se této části paměti říká "tabulka virtuálních metod" nebo "vtable".
Pro každý konkrétní datový typ s metodami je vytvořena tabulka vtable.
Do této tabulky, pak program přistupuje, když potřebuje zjistit, kde se pro daný typ nachází daná metoda.
[@rust_for_c_programmers_trait_features; @polymorphism_in_rust_brandon; @polymorphism_in_rust_oswalt]

![Struktura trait objektu [@polymorphism_in_rust_oswalt]](../../pictures/vtable_diagram.png){#fig:trait_object_inner height=300px}


```{.rust .linenos}
trait Update {
    fn update(&mut self)
}

fn update_val<T>(t: &mut dyn Update) {
    t.update();
}

fn main() {
    let mut val1: TypeA = todo!();
    let mut val2: TypeB = todo!();

    update_val(&mut val1);
    update_val(&mut val2);
}
```

: Příklad dynamického výběru {#lst:dynamic_dispatch_example}

V ukázce výše je vidět jak lze využít dynamického výběru.
Tato ukázka je velice podobná statickému výběru.
Jediné co se liší je implementace funkce `update_val`, která nyní bere jako parametr měnitelnou referenci na trait objekt `dyn Update`.
V tomto případě by byla vygenerována pouze jedna funkce `update_val` pro každý konkrétní typ implementující `Update` trait.
Funkce `update_val` poté obsahuje dodatečné vyhledání lokace `update` metody na konkrétním trait objektu za použití vtablu.

