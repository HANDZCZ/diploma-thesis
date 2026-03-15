
## Budoucí vývoj

Jak se ukázalo z experimentů,
tak definice toků za pomocí static dipspatche ([@sec:static_dispatch]) má své výhody, ale i nevýhody.
Mezi tyto nevýhody hlavně patří větší velikost výsledného binárního souboru a delší kompilace.
Z tohoto důvodu by se další verze knihovny měly soustředit na implementaci dalších toků,
které mají stejnou funkcionalitu, ale používají dynamic dispatch ([@sec:dynamic_dispatch]).

Implementací těchto dynamic dispatch toků se uživateli poskytne možnost
vybrat si, zda chce používat dynamic či static dispatch.
Pro tvorbu dynamic dispatch uzlů by měl být implementován nějaký obal,
který by dovolil použít trait objekty uzlů jako konkrétní uzly.
Za pomocí těchto dodatečných implementací
by poté bylo možno libovolně míchat static a dynamic dispatch
ve stejném toku i při skládání toků.

Dále traity `Join` ([@sec:trait_join]) a `Merge` ([@sec:local_storage_trait_merge]) používá datový typ `Box<[Self]>`,
který je pevně dán a vždy alokuje paměť na heap.
Tyto traity by neměly využívat datový typ `Box<T>` ([@sec:box]), ale generický typ,
který musí implementovat nějaké traity, jako je například trait [`Index<Idx>`](https://doc.rust-lang.org/std/ops/trait.Index.html),
který slouží k získání elementu za pomocí nějakého indexu.
Použitím generického typu si uživatel knihovny poté může vybrat,
zda chce paměť alokovat na heap, nebo na stack a jaká struktura má být použita.

Budoucí verze knihovny by také mohla obsahovat
vytváření toků dynamicky za běhu programu, například za pomocí json dokumentu.
Toto by ale znamenalo přidat tok, který kontroluje veškeré datové typy za běhu programu.
Což jde proti ideálům této knihovny, přenesení co nejvíce kontrol
a možných chyb na krok kompilace.
Z tohoto důvodu by mohla být vytvořena nová knihovna,
která bude používat stavební bloky z této knihovny.
Pokud by uživatel poté potřeboval vytvořit tok dynamicky,
tak by importoval obě knihovny a mohl by je i kombinovat.

