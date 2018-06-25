//
//  ManejoSQLITE.swift
//  LosBarkitosIpad
//
//  Created by Jesus Valladolid Rebollar on 27/2/15.
//  Copyright (c) 2015 Jesus Valladolid Rebollar. All rights reserved.
//

import FMDB
let sharedInstance = ManejoSQLITE()

class ManejoSQLITE : NSObject {
    var sqliteDatabase : FMDatabase? = nil
    var sqliteDatabasePath : String? = nil
    
    class var instance: ManejoSQLITE {
        sharedInstance.sqliteDatabase = FMDatabase(path: UtilidadesBDDSQLITE.getPath("LosBarkitosSQLITE.sqlite"))
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
        sharedInstance.sqliteDatabasePath = (documentsFolder as NSString).appendingPathComponent("LosBarkitosSQLITE.sqlite")

        //let path = UtilidadesBDDSQLITE.getPath("LosBarkitosSQLITE.sqlite")
        print("path: \(sharedInstance.sqliteDatabasePath ?? "No hay")")
        return sharedInstance
    }
    
    func insertaViajeSQLITE(_ viaje : Viaje) -> Bool {
        //let consulta : String? = "INSERT INTO viaje VALUES (?, ?, ?, ?, ?, ?, ?)"
        
        let filemgr = FileManager.default
        if filemgr.fileExists(atPath: sharedInstance.sqliteDatabasePath!) {
            if sharedInstance.sqliteDatabase!.open() {
                let consulta : String? = "INSERT INTO viaje VALUES (?,?,?,?,?,?,?)"
                if !sharedInstance.sqliteDatabase!.executeUpdate(consulta!, withArgumentsIn: [viaje.numero, viaje.precio, viaje.fecha, viaje.punto_venta, viaje.barca, viaje.vendedor, viaje.blanco]) {
                    print("\(sqliteDatabase!.lastError()) - \(sqliteDatabase!.lastErrorMessage())")
                }
                sharedInstance.sqliteDatabase!.close()
            }
        }
        
        
        
        //let estaInsertado = sharedInstance.sqliteDatabase!.executeUpdate(consulta!, withArgumentsInArray: [ viaje.numero, viaje.precio, viaje.fecha,viaje.punto_venta,viaje.barca,viaje.vendedor, viaje.blanco])
//        let estaInsertado = sharedInstance.sqliteDatabase!.executeUpdate(consulta!, withArgumentsInArray: nil)
        
  //      println("\(consulta!)")
       // sharedInstance.sqliteDatabase!.close()
    //    return estaInsertado
        return true
        
    }
    
    func numeroBarcas() -> Int32 {
        var numBarcas : Int32 = 0
        let filemgr = FileManager.default
        if filemgr.fileExists(atPath: sharedInstance.sqliteDatabasePath!) {
            if sharedInstance.sqliteDatabase!.open() {
                let consulta = "SELECT count(*) from viaje"
                let resultado : FMResultSet? = try? sharedInstance.sqliteDatabase!.executeQuery(consulta, values: nil)
                if let resultado = resultado, resultado.next() {
                     numBarcas = resultado.int(forColumnIndex: 0) as Int32
                } else {
                    numBarcas = 0
                }
                sharedInstance.sqliteDatabase!.close()
            }
        }
        return numBarcas
    }
}
