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
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    //Vareavel vai representar o elemento atual que o parse ta varrendo
    var currentElement: String = ""
    //Representa um cinema
    var theater: Theater!
    
    //variavel para armazenar todos os cinema q foram encontrado
    var theaters: [Theater] = []
    
    // variavel para sare localizacao do usuario
    lazy var locationManager = CLLocationManager()
    
    //variavel para saber o q vai limpar
    var poiAnnotations: [MKPointAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        loadXML()
        requestUserLocationAuthorization()
        searchBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //metodo que irar solicitar ao usuario a autorizacao
    func requestUserLocationAuthorization(){
        
        // servico de localicazao no device
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            
            //desiredAccuracy - propriedade que define a precisao desejada da localizacao do usuario, quanto maior a precisao maior o consumo de bateria
            //KCLLocationAccuracyBest- maneira precisa... saber exatamente o local
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            //pausa se o app estiver em background
            locationManager.pausesLocationUpdatesAutomatically = true
            
            //solicitanto a autorizacao
            switch CLLocationManager.authorizationStatus(){
            case .authorizedAlways, .authorizedWhenInUse:
                print("Usuario ja autorizou")
            case .denied:
                print("Usuario corno negou")
            case .restricted:
                print("SiFu")
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            default:
                break
            }
        }
        
        
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
    
    //Criar anotation no map
    func addTheaters(){
        for theater in theaters{
            //recuperar as coordenadas da notation
            //CLLocationCOordinate2D -> classe usada para pegar location
            let coordinate = CLLocationCoordinate2D(latitude: theater.latitude, longitude: theater.longitude)
            
            //criando annotation
            let annotation = TheaterAnnotation(coordinate: coordinate, title: theater.name, subtitle: theater.url)
            annotation.coordinate = coordinate
            annotation.title = theater.name
            annotation.subtitle = theater.url
            
            //Add no map as anotacoes
            mapView.addAnnotation(annotation)
        }
        
        //metodo que recebe um arrayn de annotation e ele da um zoom no mapa
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func getRoute(destination: CLLocationCoordinate2D){
        //Objeto que faz requisicao de rota entre 2 pontos
        let request = MKDirectionsRequest()
        //destino
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        //origem
        guard let source = locationManager.location?.coordinate else {return}
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        
        //objeto que faz a requisicao
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if error == nil {
                guard let response = response else {return}
                //Clouser onde define a ordem de ordenacao doa rray, array vai ser ordenado onde os primeiros elementos tenham um tempo esperado menor que os de elementos da frente
                let routes = response.routes.sorted(by: {$0.expectedTravelTime < $1.expectedTravelTime})
                //Rota que quero mostrar pro usuario
                guard let route = routes.first else {return}
                //removendo todos os overlays add antes
                self.mapView.removeOverlays(self.mapView.overlays)
                self.mapView.add(route.polyline, level: .aboveRoads)
                self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                
//                print("Nome da rota: ", route.name)
//                print("Distancia: ",route.distance)
//                print("Duracao: ", route.expectedTravelTime)
//                print("Tipo de transporte: ", route.transportType)
                //Array contendo passo a passo do que vc vai fazer no seu caminho
//                for step in route.steps{
//                    print("Em \(step.distance) metros, \(step.instructions)")
//                }
            }else{
                print(error!.localizedDescription)
            }
        }
        
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
        //removendo qualquer espaco em branco e entre linhas das bordas.
        let content = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if !content.isEmpty {
            switch currentElement{
            case "name":
                theater.name = content
            case "address":
                theater.address = content
            case "latitude":
                theater.latitude = Double(content)!
            case "longitude":
                theater.longitude = Double(content)!
            case "url":
                theater.url = content
            default:
                break
            }
        }
    }
    
    //metodo q indica final de um elememnto
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "Theater" {
            theaters.append(theater)
        }
        
    }
    
    //Metodo que é chamado quando estiver no final do documento
    func parserDidEndDocument(_ parser: XMLParser) {
        addTheaters()
    }
}

extension MapViewController: MKMapViewDelegate {
    //renderizar rotas
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.lineWidth = 2.0
            renderer.strokeColor = #colorLiteral(red: 0.2737571104, green: 1, blue: 0.9338441937, alpha: 1)
            return renderer
        }else{
            return MKOverlayRenderer(overlay: overlay)
        }
        
    }
    
    //metodo disparado toda vez que o usuario clica no botao ou imagem etc.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control  == view.leftCalloutAccessoryView {
            //CLicou no botao esquerdo
            guard let coordinate = view.annotation?.coordinate else {return}
            getRoute(destination: coordinate)
        }else{
            //Clicou no botao direito
        }
    }
    
    //metodo que dispara no delegate pedindo qual é a view da annotation
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //Construir objeto, formatar e depois retorna-lo.
        var annotationView: MKAnnotationView!
        
        if annotation is TheaterAnnotation {
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Theater")
            
            if annotationView == nil {
                    annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Theater")
                    annotationView.image = UIImage(named: "theaterIcon")
                    annotationView.canShowCallout = true
                
                    //Definindo callOut de uma view
                
                //Criando botao do lado esquerdo
                    let btLeft = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                    btLeft.setImage(UIImage(named: "car"), for: .normal)
                    annotationView.leftCalloutAccessoryView = btLeft
                
                //Criando botao do lado direito
                    let btRight = UIButton(type: .detailDisclosure)
                    annotationView.rightCalloutAccessoryView = btRight
            }else{
                    annotationView.annotation = annotation
            }
        }
        return annotationView
    }
}

extension MapViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch  status {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
        default:
            break
        }
    }
    
    // metodo disparado toda vez que o usuario modifica sua localizacao
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        print(userLocation.coordinate)
//        print("Velocidade: ", userLocation.location?.speed ?? 0.0)
//
//        //centralizar mapa no usuario
//        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 500, 500)
//        mapView.setRegion(region, animated: true)
    }
}

extension MapViewController: UISearchBarDelegate {
    // metodo chamado sempre que aperta no botao search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loading.startAnimating()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBar.text!
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            self.loading.stopAnimating()
            self.view.endEditing(true)
            if error == nil {
                guard let response = response else {return}
                // limapndo pesquisa anterior
                self.mapView.removeAnnotations(self.poiAnnotations)
                self.poiAnnotations.removeAll()
                for item in response.mapItems{
                    let annotation = MKPointAnnotation()
                    //placemark que entrega o estabelicimento
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    self.poiAnnotations.append(annotation)
                    
                }
                self.mapView.addAnnotations(self.poiAnnotations)
            }
        }
    }
}
