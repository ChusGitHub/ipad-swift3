//
//  PrinterFunctions.swift
//  LosBarkitosIpad
//
//  Created by Jesus Valladolid Rebollar on 28/1/15.
//  Copyright (c) 2015 Jesus Valladolid Rebollar. All rights reserved.
//

import Foundation


var arrayPort : NSArray = ["Standard"]
var arrayFunction : NSArray = ["Sample Receipt"]
var arraySensorActive : NSArray = ["Hight"]
var arraySensorActivePickerContents : NSArray = ["High When Drawer Open"]

var selectedPort : NSInteger = 0
var selectedSensorActive : NSInteger = 0

var foundPrinters : NSArray = []
var lastSelectedPortName : NSString = ""
var p_portName : NSString = ""
var p_portSettings : NSString = ""



// Mira si está la impresora conectada:
// True -> conectada
// False -> no hay impresora
func setupImpresora() -> Bool {
    
    foundPrinters = SMPort.searchPrinter("BT:")! as NSArray
    
    if foundPrinters.count > 0 {// Hay impresora conectada
        
        print(foundPrinters.count)
        let portInfo : PortInfo = foundPrinters.object(at: 0) as! PortInfo
        
        lastSelectedPortName = portInfo.portName! as NSString
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setPortName(portInfo.portName! as NSString)
        appDelegate.setPortSettings(arrayPort.object(at: 0) as! NSString)
        //var p_portName : NSString = appDelegate.getPortName()
        //var p_portSettings : NSString = appDelegate.getPortSettings()
        //infoImpresoraUILabel.text = portInfo.portName
        
        //print("Impresoras: \(foundPrinters.objectAtIndex(0))" )
        return true
    }
    else { // No hay ninguna impresora conectada
        return false        
    }
    
}


