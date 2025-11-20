
## Toky dat

Tok dat je programovací princip, který modeluje program jako orientovaný graf dat proudících mezi operacemi.
Díky datovým tokům vznikly lepší, odolnější a škálovatelnější distribuované systémy,
lepší kompilátory a lepší databáze.
[@utility_of_dataflow_computing; @concepts_of_distributed_programming]

Klasicky je program modelován jako postup operací, které se dějí v určitém pořadí.
Tento postup lze nazvat sekvenčním, procedurálním, řízeným tokem.
Oproti tomu programování datových toků klade důraz na pohyb dat a modeluje programy jako řetězce operací.
Každé spojení mezi operacemi znamená přesun či kopírování dat do další operace.
Každá operace a spojení má jednoznačně definované vstupy a výstupy, které fungují jako černé skříňky.
[@utility_of_dataflow_computing; @concepts_of_distributed_programming]

