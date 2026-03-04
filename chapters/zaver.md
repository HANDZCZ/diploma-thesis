
# Závěr

<!--
Závěr představuje shrnutí toho, jaká problematika byla v práci řešena,
co bylo cílem práce a jak výsledky práce cíl či cíle naplňují.
-->

Cílem diplomové práce bylo provést analýzu funkčních a nefunkční požadavků,
navrhnout možné řešení, pro tvorbu a kompozici uzlů a toku, a implementovat jej.

Celé řešení pokud možno němá využívat dynamic dispatch a trait objekty.
Tohoto cíle bylo dosaženo pro toky, uzly a kontextový systém.
Pro implementované úložiště však z praktických důvodů byly použity trait objekty.
Toto rozhodnutí, ale neomezuje uživatele, protože,
díky implementaci generického kontextu,
uživatel může použít jakoukoli implementaci úložiště
a není mu vnucena ta poskytovaná touto knihovnou.

Použitím pouze static dispatche pro běh, definici a skládaní toků a uzlů
by měl být kompilátor schopen lépe optimalizovat kód.
Tohoto cíle bylo také dosaženo a kompilátor je schopen optimalizovat kód
napříč uzly i toky.

Dalším cílem také bylo, aby uzly byly schopné klást požadavky na kontext
a tím docílit toho, že je jim vždy poskytnuta nějaká funkcionalita.
Tohoto cíle bylo také plně dosaženo a uzly mohou klást požadavky nejen na kontext,
ale i na vstup a výstup.
Tyto požadavky jsou také kontrolovány za kompilace a je možno předejít zbytečným chybám
za běhu programu.

V závěru tedy se autorovy povedlo navrhnout a implementovat plně statickou knihovnu,
která dovoluje provést veškeré kontroly, kompatibility mezi vstupem a výstupem uzlů či toků
a požadavků na kontext, na krok kompilace programu.
Dále také tato knihovna umožňuje kompilátoru lépe optimalizovat kód díky tomu,
že kompilátor zná veškeré datové typy použité v toku.

Dále je také probírán budoucí vývoj,
kde autor chce implementovat další toky,
které tentokrát budou používat dynamic dispatch.
Uživatel by byl poté schopen si vybrat,
zda chce používat dynamic nebo static dispatch,
nebo dokonce i jejich kombinaci.

\newpage

