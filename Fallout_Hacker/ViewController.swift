//
//  ViewController.swift
//  Fallout_Hacker
//
//  Created by Romain Menke on 14/07/15.
//  Copyright © 2015 menke dev. All rights reserved.
//

import Cocoa

typealias FoundCharacterSet = (foundString:String, inNumberOfWords:Int, characterIndex:Int)

typealias WordRanking = (word:String, ranking:Int)

class ViewController: NSViewController {
    
    @IBOutlet weak var textfield: NSTextField!
    
    @IBOutlet weak var mostSimilar: NSTextField!
    
    @IBOutlet weak var mostDifferent: NSTextField!
    
    @IBOutlet weak var wordsLeft: NSTextField!
    
    @IBOutlet weak var tryOne: NSTextField!
    
    @IBOutlet weak var tryTwo: NSTextField!
    
    @IBOutlet weak var tryThree: NSTextField!
    
    @IBOutlet weak var correctOne: NSTextField!
    
    @IBOutlet weak var correctTwo: NSTextField!
    
    @IBOutlet weak var correctThree: NSTextField!
    
    var syntaxHighLighter : HighLighter!
    
    
    var tries : [String] = []
    var corrects : [Int] = []
    
    var terminalArray : [[String]] = []
    
    var terminalWords : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.wantsLayer = true
        self.view.layer!.backgroundColor = NSColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        
        setUpHighLighter()
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func setUpHighLighter() {
        
        // build a dict of words to highlight
        let redColor = NSColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)
        let blueColor = NSColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        let greenColor = NSColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        
        let triedGroup = SyntaxGroup(wordCollection_I: [], type_I: "Tried", color_I: blueColor)
        let goodCandidateGroup = SyntaxGroup(wordCollection_I: [], type_I: "Good Candidate", color_I: greenColor)
        let badCandidateGroup = SyntaxGroup(wordCollection_I: [], type_I: "Bad Candidate", color_I: redColor)
        
        let dictionairy : SyntaxDictionairy = SyntaxDictionairy()
        dictionairy.collections.append(triedGroup)
        dictionairy.collections.append(goodCandidateGroup)
        dictionairy.collections.append(badCandidateGroup)
        
