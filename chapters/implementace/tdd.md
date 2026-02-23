
# Testování, dokumentace a dostupnost

Všechny zdrojové kódy implementace, testů a dokumentace knihovny
je možno nalézt v jednom repozitáři na autorově GitHubu.
Tento repozitář se na nachází na adrese <https://github.com/HANDZCZ/node-flow/>.

V této práci je popsána verze knihovny `v0.2.0` s MSRV (**M**inimum **S**upported **R**ust **V**ersion) `1.90.0`.
Tato knihovna je také dostupná na oficiálním registru balíčků pro programovací jazyk Rust [`crates.io`](https://crates.io/).
Na tomto registru je také možno najít dokumentaci pro jednotlivé verze knihovny
a v repozitáři je odkaz na [GitHub Pages](https://handzcz.github.io/node-flow/),
který obsahuje aktuální dokumentaci pro větev `main`.

Dokumentace je vytvořena pro každou strukturu,
která je uživateli této knihovny dostupná.
Pro každou tuto strukturu je popsáno co dělá a jak se chová, nebo k čemu slouží.
Dále také dokumentace pro tyto struktury obsahuje ukázku použití
a dodatečné odkazy na další struktury, které by uživateli umožnily lépe pochopit,
jak se má daná struktura vytvořit a kde a k čemu je ji možno použít.

Pro struktury této knihovny, ať už privátní či veřejné,
jsou vytvořeny unit testy, tam kde je potřeba testovat jejich funkčnost či jiné vlastnosti nebo omezení.
Dále také existují testy na kontrolu, jak se toky chovají,
když nejsou splněny jejich požadavky, aby práce s touto knihovnou byla co nejintuitivnější
a aby chyby generované kompilátorem byly přehledné a dávali uživateli smysl.

Například u toků je testován zvlášť "chainrun" a celý tok,
aby se izolovalo, zda se jedná o chybu v implementaci "chainrun" do toku či samotné logiky toku.
Dalším příkladem jsou úložiště, kde je nutno otestovat nejen celé úložiště na povrchové úrovni,
ale i jejich jednotlivé části.

V přílohách ([@lst:shortened_tests_run]) je uveden zkráceny běh testů,
ve kterém lze vidět, že testy se nacházejí ve více místech.
Většina testů se nachází se přímo u definice struktur,
ale komplexnější testy, které například skládají více toků do sebe,
se nachází v samostatných souborech.
Dále je vidět, že ukázky v dokumentaci jsou také testovány,
za pomocí takzvaných "Doc-testů."

