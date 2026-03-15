
## Porovnání s existujícími řešeními

Tato knihovna zatím nemá žádnou konkurenci, ani podobná řešení se stejnými ideály.
Existují řešení s podobným nápadem, poskytnutí knihovny pro vytváření toků,
ale tyto knihovny využívají pouze trait objekty a sdílené úložiště
bez explicitních vstupů a výstupů.

Jednou z těchto knihoven je knihovna [`freactor`](https://crates.io/crates/freactor),
která reprezentuje základní asynchronní jednotku práce asynchronní funkcí,
která má jediný vstup, což je kontext.
Všechna práce s daty probíhá přes kontext, což je jednoduché úložiště s klíčem `String`
a nějakou hodnotou typu json.
Typ toho úložiště je pevně daný, uživatel nemůže použít jiný typ úložiště,
a nemůže na toto úložiště klást žádné požadavky.
Uzly v tocích jsou uloženy za pomocí trait objektů a dynamic dispatch probíhá vždy.

Díky tomu, že knihovna `freactor` výhradně využívá trait objekty oproti této knihovně,
tak může nabízet dynamické vytváření toků za běhu programu.
Tohoto rozdílu knihovna využívá velmi dobře, protože nabízí definici celého toku
jen za pomocí jednoho json dokumentu, který obsahuje název asynchronních funkcí
a jak jsou mezi sebou propojeny.
Bohužel oproti této knihovně, knihovna `freactor` nemá žádnou dokumentaci,
kromě úvodní stránky na repozitáři, a nebylo ji možno dále porovnat s autorovou knihovnou
a zjistit, zda podporuje skládání toků.

Další podobnou knihovnou je knihovna [`graph-flow`](https://crates.io/crates/graph-flow),
která reprezentuje základní jednotku strukturou implementující trait `Task`,
podobně jako tato knihovna reprezentuje základní jednotku traitem `Node`,
obsahuje trait `Task` metodu `run` pro definici běhu.
Tato funkce, ale podobně jako předchozí knihovna bere pouze kontext.
Dále také trait `Task` obsahuje metodu `id`,
která vrací unikátní identifikátor pro uzel v toku.

Kontext v knihovně `graph-flow` je implementován úplně stejně jako v předchozí knihovně
a se stejnými limitacemi.
Dále díky tomu, že také výhradně využívá trait objekty, tak je možné vytvářet toky dynamicky.
Oproti předchozí knihovně si liší v tom, že umožňuje používat `if/else` logiku pro hrany mezi uzly,
toky se vytvářejí přes metody, nemá jednoduché vytváření toků přes json, a má dokumentaci.

Autorem vytvořená knihovna v porovnání s knihovnami `freactor` a `graph-flow`
nepodporuje vytváření toků dynamicky a za běhu programu,
kvůli tomu, že tato verze knihovny se soustředí na implementaci statických toků.
Díky tomu je ale schopna, na rozdíl od porovnávaných knihoven,
provést kontrolu požadavků na kontext, vstupních, výstupních
a chybových datových typů při kompilaci programu.
Oproti těmto knihovnám také umožňuje skládání toků a možnost odoptimalizace await bodů.
Dále nabízí rozsáhlou dokumentaci a aspoň jednu ukázku použití u každé funkce, metody či struktury.
Obsahuje také plno testů, jak pro kontrolu logiky, tak i ergonomiky knihovny,
které chybí v porovnávaných knihovnách.

