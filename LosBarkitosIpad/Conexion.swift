//
//  Conexion.swift
//  LosBarkitosIpad
//  Esta clase implementa  las llamadas al webservice
//  Created by Jesus Valladolid Rebollar on 21/11/14.
//  Copyright (c) 2014 Jesus Valladolid Rebollar. All rights reserved.
//

import Foundation
import AFNetworking
//import UIkit

// Protocolo a implementar por la clase que delegue esta
 protocol WebServiceProtocoloVentas {
    // funcion que implementará la clase delegada y que recibirá los datos de repuesta a la llamada
    func didReceiveResponse_listadoVendedores(_ respuesta : [String : AnyObject])
    //func didReceiveResponse_listadoVentas(respuesta : [String : AnyObject])
    func didReceiveResponse_totalBarcas(_ respuesta : [String : Int])
    func didReceiveResponse_totalEuros(_ respuesta : [String : Int])
    //func didReceiveResponse_reserva(respuesta : [String : AnyObject])
    func didReceiveResponse_barcasDia(_ respuesta : [String : AnyObject])
    func didReceiveResponse_cierreDia(_ respuesta : [String : String])
    func didReceiveResponse_hayBarcas(_ respuesta : [String : String])
    
}

protocol WebServiceProtocoloPrecio {
    func didReveiveResponse_numeroTicket(_ respuesta : [String : AnyObject])
    func didReceiveResponse_entradaBDD_ventaBarca(_ respuesta : [String : AnyObject])
    func didReceiveResponse_ajustar_numero_ticket_si_falla_impresion(_ respuesta : [String : AnyObject])

}

protocol WebServiceProtocoloControl {
    func didReceiveResponse_primeraLibre(_ respuesta : [String : [String : String]])
    func didReceiveResponse_listaLlegadas(_ respuesta : [String : AnyObject])
    func didReceiveResponse_listaReservas(_ respuesta : [String : AnyObject])
    func didReceiveResponse_salida(_ respuesta : [String : String])
    func didReceiveResponse_llegada(_ respuesta : [String : String])
    func didReceiveResponse_barcasFuera(_ respuesta : [String : [Int]])
    func didReceiveResponse_siguienteBarcaLlegar(_: [String : String])
    func didReceiveResponse_salidaReserva(_: String, tipo: Int)
    func didReceiveResponse_reservasPorDar(_: [String : AnyObject])
}

protocol WebServiceReserva {
    func didReceiveResponse_reservaPosible(_ respuesta : [Bool])
    func didReceiveResponse_reserva(_ respuesta : [String : AnyObject])
    func didReceiveResponse_incrementada(_ respuesta : [String : AnyObject])
}

protocol WebServiceListado {
    func didReceiveResponse_listadoVentas(_: [String : AnyObject])
}

protocol WebServiceVentasMF {
    func didReceiveResponse_ventaMF(_ respuesta : [String : AnyObject])
}

// PRUEBA DE CONEXIÓN CON WEBSERVICE A TRAVES DE AFNETWORKING
class webServiceCallAPI : NSObject {
    
    var delegate : WebServiceProtocoloVentas?
    var delegateControl : WebServiceProtocoloControl?
    var delegateReserva : WebServiceReserva?
    var delegateListado : WebServiceListado?
    var delegatePrecio : WebServiceProtocoloPrecio?
    var delegateMF : WebServiceVentasMF?
    
    let manager : AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()

    var responseObject : AnyObject?
    
    // Esta llamada devuelve una lista con los vendedores del sistema
    func obtenerVendedores()  {
        /*var jsonDict : NSDictionary!
        var jsonArray : NSArray!
        var error : NSError?*/
        manager.get(
            "http://www.marinaferry.info/vendedores/",
            parameters: nil,
            success: {(operation: AFHTTPRequestOperation!, responseObject) in
                //print("responseObject: \(responseObject.description)")
                //var indice : Int = 1
                var diccionario = [String : AnyObject]()
                for (k,v) in responseObject as! [String : AnyObject] {
                    if k != "error" {
                        diccionario[k] = v
                    } else if v as! NSString == "si" {// la respuesta es erronea
                        //print("HAY UN ERROR QUE VIENE DEL SERVIDOR")
                        diccionario = [String : AnyObject]()
                        diccionario["error"] = "si" as AnyObject
                    }// hay un error y hay que paralo
                }
                //print("diccionario: \(diccionario)")
                self.delegate?.didReceiveResponse_listadoVendedores(diccionario)// as NSDictionary)
            },
            
            failure: {(operation: AFHTTPRequestOperation!, error: NSError!) in
                print("Error: \(error.localizedDescription)")
                var diccionario = [String : AnyObject]()
                diccionario["error"] = "si" as AnyObject
                self.delegate?.didReceiveResponse_listadoVendedores(diccionario as Dictionary)// as NSDictionary)
            } as! (AFHTTPRequestOperation?, Error?) -> Void
        )
        
    }
    
