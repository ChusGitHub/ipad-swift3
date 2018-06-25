//
//  listadoVentasViewController.swift
//  LosBarkitosIpad
//
//  Created by Jesus Valladolid Rebollar on 15/7/15.
//  Copyright (c) 2015 Jesus Valladolid Rebollar. All rights reserved.
//

import UIKit

class listadoVentasViewController: UIViewController, WebServiceListado, UITableViewDataSource, UITableViewDelegate {
    
    var webService : webServiceCallAPI = webServiceCallAPI()
    var listadoBarcas = [[String : AnyObject]]()
    var numeroBarcas : Int = 0
    
    @IBOutlet weak var listadoVentasTableView: UITableView!
    @IBOutlet weak var anteriorUIButton: UIButton!
    
    @IBOutlet weak var totalBarcasUILabel: UILabel!
    
    @IBAction func anteriorPushButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webService.delegateListado = self
        
        webService.obtenerVentas()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func didReceiveResponse_listadoVentas(_ diccionario : [String : AnyObject]) {
        
        // println("diccionario : \(diccionario)")
        self.listadoBarcas = []
        var registro : [String : AnyObject] = [:]
        print("diccionario : \(diccionario)", terminator: "")
        for (k,v) in diccionario {
            if k == "numero_viajes" {
                self.numeroBarcas = v as! Int
            } else if (k == "error" && v as! String == "si") {
                //print("FALLO", terminator: "")
            } else {
                registro["numero"] = v["numero"] as! Int as AnyObject
                registro["punto_venta"] = v["punto_venta"] as! String as AnyObject
                registro["hora"] = v["fecha"] as! String as AnyObject
                registro["precio"] = v["precio"] as! Int as AnyObject
                registro["tipo"] = v["tipo"] as! String as AnyObject
                self.listadoBarcas.append(registro)
            }
        }
        // ordenacion de las reservas por el numero
        
        self.listadoBarcas.sort(by: {(primero : [String:AnyObject], segundo : [String:AnyObject]) -> Bool in
            return   segundo["hora"] as! String > primero["hora"] as! String
        })
        
        self.listadoVentasTableView.clearsContextBeforeDrawing = true
        self.listadoVentasTableView.reloadData()
        self.totalBarcasUILabel.text =  String(self.numeroBarcas)
        
    }
    
    // IMPLEMENTO LOS METODOS DELEGADOS DE listaUITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.numeroBarcas
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell : listadoVentasTableViewCell = self.listadoVentasTableView.dequeueReusableCell(withIdentifier: "CellListadoVentas") as! listadoVentasTableViewCell
        
        let numero : Int = self.listadoBarcas[indexPath.row]["numero"] as! Int
        cell.numeroUILabel.text = String(numero)
        cell.puntoVentaUILabel.text = self.listadoBarcas[indexPath.row]["punto_venta"] as? String
        cell.horaUILabel.text = self.listadoBarcas[indexPath.row]["hora"] as? String
        cell.tipoBarcaUILabel.text = self.listadoBarcas[indexPath.row]["tipo"] as? String
        cell.precioUILabel.text = String(self.listadoBarcas[indexPath.row]["precio"] as! Int)
        
        
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueListadoVentas" {
            let siguienteVC : VentaViewController = segue.destination as! VentaViewController
            siguienteVC.tovueltaListadoVentas = true
            siguienteVC.toPreciosViewController = 0
        }
    }

}
