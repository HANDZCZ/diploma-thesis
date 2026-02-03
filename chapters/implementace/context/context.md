
# Implementace kontextového systému

Implementovaný kontextový systém vychází z návrhu kontextového systému
pomocí generického typu ([@sec:generic_type_for_kontext]).
Hlavní myšlenkou je dovolit uživateli omezovat kontext pro každý uzel zvlášť podle jeho potřeby.
Díky této implementaci mohou uživatelé této knihovny definovat vlastní omezovací traity,
které nejsou součástí této knihovny.

V této kapitole jsou probírány a popsány implementace základních traitů
pro práci s kontextem, traity pro vytváření synchronních a asynchronních úloh
a traity pro práci s lokálním a sdíleným úložištěm.
Dále jsou zde také popsány implementace konkrétních úložišť,
které implementují traity pro lokální nebo sdílené úložiště.

```{.include shift-heading-level-by=1}
traits.md
local_storage.md
shared_storage.md
```