    func obtenerVentas() {
        /*var jsonDict :  NSDictionary!
        var jsonArray : NSArray!
        var error :     NSError?
        var puntoVenta : Int = 0*/
        var url : String = "http://www.marinaferry.info/listado_viaje/1/5"
        if IPAD == "LOSBARKITOS" {
            url = "http://www.marinaferry.info/listado_viaje/1/2"
        }

        
        manager.get(url,
            parameters: nil,
            success: {(operation: AFHTTPRequestOperation!, responseObject) in
                 //var indice : Int = 1
                var diccionario = [String : AnyObject]()
                for (k,v) in responseObject as! [String : AnyObject] {
                    if k != "error" {
                        diccionario[k] = v
                    } else if v as! NSString == "si" { // la respuesta es errónea
                        //print("HAY UN ERROR QUE VIENE DEL SERVIDOR")
                        diccionario = [String : AnyObject]()
                        diccionario["error"] = "si" as AnyObject
                    }
                }
                //print("diccionario : \(diccionario)")

                self.delegateListado?.didReceiveResponse_listadoVentas(diccionario as Dictionary)
            },
            
            failure: {(operation: AFHTTPRequestOperation!, error : NSError!) in
                //print("Error \(error.localizedDescription)")
                var diccionario = [String : AnyObject]()
                diccionario["error"] = "si" as AnyObject
                self.delegateListado?.didReceiveResponse_listadoVentas(diccionario as Dictionary)
            } as! (AFHTTPRequestOperation?, Error?) -> Void
        )
    }
    
    func entradaBDD_ventaBarca(_ ticket :Int, tipo : Int, precio : Int, puntoVenta : Int, vendedor : Int, negro : Bool) {
        //var jsonDict : NSDictionary!
        //var jsonArray : NSArray!
        //var error : NSError?
        var ticketBlanco : String = "0"
        
        if negro == false {
            ticketBlanco = "1"
        }
        if ticket == 0 {
            ticketBlanco = "0"
        }
        
        manager.get(
            "http://www.marinaferry.info/registro_barca/\(ticket)/\(tipo)/\(precio)/\(puntoVenta)/\(vendedor)/\(ticketBlanco)/", parameters: nil,
            success: {(operation: AFHTTPRequestOperation!, responseObject) in
                var diccionario = [String : AnyObject]()
                for (k,v) in responseObject as! [String : AnyObject] {
                    if k != "error" {
                        diccionario[k] = v
                    } else if v as! Int == 1 {// la respuesta es erronea
                        //print("HAY UN ERROR QUE VIENE DEL SERVIDOR")
                        diccionario = [String : AnyObject]()
                        diccionario["error"] = "si" as AnyObject
                    }
                }
                //print("diccionario : \(diccionario)")
                self.delegatePrecio?.didReceiveResponse_entradaBDD_ventaBarca(diccionario as Dictionary)
            },
            failure: {(operation, error) in
                //print("Error \(error.localizedDescription)")
                var diccionario = [String : AnyObject]()
                diccionario["error"] = "si" as AnyObject
                self.delegatePrecio?.didReceiveResponse_entradaBDD_ventaBarca(diccionario as Dictionary)
            }) //as! (AFHTTPRequestOperation?, Error?) -> Void
        
    }
    
