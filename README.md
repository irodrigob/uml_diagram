# Objetivo/Objective
A través del siguiente [proyecto](https://gitlab.com/geertjanklaps/abap-openapi-ui) descubri la herramienta web YUML para diagramas UML. / Through the following [project](https://gitlab.com/geertjanklaps/abap-openapi-ui) I discovered the YUML web tool for UML diagrams.

Investigando un poco descubir que había otros proyectos pero al instalar me dio muchos problemas de compilación y además su arquitectura no me gusto. Fue en ese momento que pense en hacerlo yo mismo aprovechando que tenía parte del trabajo realizado gracias a este [proyecto](https://github.com/irodrigob/reference_object), que fue unos de los primeros que subi a Github. / Investigating a little to discover that there were other projects but when installing it gave me a lot of compilation problems and besides his architecture i didn't like it. It was at that moment that i thought about doing it myself taking advantage of the fact that I had part of the work done thanks to this [project](https://github.com/irodrigob/reference_object), which was one of the first ones that went up to Github.

# Dependencias/Dependencies

Hay que tener instalado el repositorio "http_services"(https://github.com/irodrigob/reference_object) para su funcionamiento. / The "http_services" repository (https://github.com/irodrigob/reference_object) must be installed for its operation.

# Programa/Program

![SelectionScreen](https://github.com/irodrigob/uml_diagram/blob/master/docs/selection_screen.png)

La pantalla de selección es muy simple. Pudiendo buscar: paquete(busca los objetos de ese paquete), clases, interfaces y report. / The selection screen is very simple. Being able to search: package (search for the objects in that package), classes, interfaces and report.

Y las opciones de salida en YUML: Ver el código para usarlo en su página web o visualizar directamente en el navegador. / And the output options in YUML: See the code to use it on your website or view directly in the browser.

El listado que se muestra siempre es este: / The list shown is always this:

![Output](https://github.com/irodrigob/uml_diagram/blob/master/docs/alv_output.png)

El código generado se vería así: / The generated code would look like this:

![Code](https://github.com/irodrigob/uml_diagram/blob/master/docs/yuml_code.png)

Y si se visualiza en el navegador se ve así: / And if it is displayed in the browser it looks like this:

![Navigator](https://github.com/irodrigob/uml_diagram/blob/master/docs/yuml_html_display.png)

# Flechas usadas de YUML/Used YUML arrows

## Herencia/Inheritance
![Inheritance](https://github.com/irodrigob/uml_diagram/blob/master/docs/yuml_arrow_inheritance.png)

## Interfaces declaradas en la clase/Interfaces declared in the class
![Interface in class](https://github.com/irodrigob/uml_diagram/blob/master/docs/yuml_arrow_interface_declared_class.png)

## Objeto utilizado dentro de un objeto / Object used within an object
![Use](https://github.com/irodrigob/uml_diagram/blob/master/docs/yuml_arrow_use.png)


