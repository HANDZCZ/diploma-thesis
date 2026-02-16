
# Implementace popisu uzlů a toků {#sec:node_describe_chapter}

Pro účely vizualizace a introspekce byly vytvořeny strukturu k popisu uzlů a toků.
Tyto struktury plně popisují vstupy a výstupy uzlů, u toků také plně popisují jak jsou uzly propojeny,
včetně typu kontextu, popisu poskytnutého uživatelem a externích zdrojů použitých při běhu uzlu.

## Enum Description

```{.rust .linenos}
pub enum Description {
    Node {
        base: DescriptionBase,
    },
    Flow {
        base: DescriptionBase,
        nodes: Vec<Description>,
        edges: Vec<Edge>,
    },
}
```

: Implementace enumu `Description` {#lst:enum_description_impl}

Enum `Description` je nejvyšší vrstva, která může reprezentovat popis uzlu či toku.
Pro popis uzlu i toku je použit struct `DescriptionBase`
a u toků je ještě potřeba znát popisy vnitřních uzlů a jejich propojení.
Díky těmto propojením lze poté sestrojit vizualizační graf.

Pro tento enum je také implementováno několik pomocných funkcí a metod,
jejichž implementace je zdlouhavá, ale triviální.
Funkce `new_node` bere referenci na uzel a vrací vyplněný `Description`.
Nápodobně funkce `new_flow` bere referenci na tok, popisy vnitřních uzlů,
jejich propojení a vrací vyplněný `Description`.
Vnitřně funkce `new_node` a `new_flow` volají funkce z `DescriptionBase`
a výstup z těchto funkcí je použít pro vytvoření enumu `Description`.
Metody `get_base_ref` a `get_base_mut` jsou pomocné metody,
které zjednodušují získání `DescriptionBase`.
Poté také existují metody `with_description`, `with_externals` a `modify_name`,
což jsou pomocné metody, které jsou zde pro jednodušší úpravu hodnot vnořených atributů.

## Struct DescriptionBase {#sec:description_base_struct}

```{.rust .linenos}
pub struct DescriptionBase {
    pub r#type: Type,
    pub input: Type,
    pub output: Type,
    pub error: Type,
    pub context: Type,
    pub description: Option<String>,
    pub externals: Option<Vec<ExternalResource>>,
}

impl DescriptionBase {
    pub fn from<NodeType, Input, Output, Error, Context>() -> Self { .. }

    pub fn from_node<NodeType, Input, Output, Error, Context>(_node: &NodeType) -> Self where NodeType: Node<Input,NodeOutput<Output>, Error, Context> {
        Self::from::<NodeType, Input, Output, Error, Context>()
    }

    pub fn with_description(mut self, description: impl Into<String>) -> Self { .. }
    pub fn with_externals(mut self, externals: Vec<ExternalResource>) -> Self { .. }
}
```

: Implementace structu `DescriptionBase` {#lst:struct_description_base_impl}

Struct `DescriptionBase` je struktura, která slouží jako základ k popisu typu uzlu nebo toku,
vstupu, výstupu, chyby, kontextu, textového popisu a externích zdrojů.

Pro tuto strukturu jsou také implementovány pomocné metody a funkce.
Funkce `from` vytváří struct `DescriptionBase` z poskytnutých datových typů.
Funkce `from_node` bere referenci na uzel a pomocí funkce `from` vytváří struct `DescriptionBase`.
Poté jsou také implementovány pomocné metody `with_description` a `with_externals`,
které nastavují atributy této struktury.

## Struct Type

```{.rust .linenos}
pub struct Type {
    pub name: String,
}

impl Type {
    pub fn of<T>() -> Self { Self { name: type_name::<T>().to_owned() } }
    pub fn of_val<T>(_: &T) -> Self { Self::of::<T>() }

    pub fn get_name_simple(&self) -> String {
        tynm::TypeName::from(self.name.as_str()).as_str()
    }
}
```

: Implementace structu `Type` {#lst:struct_type_impl}

Struct `Type` slouží k popisu datového typu a má jediný atribut,
kterým je název daného datového typu.
Obsahuje funkce `of` a `of_val`, které využívají vestavěné funkce `std::any::type_name`
k získání názvu datového typu.
Tato struktura, také obsahuje metodu `get_name_simple`,
která vrací zjednodušený název datového typu,
například pro datový typ `std::option::Option<std::string::String>`
vrací `Option<String>`.
Díky této metodě je možno redukovat informační zahlcení
a tím docílit vytváření přehlednějších vizualizací.

## Stuct Edge a enum EdgeEnding

```{.rust .linenos}
pub struct Edge {
    pub start: EdgeEnding,
    pub end: EdgeEnding,
}

pub enum EdgeEnding {
    ToFlow,
    ToNode {
        node_index: usize,
    },
}
```

: Implementace structu `Edge` a enumu `EdgeEnding` {#lst:describe_edge_impl}

Struct `Edge` a enum `EdgeEnding` slouží k reprezentaci hran v orientovaném grafu,
pro vizualizaci struktury toku a propojení uzlů.

Enum `EdgeEnding` vyjadřuje k čemu má být jeden z konců hrany připojen.
Hodnota `ToFlow` znamená, že je konec hrany připojen k toku
a hodnota `ToNode` připojí konec hrany k uzlu,
který se nachází na indexu `node_index`.
Tento index také slouží pro vybrání popisu uzlu v enumu `Description`.

Pro struct `Edge` jsou také implementovány pomocné funkce `passthrough`,
`flow_to_node`, `node_to_flow` a `node_to_node`.
Tyto funkce usnadňují vytváření struktury `Edge`,
tím že uživatel poskytne na vstupu 0 až 2 parametry,
což jsou indexy uzlů, a získá vytvořenou strukturu.

## Struct ExternalResource

```{.rust .linenos}
pub struct ExternalResource {
    pub r#type: Type,
    pub description: Option<String>,
    pub output: Type,
}

impl ExternalResource {
    pub fn new<ResourceType, Output>() -> Self { .. }
    pub fn with_description(mut self, description: String) -> Self { ..}
}
```

: Implementace structu `ExternalResource` {#lst:struct_external_resource_impl}

Struct `ExternalResource` slouží k popisu nějakého externího zdroje,
který uzel potřebuje ke svému běhu, poskytovaného nějakou službou.
Obsahuje atributy pro jméno datového typu služby, textový popis
a jméno datového typu externího zdroje.
Pro tuto strukturu je také implementovaná funkce `new`,
která z přijatých generických typů vytváří struct `ExternalResource`.
Dále je také implementována pomocná metoda `with_description`,
které nastavuje atribut `description`.

## Privátní funkce remove_generics_from_name

```{.rust .linenos}
pub(crate) fn remove_generics_from_name(orig_name: &mut String) {
    let generic_start_idx = orig_name.find('<').unwrap_or(orig_name.len());
    orig_name.truncate(generic_start_idx);
}
```

: Implementace funkce `remove_generics_from_name` {#lst:remove_generics_from_name_impl}

Funkce `remove_generics_from_name` je pomocná privátní funkce,
která odstraňuje vše za a včetně generických parametrů v řetězci.
Tohoto je docíleno, tak že se najde první lokace znaku otevírací špičaté závorky (`<`)
v řetězci a originální řetězec je zkrácen na tento nalezený index.
Tato funkce je použita při vytváření popisů pro toky.
Díky této pomocné funkci a pomocné funkci `Description::modify_name`
je úprava jména datového typu toku výrazně zjednodušena.

## Konfigurovatelný D2 formátovač popisů uzlů a toků

Pro vytváření vizualizací uzlů a toků je implementován konfigurovatelný formátovač popisů.
Tento formátovač převádí popis uzlu či toku do [D2 jazyka](https://d2lang.com/) pro vytváření grafů.
Ukázka vygenerované vizualizace ([@fig:d2describer_output_example]) se nachází v přílohách.

```{.rust .linenos}
pub struct D2Describer {
    pub simple_type_name: bool,
    pub show_context_in_node: bool,
    pub show_description: bool,
    pub show_externals: bool,
}

impl D2Describer {
    pub fn new() -> Self { .. }
    pub fn modify(&mut self, func: impl FnOnce(&mut Self)) -> &mut Self { .. }
    pub fn format(&self, desc: &Description) -> String { .. }
}
```

: Implementace structu `D2Describer` {#lst:struct_d2describer_impl}

Struct `D2Describer` definuje vše potřebné pro převod popisů uzlů
a toků do D2 jazyka a obsahuje přepínače pro konfiguraci formátovače.
Atribut `simple_type_name` rozhoduje zda mají mít datové typy zjednodušený název pomocí metody `Type::get_name_simple`
a atributy `show_context_in_node`, `show_description` a `show_externals` rozhodují o tom,
jestli výsledný graf má obsahovat datový typ kontextu, textový popis a externí zdroje.

Pro tento struct je implementována funkce `new`, pro vytvoření tohoto structu s výchozím nastavením.
Dále je implementována metoda `modify`, pro jednoduchou úpravu nastavení,
a metoda `format`, která převádí popis uzlu či toku do D2 jazyka a vrací výsledný řetězec.