    func obtenerNumero(_ precio : Int) {
        /*var jsonDict : NSDictionary!
        var jsonArray : NSArray!
        var error : NSError?*/
        manager.get(
            "http://www.marinaferry.info/ultimo_numero/\(precio)",
            parameters: nil,
            success: {(operation: AFHTTPRequestOperation!, responseObject) in
                var diccionario = [String : AnyObject]()
                for (k,v) in responseObject as! [String : AnyObject] {
                    if k != "error" || (k == "error" && v as! NSString == "no"){
                        diccionario[k] = v
                    } else if k == "error" &&  v as! String == "si" {// la respuesta es erronea
                        //print("HAY UN ERROR QUE VIENE DEL SERVIDOR en ultimoNumero")
                        diccionario = [String : AnyObject]()
                        diccionario["error"] = "si" as AnyObject
                    }
                }
                // print("diccionario : \(diccionario)")
                self.delegatePrecio?.didReveiveResponse_numeroTicket(diccionario as Dictionary)
            },
            failure: {(operation, error) in
                //print("Error \(error.localizedDescription)")
                var diccionario = [String : AnyObject]()
                diccionario["error"] = "si" as AnyObject
                self.delegatePrecio?.didReveiveResponse_numeroTicket(diccionario as Dictionary)
            }) // as! (AFHTTPRequestOperation?, Error?) -> Void
    }
    
    func obtenerNumero2(_ precio : Int) {
        /*var jsonDict : NSDictionary!
        var jsonArray : NSArray!
        var error : NSError?*/
        manager.get(
            " http://www.marinaferry.info/ultimo_numero/\(precio)",
            parameters: nil,
            success: {(operation: AFHTTPRequestOperation!, responseObject) in
                var diccionario = [String : AnyObject]()
                for (k,v) in responseObject as! [String : AnyObject] {
                    if k != "error" || (k == "error" && v as! NSString == "no"){
                        diccionario[k] = v
                    } else if k == "error" &&  v as! String == "si" {// la respuesta es erronea
                        //print("HAY UN ERROR QUE VIENE DEL SERVIDOR en ultimoNumero")
                        diccionario = [String : AnyObject]()
                        diccionario["error"] = "si" as AnyObject
                    }
                }
                //print("diccionario : \(diccionario)")
                                    
                self.delegatePrecio?.didReveiveResponse_numeroTicket(diccionario as Dictionary)
            },
            failure: {(operation, error) in
                //print("Error \(error.localizedDescription)")
                var diccionario = [String : AnyObject]()
                diccionario["error"] = "si" as AnyObject
                self.delegatePrecio?.didReveiveResponse_numeroTicket(diccionario as Dictionary)
            }) // as! (AFHTTPRequestOperation?, Error?) -> Void
    }
    
    func ajustarNumeroFalloImpresion(_ tipo : Int) {
        manager.get("http://www.marinaferry.info/ajustar_numero_fallo_impresion/\(tipo)", parameters: nil,
                    success: {(operation: AFHTTPRequestOperation!, responseObject) in
                        var diccionario = [String : String]()
                        for (k,v) in responseObject as! [String : String] {
                            diccionario[k] = v
                        }
                        self.delegatePrecio?.didReceiveResponse_ajustar_numero_ticket_si_falla_impresion(diccionario as [String : AnyObject])
            },
            failure: nil)
    }
    
    
    func hayBarcas() {
        manager.get("http://www.marinaferry.info/hayBarcas", parameters: nil, success: {(operation : AFHTTPRequestOperation!, responseObject) in
            var diccionario = [String : String]()
            for (k,v) in responseObject as! [String : String] {
                if k != "error" {
                    diccionario[k] = v
                } else {
                    diccionario[k] = "error"
                }
            }
            self.delegate?.didReceiveResponse_hayBarcas(diccionario as Dictionary)
            
            }, failure: {(operation, error) in
                var diccionario = [String : String]()
                diccionario["error"] = "si"
                self.delegate?.didReceiveResponse_hayBarcas(diccionario as Dictionary)
        }) //as! (AFHTTPRequestOperation?, Error?) -> Void)
    }
    
