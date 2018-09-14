//
//  AppDelegate.swift
//  LosBarkitosIpad
//
//  Created by Jesus Valladolid Rebollar on 14/11/14.
//  Copyright (c) 2014 Jesus Valladolid Rebollar. All rights reserved.
//

import UIKit


/// ESTRUCTURA QUE GUARDA EN NUMERO DE BARCAS VENDIDAS EN TOTAL Y QUE
/// TAMBIÉN SIRVE PARA MANTENER EL ORDEN DE RESERVAS
struct numBarcas {
    var rio       : Int
    var barca : Int
    var gold     : Int
    
    func total() -> Int {
        return rio + gold + barca - 3 
    }
}

var numeroBarcasDia = numBarcas(rio : 0, barca : 0, gold : 0)


// propiedades de control de la impresora

var portName : NSString = ""
var portSettings : NSString = ""
var drawerPortName : NSString = ""
// propiedades para el control de la bd sqlite en local
var DBLocal : String = ""
var DBPath : String = ""

let IPAD : String = "MARINAFERRY"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func getPortName()->NSString {
        return portName as NSString
    }
    func setPortName(_ nombre : NSString) {
        if portName != nombre {
            portName = nombre
        }
    }
    func getPortSettings()->NSString {
        return portSettings as NSString
    }
    func setPortSettings(_ settings : NSString) {
        if portSettings != settings {
            portSettings = settings
        }
    }
    func getDrawerPortName() -> NSString {
        return drawerPortName
    }
    func setDrawerPortName(_ portName : NSString) {
        if drawerPortName != portName {
            drawerPortName = portName.copy() as! NSString
        }
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //cargarPlist_appstate(inFile: "appstate")

        // Cuando se abre la app miro si ya se ha cargado el dia
        // cargado = "si" "no"
        var cargado: String? = DataManager().getValueForKey("cargado", inFile: "appstate") as? String
        
        if (cargado == nil || cargado == "no") {
            cargarPlist_appstate(inFile: "appstate")
            cargado = "si"
        }
        
        
        // Preparo la bd local sqlite
        // se copia la BBDD al directorio de documentos de la aplicacion
    
        UtilidadesBDDSQLITE.copyFile("LosBarkitosSQLITE.sqlite")
        
        return true
        

    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    // carga el appstate con los valores correspondientes
    @discardableResult func cargarPlist_appstate(inFile file: String) -> String {
        
        DataManager().setValueForKey("estado", value: "INICIAL" as NSString, inFile: "appstate")
        
        DataManager().setValueForKey("vendedor" , value: "4" as NSString, inFile: "appstate")
        DataManager().setValueForKey("nombre_vendedor", value: "Miguel" as NSString, inFile: "appstate")
        
        DataManager().setValueForKey("rios", value: 0 as NSNumber, inFile: "appstate")
        DataManager().setValueForKey("electricas", value: 0 as NSNumber, inFile: "appstate")
        DataManager().setValueForKey("whalys", value: 0 as NSNumber, inFile: "appstate")
        DataManager().setValueForKey("golds", value: 0 as NSNumber, inFile: "appstate")
        
        DataManager().setValueForKey("riosfuera", value: 0 as NSNumber, inFile: "appstate")
        DataManager().setValueForKey("electricasfuera", value: 0 as NSNumber, inFile: "appstate")
        DataManager().setValueForKey("whalysfuera", value: 0 as NSNumber, inFile: "appstate")
        DataManager().setValueForKey("goldsfuera", value: 0 as NSNumber, inFile: "appstate")
        
        DataManager().setValueForKey("lista", value: 1 as NSNumber, inFile: "appstate")
        DataManager().setValueForKey("cargado", value: "no" as NSString, inFile: "appstate")
        DataManager().setValueForKey("lista_precio", value: "1" as NSString, inFile: "appstate")
        if IPAD == "MARINAFERRY" {
            DataManager().setValueForKey("punto_venta_codigo", value: 5 as NSNumber, inFile: "appstate")
            DataManager().setValueForKey("punto_venta", value: "MarinaFerry 2" as NSString, inFile: "appstate")
        } else {
            DataManager().setValueForKey("punto_venta_codigo", value: 2 as NSNumber, inFile: "appstate")
            DataManager().setValueForKey("punto_venta", value: "LosBarkitos" as NSString, inFile: "appstate")
        }
        
        DataManager().setValueForKey("total_barcas", value: 0 as NSNumber, inFile: "appstate")
        
        //Este valor sirve para saber si hay barcas vendidas
        // 1 -> hay barcas vendidas
        // 0 -> No hay barcas vendidas
        DataManager().setValueForKey("barcas_vendidas", value: 1 as NSNumber, inFile: "appstate")
        
        return "si"
        
    }

}

