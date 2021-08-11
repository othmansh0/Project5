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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    func startGame(){
        title = allWords.randomElement()
        usedWords.removeAll()
        tableView.reloadData()
    }

    @objc func promptForAnswer() {
        
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        // we're giving UIAlertAction some code to execute when tapped
        
       // action in means it accepts one parameter in, of type UIAlertAction
        let submitAction = UIAlertAction(title: "Submit", style: .default)  {
            
            [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else {return}
            
            self?.submit(answer)//we need to reference methods on our view controller using self so that we’re clearly acknowledging the possibility of a strong reference cycle
            
        }
        
        ac.addAction(submitAction)
        present(ac,animated: true)
        
    }
    
    
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        if isPossible(word: lowerAnswer){
            if isOriginal(word: lowerAnswer){
                if isReal(word: lowerAnswer){
                    usedWords.insert(lowerAnswer, at: 0)
                    
                    // For adding cells smoothly
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                }
            }
        }
        
    }
    
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else {return false}
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter){
                tempWord.remove(at: position)
            }
            else {return false}
            
        }
        
        
        return true
    }

    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }

    func isReal(word: String) -> Bool {
       // UITextChecker. This is an iOS class that is designed to spot spelling errors,
        //Rule: when working with any apple framework use utf16.count for char count,if it's your own code use .count
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misselledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        
        //what we care about whether any misspelling was found, and if nothing was found our NSRange ( rangeOfMisspelledWord(in:)) will have the special location NSNotFound
        return misselledRange.location == NSNotFound
    }

}