    func totalBarcas(_ PV : Int) {
       /* var jsonDict : NSDictionary!
        var jsonArray : NSArray!
        var error : NSError?*/
        manager.get("http://www.marinaferry.info/total_barcas/\(PV)", parameters: nil,
            success: {(operation: AFHTTPRequestOperation!, responseObject) in
                var diccionario = [String : Int]()
                for (k,v) in responseObject as! [String : Int] {
                    if k != "error" {
                        diccionario[k] = v
                    } else {
                        print("HAY UN ERROR QUE VIENE DEL SERVIDOR")
                        diccionario["error"] = 1
                    }
                }
                //print("diccionario : \(diccionario)")
                self.delegate?.didReceiveResponse_totalBarcas(diccionario as Dictionary)
            },
            failure: {(operation, error) in
                //print("Error \(error.localizedDescription)")
                var diccionario = [String : Int]()
                diccionario["error"] = 1
                self.delegate?.didReceiveResponse_totalBarcas(diccionario as Dictionary)
        }) //as! (AFHTTPRequestOperation?, Error?) -> Void)
    }
    
    func totalEuros(_ PV : Int)  {
        /*var jsonDict : NSDictionary!
        var jsonArray : NSArray!
        var error : NSError?*/
        manager.get("http://www.marinaferry.info/total_euros/\(PV)", parameters: nil,
            success: {(operation: AFHTTPRequestOperation!, responseObject) in
                var diccionario = [String : Int]()
                for (k,v) in responseObject as! [String : Int] {
                    if k != "error" {
                        diccionario[k] = v
                    } else {
                        //print("HAY UN ERROR QUE VIENE DEL SERVIDOR")
                        diccionario["error"] = 1
                    }
                }
                //print("diccionario : \(diccionario)")
                self.delegate?.didReceiveResponse_totalEuros(diccionario as Dictionary)
            },
            failure: {(operation, error) in
                //print("Error \(error.localizedDescription)")
                var diccionario = [String : Int]()
                diccionario["error"] = 1
                self.delegate?.didReceiveResponse_totalEuros(diccionario as Dictionary)
        }) // as! (AFHTTPRequestOperation?, Error?) -> Void)
    }
    
    func obtenerPrimerLibre() {
        /*var jsonDict : NSDictionary!
        var jsonArray : NSArray!
        var error : NSError?*/
        manager.get("http://www.marinaferry.info/primera_libre",
            parameters: nil,
            success: {(operation: AFHTTPRequestOperation!, responseObject) in
                //print("responseObject : \(responseObject)")
                self.delegateControl?.didReceiveResponse_primeraLibre(responseObject as! [String : [String : String]])
            },
            failure: {(operation, error) in
                //print("Error \(error.localizedDescription)")
                var diccionario = [String : AnyObject]()
                diccionario["error"] = "si" as AnyObject
                self.delegatePrecio?.didReveiveResponse_numeroTicket(diccionario as Dictionary)
            }) // as! (AFHTTPRequestOperation?, Error?) -> Void
    }
    