// IMPRESION DE TICKET BARKITO / FERRY
func PrintSampleReceipt3Inch(_ portName : NSString, portSettings : NSString, parametro : [String : AnyObject]) -> Bool {
    
    let formatoFecha = DateFormatter()
    formatoFecha.dateFormat = "dd-MM-yyyy"
    let fecha : Date = Date()
    let fechaConFormato = formatoFecha.string(from: fecha)
    
    let commands = NSMutableData()
    var str : String
    var datos : Data?
    
    var cmd : [UInt8]
    var ticketMF : Bool?
    
    
    if let MF = parametro["barco"] {
            ticketMF = false
    } else {
        ticketMF =  true
    }
    
     //Juego de caracteres en español
    cmd = [ 0x1b, 0x1d, 0x74, 0x01]
    commands.append(cmd, length: 4)
    
    // Anchura de texto
    cmd = [ 0x1b, 0x57, 0x03 ]
    commands.append(cmd, length: 3)
   

    // Texto centrado
    cmd = [ 0x1b, 0x1d, 0x61, 0x01 ]
    commands.append(cmd, length: 4)
    
    // Formato Texto : espacio entre caracteres
    cmd = [ 0x1b, 0x1e, 0x46, 0x02 ]
    commands.append(cmd, length: 4)
    
    // Inversion color
    cmd = [ 0x1b, 0x34 ]
    commands.append(cmd, length: 2)
    str = ticketMF == false ?  "LosBarkitos\r\n" : "MarinaFerry\r\n"
    //str = "LosBarkitos\r\n"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)
    
    if !ticketMF! {
        // Formato Texto : normal
        cmd = [0x1b, 0x57, 0x2]
        commands.append(cmd, length: 3)

        str = "d'Empúriabrava\r\n\r\n"
        datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
        commands.append(datos!)
    }
    // Inversion = no
    cmd = [ 0x1b, 0x35 ]
    commands.append(cmd, length: 2)
   
    // Formato pequeño para datos empresa
    cmd = [0x1b, 0x57, 0x00]
    commands.append(cmd, length: 3)
    
    str = ticketMF == false ? "Canal Vahimar S.L.\r\n N.I.F. B17825134\r\nc/ Juan Carlos I, 1\r\n17487 Empuriabrava\r\n" :
    "Navegació i Turisme d'Empuriabrava S.L. \r\n N.I.F. B19496761\r\nc/ Juan Carlos I, 1\r\n17487 Empuriabrava\r\n"
    //str = "Canal Vahimar S.L.\r\n N.I.F. B17825134\r\nc/ Juan Carlos I, 1\r\n17487 Empuriabrava\r\n"
    str += "Tel: 972.45.25.79\r\n"
    str += "www.marinaferry.es\r\n"
    str += "\(fechaConFormato)\r\n"
    str += "---------------------------------\r\n\r\n"
    let n : String = String(parametro["numero"] as! Int)
    str += "Num. \(n)\r\n"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)
    
    // Fecha
    


    // tamaño mediano
    cmd = [0x1b, 0x57, 0x01]
    commands.append(cmd, length: 3)
    
    str = ticketMF == false ? "Alquiler 1 hora\r\n " : "1 Paseo Barco Canales"
    //str = "Alquiler 1 hora\r\n "
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)
   
    if !ticketMF! {
        cmd = [0x1b, 0x57, 0x02]
        commands.append(cmd, length: 3)
        let b : String = parametro["barca"] as! String
        //print("barca \(b)")
        str = b + "\r\n\r\n"
        datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
        commands.append(datos!)
    }
    
    // tamaño pequeño
    cmd = [0x1b, 0x57, 0x00]
    commands.append(cmd, length: 3)
    // A la derecha
    cmd = [0x1b, 0x1d, 0x61, 0x02]
    commands.append(cmd, length: 4)
  
    let p : String = String(parametro["precio"] as! Int)
    let iva : Double =  round(100*(parametro["precio"] as! Double - (parametro["precio"] as! Double / 1.21)))/100
    let pdouble : Double =  round(100*(parametro["precio"] as! Double / 1.21))/100
    var r : String! = ""
    if !ticketMF! {
        r  = String(parametro["reserva"] as! Int)
    }
    
    str = "Precio : \t \(pdouble) eur.-\r\n"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)
    str = "I.V.A : \t\(iva) eur.-\r\n"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)
    
    // tamaño mediano
    cmd = [0x1b, 0x57, 0x01]
    commands.append(cmd, length: 3)
    
    str = "Total : \(p) eur.-\r\n\r\n"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)
    
    cmd = [0x1b, 0x57, 0x00]
    commands.append(cmd, length: 3)
    // Centrado
    cmd = [0x1b, 0x1d, 0x61, 0x01]
    commands.append(cmd, length: 4)

    str = "I.V.A incluido en el precio\r\n"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)
    
    str = "----------------------------------------\r\n\r\n\r\n"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)

    if !ticketMF! {
        // Esta es la reserva del ticket
        // tamaño pequeño
        cmd = [0x1b, 0x57, 0x01]
        commands.append(cmd, length: 3)
    
        str = "Reserva : \(r!)\r\n\r\n"
        datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
        commands.append(datos!)

        str = "----------------------------------------\r\n\r\n\r\n"
        datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
        commands.append(datos!)
    
        //cmd = [ 0x1b, 0x64, 0x00 ] // Corta el papel
        //commands.appendBytes(cmd, length: 3)
    
        let v : String = parametro["vendedor"] as! String
        str = "\n\r\n\rVendedor : \(v)\n\r\n\r"
        datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
        commands.append(datos!)

        
    }
    cmd = [ 0x1b, 0x64, 0x02 ] // Corta el papel
    commands.append(cmd, length: 3)
    str = "\n\r\n\r\n\r\n\r"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)

    
    return (sendCommand(commands as Data,portName: portName, portSettings: portSettings,timeoutMillis: 10000))
}

