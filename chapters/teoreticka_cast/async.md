
## Asynchronní programování

Asynchronní programování je efektivní přístup ke zlepšení výkonu systémů s vysokou zátěží,
jelikož umožňuje souběžné provádění úloh bez blokování provádění jiných úloh.
Na rozdíl od synchronního programování, kde jsou úlohy prováděny postupně,
asynchronní programování umožňuje systému zpracovávat více operací současně,
což vede k rychlejším odezvám a efektivnějšímu využití prostředků.
[@async_programming_techniques; @async_iot_embedded]

Ve srovnání se synchronním programováním nabízí asynchronní programování
lepší výkon v aplikacích závislých na I/O operacích,
protože umožňuje systému zpracovávat více operací,
a to bez nutnosti čekat na dokončení každé z nich.
U úloh náročných na výpočetní výkon však může být zlepšení výkonu méně patrné,
nebo může dojít ke zpomalení, protože úlohy je stále nutné zpracovávat postupně na jednom jádru procesoru.
[@async_programming_techniques; @async_iot_embedded]

![Porovnání asynchronního a synchronního zpracování [@async_picture]](../../pictures/sync_vs_async.png){#fig:async_comparison}

