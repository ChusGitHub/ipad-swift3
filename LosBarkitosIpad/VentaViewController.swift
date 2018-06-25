 //
//  FirstViewController.swift CLARO
//  LosBarkitosIpad
//
//  Created by Jesus Valladolid Rebollar on 14/11/14.
//  Copyright (c) 2014 Jesus Valladolid Rebollar. All rights reserved.
//
//import "VendedorUITableViewCell"

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

/*
protocol PrinterConnectivityDelegate {
    func connectedPrinterDidChangeTo(printer : Printer)
}*/


class VentaViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, WebServiceProtocoloVentas {


    let RIO       = 1
    let BARCA     = 2
    let GOLD      = 3
    
    let VENDEDOR =  1
    let VENTAS =    2
    
    // Acceso a la base de datos SQLITE
    let db = SQLiteDB.shared

    
    @IBOutlet weak var btnViewVendedoresUIButton: UIButton!
    
    @IBOutlet weak var vendedorUITextField: UITextField!
    
    @IBOutlet  weak var vendedorUITableView: UITableView!
    
    // Propiedades de la tabla de las ventas
    
   // @IBOutlet weak var ventasUITableView: UITableView!
    
    // Botones de las barcas

    @IBOutlet var btnBarcasIUButtonCollection: [UIButton]!
    
    @IBOutlet weak var infoImpresoraUILabel: UILabel!
    
    @IBOutlet weak var txtPasswordUITextField: UITextField!
    
    @IBOutlet weak var btnAceptarUIButton: UIButton!
    
    @IBOutlet weak var passwordUIView: UIView!
    
    @IBOutlet weak var infoAdministradoUILabel: UILabel!
    
    @IBOutlet weak var tipoListaUIView: UIView!
    
    @IBOutlet weak var numeroBarcasUILabel: UILabel!
   
    /// SE TIENE QUE CAMBIAR CADA VEZ QUE SE ACTUALIZA UN IPAD
    var PUNTO_VENTA : Int = 0
    var PUNTO_VENTA_NOMBRE : String = ""

    var barcaActual : Int = -1
    var barcaActualString : String? = nil

    
    // Este es el enlace a la clase que hace la conexion al servidor
    var webService : webServiceCallAPI = webServiceCallAPI()
    var conec : Conectividad = Conectividad()
    var hayConexion : Bool = false

    // Items de vendedorUITableView
    // numero de ticket en BDD
    var numeroTicket : Int = 0
    // ticket si es negro o no
    var negro : Bool = false
    // Diccionario que mantiene codigo y nombre de un vendedor
    var vendedor = [String : String]()
    // Diccinario que mantiene los datos de una venta
    var venta : [String : String] = [:]
    // Array de los diccionarios de los vendedores
    var vendedores = [[String : String]]()
    //var ventas  = [[String : String]]()
    var ventas = [[String:String]]()
    var ventasOrdenadas = [[String:String]]()
    
    var respuesta = [String : String]()
    
     
    // Valor devuelto por el PreciosViewController
    // Todo correcto : Ok
    // algo falla : String con informacion de lo que falla
    var toPreciosViewController : Int = 0
    
    // Valor devuelto por el tipoReservaViewController
  //  var totipoReservaViewControllerTipo : Int = 0
   // var totipoReservaViewControllerPV : Int = 0
    var tovueltaReservaViewController : Bool = false
    var tovueltaListadoVentas : Bool = false
    
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
    
    var gestion : String = "usuario"
    let datosUIPickerView = ["Lista Baja", "Lista Media", "Lista Alta"]
    
    var totalBarcas : [Int] = [0,0,0,0]
    var totalEuros : Int = 0
    
    var reservas : [Int] = [0,0,0,0]
    
    //let conectado : Conectividad?
    // Variables para conectividad
 //   var hostReachability : Reachability?
  //  var internetReachability : Reachability?
  //  var wifiReachability : Reachability?
    //var estado : Reachability.NetworkStatus?

    
    // LLamo a obtenerVendedores cuando se pulsa el boton del uitableview
    @IBAction func btnViewVendedoresIBAction(_ sender: AnyObject) {
        if self.vendedorUITableView.isHidden == true {
            webService.obtenerVendedores()
            self.vendedorUITableView.isHidden = false
            self.btnViewVendedoresUIButton.isEnabled = false
        } else {
            self.vendedorUITableView.isHidden = true
            self.btnViewVendedoresUIButton.isEnabled = false
        }
     }
    
