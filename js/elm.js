import Elm from "../src/Application.elm";

var socketio = require('socket.io-client');

var app = Elm.Application.fullscreen({ theme: process.env.THEME });

const storage = window.localStorage || {
    setItem(k, v) {
        this[k] = v;
    },
    getItem(k) {
        return this[k];
    }
};

// LocalStorage
function storeObject(key, object) {
    storage.setItem(key, JSON.stringify(object));
}

function retrieveObject(key) {
    const value = storage.getItem(key);
    return value ? JSON.parse(value) : null;
}

app.ports.storeSession.subscribe(function(session) {
    storeObject("session", session);
    var sessionData = retrieveObject("session");
    app.ports.onSessionChange.send(sessionData);
});

app.ports.retrieveSession.subscribe(function() {
    var sessionData = retrieveObject("session");
    app.ports.onSessionChange.send(sessionData);
});

// SocketIO 
app.ports.connect.subscribe(function(str){
    console.log("attempting connection to: " + str);
    const socket = socketio(str);
    app.ports.emit_.subscribe(function(obj) {
        //Index tuple to extract message event and data
        var evenTag = obj["event"];
        var data = obj["data"];
        console.log("Outgoing event: " + evenTag);
        console.dir(data);
        socket.emit(evenTag, data);
    });

    app.ports.listen.subscribe(function(eventName){
        console.log('Listening to event: ' + eventName);
        socket.on(eventName, function (data) {
            console.log('Got event: ' + eventName);
            console.log(data);
            app.ports.on_.send([eventName, data]);
        });
    });
});

// Echo
app.ports.shout.subscribe(function(object){
   app.ports.hear.send(object); 
})