    func listaLlegadas(_ tipo : Int) {
        
        /*var jsonDict : NSDictionary!
        var jsonArray : NSArray!
        var error : NSError?*/
        var parametro : String =  String()
        
        switch tipo {
        case 1:
            parametro = "Rio"
        case 2:
            parametro = "Barca"
        case 3:
            parametro = "Gold"
        default:
            parametro = "Rio"
        }
        
        manager.get("http://www.marinaferry.info/orden_llegada/\(parametro)",
            parameters: nil,
            success: {(operation: AFHTTPRequestOperation!, responseObject) in
                var diccionario = [String : AnyObject]()
                for (k,v) in responseObject as! [String : AnyObject] {
                    if k != "error" {
                        diccionario[k] = v
                    } else if v as! NSString == "si" { // la respuesta es errónea
                        //print("HAY UN ERROR QUE VIENE DEL SERVIDOR")
                        diccionario = [String : AnyObject]()
                        diccionario["error"] = "si" as AnyObject
                    }
                }
                //print("diccionario : \(diccionario)")
                
                self.delegateControl?.didReceiveResponse_listaLlegadas(diccionario as Dictionary)

            },
            failure: {(operation, error) in
                //print("Error \(error.localizedDescription)")
                var diccionario = [String : AnyObject]()
                diccionario["error"] = "si" as AnyObject
                self.delegateControl?.didReceiveResponse_listaLlegadas(diccionario as! [String : [String : String]] as [String : AnyObject])
            }) // as! (AFHTTPRequestOperation?, Error?) -> Void
    }
    
    
    func listaReservas(_ tipo : Int) {
        /*var jsonDict : NSDictionary!
        var jsonArray : NSArray!
        var error : NSError?
        var responseObject = [String : AnyObject]()*/
        var parametro : String =  String()
        
        
        switch tipo {
        case 1:
            parametro = "Rio"
        case 2:
            parametro = "Barca"
        case 3:
            parametro = "Gold"
        default:
            parametro = "Rio"
        }
        
        manager.get("http://www.marinaferry.info/listado_reservas/\(parametro)/",
            parameters: nil,
            success: {(operation: AFHTTPRequestOperation!, responseObject) in
                var diccionario = [String : AnyObject]()
                for (k,v) in responseObject as! [String : AnyObject] {
                    if k != "error" {
                        diccionario[k] = v
                    } else if v as! NSString == "si" { // la respuesta es errónea
                        //print("HAY UN ERROR QUE VIENE DEL SERVIDOR")
                        diccionario = [String : AnyObject]()
                        diccionario["error"] = "si" as AnyObject
                    }
                }
                //print("diccionario : \(diccionario)")
                
                self.delegateControl?.didReceiveResponse_listaReservas(diccionario as [String : AnyObject])
                
            },
            failure: {(operation, error) in
                //print("Error \(error.localizedDescription)")
                var diccionario = [String : AnyObject]()
                diccionario["error"] = "si" as AnyObject
                self.delegateControl?.didReceiveResponse_listaReservas(diccionario as! [String : [String : String]] as [String : AnyObject])
            }) // as! (AFHTTPRequestOperation?, Error?) -> Void
    }
    
    func incrementarNumeroReserva(_ tipo : Int) {
        manager.get("http://www.marinaferry.info/incrementar_reserva/\(tipo)",
                    parameters: nil,
                    success: {(operation: AFHTTPRequestOperation!, responseObject) in
                        var diccionario = [String : AnyObject]()
                        for (k,v) in responseObject as! [String : AnyObject] {
                            if k == "mensaje" && v as! String == "ok" {
                                diccionario["error"] = "no" as AnyObject
                            } else if k == "contenido" {
                                diccionario["datos"] = v
                            }
                        }
                        self.delegateReserva?.didReceiveResponse_incrementada(diccionario)
                    
                    
            }, failure: {(operation, error) in
                //print("Error \(error.localizedDescription)")
                var diccionario = [String : AnyObject]()
                diccionario["error"] = "si" as AnyObject
                self.delegateControl?.didReceiveResponse_listaReservas(diccionario as! [String : [String : String]] as [String : AnyObject])
            }) // as! (AFHTTPRequestOperation?, Error?) -> Void
    }
    
    func obtenerNumeroReserva(_ tipo : Int, pv : Int) {
        /*var jsonDict : NSDictionary!
        var jsonArray : NSArray!
        var error : NSError?*/
        
        manager.get("http://www.marinaferry.info/reserva/\(tipo)/\(pv)",
            parameters: nil,
            success: {(operation: AFHTTPRequestOperation!, responseObject) in
                //print("responseObject : \(responseObject)")
                var diccionario = [String : AnyObject]()
                for (k,v) in responseObject as! [String : AnyObject] {
                    if k != "error" {
                        diccionario[k] = v
                    } else if v as! NSString == "si" { // la respuesta es errónea
                        //print("HAY UN ERROR QUE VIENE DEL SERVIDOR")
                        diccionario = [String : AnyObject]()
                        diccionario["error"] = "si" as AnyObject
                    }
                }
                //print("diccionario : \(diccionario)")

                self.delegateReserva?.didReceiveResponse_reserva(responseObject as! [String : AnyObject])
            },
            failure: {(operation, error) in
                //print("Error \(error.localizedDescription)")
                var diccionario = [String : AnyObject]()
                diccionario["error"] = "si" as AnyObject
                self.delegateReserva?.didReceiveResponse_reserva(diccionario as [String : AnyObject])
            }) // as! (AFHTTPRequestOperation?, Error?) -> Void
    }
    