  /*  @IBAction func btnRefrescarVentas(sender: UIButton) {
        
        // limpiar uitableview
        self.ventasUITableView.clearsContextBeforeDrawing = true
        webService.obtenerVentas()
    }*/
    
    @IBAction func btnBarcasUIButtonTouch(_ sender: UIButton) {

        switch sender.tag {
        case 0:
            self.barcaActual = RIO
            self.barcaActualString = "RIO"
        case 1:
            self.barcaActual = BARCA
            self.barcaActualString = "BARCA"
        case 2:
            self.barcaActual = GOLD
            self.barcaActualString = "GOLD"
        default:
            self.barcaActual = -1
            self.barcaActualString = nil
        }
    }
    
    
    @IBAction func btnGestionUIbutton(_ sender: UIButton) {
        self.txtPasswordUITextField.text = ""
        if self.passwordUIView.isHidden == true {
            self.passwordUIView.isHidden = false
        } else {
            self.passwordUIView.isHidden = true
        }
    }
    
    
    @IBAction func btnAceptarGestionPushButton(_ sender: UIButton) {
        
        if self.txtPasswordUITextField.text == "Otisuhc0" {
            self.gestion = "administrador"
            self.infoAdministradoUILabel.text = "Administrador"
            self.tipoListaUIView.isHidden = false
            self.passwordUIView.isHidden = true
            txtPasswordUITextField.resignFirstResponder()
        } else {
            self.resignFirstResponder()
            let alerta = UIAlertController(title: "PASS INCORRECTO", message: "El password es incorrecto. No tiene privilegios de administrador", preferredStyle: UIAlertControllerStyle.alert)
            let aceptarAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel, handler: {action in self.noAdministrador()} )
            alerta.addAction(aceptarAction)
            self.present(alerta, animated: true, completion: nil)
        }
    }
    
    @IBAction func lista1ButtonListaUIView(_ sender: AnyObject) {
        DataManager().setValueForKey("lista_precio", value: "1" as NSString, inFile: "appstate")
        self.tipoListaUIView.isHidden = true
    }
    @IBAction func lista2ButtonListaUiView(_ sender: AnyObject) {
        DataManager().setValueForKey("lista_precio", value: "2" as NSString, inFile: "appstate")
        self.tipoListaUIView.isHidden = true
    }
    @IBAction func lista3ButtonListaUIView(_ sender: AnyObject) {
        DataManager().setValueForKey("lista_precio", value: "3" as NSString, inFile: "appstate")
        self.tipoListaUIView.isHidden = true
    }

    @IBAction func cerrarDia(_ sender: AnyObject) {
        // Hay que poner los contadores de las reservas a 0
        DataManager().setValueForKey("total_barcas", value: 0 as NSNumber, inFile: "appstate")
        DataManager().setValueForKey("cargado", value: "no" as NSString, inFile: "appstate")
        self.webService.cierreDia()
        
        
    }
    
    @IBAction func imprimirTotalVentas(_ sender: UIButton) {
        
        let totalImpreso : Bool = imprimirTotal()
        
        if !totalImpreso {
            let alertaNoImpresora = UIAlertController(title: "SIN IMPRESORA", message: "No hay una impresora conectada. Intenta establecer nuevamente la conexión (Ajustes -> Bluetooth->Seleccionar Impresora TSP)", preferredStyle: UIAlertControllerStyle.alert)
            
            let OkAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            
            alertaNoImpresora.addAction(OkAction)

        }
        
    }
    @IBAction func habilitarReservaUIButton(_ sender: UIButton) {
        
        
    }
    
    @IBAction func listadoVentasUIButton(_ sender: UIButton) {
        self.tovueltaListadoVentas = true
        webService.delegate = self
    }
    
    @IBAction func reservasUIButton(_ sender: UIButton) {
        webService.delegate = self
        self.tovueltaReservaViewController = false
        
        /*var alertController = UIAlertController(title: "RESERVA", message: "Clic en el tipo de barco para reservar", preferredStyle: UIAlertControllerStyle.Alert)
        let rioAction = UIAlertAction(title: "Rio", style: UIAlertActionStyle.Default, handler: {action in self.webService.obtenerNumeroReserva(self.RIO, pv: 2)})
        let electricaAction = UIAlertAction(title: "Eléctrica", style: UIAlertActionStyle.Default, handler: {action in self.webService.obtenerNumeroReserva(self.ELECTRICA, pv: 2)})
        let whalyAction = UIAlertAction(title: "Whaly", style: UIAlertActionStyle.Default, handler: {action in self.webService.obtenerNumeroReserva(self.WHALY, pv: 2)})
        let goldAction = UIAlertAction(title: "Gold", style: UIAlertActionStyle.Default, handler: {action in self.webService.obtenerNumeroReserva(self.GOLD, pv: 2)})

        alertController.addAction(rioAction)
        alertController.addAction(electricaAction)
        alertController.addAction(whalyAction)
        alertController.addAction(goldAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)*/

    }
    
    func noAdministrador () {
        self.gestion = "usuario"
        self.passwordUIView.isHidden = true
        self.infoAdministradoUILabel.text = "Usuario"
    }
    
    required init?(coder aDecoder: NSCoder) {
    
        super.init(coder: aDecoder)
        webService.delegate = self
     //   if self.PUNTO_VENTA == 0 {
      //      self.PUNTO_VENTA  = DataManager().getValueForKey("punto_venta_codigo", inFile: "appstate") as Int
        //}
        //if self.PUNTO_VENTA_NOMBRE == "" {
          //  self.PUNTO_VENTA_NOMBRE  = DataManager().getValueForKey("punto_venta", inFile: "appstate") as String
        //}
      //  webService.obtenerNumero()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if IPAD == "MARINAFERRY" {
            self.PUNTO_VENTA = 5
            self.PUNTO_VENTA_NOMBRE = "MarinaFerry 2"
        } else {
            self.PUNTO_VENTA_NOMBRE = "LosBarkitos"
            self.PUNTO_VENTA = 2
        }
        
        // miro la conectividad del ipad
        /*if conec.estaConectado() == true {
            print("Esta conectado")
        } else {
            print("No está conectado")
        }*/
        // MIRA LA CONECTIVIDAD 
        self.hayConexion = conec.estaConectado()

        self.passwordUIView.isHidden = true
        self.tipoListaUIView.isHidden = true
        
        
       // NSNotificationCenter.defaultCenter().addObserver(self, selector: {action in accessoryConected}, name: EAAccessoryDidConnectNotification, object: nil)
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: {action in accessoryDisconnected}, name: EAAccessoryDidConnectNotification, object: nil)
        
        // Compruebo si ya se ha abierto el dia
        // print(DataManager().getValueForKey("vendedor", inFile: "appstate") as! String)
    
        //cargarValoresCon_appstate(inFile: "appstate")
        
        // Registro el cell class vendedorViewController
        self.vendedorUITableView.isHidden = true
        
        // Si es posible pongo el nombre del vendedor
        self.vendedorUITextField.text = DataManager().getValueForKey("nombre_vendedor", inFile: "appstate") as? String
        if self.PUNTO_VENTA == 0 {
            self.PUNTO_VENTA = DataManager().getValueForKey("punto_venta_codigo", inFile: "appstate") as! Int
        }
        if self.PUNTO_VENTA_NOMBRE == "" {
            self.PUNTO_VENTA_NOMBRE = DataManager().getValueForKey("punto_venta", inFile: "appstate") as! String
        }
        
        
        
        
        // creo enlace a webService y digo que el protocolo soy yo mismo
        webService.delegate = self
        
        txtPasswordUITextField.delegate = self
        
        // Aqui calculamos si hay barcas que ya han salido
        webService.hayBarcas()
        
        webService.barcasDia()
        //webService.obtenerNumero()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Miro si hay impresora conectada
        let _ : Bool =  setupImpresora()
       
        self.infoAdministradoUILabel.text = "Usuario"
        
       // let total : Int32 = numeroBarcasSQLite()
       // self.numeroBarcasUILabel.text = String(total)
        
        self.tovueltaListadoVentas = false
        
        if IPAD == "MARINAFERRY" {
            self.PUNTO_VENTA = 5
            self.PUNTO_VENTA_NOMBRE = "MarinaFerry 2"
        } else {
            self.PUNTO_VENTA_NOMBRE = "LosBarkitos"
            self.PUNTO_VENTA = 2
        }
    
        //self.internetReachability = Reachability.reachabilityForInternetConnection()
        //self.internetReachability?.startNotifier()
        //self.verificarEstado(self.internetReachability!)

    }
    
    //func verificarEstado(reachability : Reachability?) {
       
      //  var connectionRequired : Bool = false
       // self.estado = reachability!.currentReachabilityStatus
        
