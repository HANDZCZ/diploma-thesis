
## Nefunkční požadavky

Tato kapitola se zabývá nefunkčními požadavky,
které určují kvalitativní vlastnosti navrhované knihovny.
Tyto požadavky nespecifikují konkrétní funkčnost,
ale popisují očekávané vlastnosti systému,
jako je výkon, spolehlivost a použitelnost.

### Výkon

Režie knihovnou definovaných toku by měla být co nejmenší.
Toky by měly efektivně využívat systémové zdroje.
Neměly by alokovat paměť, která nemusí být využita
a neměly by zbytečně blokovat vlákno a tak zabraňovat dalším úlohám v běhu.

### Dokumentace

Knihovna musí mít plnou dokumentaci s ukázkami.
Dokumentace a chybová hlášení musí být srozumitelná.
Dokumentace prvků knihovny musí vysvětlovat k čemu slouží a jak fungují.
Design API knihovny by měl být snadno pochopitelný a intuitivní.

### Struktura kódu

Kód knihovny by měl být modulární, dobře strukturovaný a obsahovat testy.
Testy by měly testovat funkčnost toků,
krajní případy a hlavně by měly selhat již při kompilaci,
když nebudou splněny podmínky toků.

### Přenositelnost a kompatibilita

Knihovna by měla být kompatibilní s různými operačními systémy, na který Rust běží.
Hlavně musí být kompatibilní s operačními systémy Windows a Linux.
Knihovna by také měla být kompatibilita pokud možno se všemi asynchronními runtimy v Rustu.
Hlavně by měla být kompatibilní s [tokio](https://docs.rs/tokio/latest/tokio/)
a [smol](https://docs.rs/smol/latest/smol/) runtimy.
Kvůli těmto důvodům by knihovna měla obsahovat co nejméně závislostí,
aby bylo možno použít tuto knihovnu pokud možno kdekoliv a s čímkoliv.

