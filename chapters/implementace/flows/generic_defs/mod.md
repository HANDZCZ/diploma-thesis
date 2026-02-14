
## Makro define_flow_and_ioe_conv_builder

Makro `define_flow_and_ioe_conv_builder` je pomocné makro,
které kombinuje makra `define_flow` a `define_builder`
za účelem vytvoření toku se stejnou strukturou a builderem,
ale s jinou funkcí.
Na vstupu bere všechny parametry obou maker
a vnitřně pomocí těchto parametrů volá tyto makra,
která vygenerují definici toku a builderu.
Díky tomuto makru je velice jednoduché definovat nový tok,
který se liší pouze ve funkcionalitě či dodatečných požadavcích.

