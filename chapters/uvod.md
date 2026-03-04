
# Úvod

<!--
Záměrem úvodu je uvést do problematiky práce, vysvětlit důvod volby tématu práce
a vymezit problémovou situaci, která bude v bakalářské/diplomové práci řešena.
-->

V dnešní době je software čím dál komplexnější a komplikovanější.
Komplexní software je většinou rozdělen na moduly,
které spolu spolupracují a uživateli poskytují jen nezbytná rozhraní
pro komunikaci či manipulaci s nimi.
Díky tomuto přístupu je možno tyto moduly měnit vnitřně jak je potřeba.
Tyto moduly se vnitřně skládají z různých stavebních bloků,
jako jsou funkce, různé struktury, primitiva a jejich kombinace.

Jednou z těchto technik je vytváření datových toků,
kde každý tok je složen z uzlů, které dělají jen základní jednotku práce,
jako je například získání dat ze serveru nebo parsování dat do nějakého formátu.
Tyto jednoduché uzly jsou poté skládány do toků,
které mají různé mechanismy pro běh a správu těchto uzlů,
a tím vytvářejí komplexní operace.

Tato práce se zabývá tvorbou, definicí a limitacemi datových toků,
které jsou definovány a jejich požadavky jsou kontrolovány za kompilace programu.
Pro dosažení tohoto cíle je vytvořena analýza funkčních a nefunkčních požadavků.
Na základě této analýzy je vytvořen návrh pro definici a kompozici toků a uzlů.
Implementace poté využívá vytvořeného návrhu a navazuje na něj definicí
a implementací různých typů toků, kontextového systému,
definicí základních traitů a jednotek.

Tvorba nové knihovny a téma této diplomové práce bylo zvoleno,
protože existující knihovny nevyužívají jednu z nejsilnějších vlastností jazyka Rust,
což je jeho typový systém, a pro vytváření a kontrolu datových typů používají reflexi za běhu.
Toto způsobuje, že chyby, které by mohly být řešeny při kompilaci jsou řešeny za běhu programu
a bez rozsáhlých testů často nejsou zachyceny.
Dále také tento přistup způsobuje, že kompilátor není schopen kód programu pořádně optimalizovat,
protože nevidí konkrétní datové typy.

\newpage

