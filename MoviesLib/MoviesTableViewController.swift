//
//  MoviesTableViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 21/06/18.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
import CoreData
class MoviesTableViewController: UITableViewController {
//  var movies:[Movie] = []
    var fetchedResultController: NSFetchedResultsController<Movie>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMovies()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    private func loadMovies(){
        
        //Agora carrega do sqlite
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        //ordenando pelo titulo
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        do{
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
        
        
// ANTES CARREGAVA DE UM JSON
//1º passo: recuperar a url do arquivo json
//        guard let jsonURL = Bundle.main.url(forResource: "movies", withExtension: "json") else {return}//2º passo: transformar URL, puxar o arquivo e jogar pra uma variavel... criando um arquivo tipo data
//        do{
//            let jsonData = try Data(contentsOf: jsonURL)
//            //pegando jsonData e transfomando no arquivo movie
//            movies = try JSONDecoder().decode([Movie].self, from: jsonData)
//            for movie in movies {
//                print(movie.title, movie.duration)
//            }
//        }catch{
//            print(error.localizedDescription)
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ViewController{
//            vc.movie = movies[tableView.indexPathForSelectedRow!.row]
            vc.movie = fetchedResultController.object(at: tableView.indexPathForSelectedRow!)
            
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return movies.count
        //se der merda retorna 0
        return fetchedResultController.fetchedObjects?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MovieTableViewCell

        //recuperando filme
//        let movie = movies[indexPath.row]
        //textlabel - label rpincipal
//        cell.textLabel?.text = movie.title
//        cell.detailTextLabel?.text = movie.duration
        let movie = fetchedResultController.object(at: indexPath)
        cell.lbTitle.text = movie.title
//        cell.ivMovie.image = UIImage(named: movie.image+"small")
        cell.ivMovie.image = movie.image as? UIImage
        cell.lbRating.text = "⭐️ \(movie.rating)/10"
        cell.lbSumary.text = movie.summary
//        print(movie.title)

        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

//
//     Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//             Delete the row from the data source
            let movie = fetchedResultController.object(at: indexPath)
            do {
                context.delete(movie)
              try context.save()
            }catch{
                print(error.localizedDescription)
            }
        }
    }
 

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MoviesTableViewController: NSFetchedResultsControllerDelegate {
    //metodo disparado toda vez que ha uma mudanca de conteudo
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}


