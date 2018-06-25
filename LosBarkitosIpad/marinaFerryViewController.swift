//
//  marinaferryViewController.swift
//  LosBarkitosIpad
//
//  Created by Jesús Valladolid Rebollar on 8/12/17.
//  Copyright © 2017 Jesus Valladolid Rebollar. All rights reserved.
//

import UIKit

class Ticket: NSObject {
    

    var numero : Int = 0
    var fecha : String = ""
    var precio : Float = 0.0
    var punto : String = ""
    var particular : Bool = true
    
    func base() -> Float { return Float(precio / 1.21)}
    func iva() -> Float { return Float(precio - base()) }
}

class marinaferryViewController: UIViewController, WebServiceVentasMF {
    let PUNTO_VENTA = 1

    var webService : webServiceCallAPI = webServiceCallAPI()
    var tic = Ticket()
    
    @IBOutlet weak var partGrupView: UIView!
    @IBOutlet weak var partButton: UIButton!
    @IBOutlet weak var gruposButton: UIButton!
    @IBOutlet weak var precioPartView: UIView!
    @IBOutlet weak var precioGruposView: UIView!
    @IBOutlet weak var contGrupoUILabel: UILabel!
    @IBOutlet weak var contPartUILabel: UILabel!
    @IBOutlet weak var borrarContadorUIButton: UIButton!
    
    @IBAction func partPush(_ sender: UIButton) {
        fadeOut(view: self.precioGruposView)
        fadeIn(view: self.precioPartView)
        fadeOut(view: self.contGrupoUILabel)
        fadeIn(view: self.contPartUILabel)
        partButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        gruposButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
    @IBAction func gruposPush(_ sender: UIButton) {
        fadeIn(view: self.precioGruposView)
        fadeOut(view: self.precioPartView)
        fadeIn(view: self.contGrupoUILabel)
        fadeOut(view: self.contPartUILabel)
        gruposButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        partButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
    @IBAction func precioGrupoPush(_ sender: UIButton) {
        
        if let precio : Float = Float(sender.titleLabel!.text!) {
            webService.MFinsertar_ticket(precio, part: 0) // Si parametro = 1 es particular
        }
    }
    @IBAction func precioPartPush(_ sender: UIButton) {
        
        if let precio : Float = Float(sender.titleLabel!.text!) {
            webService.MFinsertar_ticket(precio, part: 1) // Si parametro = 1 es particular
        }
    }
    @IBAction func borrarContadorPush(_ sender: UIButton) {
        self.contPartUILabel.text = "0"
        self.contGrupoUILabel.text = "0"
    }
    
    ////////////////////////////////////////////////////////////////////////
    
    /// Fade in a view with a duration
    ///
    /// Parameter duration: custom animation duration
    func fadeIn(withDuration duration: TimeInterval = 1.0, view : UIView) {
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 1.0
        })
    }
    /// Fade out a view with a duration
    ///
    /// - Parameter duration: custom animation duration
    func fadeOut(withDuration duration: TimeInterval = 1.0, view: UIView) {
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 0.0
        })
    }
    /////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
        self.precioPartView.alpha = 0
        self.precioGruposView.alpha = 0
        self.contPartUILabel.alpha = 0
        self.contGrupoUILabel.alpha = 0
        
        self.contPartUILabel.text = "0"
        self.contGrupoUILabel.text = "0"
        
        webService.delegateMF = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didReceiveResponse_ventaMF(_ respuesta: [String : AnyObject]) {
            
            for (k,v) in respuesta {
                if k as String == "error" && v as! Int == 1 {
                    print("ERROR EN EL SERVIDOR")
                } else if k as String == "error" && v as! Int == 0 {
                    
                    self.rellenarTicket(respuesta)
                    self.procesarTicket()
                }
            }
        
    }
    
 
    func rellenarTicket(_ datos : [String : AnyObject]) {
    
        
        for (k,v) in datos {
            switch k  {
            case "numero"     : tic.numero     = v as! Int
            case "precio"     : tic.precio     = v as! Float
            case "fecha"      : tic.fecha      = v as! String
            case "punto"      : tic.punto      = v as! String
            case "particular" : tic.particular = v as! Bool
            default : break
            }
        }
        
    }
    
    func procesarTicket() {
        // Si se consigue imprimir el ticket se introduce en la BDD, sino da una alerta
        let ticketImpreso = self.imprimirTicket()
        if (ticketImpreso == true) {
            if self.contPartUILabel.alpha != 0 {
                self.contPartUILabel.text = String(Int(self.contPartUILabel.text!)! + 1)
            } else {
                self.contGrupoUILabel.text = String(Int(self.contGrupoUILabel.text!)! + 1)
            }
        } else {
            self.dismiss(animated: true, completion: {
                let alertaNOInsercionBDD = UIAlertController(title: "SIN IMPRESORA-NO HAY TICKET", message: "No hay una impresora conectada. Intenta establecer nuevamente la conexión (Ajustes -> Bluetooth->Seleccionar Impresora TSP) - No se ha insertado en la BDD", preferredStyle: UIAlertControllerStyle.alert)
                
                let OkAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                
                alertaNOInsercionBDD.addAction(OkAction)
                
                self.present(alertaNOInsercionBDD, animated: true, completion: nil)
                
            })
            
        }
    }

    
    func imprimirTicket() -> Bool? {
        
        if setupImpresora() {
            
            foundPrinters = SMPort.searchPrinter("BT:")! as NSArray
            
            
            let portInfo : PortInfo = foundPrinters.object(at: 0) as! PortInfo
            lastSelectedPortName = portInfo.portName! as NSString
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.setPortName(portInfo.portName! as NSString)
            appDelegate.setPortSettings(arrayPort.object(at: 0) as! NSString)
            let p_portName : NSString = appDelegate.getPortName()
            let p_portSettings : NSString = appDelegate.getPortSettings()
            
            let vend    : String = DataManager().getValueForKey("nombre_vendedor", inFile: "appstate") as! String
            let punto   : String = DataManager().getValueForKey("punto_venta", inFile: "appstate") as! String
            let precio  : Int = Int(self.tic.precio)
            let numero  : Int = self.tic.numero
            let diccParam : [String : AnyObject] = [
                "numero"      : numero as AnyObject,
                "punto_venta" : punto as AnyObject,
                "precio"      : precio as AnyObject,
                "vendedor"    : vend as AnyObject
            ]
            
            let ticketImpreso : Bool = PrintSampleReceipt3Inch(p_portName, portSettings: p_portSettings, parametro: diccParam)
            
            // Trataré de desconectar el puerto
            
            return ticketImpreso
        } else {
            return false
        }
    }
    
    
    
}

