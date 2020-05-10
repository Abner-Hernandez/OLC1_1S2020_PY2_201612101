%{
	const Node = require('./clases/Node');
	const Error = require('./clases/Error');
%}

/* Definición Léxica */
%lex

%options case-sensitive

%%

//SIMBOLOS
//incremento y decremento
"++"              return 'incremento';
"--"              return 'decremento';

//aritmeticos
"+"              return 'suma';
"-"              return 'resta';   
"*"              return 'multiplicacion';
"^"              return 'potencia';
"/"              return 'slash';
"%"              return 'modulo';

//relacionales
">="               return 'mayorigual';
"<="               return 'menorigual';
"<"                return 'menor';
">"                return 'mayor';
"=="               return 'identico';
"==="              return 'referencias';
"!="               return 'diferente';

//simbolos
"["              return 'llavea';     
"]"              return 'llavec';
"{"              return 'corchetea';     
"}"              return 'corchetec';
"("              return 'parenta';     
")"              return 'parentc';
","              return 'coma';
"."              return 'punto';
"="              return 'igual';
";"              return 'puntocoma';
":"              return 'dospuntos';

//logicos
"!"              return 'not';
"&"              return 'and';
"|"              return 'or';



//Reservadas
//"null"                  return 'resnull';
"int"                   return 'resinteger';
"double"                return 'resdouble';
"char"                  return 'reschar';
"import"                return 'resimport';
"true"                  return 'restrue';
"false"                 return 'resfalse';
"if"                    return 'resif';
"else"                  return 'reselse';
"switch"                return 'resswitch';
"case"                  return 'rescase';
"default"               return 'resdefault';
"break"                 return 'resbreak';
"continue"              return 'rescontinue';
"return"                return 'resreturn';
"System.out.println"    return 'resprint';
"println"               return 'resprintln';
"void"                  return 'resvoid';
"for"                   return 'resfor';
"while"                 return 'reswhile';
"do"                    return 'resdo';
"boolean"               return 'resboolean';
"class"                 return 'resclass';
"import"                return 'resimport';

