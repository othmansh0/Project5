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
  
    
//
//    override func viewWillAppear(_ animated: Bool) {
//        let defaults = UserDefaults.standard
//        defaults.set(usedWords,forKey: "usedWords")
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Restart", style: .done, target: self, action: #selector(startGame))
        
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsUrl){
                //try?:"call this code, and if it throws an error just send back nil"
                allWords = startWords.components(separatedBy: "\n") //splits string into array
            }
        }
        
        if allWords.isEmpty { //faster than .count == 0
            allWords = ["silkworm"]
        }
        let defaults = UserDefaults.standard
        let loadedArray = defaults.object(forKey: "usedWords") as? [String] ?? [String]()
        usedWords = loadedArray
        print(loadedArray)
        
        let ac2 = UIAlertController(title: "", message: loadedArray.joined(separator: ","), preferredStyle: .alert)
        ac2.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        present(ac2, animated: true, completion: nil)
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
    
    @objc func startGame(){
        title = allWords.randomElement()
        //usedWords.removeAll()
        tableView.reloadData()//call numberOfRowsInSection again + calling cellForRowAt repeatedly
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
        
        let errorTitle:String
        let errorMessage:String
        
        
        if isPossible(word: lowerAnswer){
            if isOriginal(word: lowerAnswer){
                if isReal(word: lowerAnswer){
                    usedWords.insert(lowerAnswer, at: 0)
                    let defaults = UserDefaults.standard
                    defaults.set(usedWords,forKey: "usedWords")
                    // For adding cells smoothly
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    return
                } else{
                    errorTitle = "Word not recognised"
                    errorMessage = "You can't just make them up, you know!"
                }
                
            } else {
                errorTitle = "Word used already"
                errorMessage = "Be more original!"
            }
        } else {
            guard let title = title?.lowercased() else {
                return
            }
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from \(title)"
            
        }
       
        showErrorMessage(errorMessage: errorMessage, errorTitle: errorTitle)
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else {return false}
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter){//return first position of substring or nil
                tempWord.remove(at: position)
            }
            else {return false}
            
        }
        
        
        return true
    }

    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word) //check if answer is repeated
    }

    func isReal(word: String) -> Bool {
       // UITextChecker iOS class designed to spot spelling errors
       //Rule: when working with any apple framework use utf16.count for char count,if it's your own code use .count
        guard let title = title else {
            return false
        }
        if(word.count < 3 || word == title) {
            return false
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        
        //what we care about whether any misspelling was found, and if nothing was found our NSRange ( rangeOfMisspelledWord(in:)) will have the special location NSNotFound
        return misspelledRange.location == NSNotFound
    }
    
    
    func showErrorMessage(errorMessage: String, errorTitle: String) {
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default))
        present(ac, animated: true)
    }
    

}

