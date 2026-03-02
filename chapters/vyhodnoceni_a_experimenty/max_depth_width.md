
## Maximální hloubka toku

V kapitole "Implementace toků" ([@sec:flows_implementation])
bylo vzneseno tvrzení
"teoreticky lze vytvářet vnořené toky s nekonečnou hloubkou, avšak v realitě by uživatel jistě narazil na nějaký limit."
Pro zjištění právě tohoto limitu byl vytvořen experiment,
který skládá `SequentialFlow` toky do sebe.
Tok `SequentialFlow` byl vybrán, protože při reálném použití je tento tok nejvíce využíván.

Při výchozím nastavení "recursion_limit," což je 128, bylo dosaženo hloubky 25
a i při této hloubce byl kompilátor schopen odoptimalizovat celý složený tok na jednu `add` instrukci.
Po překročení této hloubky již bylo nutno navýšit "recursion_limit."

Tento limit byl poté navyšován až na hodnotu 8191 a bylo dosaženo aspoň hloubky 1296.
Při této hloubce byl ještě kompilátor schopný program zkompilovat.
Při dalším navýšení hloubky o 128, již přeteče stack kompilátoru.
Tento test proběhl na Linux systému a kompilátor měl k dispozici
výchozí velikost stacku, což je 8 MiB.

## Maximální šířka toku

Podobně jako proběhl experiment pro zjištění maximální hloubky toku,
tak proběhl experiment pro zjištění maximální "šířky" toku.
Šířkou toku je myšleno kolik uzlů je možno do jednoho toku vložit,
než je dosaženo nějakého limitu.
Pro tento experiment byl také použit tok `SequentialFlow` ze stejných důvodů.

Při výchozím nastavení "recursion_limit," bylo dosaženo šířky 23.
Po překročení této šířky již bylo nutno navýšit "recursion_limit."

Tento limit byl poté navyšován až na hodnotu 1644 a bylo dosaženo šířky 327.
Při této šířce byl ještě kompilátor schopný program zkompilovat.
Při navýšení šířky na 328, již přeteče stack kompilátoru stejně jako u experimentu maximální hloubky.
Tento test také proběhl na Linux systému a kompilátor měl k dispozici 8 MiB stacku.

## Maximální kombinovaná hloubka a šířka toku

Experimenty pro maximální hloubkou a šířku probíhaly pouze s jedním uzlem,
nebo jedním tokem, ale při reálném použití této knihovny by toky měly různé hloubky a šířky.
V tomto experimentu bylo testováno jaký je limit pro toky složené z dalších toků,
které obsahují nějaké uzly či další toky.

Poměry toků, uzlů a hloubky byly odhadnuty tak, aby nejvíce odpovídaly reálné práci s touto knihovnou.
Aplikovaním těchto poměrů vznikl tok, který obsahoval 4673 toků, 23008 uzlů,
dosáhl hloubky 358 a potřeboval "recursion_limit" nastavený na 2112.
Při přidání dalších 13 toků, 64 uzlů a navýšeni hloubky na 359 kompilace selže při linkovací fázi,
protože velikost debug symbolů přesahuje velikost sekce.
Po vypnutí generace debug symbolů kompilace skončí úspěšně.

