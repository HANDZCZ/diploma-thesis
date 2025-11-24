
## Trait Any, downcasting a TypeId

Trait objekty `dyn Any` slouží hlavně k odstínění konkrétního datového typu.
Tímto umožňují například vytvoření heterogenních kolekcí a reflexi za běhu programu.
Na těchto trait objektech je poté možno použít různé downcast metody,
které se pokusí vrátit object s konkrétním datovým typem.
K tomuto účelu také slouží `TypeId`, což je identifikátor pro datový typ.
[@rust_docs_any_module; @rust_docs_typeid; @rust_docs_any_trait]


### TypeId

TypeId je globálně unikátní identifikátor datového typu.
Existuje také funkce `TypeId::of<T>()`, která vrací `TypeId` pro konkrétní datový typ `T`.
[@rust_docs_typeid]

```{.rust .linenos}
use std::any::TypeId;

fn is_string<T: ?Sized + 'static>(_: &T) -> bool {
    TypeId::of::<String>() == TypeId::of::<T>()
}

assert_eq!(is_string(&0), false);
assert_eq!(is_string(&"cookie monster".to_string()), true);
```

: Příklad použítí `TypeId::of<T>()` funkce [@rust_docs_typeid] {#lst:typeid_of_example}


### Trait `Any`

Trait `Any` je jedním z hlavních stavebních bloků pro dynamické typování a runtime reflexi.
Obsahuje pouze jednu metodu `type_id`, která vrací `TypeId`, konkrétního datového typu.
Tato metoda je hlavně využita při použití trait objektu `dyn Any`.
Existuje také obecná implementace, která implementuje tento trait pro všechny datové typy,
které splňují tzv. `'static` lifetime.
[@rust_docs_any_trait]

```{.rust .linenos}
use std::any::{Any, TypeId};

fn is_string(s: &dyn Any) -> bool {
    TypeId::of::<String>() == s.type_id()
}

assert_eq!(is_string(&0), false);
assert_eq!(is_string(&"cookie monster".to_string()), true);
```

: Příklad použítí traitu `Any` [@rust_docs_any_trait] {#lst:any_trait_example}


### Downcast metody

Downcast metody slouží k získání reference či instance konkretního datového typu z `dyn Any` trait objektu nebo `Box<dyn Any>`.
[@rust_docs_any_trait]

| Metoda | Popis | Implementováno pro |
|------|-----------|---------|
`is<T>` | Vrací zda je vnitřní datový typ stejný jako datový typ `T`. | `dyn Any`,<br>`dyn Any + Send`,<br>`dyn Any + Send + Sync`
`downcast_ref<T>` | Vrací referenci na vnitřní hodnotu jako datový typ `T`, pokud je datový typ stejný. | `dyn Any`,<br>`dyn Any + Send`,<br>`dyn Any + Send + Sync`
`downcast_mut<T>` | Vrací měnitelnou referenci na vnitřní hodnotu jako datový typ `T`, pokud je datový typ stejný. | `dyn Any`,<br>`dyn Any + Send`,<br>`dyn Any + Send + Sync`
`downcast<T>` | Vrací vnitřní hodnotu jako datový typ `Box<T>`, pokud je datový typ stejný. | `Box<dyn Any>`,<br>`Box<dyn Any + Send>`,<br>`Box<dyn Any + Send + Sync>`
Unchecked downcast varianty | Vrací to samé jako základní varianty, akorát nekontrolují zda vnitřní datový typ je stejný. ||

: Popis implementováných metod pro pro varianty traitu `Any` [@rust_docs_any_trait] {#tbl:any_methods}


