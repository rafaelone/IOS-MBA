//
//  URLViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 28/06/18.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit

class URLViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    
    var url:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //criando objURL
        guard let  webPageURL = URL(string: url) else {return}
        //criando obj de requisicao de pagina
        let request = URLRequest(url: webPageURL)
        webView.loadRequest(request)
        webView.delegate = self
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    @IBAction func runJS(_ sender: UIBarButtonItem) {
        let jsCode = "alert('Nunca Uuse isso !!')"
        webView.stringByEvaluatingJavaScript(from: jsCode)
    }
    
   
}


extension URLViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("Comecando a carregar a pagina")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        loading.stopAnimating()
        print("Terminando de carregar a pagina")
    }
    
    //metodo que serve para saber se a webview deve comecar o carregamento de determinado request, definir o q pode e o que nao pode
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        print(">>>>>>>>>>> \(request.url?.absoluteString)")
        if request.url?.absoluteString.range(of: "facebook.com") != nil {
            return false
        }
        return true
    }
}
