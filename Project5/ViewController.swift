//
//  ViewController.swift
//  Project5
//
//  Created by othman shahrouri on 8/11/21.
//

import UIKit

class ViewController: UITableViewController {

    var allWords = [String]()
    var usedWords = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsUrl){
                //try?:"call this code, and if it throws an error just send back nil"
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
        
    }
    
    
    
    func startGame(){
        title = allWords.randomElement()
        usedWords.removeAll()
        tableView.reloadData()
    }


}