    // Devuelve una lista de bools que controla que barca se puede reservar
    func mirarPosibleReserva(_ tipo : Int) {
        //var error : NSError?
        
        manager.get("http://www.marinaferry.info/posible_reserva/\(tipo)",
            parameters: nil,
            success: {(operation: AFHTTPRequestOperation!, responseObject) in
                
                self.delegateReserva?.didReceiveResponse_reservaPosible(responseObject as! [Bool])
            },
            failure: nil
        )
    }
    
    func salidaBarca(_ tipo : Int) {
        //var error : NSError?
        
        manager.get("http://www.marinaferry.info/salida/\(tipo)",
            parameters: nil,
            success: {(operation : AFHTTPRequestOperation!, responseObject) in
                
                self.delegateControl?.didReceiveResponse_salida(responseObject as! [String : String])
            },
            failure: nil
        )
    }
    
    func llegadaBarca(_ tipo : Int) {
        
        manager.get("http://www.marinaferry.info/llegada/\(tipo)",
            parameters: nil,
            success: {(operation : AFHTTPRequestOperation!, responseObject) in
                
                self.delegateControl?.didReceiveResponse_llegada(responseObject as! [String : String])
            },
            failure: nil
        )
    }
    
    func barcasFuera() {
        manager.get("http://www.marinaferry.info/fuera",
            parameters: nil,
            success: {(operation : AFHTTPRequestOperation!, responseObject) in
                //print(responseObject)
                self.delegateControl?.didReceiveResponse_barcasFuera(responseObject as! [String : [Int]])
            },
            failure: nil)
    }
    
    func siguienteBarcaLlegar() {
        //var error : NSError?
        
        manager.get("http://www.marinaferry.info/primera_en_llegar",
            parameters: nil,
            success: {(operation : AFHTTPRequestOperation!, responseObject) in
                self.delegateControl?.didReceiveResponse_siguienteBarcaLlegar(responseObject as! [String : String])
            },
            failure: nil)
        
        
    }
    
    func cierreDia() {
        
        manager.get("http://www.marinaferry.info/cierre_dia",
            parameters: nil,
            success: {(operation : AFHTTPRequestOperation!, responseObject) in
                        //print(responseObject)
                self.delegate?.didReceiveResponse_cierreDia(responseObject as! [String : String])
            },
            failure: nil)
        
        
    }
    
    func barcasDia() {
        manager.get("http://www.marinaferry.info/barcas_dia", parameters: nil, success: {(operation : AFHTTPRequestOperation!, responseObject) in
            self.delegate?.didReceiveResponse_barcasDia(responseObject as! [String : AnyObject])

            },
            failure: nil)
    }
    
    func salidaReserva(_ tipo : Int, numero : Int) {
         
        manager.get("http://www.marinaferry.info/reserva_fuera/\(tipo)/\(numero)",
            parameters: nil,
            success: {(operation : AFHTTPRequestOperation!, responseObject) in
                self.delegateControl?.didReceiveResponse_salidaReserva("OK", tipo: tipo)
            },
            failure: {(operation, responseObject) in
                self.delegateControl?.didReceiveResponse_salidaReserva("KO", tipo: tipo)
        })
    }
    
    func numeroReservasPorDar() {
        
        manager.get("http://www.marinaferry.info/total_reservas",
            parameters: nil,
            success: {(operation : AFHTTPRequestOperation!, responseObject) in
                self.delegateControl?.didReceiveResponse_reservasPorDar(responseObject as! [String : AnyObject])
            },
            failure: {(operation, error) in
                if self.responseObject != nil {
                    self.delegateControl?.didReceiveResponse_reservasPorDar(self.responseObject as! [String : AnyObject])
                }
            }
        )
    }
    
    func MFinsertar_ticket(_ precio : Float, part : Int) {
        
        manager.get("http://www.marinaferry.info/MFinsertar_ticket/" + String(Int(precio * 100)) + "/" + String(part),
                    parameters: nil,
                    success: {(operation : AFHTTPRequestOperation!, responseObject) in
                        self.delegateMF?.didReceiveResponse_ventaMF(responseObject as! [String : AnyObject])
                    
                    },
                    failure : {(operation, error) in
                        if self.responseObject != nil {
                            print("pasó")
                        }
        }
                    )
    }
}

