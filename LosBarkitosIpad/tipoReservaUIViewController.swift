//
//  tipoReservaUIViewController.swift
//  LosBarkitosIpad
//
//  Created by Jesus Valladolid Rebollar on 7/4/15.
//  Copyright (c) 2015 Jesus Valladolid Rebollar. All rights reserved.
//

import UIKit
var reservas : [Int] = [0,0,0,0]

class tipoReservaUIViewController: UIViewController, WebServiceReserva {
    
    let RESERVA_RIO       = 1
    let RESERVA_BARCA     = 2
    let RESERVA_GOLD      = 3

    var reservas : [Int] = [0,0,0]
    var webService : webServiceCallAPI = webServiceCallAPI()

    // Valor devuelto por el tipoReservaViewController
    var totipoReservaViewControllerTipo : Int = 0
    var totipoReservaViewControllerPV : Int = 0
    var tovueltaReservaViewController : Bool = false
    var tovueltaListadoVentas : Bool = false

    
    @IBOutlet weak var btnRioReservaUIButton: UIButton!
    @IBOutlet weak var btnElectricaReservaUIButton: UIButton!
    @IBOutlet weak var btnBarcaReservaUIButton: UIButton!
    @IBOutlet weak var btnGoldReservaUIButton: UIButton!
    
    
    @IBAction func btnReservaPushButton(_ sender : UIButton) {
        self.webService.obtenerNumeroReserva(sender.tag, pv: self.totipoReservaViewControllerPV)
        self.tovueltaReservaViewController = false
    }
    
    @IBAction func cancelarReservaUIButton(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    override func viewDidLoad() {

        super.viewDidLoad()
        webService.delegateReserva = self
        
        // Do any additional setup after loading the view.
    }
    
    func didReceiveResponse_reservaPosible(_ respuesta : [Bool]) {
        
        self.btnRioReservaUIButton.isEnabled = respuesta[0]
        //self.btnElectricaReservaUIButton.enabled = respuesta[1]
        self.btnBarcaReservaUIButton.isEnabled = respuesta[1]
        self.btnGoldReservaUIButton.isEnabled = respuesta[2]
        
    }
    
    func didReceiveResponse_reserva(_ respuesta : [String : AnyObject]) {
        //print("respuesta del servidor : \(respuesta)")
        //var dicc : [String : AnyObject]
        var PV : String = ""
        var HR : String = ""
        var HP : String = ""
        var tipo : String = ""
        self.reservas = [0,0,0]
        for (k,v) in respuesta {
            if k == "PV" {
                PV = v as! String
            }
            if k == "reservas" {
                self.reservas = v as! [Int]
            }
            if k == "hora reserva" {
                HR = v as! String
            }
            if k == "hora prevista" {
                HP = v as! String
            }
            if k == "exito" {
                tipo = v as! String
            }
        }
        imprimirReserva(PV, HR: HR, HP: HP, tipo: tipo)
    }

    
    func didReceiveResponse_incrementada(_ respuesta : [String : AnyObject]) {
        
    }
    
    
    // Mira si está la impresora conectada:
    // True -> conectada
    // False -> no hay impresora
    func setupImpresora() -> Bool {
        
        foundPrinters = SMPort.searchPrinter("BT:")! as NSArray
        
        if foundPrinters.count > 0 {// Hay impresora conectada
            
            //print(foundPrinters.count)
            let portInfo : PortInfo = foundPrinters.object(at: 0) as! PortInfo
            
            lastSelectedPortName = portInfo.portName! as NSString
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.setPortName(portInfo.portName! as NSString)
            appDelegate.setPortSettings(arrayPort.object(at: 0) as! NSString)
            var _ : NSString = appDelegate.getPortName()
            var _ : NSString = appDelegate.getPortSettings()
            //infoImpresoraUILabel.text = portInfo.portName
            
           // print("Impresoras: \(foundPrinters.objectAtIndex(0))" )
            return true
        }
        else { // No hay ninguna impresora conectada
            let alertaNoImpresora = UIAlertController(title: "SIN IMPRESORA", message: "No hay una impresora conectada. Intenta establecer nuevamente la conexión (Ajustes -> Bluetooth->Seleccionar Impresora TSP)", preferredStyle: UIAlertControllerStyle.alert)
            
            let OkAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            
            alertaNoImpresora.addAction(OkAction)
            
            self.present(alertaNoImpresora, animated: true, completion: nil)
            return false
            
        }
        
    }
    
    func imprimirReserva(_ PV : String, HR : String, HP : String, tipo: String) {
        if setupImpresora() {
            foundPrinters = SMPort.searchPrinter("BT:")! as NSArray
            
            
            let portInfo : PortInfo = foundPrinters.object(at: 0) as! PortInfo
            lastSelectedPortName = portInfo.portName! as NSString
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.setPortName(portInfo.portName! as NSString)
            appDelegate.setPortSettings(arrayPort.object(at: 0) as! NSString)
            let p_portName : NSString = appDelegate.getPortName()
            let p_portSettings : NSString = appDelegate.getPortSettings()
            
            let _ : Bool = PrintSampleReceipt3Inch(p_portName, portSettings: p_portSettings, PV: PV, parametro: self.reservas, HR: HR, HP: HP, tipoBarca: tipo)
        } else {
            let alertaNoImpresora = UIAlertController(title: "SIN IMPRESORA", message: "No hay una impresora conectada. Intenta establecer nuevamente la conexión (Ajustes -> Bluetooth->Seleccionar Impresora TSP)", preferredStyle: UIAlertControllerStyle.alert)
            
            let OkAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            
            alertaNoImpresora.addAction(OkAction)
            
            self.present(alertaNoImpresora, animated: true, completion: nil)

        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /* COMENTADO PORQUE NO SE USA EL VALOR
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueReservaRio" {
            let siguienteVC : VentaViewController = segue.destination as! VentaViewController
            
        } else if segue.identifier == "segueReservaElectrica" {
            let siguienteVC : VentaViewController = segue.destination as! VentaViewController

            
        } else if segue.identifier == "segueReservaBarca" {
            let siguienteVC : VentaViewController = segue.destination as! VentaViewController
 

        } else if segue.identifier == "segueReservaGold" {
            let siguienteVC : VentaViewController = segue.destination as! VentaViewController
     
        } else if segue.identifier == "segueReservaCancelar" {
            let siguienteVC : VentaViewController = segue.destination as! VentaViewController
            
        }
    }
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


}
