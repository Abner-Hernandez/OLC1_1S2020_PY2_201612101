
var contador=0;
var aux_cont = 0 ;

var varsclass = [];
var varsfunction = [];
var vars = [];

var varsclass1 = [];
var varsfunction1 = [];
var vars1 = [];

var errores1 = [];
var errores2 = [];
var reportsclass = "";
var reportsfunction = "";
var reportsvars = "";

function get_cont(){
    return contador++;
}

var vent_focus="pestana1";
function get_vent(){
    return vent_focus;
}

function set_vent(vent){
    vent_focus=vent;
}

var lista=new Array();
function linkedlist(pestana,nombre) {
    var obj=new Object();
    obj.pestana=pestana;
    obj.nombre=nombre;
    lista.push(obj);
}

function deletepes(pestana){
    for(var i=0;i<lista.length;i++){
        if(lista[i].pestana==pestana){
            delete lista[i];
        }
    }
}

/*--------------------------------------Funcion Al Cambiar Ventana---------------------------------------*/
function index(pestanias, pestania) {
    var id=pestania.replace('pestana','');
    set_vent('textarea'+id);

    var pestanna1 = document.getElementById(pestania);
    var listaPestannas = document.getElementById(pestanias);
    var cpestanna = document.getElementById('c'+pestania);
    var listacPestannas = document.getElementById('contenido'+pestanias);

    var i=0;
    while (typeof listacPestannas.getElementsByTagName('div')[i] != 'undefined'){
        $(document).ready(function(){
            $(listacPestannas.getElementsByTagName('div')[i]).css('display','none');
            $(listaPestannas.getElementsByTagName('li')[i]).css('background','');
            $(listaPestannas.getElementsByTagName('li')[i]).css('padding-bottom','');
        });
        i += 1;
    }

    jQuery(document).ready(function(){
        $(cpestanna).css('display','');
        $(pestanna1).css('background','dimgray');
        $(pestanna1).css('padding-bottom','2px');
    });

    try {
        var act=document.getElementById('cpestana'+id);
        var tact=document.getElementById('textarea'+id);

        while (act.firstChild) {
            act.removeChild(act.firstChild);
        }

        act.appendChild(tact);
        var editor=CodeMirror(act, {
            lineNumbers: true,
            value: tact.value,
            matchBrackets: true,
            styleActiveLine: true,
            theme: "eclipse",
            mode: "text/x-java"
        }).on('change', editor => {
            tact.value=editor.getValue();
        });
    }catch(error) {}
}

/*---------------------------------------Funcion Agregar Pestania----------------------------------------*/
function agregar() {
    var x=get_cont();
    var lu=document.getElementById("lista");
    var li=document.createElement("li");
    li.setAttribute('id','pestana'+x);
    var a=document.createElement("a");
    a.setAttribute('id','a'+x);
    a.setAttribute('href', 'javascript:index("pestanas","pestana'+x+'")');
    a.text='pestana'+x;
    li.appendChild(a);
    lu.appendChild(li);
    index("pestanas","pestana"+x);

    var contenido=document.getElementById("contenidopestanas");
    var divp=document.createElement("div");
    divp.setAttribute('id','cpestana'+x);
    var ta=document.createElement("textarea");
    ta.setAttribute('id','textarea'+x);
    ta.setAttribute('name','textarea'+x);
    ta.setAttribute('class','ta');
    ta.setAttribute('style','display:none');
    ta.cols=123;
    ta.rows=30;
    divp.appendChild(ta);
    contenido.appendChild(divp);

    var act=document.getElementById('cpestana'+x);
    var tact=document.getElementById('textarea'+x);
    var editor=CodeMirror(act, {
        lineNumbers: true,
        value: tact.value,
        matchBrackets: true,
        styleActiveLine: true,
        theme: "eclipse",
        mode: "text/x-java"
    }).on('change', editor => {
        tact.value=editor.getValue();
    });
}