// IMPRESION DE RESERVA BARKITO
func PrintSampleReceipt3Inch(_ portName : NSString, portSettings : NSString, PV : String,  parametro : [Int], HR : String, HP : String, tipoBarca: String) -> Bool {
    
    //let horaActual : NSDate = NSDate()
    
    let commands = NSMutableData()
    var str : String
    var datos : Data?
    
    var cmd : [UInt8]
    var tipo : Int = 0
    var numReserva : Int = 0
    
    // Miro de donde es la reserva
    for num in parametro {
        if num != 0 {
            tipo += 1
            numReserva = num
            break
        }
    }
    
    //Juego de caracteres en español
    cmd = [ 0x1b, 0x1d, 0x74, 0x01]
    commands.append(cmd, length: 4)
    
    // Anchura de texto
    cmd = [ 0x1b, 0x57, 0x03 ]
    commands.append(cmd, length: 3)
    
    
    // Texto centrado
    cmd = [ 0x1b, 0x1d, 0x61, 0x01 ]
    commands.append(cmd, length: 4)
    
    // Formato Texto : espacio entre caracteres
    cmd = [ 0x1b, 0x1e, 0x46, 0x02 ]
    commands.append(cmd, length: 4)
    
    // Inversion color
    cmd = [ 0x1b, 0x34 ]
    commands.append(cmd, length: 2)
    str = "LosBarkitos\r\n"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)
    
    // Formato Texto : normal
    cmd = [0x1b, 0x57, 0x2]
    commands.append(cmd, length: 3)
    
    str = "d'Empúriabrava\r\n\r\n"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)
    
    // Inversion = no
    cmd = [ 0x1b, 0x35 ]
    commands.append(cmd, length: 2)
    
    // Formato pequeño para datos empresa
    cmd = [0x1b, 0x57, 0x01]
    commands.append(cmd, length: 3)
    
    str = "Reserva\r\n"
    str += PV + "\r\n\n"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)

    // tamaño grande
    cmd = [0x1b, 0x57, 0x03]
    commands.append(cmd, length: 3)
    // Centrado
    cmd = [0x1b, 0x1d, 0x61, 0x01]
    commands.append(cmd, length: 4)
    
    str = String(numReserva)
    if tipoBarca == "whaly" {
        str += "\nBarca"
    } else {
        str += "\n" + tipoBarca
    }
    
    str += "\r\n\n---------------------------------\r\n\r\n"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)
    
    // tamaño pequeño
    cmd = [0x1b, 0x57, 0x00]
    commands.append(cmd, length: 3)

    
    str = "Hora de la Reserva : \(HR)\r\n"
    str += "Hora Prevista : \(HP)\r\n\r\n"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)

    
    str = "\n\r\n\r\n\r\n\r"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)
    
    cmd = [ 0x1b, 0x64, 0x02 ] // Corta el papel
    commands.append(cmd, length: 3)

    return (sendCommand(commands as Data,portName: portName, portSettings: portSettings,timeoutMillis: 10000))
}


// TICKET RESUMEN DEL DIA
func PrintTotal3Inch(_ p_portName : NSString, p_portSettings : NSString, diccParam : [String : AnyObject]) -> Bool {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    let horaActual = dateFormatter.string(from: Date())
    
    let commands = NSMutableData()
    var str : String
    var datos : Data?
    
    var cmd : [UInt8]

    //Juego de caracteres en español
    cmd = [ 0x1b, 0x1d, 0x74, 0x01]
    commands.append(cmd, length: 4)
    
    // Anchura de texto
    cmd = [ 0x1b, 0x57, 0x03 ]
    commands.append(cmd, length: 3)
    
    // Texto centrado
    cmd = [ 0x1b, 0x1d, 0x61, 0x01 ]
    commands.append(cmd, length: 4)
    
    // Formato Texto : espacio entre caracteres
    cmd = [ 0x1b, 0x1e, 0x46, 0x02 ]
    commands.append(cmd, length: 4)
    
    // Formato Texto : normal
    cmd = [0x1b, 0x57, 0x2]
    commands.append(cmd, length: 3)
    
    // Inversion = si
    //cmd = [ 0x1b, 0x34 ]
    //commands.appendBytes(cmd, length: 2)
    
    let pv: AnyObject = diccParam["p_venta"]!
    str = "\(pv)\r\n"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)
   
    str = diccParam["dia"] as! String
    str += "\r\n"
    str += horaActual
    str += "\r\n--------------------\r\n"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)
    
    
    // Inversion color NO
    cmd = [ 0x1b, 0x35 ]
    commands.append(cmd, length: 2)
    
    // Formato Texto : normal
    cmd = [0x1b, 0x57, 0x2]
    commands.append(cmd, length: 3)
    
    // A la derecha
    cmd = [0x1b, 0x1d, 0x61, 0x02]
    commands.append(cmd, length: 4)
    
    let Rios = diccParam["rio"] as! Int
    str = "Rios : \t \(Rios)\n"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)
    
  
    let Electricas = diccParam["electrica"] as! Int
    str = "Electricas : \t \(Electricas)\r\n"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)

    let Whalys = diccParam["barca"] as! Int
    str = "Barca : \t \(Whalys)\r\n"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)

    let Golds = diccParam["gold"] as! Int
    str = "Golds : \t \(Golds)\r\n\n\n"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)

    // Texto centrado
    cmd = [ 0x1b, 0x1d, 0x61, 0x01 ]
    commands.append(cmd, length: 4)

    // Inversion color
    cmd = [ 0x1b, 0x34 ]
    commands.append(cmd, length: 2)

    // Texto centrado
    cmd = [ 0x1b, 0x1d, 0x61, 0x01 ]
    commands.append(cmd, length: 4)

    str = "Total barcas:"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)
    
    // Formato Texto : normal
    cmd = [0x1b, 0x57, 0x2]
    commands.append(cmd, length: 3)

    str = String(Rios + Electricas + Whalys + Golds)
    str += "\n\r"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)

    // Inversion color
    cmd = [ 0x1b, 0x34 ]
    commands.append(cmd, length: 2)
    
    str = "Total Euros:"
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)
    
    // Formato Texto : normal
    cmd = [0x1b, 0x57, 0x2]
    commands.append(cmd, length: 3)

    str = String(diccParam["euros"] as! Int)
    datos = str.data(using: String.Encoding.ascii, allowLossyConversion: true)
    commands.append(datos!)

    cmd = [ 0x1b, 0x64, 0x02 ] // Corta el papel
    commands.append(cmd, length: 3)

    
    return (sendCommand(commands as Data, portName: portName, portSettings: p_portSettings, timeoutMillis: 10000))
}

