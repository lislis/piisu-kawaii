const SerialPort = require('serialport')
const Readline = require('@serialport/parser-readline')
const WebSocket = require('ws')

// this might be different for you, see what the arduino ide says
const port = new SerialPort('/dev/ttyUSB0', { baudRate: 9600 }) // change port if necessary
const parser = port.pipe(new Readline({ delimiter: '\n' })) // look in arduino code for separator
const wss = new WebSocket.Server({ port: 8088 })


let sensordata = {}

port.on("open", () => {
    console.log('serial port open')
});

parser.on('data', data =>{
    console.log('got word from arduino:', data)
    let split = data.split(',')

    if (split.length === 3) { // this is true when sensor init is done
        let obj = {x: split[0], y: split[1], z: split[2].split('\r')[0]}
        sensordata = JSON.stringify(obj)

        wss.clients.forEach(client => {
            if (client.readyState === WebSocket.OPEN) {
                client.send(sensordata)
            }
        });
    }
});


wss.on('connection', ws => {
    ws.on('message', message => {
        console.log(`Received message => ${message}`)
    })
    ws.send('Hello! Message From Server!!')
})