function quitar(){
    dd();
    try{
        var lu=document.getElementById("lista");
        lu.removeChild(document.getElementById(get_vent().replace("textarea","pestana")));
        var contenido=document.getElementById("contenidopestanas");
        contenido.removeChild(document.getElementById(get_vent().replace("textarea","cpestana")));
        deletepes(get_vent());
    }catch(error){}
}


/*-----------------------------------------------File---------------------------------------------------*/
function AbrirArchivo(files){
    var file = files[0];
    var reader = new FileReader();
    reader.onload = function (e) {
        var act=document.getElementById(get_vent().replace("textarea","cpestana"));
        var tact=document.getElementById(get_vent());
        tact.value = e.target.result;

        while (act.firstChild) {
            act.removeChild(act.firstChild);
        }

        act.appendChild(tact);
        var editor=CodeMirror(act, {
            lineNumbers: true,
            value: tact.value,
            matchBrackets: true,
            styleActiveLine: true,
            theme: "eclipse",
            mode: "text/x-java"
        }).on('change', editor => {
            tact.value=editor.getValue();
        });
    };
    reader.readAsText(file);
    file.clear;

    var a=document.getElementById(get_vent().replace("textarea","a"));
    a.text=file.name;
    linkedlist(get_vent(),file.name);

    var file_input=document.getElementById("fileInput");
    document.getElementById('fileInput').value="";
}

function DescargarArchivo(){
    var ta=document.getElementById(get_vent());
    var contenido=ta.value;//texto de vent actual

    //formato para guardar el archivo
    var hoy=new Date();
    var dd=hoy.getDate();
    var mm=hoy.getMonth()+1;
    var yyyy=hoy.getFullYear();
    var HH=hoy.getHours();
    var MM=hoy.getMinutes();
    var formato=get_vent().replace("textarea","")+"_"+dd+"_"+mm+"_"+yyyy+"_"+HH+"_"+MM;

    var nombre="Archivo"+formato+".coline";//nombre del archivo
    var file=new Blob([contenido], {type: 'text/plain'});

    if(window.navigator.msSaveOrOpenBlob){
        window.navigator.msSaveOrOpenBlob(file, nombre);
    }else{
        var a=document.createElement("a"),url=URL.createObjectURL(file);
        a.href=url;
        a.download=nombre;
        document.body.appendChild(a);
        a.click();
        setTimeout(function(){
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url);  
        },0); 
    }
}

function send_request()
{
    var ta=document.getElementById(get_vent());
    var contenido=ta.value;//texto de vent actual

    var url = 'http://localhost:3000/compilar';

    $.post(url,{code: contenido}, function(data, status){
        if(status.toString() == "success"){
            agregar_ast(data.AST);
        }else{
            alert("Error en la conexion:" + status)
        }
    });
}


function agregar_ast(add_ast)
{
    if(aux_cont == 1)
        return;
    else if(aux_cont == 2)
        aux_cont = 0;
    aux_cont++;

    document.getElementById("arbol").innerHTML = "<ul>"+ add_ast +"</ul>";

    var toggler = document.getElementsByClassName("caret");
    var i;
    for (i = 0; i < toggler.length; i++) {
      toggler[i].addEventListener("click", function() {
        this.parentElement.querySelector(".nested").classList.toggle("active");
        this.classList.toggle("caret-down");
      });
    }
}

