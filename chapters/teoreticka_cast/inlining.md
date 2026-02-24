
## Inlining {#sec:inlining}

Inlining je optimalizace prováděná ručně nebo kompilátorem,
při níž se volání funkce nahradí tělem volané funkce.
Inlining je podobný makroexpanzi, ale probíhá během kompilace,
aniž by došlo ke změně zdrojového kódu.
[@inlining_rust_perf_book; @inlining_in_rust_medium]

Funkce bez inliningu často tvoří nemalou část běhu programu.
Inlining těchto funkcí odstraňuje vstupy a výstupy (do a z funkcí)
a umožňuje kompilátoru provést další optimalizace.
Výslednou změnu rychlosti programu lze v nejlepším případě považovat za zanedbatelnou,
avšak každé zrychlení se počítá.
Nejhorší možný případ by pak byl takový, že je voláno mnoho malých
a jednoduchých funkcí (např. `return (a + c) * b` by bylo tělo funkce),
kde většina času by byla strávena na vstupech a výstupech těchto funkcí.
[@inlining_rust_perf_book; @inlining_in_rust_medium]

Rust pro tento účel obsahuje `inline` atribut, který může mít více významů.

| Atribut | Popis |
|---|---------|
Bez atributu | Kompilátor sám rozhodne, zda má být funkce inlinenutá. Rozhodnutí závisí jak na nastavení kompilátoru, jako je úroveň optimalizace, tak i na velikosti funkce, zda je funkce generická a zda se funkce nachází v jiné knihovně.
`#[inline]` | Naznačuje kompilátoru, že by funkce asi měla být inlinenutá.
`#[inline(always)]` | Silně naznačuje, že by funkce by měla být vždy inlinenutá, ale kompilátor může požadavek i tak odmítnout.
`#[inline(never)]` | Silně naznačuje, že by funkce by neměla být inlinenutá.

: Popis `inline` atributu [@inlining_rust_perf_book; @inlining_in_rust_medium] {#tbl:inline_attr}

```{.rust .linenos}
fn funkce1(a: i32, b: i32, c: i32) -> i32 {
    return (a + c) * b;
}
fn funkce2(a: i32, b: i32) -> i32 {
    return a * a - b;
}

fn main() {
    let a = 5;
    let b = 12;
    let c = 25;

    let r1 = funkce1(a, b, c);
    let r2 = funkce1(c, a, b);
    let res = funkce2(r1, r2);
}
```

: Příklad kódu před inliningem {#lst:inlining_in_example}

Před inliningem v hlavní funkci jsou volané funkce `funkce1` a `funkce2`,
které mají velmi jednoduché tělo funkce a měly by být kompilátorem inlinenuté.

```{.rust .linenos}
fn main() {
    let a = 5;
    let b = 12;
    let c = 25;

    let r1 = (a + c) * b;
    let r2 = (c + b) * a;
    let res = r1 * r1 - r2;
}
```

: Příklad kódu po inliningu {#lst:inlining_out_example}

Po inliningu jsou v hlavní funkci volané funkce nahrazeny tělem těchto funkcí.
Zde by samozřejmě kompilátor neskončil a odoptimalizoval i samotné počty,
protože již zná všechny operandy (nakonec by v hlavní funkci zbylo jen `let res = 129415`).
Toto kód je jen pro ilustraci, na které je vidět jak inlining funguje.

