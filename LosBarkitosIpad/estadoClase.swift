//
//  estadoClase.swift
//  LosBarkitosIpad
//
//  Created by Jesus Valladolid Rebollar on 23/2/15.
//  Copyright (c) 2015 Jesus Valladolid Rebollar. All rights reserved.
//

import Foundation
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


class estado: NSObject {
    
    var nombreEstado : String?
    
    var horaLlegada : Date? // almacena la hora de la primera barca disponible
    
    var control : Int?
    
    // nombreEstado : INICIAL - No hay reservas ni barcas fuera
    //                INTERMEDIO - No hay reservas pero hay barcas fuera
    //                FINAL - Hay reservas
    
    func transicion(_ nombreEstado : String, control : Int, tipoTransicion : String) -> estado {
        
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "hh:mm:ss"
        self.control = control
        self.nombreEstado = nombreEstado
        
        if nombreEstado == "INICIAL" {
            if tipoTransicion == "SALIDA" {
                
                self.horaLlegada = Date().addingTimeInterval(3600) // se añade una hora a la hora de salida
                self.nombreEstado = "INTERMEDIO"
                self.control = 0
            }
        } else if nombreEstado == "INTERMEDIO" {
            if tipoTransicion == "LLEGADA" {
                self.horaLlegada = nil
                self.nombreEstado = "INICIAL"
                self.control = 0
            } else if tipoTransicion == "RESERVA" {
                self.horaLlegada = self.horaLlegada?.addingTimeInterval(3600) // se incrementa una hora
                self.nombreEstado = "FINAL"
                self.control? += 1
            }
        } else if nombreEstado == "FINAL" {
            if tipoTransicion == "SALIDA" {
                if self.control > 0 {
                    self.control? -= 1
                } else if self.control == 1 {
                    self.nombreEstado = "INTERMEDIO"
                    self.control = 0
                }
                if tipoTransicion == "RESERVA" {
                    self.control? += 1
                    self.horaLlegada = self.horaLlegada?.addingTimeInterval(3600) // se incrementa una hora
                }
            }
        }
        return self
    }
}