        syntaxHighLighter = HighLighter(syntaxDictionairy_I: dictionairy)
        
    }

    override func controlTextDidChange(obj: NSNotification) {
        
        if textfield.stringValue != "" {
            
            tries = []
            corrects = []
            terminalArray = []
            terminalWords = []
            
            buildArray()
            
            if tryOne.stringValue != "" && correctOne.stringValue != "" {
                
                syntaxHighLighter.syntaxDictionairy.collections[0].wordCollection = []
                
                tries.append(tryOne.stringValue)
                syntaxHighLighter.syntaxDictionairy.collections[0].wordCollection.append(tryOne.stringValue)
                corrects.append(correctOne.integerValue)
                
                if tryTwo.stringValue != "" && correctTwo.stringValue != "" {
                    
                    tries.append(tryTwo.stringValue)
                    syntaxHighLighter.syntaxDictionairy.collections[0].wordCollection.append(tryTwo.stringValue)
                    corrects.append(correctTwo.integerValue)
                    
                    if tryThree.stringValue != "" && correctThree.stringValue != "" {
                        
                        tries.append(tryThree.stringValue)
                        syntaxHighLighter.syntaxDictionairy.collections[0].wordCollection.append(tryThree.stringValue)
                        corrects.append(correctThree.integerValue)
                        
                    }
                    
                }
                
                syntaxHighLighter.run(textfield.stringValue) { (finished) -> Void in
                    self.textfield.attributedStringValue = self.syntaxHighLighter.highlightedString
                }
                
                hack(buildTries(), correctLettersArray: corrects)
                
                reBuildArray()
            }
            
        } else {
            mostSimilar.stringValue = ""
            
            mostDifferent.stringValue = ""
            
            wordsLeft.stringValue = ""
            
            tryOne.stringValue = ""
            
            tryTwo.stringValue = ""
            
            tryThree.stringValue = ""
            
            correctOne.stringValue = ""
            
            correctTwo.stringValue = ""
            
            correctThree.stringValue = ""
        }
        
    }
    
    func buildTries() -> [[String]] {
        
        var triesArray : [[String]] = []
        
        var wordLength = 0
        
        for i in 0..<tries.count {
            
            let word = tries[i]
            
            if i == 0 {
                wordLength = (word as NSString).length
            }
            
            var tempCharArray : [Character] = [Character](word.characters)
            var tempStringArray : [String] = []
            for iC in 0..<tempCharArray.count {
                
                tempStringArray.append(String(tempCharArray[iC]))
                
            }
            
            if (word as NSString).length == wordLength {
                
                triesArray.append(tempStringArray)
                
            }
        }
        
        return triesArray
        
    }
    
    
    func buildArray() {
        
        let terminalColl : String = textfield.stringValue
        
        var terminalDict : [String] = terminalColl.componentsSeparatedByString(" ")
        terminalWords = terminalDict
        
        terminalArray = []
        
        var wordLength = 0
        
        for i in 0..<terminalDict.count {
            
            let word = terminalDict[i]
            
            if i == 0 {
                wordLength = (word as NSString).length
            }
            
            var tempCharArray : [Character] = [Character](word.characters)
            var tempStringArray : [String] = []
            for iC in 0..<tempCharArray.count {
                
                tempStringArray.append(String(tempCharArray[iC]))
                
            }
            
            if (word as NSString).length == wordLength {
                
                terminalArray.append(tempStringArray)
                
            }
        }
        
        let wordLengthCheck = (terminalDict[0] as NSString).length
        var foundMistake : Bool = false
        
        for i in 1..<terminalDict.count {
            let currentLength = (terminalDict[i] as NSString).length
            if currentLength != wordLengthCheck {
                
                textfield.textColor = NSColor.redColor()
                foundMistake = true
                
            }
            
        }
        
        if foundMistake == false {
            textfield.textColor = NSColor.blackColor()
        }
        
        findMostSimilar()
        findLeastSimilar()
        
    }
    
    func reBuildArray() {
        
        let terminalColl : String = wordsLeft.stringValue
        
        var terminalDict : [String] = terminalColl.componentsSeparatedByString("\n")
        terminalWords = terminalDict
        
        terminalArray = []
        
        var wordLength = 0
        
        for i in 0..<terminalDict.count {
            
            let word = terminalDict[i]
            
            if i == 0 {
                wordLength = (word as NSString).length
            }
            
            var tempCharArray : [Character] = [Character](word.characters)
            var tempStringArray : [String] = []
            for iC in 0..<tempCharArray.count {
                
                tempStringArray.append(String(tempCharArray[iC]))
                
            }
            
            if (word as NSString).length == wordLength {
                
                terminalArray.append(tempStringArray)
                
            }
        }
        
        
        findMostSimilar()
        findLeastSimilar()
        
    }
    
    
    func findMostSimilar() {
        
        var sameCharacters = 0
        var indexOfMostSimilar = [0,0]
        
        var rankings : [WordRanking] = []
        // get firstWord
        
        for iFW in 0..<terminalArray.count {
            
            var firstWord = terminalArray[iFW]
            
            
            // get secondWord
            for iSW in 0..<terminalArray.count {
                
                var secondWord = terminalArray[iSW]
                var tempSameCharaters : Int = 0
                
                // if not the sameWord
                if iFW != iSW {
                    
                    //compare characters
                    
                    for iChar in 0..<firstWord.count {
                        
                        if firstWord[iChar] == secondWord[iChar] {
                            tempSameCharaters = tempSameCharaters + 1
                        }
                        
                    }
                    
                }
                
                if tempSameCharaters > sameCharacters {
                    
                    sameCharacters = tempSameCharaters
                    indexOfMostSimilar[0] = iFW
                    indexOfMostSimilar[1] = iSW
                }
                
            }
        }
        
        let mostSharedLetters = terminalArray[indexOfMostSimilar[0]]
        
        rankings.append((word:terminalWords[indexOfMostSimilar[0]], ranking:terminalArray[0].count))
        
        for i in 0..<terminalArray.count {
            
            var tempSameCharaters : Int = 0
            
            if terminalArray[i] != mostSharedLetters {
            
                for iChar in 0..<mostSharedLetters.count {
            
                    if mostSharedLetters[iChar] == terminalArray[i][iChar] {
                        tempSameCharaters = tempSameCharaters + 1
                    }
                    
                }
                let newRanking = (word:terminalWords[i], ranking:tempSameCharaters)
                rankings.append(newRanking)
                
            }
        }
        
        let sortedSet = rankings.sort({ $0.ranking > $1.ranking })
        
        var printString : String = ""
        
        for iB in 0..<sortedSet.count {
            if iB == 0 {
                syntaxHighLighter.syntaxDictionairy.collections[1].wordCollection = []
                syntaxHighLighter.syntaxDictionairy.collections[1].wordCollection.append(sortedSet[iB].word)
                
            }
            printString = printString + "\(sortedSet[iB].word)\n"
            
        }
        
        syntaxHighLighter.run(textfield.stringValue) { (finished) -> Void in
            self.textfield.attributedStringValue = self.syntaxHighLighter.highlightedString
        }
        
        mostSimilar.stringValue = printString
        
    }
    
    func findLeastSimilar() {
        
        var sameCharacters = 99
        var indexOfMostSimilar = [0,0]
        // get firstWord
        
        for iFW in 0..<terminalArray.count {
            
            var firstWord = terminalArray[iFW]
            
            
            // get secondWord
            for iSW in 0..<terminalArray.count {
                
                var secondWord = terminalArray[iSW]
                var tempSameCharaters : Int = terminalArray[0].count
                
                // if not the sameWord
                if iFW != iSW {
                    
                    //compare characters
                    
                    for iChar in 0..<firstWord.count {
                        
                        if firstWord[iChar] != secondWord[iChar] {
                            tempSameCharaters = tempSameCharaters - 1
                        }
                        
                    }
                    
                }
                
                if tempSameCharaters < sameCharacters {
                    
                    sameCharacters = tempSameCharaters
                    indexOfMostSimilar[0] = iFW
                    indexOfMostSimilar[1] = iSW
                }
                
            }
        }
//        if terminalWords[indexOfMostSimilar[1]] != "" {
//            syntaxHighLighter.syntaxDictionairy.collections[2].wordCollection = []
//            syntaxHighLighter.syntaxDictionairy.collections[2].wordCollection.append(terminalWords[indexOfMostSimilar[1]])
//            
//            syntaxHighLighter.run(textfield.stringValue) { (finished) -> Void in
//                self.textfield.attributedStringValue = self.syntaxHighLighter.highlightedString
//            }
//        }
        
        mostDifferent.stringValue = "\(terminalWords[indexOfMostSimilar[0]])\n\(terminalWords[indexOfMostSimilar[1]])"
        
    }
    
    
    
    func findCharacterSet() {
        
        var foundCharacters : [FoundCharacterSet] = []
        // get firstWord
        
        for iFW in 0..<terminalArray.count {
            
            var firstWord = terminalArray[iFW]
            
            
            for iChar in 0..<firstWord.count {
                
                var tempFoundInWords : Int = 0
                let tempCharachter = firstWord[iChar]
                
                for iSW in 0..<terminalArray.count {
                    
                    if iFW != iSW {
                        
                        var secondWord = terminalArray[iSW]
                        let secondCharacter = secondWord[iChar]
                        
                        if tempCharachter == secondCharacter {
                            
                            tempFoundInWords = tempFoundInWords + 1
                            
                        }
                    }
                }
                
                
                foundCharacters.append((foundString:tempCharachter, inNumberOfWords:tempFoundInWords, characterIndex:iChar))
                
            }
            
        }
        
        let sortedSet = foundCharacters.sort({ $0.inNumberOfWords > $1.inNumberOfWords })
        
        var finalSetArray : [FoundCharacterSet] = []
        
        for i in 0..<sortedSet.count {
            
            if finalSetArray.count > 0 {
                
                var indexFound : Bool = false
                
                for iB in 0..<finalSetArray.count {
                    if sortedSet[i].characterIndex == finalSetArray[iB].characterIndex {
                        
                        indexFound = true
                        
                    }
                }
                
                if indexFound == false {
                    
                    finalSetArray.append(sortedSet[i])
                    
                }
                
            } else {
                
                finalSetArray.append(sortedSet[i])
                
            }
            
        }
        
        print(finalSetArray)
        
        var mostCommonLettersWord : [FoundCharacterSet] = []
        
        for i in 0..<terminalArray[0].count {
            
            mostCommonLettersWord.append((foundString:"a", inNumberOfWords:0, characterIndex:i))
            
        }
        
        for i in 0..<finalSetArray.count {
            
            let foundSet = finalSetArray[i]
            
            if foundSet.inNumberOfWords > mostCommonLettersWord[foundSet.characterIndex].inNumberOfWords {
                
                mostCommonLettersWord[foundSet.characterIndex] = foundSet
                
            }
            
        }
        
        print(mostCommonLettersWord)
        
        var foundWord : [String] = []
        
        for i in 0..<mostCommonLettersWord.count {
            
            foundWord.append(mostCommonLettersWord[i].foundString)
            
        }
        
        print(foundWord)
    }
    
    func hack(triedWords:[[String]], correctLettersArray:[Int]) {
        
        var crossCheckArray : [[String]] = []
        
        var newStringArray : [[String]] = []
        var newWordArray : [String] = []
        // get firstWord
        
        
        for i in 0..<triedWords.count {
            
            var word = triedWords[i]
            let correctLetters = correctLettersArray[i]
            
            var attributedArray : [[NSMutableAttributedString]] = []
            
            var tempCrossCheck : [String] = []
            
            // get secondWord
            for iSW in 0..<terminalArray.count {
                
                var secondWord = terminalArray[iSW]
                var tempSameCharaters : Int = 0
                var tempAttributedArray : [NSMutableAttributedString] = []
                
                if word != terminalArray[iSW] {
                    
                    //compare characters
                    
                    for iChar in 0..<word.count {
                        
                        print(word)
                        print(secondWord)
                        
                        var attrString1 = NSMutableAttributedString(string: word[iChar])
                        
                        if word[iChar] == secondWord[iChar] {
                            tempSameCharaters = tempSameCharaters + 1
                            
                            var range = (word[iChar] as NSString).rangeOfString(word[iChar])
                            attrString1.addAttribute(NSForegroundColorAttributeName, value: NSColor.orangeColor(), range: range)
                            
                        } else {
                            var range = (word[iChar] as NSString).rangeOfString(word[iChar])
                            attrString1.addAttribute(NSForegroundColorAttributeName, value: NSColor.redColor(), range: range)
                        }
                        
                        tempAttributedArray.append(attrString1)
                        
                    }
                    
                    attributedArray.append(tempAttributedArray)
                    
                }
                
                
                
                if tempSameCharaters == correctLetters {
                    
                    newStringArray.append(secondWord)
                    newWordArray.append(terminalWords[iSW])
                    tempCrossCheck.append(terminalWords[iSW])
                }
            }
            
            crossCheckArray.append(tempCrossCheck)
            
            
        }
        
        var printString : String = ""
        
        var secondCrossCheckArray : [String] = []
        
        if crossCheckArray.count > 1 {
            
            for i in 0..<crossCheckArray[0].count {
                
                for iB in 0..<crossCheckArray[1].count {
                    
                    if crossCheckArray[0][i] == crossCheckArray[1][iB] {
                        
                        secondCrossCheckArray.append(crossCheckArray[0][i])
                        
                    }
                    
                }
                
            }
        } else {
            
            secondCrossCheckArray = newWordArray
            
        }
        
        
        if crossCheckArray.count > 2 {
            
            for i in 0..<crossCheckArray[2].count {
                
                for iB in 0..<secondCrossCheckArray.count {
                    
                    if crossCheckArray[2][i] == secondCrossCheckArray[iB] {
                        
                        printString = printString + "\(secondCrossCheckArray[iB])\n"
                        
                    }
                    
                }
                
            }
            
        } else {
            
            for i in 0..<secondCrossCheckArray.count {
                
                printString = printString + "\(secondCrossCheckArray[i])\n"
                
            }
            
        }
        
        
        wordsLeft.stringValue = printString
    }

}

