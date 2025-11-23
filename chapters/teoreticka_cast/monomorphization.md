
## Monomorfizace {#sec:monomorfizace}

Monomorfizace je proces změny generického kódu na specifický kód doplněním konkrétních datových typů.
Během tohoto procesu kompilátor hledá všechna místa, kde je generický kód volán,
a generuje kopii kódu pro konkrétní datové typy, se kterými je generický kód volán.
[@rust_compiler_book_monomorphization; @rust_book_monomorphization; @what_is_monomorphization]

Použití monomorfizace je výhodné, protože výsledkem je tzv. "mezijazyk" (intermediate representation (IR))
se specifickými typy, což umožňuje účinnější optimalizaci.
Výsledný kód je většinou rychlejší než dynamický výběr ([@sec:dynamic_dispatch]), ale za cenu delšího času kompilace
a větší velikosti binárního souboru.
[@rust_compiler_book_monomorphization; @rust_book_monomorphization; @what_is_monomorphization]

```{.rust .linenos}
enum Option<T> {
    Some(T),
    None,
}

fn main() {
    let integer = Option::Some(5);
    let float = Option::Some(5.0);
}
```

: Příklad kódu před monomorfizací [@rust_book_monomorphization] {#lst:monomorphization_in_example}

V ukázce výše je vidět kód před monomorfizací, kde je definovaný vestavěný typ `Option`,
který bere jako generický parametr nějaký datový typ `T`
a v hlavní metodě je tento datový typ `Option` použit s dvěma různými datovými typy.

```{.rust .linenos}
enum Option_i32 {
    Some(i32),
    None,
}

enum Option_f64 {
    Some(f64),
    None,
}

fn main() {
    let integer = Option_i32::Some(5);
    let float = Option_f64::Some(5.0);
}
```

: Příklad kódu po monomorfizaci [@rust_book_monomorphization] {#lst:monomorphization_out_example}

Po monomorfizaci došlo k vytvoření dvou kopií kódu.
Datové typy pro vytvoření kopií byly získány z hlavní metody, kde datový typ `Option` je použitý.
Pro datový typ `i32` byla vytvořena kopie `Option_i32`
a pro datový typ `f64` byla vytvořena kopie `Option_f64`.
Tyto dvě kopie jsou poté použity v hlavní metodě místo generického datového typu `Option`.
Toto kód je samozřejmě jen pro ilustraci, ale na této ukázce je nádherně vidět jak monomorfizace funguje.

