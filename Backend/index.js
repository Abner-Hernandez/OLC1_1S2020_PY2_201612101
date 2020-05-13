const express = require('express');
const bodyparser = require('body-parser')
const parser = require('./grammar');
const cors = require('cors');
const Node = require('./clases/Node');

var app = express()
global.globentradas = [];
global.globerrores = [];
global.globresults = [];
global.globresultsFVC = [];

app.use(bodyparser.json())
app.use(bodyparser.urlencoded({extended: false}))
app.use(cors({origin: 'http://localhost:8000'}))

app.post('/compilar',(req,res) => {
    console.log(req.body);
    
    global.globerrores = [];
    global.globresults = [];
    global.globresultsFVC = [];

    if(globentradas.length > 1)
        globentradas = [];

    if(globentradas.length == 0)
    {
        globentradas.push(req.body.code);
        parser.parse(req.body.code);
    }else if(globentradas.length == 1)
    {
        globentradas.push(req.body.code);
        parser.parse(req.body.code);
    }
    //console.log(globerrores.length);
    //console.log(globresults.length);
    //console.log(globresultsFVC.length);
    //console.log(parser.RES.operar())
    //console.log(count.getOutput());
    //console.log(count.getError());
    res.send({ERROR: globerrores, AST: globresults[globresults.length -1], VARS: globresultsFVC});
})

app.listen(3000,() => {
    console.log('on port 3000')
})