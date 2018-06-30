//
//  MovieRegisterViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 30/06/18.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit

class MovieRegisterViewController: UIViewController {

    
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tfRating: UITextField!
    @IBOutlet weak var tfDuration: UITextField!
    @IBOutlet weak var lbCategories: UILabel!
    @IBOutlet weak var tvSummary: UITextView!
    @IBOutlet weak var ivPoster: UIImageView!
    @IBOutlet weak var btnAddEdit: UIButton!
    
    var movie: Movie!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if movie  != nil {
            tfTitle.text = movie.title
            tfDuration.text = movie.duration
            tfRating.text = "\(movie.rating)"
            ivPoster.image = movie.image as? UIImage
            tvSummary.text = movie.summary
            btnAddEdit.setTitle("Atualizar", for: .normal)
        }

        // Do any additional setup after loading the view.
    }
   
    @IBAction func addEditMovie(_ sender: Any) {
        
        if movie == nil {
            //modo de criacao
            movie = Movie(context: context)
        }
        movie.title = tfTitle.text!
        movie.rating = Double(tfRating.text!)!
        movie.duration = tfDuration.text!
        movie.summary = tvSummary.text!
        
        do{
        try context.save()
            //voltando pra tela anterior
            navigationController?.popViewController(animated: true)
        } catch {
            print(error.localizedDescription)
        }
        
        
    }
    
}