//        if reachability!.isReachable() {
    //        print("conectado")
      //  } else {
            
       // }
    //}
    
    func imprimirTotal() -> Bool {
        
        if setupImpresora() {
            
            self.foundPrinters = SMPort.searchPrinter("BT:")! as NSArray
            
            
            let portInfo : PortInfo = self.foundPrinters.object(at: 0) as! PortInfo
            self.lastSelectedPortName = portInfo.portName! as NSString
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.setPortName(portInfo.portName! as NSString)
            appDelegate.setPortSettings(arrayPort.object(at: 0) as! NSString)
            var _ : NSString = appDelegate.getPortName()
            var _ : NSString = appDelegate.getPortSettings()
            
            // AQUI ESTAN LOS DATOS A IMPRIMIR
            
            prepararImpresion()
            
            // Trataré de desconectar el puerto
            
            return true
        } else {
            return false
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //////////////////////////////////////////////////////////////////////////////////////////////
    // Respuesta del webService de las llamadas al sistema
    /////////////////////////////////////////////////////////////////////////////////////////////
    
    func didReceiveResponse_hayBarcas(_ respuesta: [String : String]) {
        for (k,v) in respuesta {
            if k == "hayBarcas" && v == "SI" {
                webService.cierreDia()
            } else {
                print("ERROR")
            }
        }
    }
    
    
    func didReceiveResponse_listadoVendedores(_ respuesta: Dictionary<String, AnyObject >) {
       // print("Respuesta del servidor : \(respuesta)")
        for (k,v) in respuesta {
            if k as NSString == "error" && v as! NSString == "si" {
                print("ERROR EN EL DICCIONARIO DEVUELTO")
                fatalError()
            }
            // añado el vendedor al diccionario
            self.vendedor = [:]
            let cod = v["codigo"] as! Int
            let nom = v["nombre"] as! String
            self.vendedor[String(cod)] = nom
            // print("cod: \(cod)")
            // print("nom: \(nom)")

            self.vendedores.append(self.vendedor)
        }
        self.vendedorUITableView.clearsContextBeforeDrawing = true
        self.vendedorUITableView.reloadData()
    }
    
    
    /*func didReceiveResponse_listadoVentas(respuesta: [String : AnyObject]) {
        self.ventas = []
        println("respuesta del servidor(respuesta) : \(respuesta)")
        for (k,v) in respuesta {
            if k as NSString == "error" && v as NSString == "si" {
                println("ERROR EN EL DICCIONARIO DEVUELTO")
                EXIT_FAILURE
            
            } else if k as NSString == "numero_viajes" {
                    self.numeroBarcasUILabel.text = String(v as Int)
            } else {
                println("k: \(k), v: \(v)")
                let n : Int = v["numero"] as Int
                self.venta["numero"] = String(n)
                self.venta["nombre"] = v["nombre_vendedor"] as? String
                let p : Int = v["precio"] as Int
                self.venta["precio"] = String(p)
                self.venta["base"]   = v["punto_venta"] as? String
                self.venta["fecha"]  = v["fecha"] as? String
                self.venta["tipo"]   = v["tipo"] as? String
                self.ventas.append(self.venta)
            }
        }
        ordenarVentas()
        println("ventas ordenadas : \(self.ventas)")
        self.ventasUITableView.clearsContextBeforeDrawing = true        // limpiar uitableview
        self.ventasUITableView.reloadData()
    }*/
    
    
    func prepararImpresion() {
        webService.totalBarcas(self.PUNTO_VENTA)
        
       // let totalBarcas : Int = self.totalBarcas[0] + self.totalBarcas[1] + self.totalBarcas[2] + self.totalBarcas[3]
    }
    func didReceiveResponse_totalBarcas(_ respuesta : [String : Int]) {
        
        //print("respuesta del servidor : Total Barcas :\(respuesta)")
        for (k,v) in respuesta {
            if k as NSString == "error" && v as Int == 1 {
                print("Error en el diccionario devuelto : \(v)")
            } else {
                self.totalBarcas = Array(respuesta.values)
            }
        }
        webService.totalEuros(self.PUNTO_VENTA)
    }
    
    func didReceiveResponse_totalEuros(_ respuesta : [String : Int]) {
        
        print("respuesta del servidor : Total Euros :\(respuesta)")
        for (k,v) in respuesta {
            if k == "total" {
                self.totalEuros = v as Int
            } else {
                self.totalEuros = 0
            }
        }
        
        let formatoFecha = DateFormatter()
        formatoFecha.dateFormat = "dd-MM-yyyy"
        let dia = formatoFecha.string(from: Date())
        
        let diccParam : [String : AnyObject] = [
            "p_venta"   : self.PUNTO_VENTA_NOMBRE as AnyObject,
            "rio"       : self.totalBarcas[0] as AnyObject,
            "electrica" : self.totalBarcas[1] as AnyObject,
            "barca"     : self.totalBarcas[2] as AnyObject,
            "gold"      : self.totalBarcas[3] as AnyObject,
            "dia"       : dia as AnyObject,
            "euros"     : self.totalEuros as AnyObject,
            "total"     : totalBarcas as AnyObject
        ]
        
        _  = PrintTotal3Inch(p_portName, p_portSettings: p_portSettings, diccParam: diccParam)
    }
    
    
    func didReceiveResponse_cierreDia(_ respuesta : [String : String]) {
        if respuesta["mensaje"] == "ok" {
            let alerta = UIAlertController(title: "INICIALIZANDO RESERVAS", message: "Las reservas se han restablecido todas a 0", preferredStyle: UIAlertControllerStyle.alert)
            let aceptarAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel, handler: nil )
            alerta.addAction(aceptarAction)
            self.present(alerta, animated: true, completion: nil)
        } else {
            let alerta = UIAlertController(title: "INICIALIZANDO RESERVAS", message: "Error en el servidor", preferredStyle: UIAlertControllerStyle.alert)
            let aceptarAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel, handler: nil )
            alerta.addAction(aceptarAction)
            self.present(alerta, animated: true, completion: nil)

        }
        
        self.tipoListaUIView.isHidden = true
        
    }
    
    func didReceiveResponse_barcasDia(_ respuesta: [String : AnyObject]) {
        
        var salidas = [Int]()
        for (k,v) in respuesta {
            
            if k == "mensaje" && v as! String == "ko" {
                print ("ERROR")
            }
            if k == "contenido" {
                salidas = v as! [Int]
            }
        }
        numeroBarcasDia.rio = salidas[0]
        numeroBarcasDia.barca = salidas[1]
        numeroBarcasDia.gold = salidas[2]
        self.numeroBarcasUILabel.text = String(numeroBarcasDia.total())
        
    }
    
    func cargarValoresCon_appstate(inFile file: String) {
     
        let nombre_v : String = DataManager().getValueForKey("nombre_vendedor", inFile: file) as! String
        let codigo_v  = DataManager().getValueForKey("vendedor", inFile: file) as! String
        
        self.vendedorUITextField.text = nombre_v
        self.vendedor[codigo_v] = nombre_v
        
    }

    
    // IMPLEMENTO LOS METODOS DELEGADOS DE vendedorUITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == VENDEDOR {
            return self.vendedores.count
        } else {
            return self.ventas.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
       // if tableView.tag == VENDEDOR {
            let cell: VendedorUITableViewCell = self.vendedorUITableView.dequeueReusableCell(withIdentifier: "cell") as! VendedorUITableViewCell
        
        
            cell.nombreVendedorUILabelCell.textColor = UIColor.gray
            cell.codigoVendedorUILabelCell.textColor = UIColor.gray
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
            } else {
                cell.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
            }
        
            let vendedor = self.vendedores[indexPath.row]
            let codigo = Array(vendedor.keys)
            let nombre = Array(vendedor.values)
            cell.codigoVendedorUILabelCell.text = String(codigo[0])
            cell.nombreVendedorUILabelCell.text = nombre[0]
        
            // añado el codigo del vendedor al plist
            DataManager().setValueForKey("vendedor", value: codigo as AnyObject, inFile: "appstate")
            DataManager().setValueForKey("nombre_vendedor", value: nombre as AnyObject, inFile: "appstate")

            return cell
            
        }/* else {
            var cell: VentasTicketTableViewCell = self.ventasUITableView.dequeueReusableCellWithIdentifier("CellVentas") as  VentasTicketTableViewCell
            cell.numeroVentasTicketsUILabel.text = self.ventas[indexPath.row]["numero"]
            cell.vendedorVentasTicketsUILabel.text = self.ventas[indexPath.row]["nombre"]
            println(self.ventas[indexPath.row]["nombre"])
            cell.precioVentasTicketsIULabel.text = self.ventas[indexPath.row]["precio"]
            println(self.ventas[indexPath.row]["precio"])
            cell.baseVentasTicketsUILabel.text = self.ventas[indexPath.row]["base"]
            println(self.ventas[indexPath.row]["base"])
            cell.horaVentasTicketsUILabel.text = self.ventas[indexPath.row]["fecha"]
            println(self.ventas[indexPath.row]["fecha"])
            cell.barcaVentasTicketsUILabel.text = self.ventas[indexPath.row]["tipo"]
            println(self.ventas[indexPath.row]["tipo"])
            
            return cell
        }
    }*/
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let altura = tableView.frame.height
        if tableView.tag == VENDEDOR {
            return altura/(CGFloat) (self.vendedores.count)
        } else {
            return 50.0        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == VENDEDOR {
            // recupero los valores de la celda
            let dictVendedor : [String : String] = self.vendedores[indexPath.row]
            let codigo = Array(dictVendedor.keys)
            let nombre = Array(dictVendedor.values)
        
            // Guardo el vendedor en el plist
            DataManager().setValueForKey("vendedor", value: codigo[0] as AnyObject, inFile: "appstate")
            DataManager().setValueForKey("nombre_vendedor", value: nombre[0] as NSString, inFile: "appstate")
        
            // Pongo el nombre del vendedor en el uitextview
            self.vendedorUITextField.text = nombre[0]
        
            // Quito el uitableview de los  vendedores
            self.vendedorUITableView.isHidden = true
            self.btnViewVendedoresUIButton.isEnabled = true
            self.vendedores = []
            self.vendedorUITableView.clearsContextBeforeDrawing = true
            self.vendedorUITableView.reloadData()
        } else {
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguePrecios" {
            let siguienteVC : PreciosViewController = segue.destination as! PreciosViewController
            siguienteVC.toTipo = self.barcaActual
            siguienteVC.barcaActualString = self.barcaActualString
            
        }
        if segue.identifier == "segueTipoReserva" {
            let siguienteVC : tipoReservaUIViewController = segue.destination as! tipoReservaUIViewController
            siguienteVC.totipoReservaViewControllerPV = self.PUNTO_VENTA
            
        }
    }
    
    func ordenarVentas() {
       // println("SIN ORDENAR : \(self.ventas)")
        self.ventas.sort(by: {(primero : [String:String], segundo : [String:String]) -> Bool in
            return Int(primero["numero"]!) > Int(segundo["numero"]!)
        })
        //(println(" ORDENADO : \(self.ventas)")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.txtPasswordUITextField.text == "Otisuhc0" {
            self.gestion = "administrador"
            self.infoAdministradoUILabel.text = "Administrador"
            self.tipoListaUIView.isHidden = false
            self.passwordUIView.isHidden = true
            txtPasswordUITextField.resignFirstResponder()
        } else {
            txtPasswordUITextField.resignFirstResponder()
            let alerta = UIAlertController(title: "PASS INCORRECTO", message: "El password es incorrecto. No tiene privilegios de administrador", preferredStyle: UIAlertControllerStyle.alert)
            let aceptarAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel, handler: {action in self.noAdministrador()} )
            alerta.addAction(aceptarAction)
            self.present(alerta, animated: true, completion: nil)
        }
        return true
    } 
    
    

}
