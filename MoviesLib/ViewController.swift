//
//  ViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 14/06/18.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
  
    @IBOutlet weak var ivMovie: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbCategories: UILabel!
    @IBOutlet weak var lbDuration: UILabel!
    @IBOutlet weak var lbRating: UILabel!
    
    @IBOutlet weak var lbSinopse: UITextView!
  
    
    var movie: Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      lbTitle.text = movie.title
      lbCategories.text = movie.categories
      lbDuration.text = movie.duration
      lbRating.text = "⭐️ \(movie.rating)/10"
      ivMovie.image = UIImage(named: movie.image)
       lbSinopse.text = movie.summary
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