/* Espacios en blanco */
[ \r\t]+                  {}
\n                  {}
"//".*
[/][*][^*]*[*]+([^/*][^*]*[*]+)*[/]

[0-9]+"."[0-9]+\b             			 return 'decimal';
[0-9]+\b                   			     return 'entero';
([a-zA-Z"_"])[a-z0-9A-Z"_""ñ""Ñ"]*       return 'id';
[\'][^][\']                              return 'caracter';
([\"](\\\"|[^\"])*[^\\][^\"])|[^\"][^\"] return 'cadena';

<<EOF>>                 return 'EOF';

.                       { try{ globerrores.push(new Error('LEXICO', yytext, yylloc.first_line, yylloc.first_column));  }catch(e){}}
/lex

/* Asociación de operadores y precedencia */

%right igual
//%right interrogacion
%left incremento
%left decremento
//%left xor
%left or
%left and
%left identico, diferente, referencias
%left mayor, menor, mayorigual, menorigual
%left suma, resta
%left multiplicacion, slash,modulo
%right potencia
%right not
%left parenta,parentc,llavea,llavec

%start ini


/*
                            <li><span class="caret">Green Tea</span>
                              <ul class="nested">
                                <li>Sencha</li>
                                <li>Gyokuro</li>
                                <li>Matcha</li>
                                <li>Pi Lo Chun</li>
                              </ul>
                            </li>
*/

%% /* Definición de la gramática */

ini
	: RCLASS EOF { $$ = $1; globresults.push( $1 ); }  
     | EOF
    	| error { try{ globerrores.push(new Error('SINTACTICO', yytext, @1.first_line, @1.first_column)); }catch(e){} }
    //| error {console.log(yytext);}
;            

IMPORTS
    :IMPORTD { $$ = "<li><span class=\"caret\">IMPORT</span>\n<ul class=\"nested\">\n" + $1; }
    |IMPORTS IMPORTD { $$ = $1 + "<li><span class=\"caret\">IMPORT</span>\n<ul class=\"nested\">\n" + $2; }
;

IMPORTD
    :resimport id puntocoma { $$ = "<li>"+ $1 +"</li>\n" + "<li>"+ $2 +"</li>\n" + "<li>"+ $3 +"</li>\n</ul>\n</li>\n";}
;

CLASSD
    :resclass id corchetea INSTRUCTIONSG corchetec { for(var i = 0 ; i < globresultsFVC.length; i++){globresultsFVC[i].PARENT += "class: " + $2 + " ";} $$ = "<li>"+ $1 +"</li>\n" + "<li>"+ $2 +"</li>\n" + "<li>"+ $3 +"</li>\n" + "<li><span class=\"caret\">CONTENIDO</span>\n<ul class=\"nested\">\n" + $4 + "</ul>\n</li>\n" + "<li>"+ $5 +"</li>\n"; globresultsFVC.unshift({TIPO: "class", VALUE: $2, PARENT: "class"})}
;

RCLASS
    :IMPORTS CLASSD { $$ = "<li><span class=\"caret\">IMPORTS</span>\n<ul class=\"nested\">\n" + $1 + "</ul>\n</li>\n" + "<li><span class=\"caret\">CLASS</span>\n<ul class=\"nested\">\n" + $2 + "</ul>\n</li>\n";}
    |CLASSD {$$ = "<li><span class=\"caret\">CLASS</span>\n<ul class=\"nested\">\n" + $1 + "</ul>\n</li>\n";}
;

INSTRUCTIONSG
	: INSTRUCTIONSG INSTRUCTIONG { $$ = $1 + $2; }
	| INSTRUCTIONG { $$ = $1; }
;

INSTRUCTIONG
	: FUNCTION { $$ = "<li><span class=\"caret\">FUNCION</span>\n<ul class=\"nested\">\n" + $1 + "</ul>\n</li>\n" }
    | DECLARATION SEMICOLON {$$ = "<li><span class=\"caret\">DECLARACION</span>\n<ul class=\"nested\">\n" + $1 + "<li>"+ $2 +"</li>\n</ul>\n</li>\n";}
;

SEMICOLON
     : puntocoma{}
     | {}
;

FUNCTION
    : TYPE id parenta LISTAPARAMETROS parentc BLOCK { for(var i = 0 ; i < globresultsFVC.length; i++){globresultsFVC[i].PARENT += "funcion: " + $2 + " ";} $$ = "<li>"+ $1 +"</li>\n" + "<li>"+ $2 +"</li>\n" + "<li>"+ $3 +"</li>\n" + "<li><span class=\"caret\">PARAMETROS</span>\n<ul class=\"nested\">\n" + $4 + "</ul>\n</li>\n" + "<li>"+ $5 +"</li>\n" + "<li><span class=\"caret\">CUERPO</span>\n<ul class=\"nested\">\n" + $6 + "</ul>\n</li>\n"; globresultsFVC.unshift({TIPO: "funcion", VALUE: "Tipo: " + $1 + " Nombre: " + $2 + " Parametros: " +  $4, PARENT: "", NOMBRE: $2});}
    | resvoid id parenta LISTAPARAMETROS parentc BLOCK { for(var i = 0 ; i < globresultsFVC.length; i++){globresultsFVC[i].PARENT += "funcion: " + $2 + " ";} $$ = "<li>"+ $1 +"</li>\n" + "<li>"+ $2 +"</li>\n" + "<li>"+ $3 +"</li>\n" + "<li><span class=\"caret\">PARAMETROS</span>\n<ul class=\"nested\">\n" + $4 + "</ul>\n</li>\n" + "<li>"+ $5 +"</li>\n" + "<li><span class=\"caret\">CUERPO</span>\n<ul class=\"nested\">\n" + $6 + "</ul>\n</li>\n"; globresultsFVC.unshift({TIPO: "funcion", VALUE: "Tipo: " + $1 + " Nombre: " + $2 + " Parametros: " + $4, PARENT: "", NOMBRE: $2});}
    | TYPE id parenta parentc BLOCK{ for(var i = 0 ; i < globresultsFVC.length; i++){globresultsFVC[i].PARENT += "funcion: " + $2 + " ";} $$ = "<li>"+ $1 +"</li>\n" + "<li>"+ $2 +"</li>\n" + "<li>"+ $3 +"</li>\n" + "<li>"+ $4 +"</li>\n" + "<li><span class=\"caret\">CUERPO</span>\n<ul class=\"nested\">\n" + $5 + "</ul>\n</li>\n"; globresultsFVC.unshift({TIPO: "funcion", VALUE: "Tipo: " + $1 + " Nombre: " + $2, PARENT: "", NOMBRE: $2}); }
    | resvoid id parenta parentc BLOCK { for(var i = 0 ; i < globresultsFVC.length; i++){globresultsFVC[i].PARENT += "funcion: " + $2 + " ";} $$ = "<li>"+ $1 +"</li>\n" + "<li>"+ $2 +"</li>\n" + "<li>"+ $3 +"</li>\n" + "<li>"+ $4 +"</li>\n" + "<li><span class=\"caret\">CUERPO</span>\n<ul class=\"nested\">\n" + $5 + "</ul>\n</li>\n"; globresultsFVC.unshift({TIPO: "funcion", VALUE: "Tipo: " + $1 + " Nombre: " + $2, PARENT: "", NOMBRE: $2}); }
;

TYPE
     : resinteger {$$ = $1;}
     | resdouble {$$ = $1;}
     | resboolean {$$ = $1;}
     | reschar {$$ = $1;}
;

LISTAPARAMETROS
     : LISTAPARAMETROS coma TYPE id { $$ = $1 + "<li>"+ $2 +"</li>\n" + "<li>"+ $3 +"</li>\n" + "<li>"+ $4 +"</li>\n"}
     | TYPE id {$$ = "<li>"+ $1 +"</li>\n" + "<li>"+ $2 +"</li>\n";}
;

DECLARATION
     : TYPE LISTID igual EXP { $$ = "<li>"+ $1 +"</li>\n" + $2 + "<li>"+ $3 +"</li>\n" + $4; var vars = $2.split(","); for(var i = 0 ; i < vars.length ; i++){globresultsFVC.unshift({TIPO: "variable", VALUE: "Tipo: " + $1 + " Nombre: " + vars[i] + " Value: " + $4, PARENT: ""});} }
     | TYPE LISTID { $$ = "<li>"+ $1 +"</li>\n" + $2 ; var vars = $2.split(","); for(var i = 0 ; i < vars.length ; i++){globresultsFVC.unshift({TIPO: "variable", VALUE: "Tipo: " + $1 + " Nombre: " + vars[i], PARENT: ""});} }
;

LISTID
     : LISTID coma id {$$ = $1 + "<li>"+ $2 +"</li>\n" + "<li>"+ $3 +"</li>\n";}
     | id {$$ = "<li>"+ $1 +"</li>\n";}
;

BLOCK
     : corchetea BLOCK2 {$$ = "<li>"+ $1 +"</li>\n" + $2;}//INSTRUCTIONS corchetec
;

BLOCK2
     : INSTRUCTIONS corchetec {$$ = $1 + "<li>"+ $2 +"</li>\n";}
     | corchetec {$$ = "<li>"+ $1 +"</li>\n";}
;

INSTRUCTIONS
     : INSTRUCTIONS INSTRUCTION {$$ = $1 + $2;}
     | INSTRUCTION {$$ = $1;}
;

INSTRUCTION
    : DECLARATION SEMICOLON {$$ = "<li><span class=\"caret\">DECLARACION</span>\n<ul class=\"nested\">\n" + $1 + "<li>"+ $2 +"</li>\n</ul>\n</li>\n";}
    | ASSIGNMENT SEMICOLON {$$ = "<li><span class=\"caret\">ASIGNACION</span>\n<ul class=\"nested\">\n" + $1 + "<li>"+ $2 +"</li>\n</ul>\n</li>\n";}
    | IF { $$ = "<li><span class=\"caret\">SENTENCIA_IF</span>\n<ul class=\"nested\">\n" + $1 + "</ul>\n</li>\n"; }
    | SWITCH {$$ = "<li><span class=\"caret\">SENTENCIA_SWITCH</span>\n<ul class=\"nested\">\n" + $1 + "</ul>\n</li>\n";}
    | WHILE {$$ = "<li><span class=\"caret\">SENTENCIA_WHILE</span>\n<ul class=\"nested\">\n" + $1 + "</ul>\n</li>\n";}
    | DOWHILE SEMICOLON {$$ = "<li><span class=\"caret\">SENTENCIA_DOWHILE</span>\n<ul class=\"nested\">\n" + $1 + "</ul>\n</li>\n";}
    | FOR {$$ = "<li><span class=\"caret\">SENTENCIA_FOR</span>\n<ul class=\"nested\">\n" + $1 + "</ul>\n</li>\n";}
    | PRINT SEMICOLON {$$ = "<li><span class=\"caret\">SENTENCIA_PRINT</span>\n<ul class=\"nested\">\n" + $1 + "</ul>\n</li>\n";}
    | resbreak SEMICOLON {$$ = "<li>"+ $1 +"</li>\n";}
    | rescontinue SEMICOLON {$$ = "<li>"+ $1 +"</li>\n";}
    | resreturn EXPRT SEMICOLON {$$ = "<li>"+ $1 +"</li>\n";}
    | resreturn puntocoma {$$ = "<li>"+ $1 +"</li>\n";}
;
//FALTA THROW

ASSIGNMENT
    : id igual EXP {$$ = "<li>"+ $1 +"</li>\n" + "<li>"+ $2 +"</li>\n" + $3;}
;

PARAMETROUNITARIO
     : parenta EXPRT parentc {$$ = "<li>"+ $1 +"</li>\n" + $2 + "<li>"+ $3 +"</li>\n";}
;

IF
     :  CELSE ELSE { if($2 == null){$$ = $1;}else $$ = $1 + $2;}
;

CELSE
     : CELSE reselse IFF {$$ = "<li><span class=\"caret\">IF</span>\n<ul class=\"nested\">\n" + $1 + "</ul>\n</li>\n" + "<li>"+ $2 +"</li>\n" + "<li><span class=\"caret\">ELSE_IF</span>\n<ul class=\"nested\">\n" + $3 + "</ul>\n</li>\n";}
     | IFF {$$ = $1;}
;

ELSE
     : reselse BLOCK {$$ = "<li><span class=\"caret\">ELSE</span>\n<ul class=\"nested\">\n" + $2 + "</ul>\n</li>\n";}
     | {$$ = null;}
;

IFF
     : resif PARAMETROUNITARIO BLOCK { $$ = "<li><span class=\"caret\">CONDICIONES</span>\n<ul class=\"nested\">\n" + $2 + "</ul>\n</li>\n" + "<li><span class=\"caret\">CUERPO</span>\n<ul class=\"nested\">\n" + $3 + "</ul>\n</li>\n"; }
;

SWITCH
     : resswitch PARAMETROUNITARIO corchetea CASES DEFAULT corchetec {$$ = "<li><span class=\"caret\">CONDICIONES</span>\n<ul class=\"nested\">\n" + $2 + "</ul>\n</li>\n" + "<li>"+ $3 +"</li>\n";}
;

//"<li><span class=\"caret\">EXPRESION</span>\n<ul class=\"nested\">\n" + $2 + "</ul>\n</li>"
CASES
     : CASES rescase EXPRT dospuntos INSTRUCTIONS { $$ = $1 + "<li><span class=\"caret\">CASE</span>\n<ul class=\"nested\">\n"+ "<li>"+ $2 +"</li>\n" + "<li><span class=\"caret\">EXPRESION</span>\n<ul class=\"nested\">\n" + $3 + "</ul>\n</li>" + "<li>"+ $4 +"</li>\n" + "<li><span class=\"caret\">CASE_CONTENIDO</span>\n<ul class=\"nested\">\n" + $5 + "</ul>\n</li>\n" + "</ul>\n</li>\n";}
     | CASES rescase EXPRT dospuntos { $$ = $1 + "<li><span class=\"caret\">CASE</span>\n<ul class=\"nested\">\n" + "<li>"+ $2 +"</li>\n" + "<li><span class=\"caret\">EXPRESION</span>\n<ul class=\"nested\">\n" + $3 + "</ul>\n</li>\n" + "<li>"+ $4 +"</li>\n" + "</ul>\n</li>\n";}
     | rescase EXPRT dospuntos INSTRUCTIONS {$$ = "<li><span class=\"caret\">CASE</span>\n<ul class=\"nested\">\n" + "<li>"+ $1 +"</li>\n" + "<li><span class=\"caret\">EXPRESION</span>\n<ul class=\"nested\">\n" + $2 + "</ul>\n</li>\n" + "<li>"+ $3 +"</li>\n" + "<li><span class=\"caret\">CASE_CONTENIDO</span>\n<ul class=\"nested\">\n" + $4 + "</ul>\n</li>\n" + "</ul>\n</li>\n"; }
     | rescase EXPRT dospuntos {$$ = "<li><span class=\"caret\">CASE</span>\n<ul class=\"nested\">\n" + "<li>"+ $1 +"</li>\n" + "<li><span class=\"caret\">EXPRESION</span>\n<ul class=\"nested\">\n" + $2 + "</ul>\n</li>\n" + "<li>"+ $3 +"</li>\n" + "</ul>\n</li>\n"; }
;

DEFAULT
     : resdefault dospuntos INSTRUCTIONS {$$ = "<li><span class=\"caret\">DEFAULT</span>\n<ul class=\"nested\">\n" + "<li>"+ $1 +"</li>\n" + "<li>"+ $2 +"</li>\n" + "<li><span class=\"caret\">DEFAULT_CONTENIDO</span>\n<ul class=\"nested\">\n" + $3 + "</ul>\n</li>\n" + "</ul>\n</li>\n";}
     | resdefault dospuntos {$$ = "<li><span class=\"caret\">DEFAULT</span>\n<ul class=\"nested\">\n"+  "<li>"+ $1 +"</li>\n" + "<li>"+ $2 +"</li>\n" + "</ul>\n</li>\n";}
     | {}
;

WHILE
     : reswhile PARAMETROUNITARIO BLOCK {$$ ="<li><span class=\"caret\">CONDICIONES</span>\n<ul class=\"nested\">\n" + $2 + "</ul>\n</li>\n" + "<li><span class=\"caret\">CUERPO</span>\n<ul class=\"nested\">\n" + $3 + "</ul>\n</li>\n";}
;

DOWHILE
     : resdo BLOCK reswhile PARAMETROUNITARIO {$$ = "<li><span class=\"caret\">CUERPO</span>\n<ul class=\"nested\">\n" + $2 + "</ul>\n</li>\n" + "<li>"+ $3 +"</li>\n" + "<li><span class=\"caret\">CONDICIONES</span>\n<ul class=\"nested\">\n" + $4 + "</ul>\n</li>\n"; }
;

FOR
     : resfor parenta DECLARATION puntocoma EXPRT puntocoma id DECINC parentc BLOCK {$$ = "<li>"+ $2 +"</li>\n" + "<li><span class=\"caret\">DECLARACION</span>\n<ul class=\"nested\">\n" + $3 + "</ul>\n</li>\n" + "<li>"+ $4 +"</li>\n" + "<li><span class=\"caret\">EXPRESION</span>\n<ul class=\"nested\">\n" + $5 + "</ul>\n</li>" + "<li>"+ $6 +"</li>\n" + "<li>"+ $7 +"</li>\n" + "<li>"+ $8 +"</li>\n" + "<li>"+ $9 +"</li>\n" + "<li><span class=\"caret\">CUERPO</span>\n<ul class=\"nested\">\n" + $10 + "</ul>\n</li>\n";}
;

DECINC
     :incremento {$$ = $1;}
     |decremento {$$ = $1;}
;

PRINT
    : resprint PARAMETROUNITARIO {$$ = $1;}
;

EXPRT
	: EXPRT or EXPRT {$$ = $1 + "<li>"+ $2 +"</li>\n" + $3;}
    |  EXPRT2 {$$ = $1;}
;

EXPRT2
	: EXPRT2 and EXPRT2 {$$ = $1 + "<li>"+ $2 +"</li>\n" + $3;}
    | EXPR {$$ = $1;}
;
//-----------------------------------------------------------------------------------------------------------

//producciones para las operaciones relacionales
EXPR
	: EXPR diferente EXPR {$$ = $1 + "<li>"+ $2 +"</li>\n" + $3;}
     | EXPR identico EXPR {$$ = $1 + "<li>"+ $2 +"</li>\n" + $3;}
     | EXPR referencias EXPR {$$ = $1 + "<li>"+ $2 +"</li>\n" + $3;}
     | EXPR1 {$$ = $1;}
;

EXPR1
     : EXPR1 mayor EXPR1 {$$ = $1 + "<li>"+ $2 +"</li>\n" + $3;}
     | EXPR1 menor EXPR1 {$$ = $1 + "<li>"+ $2 +"</li>\n" + $3;}
     | EXPR1 mayorigual EXPR1 {$$ = $1 + "<li>"+ $2 +"</li>\n" + $3;}
     | EXPR1 menorigual EXPR1 {$$ = $1 + "<li>"+ $2 +"</li>\n" + $3;}
     | EXP {$$ = $1;};
//-----------------------------------------------------------------------------------------------------------

//producciones para operaciones aritmeticas
EXP : EXP suma EXP {$$ = $1 + "<li>"+ $2 +"</li>\n" + $3;}
    | EXP resta EXP {$$ = $1 + "<li>"+ $2 +"</li>\n" + $3;}
    | EXP1 {$$ = $1;};

EXP1 : EXP1 multiplicacion EXP1 {$$ = $1 + "<li>"+ $2 +"</li>\n" + $3;}
     | EXP1 slash EXP1 {$$ = $1 + "<li>"+ $2 +"</li>\n" + $3;}
     | EXP1 modulo EXP1 {$$ = $1 + "<li>"+ $2 +"</li>\n" + $3;}
     | EXP1 potencia EXP1 {$$ = $1 + "<li>"+ $2 +"</li>\n" + $3;}
     | EXP2 {$$ = $1;};

EXP2
	: not EXP2 {$$ = "<li>"+ $1 +"</li>\n" + $2;}
    | EXP3 {$$ = $1;}
;

EXP3
     : decimal {$$ = "<li>"+ $1 +"</li>\n";}
     | entero {$$ = "<li>"+ $1 +"</li>\n";}
     | resta decimal {$$ = "<li>"+ $1 +"</li>\n" + "<li>"+ $2 +"</li>\n";}
     | resta entero {$$ = "<li>"+ $1 +"</li>\n" + "<li>"+ $2 +"</li>\n";}
     | parenta EXP parentc {$$ = "<li>"+ $1 +"</li>\n" + $2 + "<li>"+ $3 +"</li>\n";}
     | cadena {$$ = "<li>"+ $1 +"</li>\n";}
     | caracter {$$ = "<li>"+ $1 +"</li>\n";}
     | restrue {$$ = "<li>"+ $1 +"</li>\n";}
     | resfalse {$$ = "<li>"+ $1 +"</li>\n";}
     | id {$$ = "<li>"+ $1 +"</li>\n";}
;
   