//
//  MapViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 26/06/18.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
//Importar MpaKit para trabalhar com mapa ou anotation
import MapKit

class MapViewController: UIViewController {

    //IBOutlet
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    //Vareavel vai representar o elemento atual que o parse ta varrendo
    var currentElement: String = ""
    //Representa um cinema
    var theater: Theater!
    
    //variavel para armazenar todos os cinema q foram encontrado
    var theaters: [Theater] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadXML()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //metodo para load xml
    func loadXML(){
        //recuperando url do arquivo xml
        guard let xmlURL = Bundle.main.url(forResource: "theaters", withExtension: "xml") else {return}
    
        //parseando XML
        guard let xmlParser = XMLParser(contentsOf: xmlURL) else {return}
        //Propria classe vai ser delegate do meu xmlParse
        xmlParser.delegate = self
        xmlParser.parse()
    }
}


//Implementando protocolo Delegate
extension MapViewController: XMLParserDelegate {
    
    //Primeiro metodo - DIDStartElement - chamado toda vez q a varredura do parse encontra o inicio do elemento
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        //toda vez q encontra um elemento joga o nome para a variavel
        currentElement = elementName
        if elementName == "Theater" {
            // Se encontrar o elemento cujo o nome seja Theater entao instancia uma nova classe
            theater = Theater()
        }
    }
    
    //Metodo disparado toda vez q o parse encontra o conteudo de um nó
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
    }
    
    //metodo q indica final de um elememnto
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "Theater" {
            theaters.append(theater)
        }
        
    }
}
