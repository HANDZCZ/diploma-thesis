
## Dyn kompatibilita {#sec:dyn_compatibility}

Dyn kompatibilita se používá u traitů a značí zda lze trait použít při definici trait objektu.
Pokud je trait dyn kompatibilní, tak je možné vytvořit vtable a lze tento trait použít jako trait objekt,
ale pokud trait není dyn kompatibilní, tak to znamená,
že nelze vytvořit vtable a nelze tento trait použít jako trait objekt.
[@rust_reference_dyn_compatibility]

```{.rust .linenos}
trait DynKompatibilni {
    fn tiskni(&self);
    fn ziskej_hodnotu(&self) -> u32;
    fn nastav_hodnotu(&mut self, val: u32);
}
```

: Příklad dyn kompatibilního traitu {#lst:dyn_compatible_trait_example}

```{.rust .linenos}
trait DynNekompatibilni {
    fn duplikuj_sebe(&self) -> Self;
      // při použití např. Vec<&dyn DynNekompatibilni> by každá instance typu
      // implementující tento trait vracela jiný výstupní typ

    fn ziskej_typ() -> TypeId;
      // <dyn DynNekompatibilni>::ziskej_typ() není možno zavolat,
      // protože chybí nějaký ukazatel na konkrétní typ (např. &self)
      // a tím pádem není možno přistoupit k vtablu

    fn pridej<T: Into<u64>>(&self, val: T);
      // v tomto případě by vtable musel obsahovat všechny variace této funkce,
      // se kterými tato metoda byla volána,
      // což by způsobilo, že vtable bude obrovský a dále by bylo potřeba, aby
      // kompilátor nalezl všechny invokace přes celý projekt a jeho závislosti
}
```

: Příklad dyn nekompatibilního traitu {#lst:not_dyn_compatible_trait_example}

