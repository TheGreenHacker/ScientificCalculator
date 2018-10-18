//
//  ViewController.swift
//  BasicCalculator
//
//  Created by Jack Li on 12/29/17.
//  Copyright © 2017 Jack Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var sequence: UILabel!
    
    @IBOutlet weak var displayValue: UILabel!
    
    private var middleOfTyping: Bool = false
    
    private var brain: Brain = Brain()
    
    private var hasDecimal: Bool = false
    
    @IBAction func touchedDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        //let currentText = displayValue.text!
        if middleOfTyping{
            let currentText = displayValue.text!
            if digit != "." || (digit == "." && !hasDecimal){
                displayValue.text = currentText + digit
                if digit == "."{
                    hasDecimal = true
                }
            }
        }
        else {
            if digit == "."{
                let currentText = displayValue.text!
                displayValue.text = currentText + digit
                hasDecimal = true
            }
            else {
                displayValue.text = digit
            }
            middleOfTyping = true
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if middleOfTyping{
            brain.nums.push(item: displayValue.text!)
            //print("pushed \(displayValue.text!) onto num stack")
            //print("num stack now has \(brain.vals.size()) items")
            middleOfTyping = false
            hasDecimal = false
        }
        if let mathSymbol = sender.currentTitle{
            //print(mathSymbol)
            brain.performOperation(mathSymbol)
        }
        let currRecord = brain.history
        //print(currRecord)
        if brain.resultIsPending{
            sequence.text = currRecord + "..."
        }
        else {
            sequence.text = currRecord + "="
        }
        if let currVal = brain.result{
            displayValue.text = currVal
        }
    }
    
    
    
}