function llenar_arreglos(first, second)
{
    if(first.length > 0 && second.length > 0)
    {
        for(var i = 0; i < first.length ; i++)
        {
            if(first[i].TIPO == "class")
            {
                varsclass.push({TIPO: first[i].TIPO, VALUE: first[i].VALUE, PARENT: first[i].PARENT});
            }else if(first[i].TIPO == "funcion")
            {
                var value = first[i].VALUE.replace("<li>", "");
                value = value.replace("</li>", "");
                value = value.replace("\n", "");
                varsfunction.push({TIPO: first[i].TIPO, VALUE: value, PARENT: first[i].PARENT});
            }else if(first[i].TIPO == "variable")
            {
                var value = first[i].VALUE.replace("<li>", "");
                value = value.replace("</li>", "");
                value = value.replace("\n", "");
                vars.push({TIPO: first[i].TIPO, VALUE: value, PARENT: first[i].PARENT});
            }
        }

        for(var i = 0; i < second.length ; i++)
        {
            if(second[i].TIPO == "class")
            {
                varsclass1.push({TIPO: second[i].TIPO, VALUE: second[i].VALUE, PARENT: second[i].PARENT});
            }else if(second[i].TIPO == "funcion")
            {
                var value = second[i].VALUE.replace("<li>", "");
                value = value.replace("</li>", "");
                value = value.replace("\n", "");
                varsfunction1.push({TIPO: second[i].TIPO, VALUE: value, PARENT: second[i].PARENT, NOMBRE: second[i].NOMBRE});
            }else if(second[i].TIPO == "variable")
            {
                var value = second[i].VALUE.replace("<li>", "");
                value = value.replace("</li>", "");
                value = value.replace("\n", "");
                vars1.push({TIPO: second[i].TIPO, VALUE: value, PARENT: second[i].PARENT});
            }
        }
        //send to create reports

        //first vars
        for(var i = 0; i < vars.length ; i++)
        {
            for(var j = 0; j < vars1.length ; j++)
            {
                if(vars1[j].VALUE == vars[i].VALUE && vars1[j].PARENT == vars[i].PARENT)
                {
                    add_to_table_rc(vars2[j].VALUE, vars[i].VALUE);
                }
                //realizo la comparacion si son iguales las clases
            }

        }
        for(var i = 0; i < varsfunction.length ; i++)
        {
            for(var j = 0; j < vars.length ; j++)
            {
                if(exixte_parent(vars[j].VALUE, varsfunction[i].NOMBRE ))
                {
                    for(var k = 0; k < vars1.length ; k++)
                    {
                        if(vars1[k].VALUE == vars[j].VALUE && vars1[k].PARENT == vars[j].PARENT)
                        {
                            add_to_table_rc(vars2[j].VALUE, vars[i].VALUE);
                        }
                        //realizo la comparacion si son iguales las clases
                    }
                }
    
            }

        }
    }else
        return;
}

function exixte_parent(str, str2)
{
    for(var i = 0 ; i < str.length ; i++)
    {
        if( i + str2.length <= str.length && str.substring(i, str2.length) == str2)
        {
            return true; break;
        }
    }
    return false;
}

function crear_reporte_clases()
{

}

function crear_reporte_variables()
{

}

function crear_reporte_funciones()
{

}


function add_to_table_rc(dato_1, dato_2)
{
    if(reportsclass == ""){
        reportsclass +="<table>\n<tr>\n<th>Analisis 1</th>\n<th>Analisis 2</th>\n</tr>\n";
    }
    else{
        reportsclass += "<tr>\n<td>"+ dato_1 +"</td>\n<td>"+ dato_2 +"</td>\n"
    }
    //</table>
}

function add_to_table_rf(dato_1, dato_2)
{
    if(reportsfunction == ""){
        reportsfunction +="<table>\n<tr>\n<th>Analisis 1</th>\n<th>Analisis 2</th>\n</tr>\n";
    }
    else{
        reportsfunction += "<tr>\n<td>"+ dato_1 +"</td>\n<td>"+ dato_2 +"</td>\n"
    }
    //</table>
}

function add_to_table_rf(dato_1, dato_2)
{
    if(reportsvars == ""){
        reportsvars +="<table>\n<tr>\n<th>Analisis 1</th>\n<th>Analisis 2</th>\n</tr>\n";
    }
    else{
        reportsvars += "<tr>\n<td>"+ dato_1 +"</td>\n<td>"+ dato_2 +"</td>\n"
    }
    //</table>
}