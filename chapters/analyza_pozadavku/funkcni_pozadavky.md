
## Funkční požadavky

Tato kapitola popisuje funkční požadavky kladené na knihovnu.
Popisuje konkrétní funkce a chování,
které musí knihovna poskytovat pro vytváření asynchronních toků dat.
Tyto požadavky definují, jaké funkce by měla knihovna uživatelům poskytnout
a jaké operace by měla být schopna provádět.

### Definice uzlů a toků

Knihovna musí umožnit definici uzlů a toků, které berou nějaký vstup a vrací nějaký výstup.
Definice uzlu a toku by měla obsahovat nějakou funkci (např. `run()`),
která umožní uživateli volně pracovat se vstupními daty a transformovat je na výstupní data.
Tato funkce musí být asynchronní, aby uživatel mohl pracovat s I/O operacemi efektivně.

### Skládání toků

Knihovna musí umožnit skládání uzlů do toků.
Tyto toky také musí být možno skládat do dalších toků,
a tak vytvářet komplexnější toky.
Při skládání uzlů do toku je nutno, aby bylo jasno jak jsou uzly propojeny,
a jak uzly budou spouštěny.

### Spouštění toků

Spouštění toků by mělo být realizováno pomocí nějaké vhodně nazvané metody, jako je např. `run`.
Tato metoda by měla brát vstupní data a vracet asynchronní úlohu,
na kterou je možno čekat a získat výsledek, což by měly být výstupní data.

### Zpracování chyb

Uzly by měly být schopny vracet chyby, jako jsou výjimky nebo selhání nějaké operace.
Tyto chyby musí být součástí výstupního datového typu,
aby si jich uživatel byl vědom a řešil jejich možné nastání.

### Konfigurace a inicializace uzlů

Knihovna by měla umožnit uživateli definovat vlastní logiku konfigurace uzlu,
jako je maximální počet instancí pro tok nebo i pro uzel, nebo sdílení dat mezi uzly.
Knihovna nemusí tuto logiku poskytovat, ale měla by jí umožnit.
Dále by také knihovna měla umožnit inicializační a domoliční logiku pro uzly.

### Typová bezpečnost a generika

Knihovna musí ověřit za kompilace, že toky je možno sestavit a nedojde k tomu,
že výstup jednoho uzlu není kompatibilní s očekávaným vstupem následujícího uzlu a celý program spadne.
Knihovna by také měla podporovat generické typy pro vstupy a výstupy uzlů,
což umožní uzlům pracovat s různými datovými typy.