func sendCommand(_ commandsToPrint : Data, portName : NSString, portSettings: NSString, timeoutMillis : u_int) -> Bool{
    
    //var starPort : SMPort
    let commandSize : Int = commandsToPrint.count as Int
 //   println("Tamaño datos a imprimir: \(commandSize)" )
    //var dataToSentToPrinter = UnsafePointer<UInt8>(commandsToPrint.bytes)
    var dataToSentToPrinter = [CUnsignedChar](repeating: 0, count: commandsToPrint.count)
    //var dataToSentToPrinter = (commandsToPrint.bytes)
    
    //commandsToPrint.getBytes(&dataToSentToPrinter)
    (commandsToPrint as NSData).getBytes(&dataToSentToPrinter, length: commandSize)
    //commandsToPrint.getBytes(&dataToSentToPrinter)//, length: sizeofValue(dataToSentToPrinter))
    
    
//    println("commandstoPrint: \(commandsToPrint)")
    
  //  println("Datos : \(dataToSentToPrinter)")
    if let starPort = SMPort.getPort(portName as String, portSettings as String, timeoutMillis) {
        
        var status : StarPrinterStatus_2? = nil
        starPort.beginCheckedBlock(&status, 2)
        
        if status?.offline == 1 {
            print("Error: La impresora no esta en linea")
            return false
        }
        
        var endTime : timeval = timeval(tv_sec: 0, tv_usec: 0)
        gettimeofday(&endTime, nil)
        endTime.tv_sec += 30
        
        //println("commandSize : \(commandSize). dataToSEntToPrinter: \(dataToSentToPrinter)")
        var totalAmountWritten : Int = 0
        while (Int(totalAmountWritten) < commandSize) {
            let remaining : Int  = Int(UInt32(commandSize) - UInt32(totalAmountWritten))
            let amountWritten : UInt32 = starPort.write(dataToSentToPrinter, UInt32(totalAmountWritten),UInt32(remaining))
            totalAmountWritten = Int(totalAmountWritten) + Int(amountWritten)
            
            var now : timeval = timeval(tv_sec: 0, tv_usec: 0)
            gettimeofday(&now, nil)
            if (now.tv_sec > endTime.tv_sec) {
                break
            }
            //starPort.endCheckedBlockTimeoutMillis = 1000
            //starPort.endCheckedBlock(&status!, 2)
           
        }
    
        if (UInt32(totalAmountWritten) < UInt32(commandSize)) {
            print("Error: Impresion fuera de tiempo")
            return false
        }
        
        starPort.endCheckedBlockTimeoutMillis = 30000
        if (status != nil) {
            starPort.endCheckedBlock(&status!, 2)
        } else {
            starPort.beginCheckedBlock(&status, 2)
            starPort.endCheckedBlock(&status, 2)
        }
        
        //free((UnsafeMutablePointer<Void>),dataToSentToPrinter)
        SMPort.release(starPort)
    } else {
        print("Error: Writte port timed out")
        return false
    }
    //free(dataToSentToPrinter)
    

    return true
}
