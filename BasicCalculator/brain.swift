//
//  brain.swift
//  BasicCalculator
//
//  Created by Jack Li on 12/29/17.
//  Copyright © 2017 Jack Li. All rights reserved.
//

import Foundation

//auxillary functions to implement mathematic functions not included in Swift's standard library

//factorial
//assumes n is an Int for now
//TO DO: error handling for non-Int Double values
func factorial(_ n : Double) -> Double {
    if n == 0 || n == 1{
        return n
    }
    return n * factorial(n-1)
}

//NOTE: may not be needed
//TO DO?: get working with decimals
func powerOf10(_ n: Double) -> Double {
    if n == 0 {
        return 1
    }
    if (n > 0){
        return 10 * powerOf10(n-1)
    }
    else {
        return 1/10 * powerOf10(n + 1)
    }
}

//the model part of the app, where all computations are handled
struct Brain{
    private var numStack: Stack<String> //keeps track of recent numbers that get pushed and popped off as user types
    
    private var opStack: Stack<String>  //keeps track of recent operations that get pushed and popped off as operations are performed
    
    private var pending: Bool  //to prevent any calculations from being made prematurely to maintain proper mathematical operational precedance
    
    private var description: String  //history of ops and numbers in exact order they appear as user types, NOT based on order they were in on the stacks
    
    init(){
        numStack = Stack<String>(startingElement: "0") //create a dummy 0 in case user wants to perform with the initial 0 on the screen right of the bat
        opStack = Stack<String>()
        pending = true
        description = ""
    }

    private enum Operation{   //different types of operations this calculator will handle
        case constant(Double)
        case parenthesis(String)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
        case clear
    }
    
    private let precedence: Dictionary<String, Int> = [ //precedence table of common mathematical operations, symbols, and constants found on modern scientific calculators. sorted in order from least significant to most significant
        "𝝿": 0,  //TO DO: do constants need precedence?
        "e": 0,
        "ln": 1,  //TO DO: Do unary ops need precedence?
        "x!": 1,
        "±": 1,
        "1/x": 1,
        "log₁₀": 1, //TO DO: do these rankings for precedence make sense?
        "10ˣ": 1,
        "+": 1,
        "−": 1,
        "sin": 2,
        "cos": 2,
        "tan": 2,
        "asin": 2,
        "acos": 2,
        "atan": 2,
        "×": 2,
        "÷": 2,
        "%": 2,
        "√": 3,
        "x²": 3,
        "xᴺ": 3,
        "x⁻ᴺ": 3,
        "(": 4,
        ")": 4,
        "=": 5,
        "c": 5
    ]
    
    //where most of the magic happens
    //most of these are handled by Swift's standard library and closures if need be
    private let operations: Dictionary<String, Operation> = [
        "𝞹": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "ln": Operation.unaryOperation(log),
        "x!": Operation.unaryOperation(factorial),
        "±": Operation.unaryOperation({-$0}),
        "sin": Operation.unaryOperation(sin),
        "cos": Operation.unaryOperation(cos),
        "tan": Operation.unaryOperation(tan),
        "asin": Operation.unaryOperation(asin),
        "acos": Operation.unaryOperation(acos),
        "atan": Operation.unaryOperation(atan),
        "√": Operation.unaryOperation(sqrt),
        "x²": Operation.unaryOperation({$0 * $0}),
        "1/x": Operation.unaryOperation({1/$0}),
        "%": Operation.unaryOperation({$0/100}),
        "log₁₀": Operation.unaryOperation(log10),
        "10ˣ": Operation.unaryOperation(powerOf10),
        "+": Operation.binaryOperation({$0 + $1}),
        "−": Operation.binaryOperation({$0 - $1}),
        "×": Operation.binaryOperation({$0 * $1}),
        "÷": Operation.binaryOperation({$0 / $1}),
        "xᴺ": Operation.binaryOperation({pow($0, $1)}),
        "(": Operation.parenthesis("("),
        ")": Operation.parenthesis(")"),
        "=": Operation.equals,
        "c": Operation.clear
    ]
    
    var nums: Stack<String> {
        get {
            return numStack
        }
        set {
            numStack = newValue   //keep our brain updated on what new numbers user enters in
        }
    }
    
    var ops: Stack<String> {
        get {
            return opStack
        }
        set {
            opStack = newValue  //likewise, we need to monitor what operations the user expects for calculator to perform
        }
    }
    
    var resultIsPending: Bool { //lets controller what calculator's current status is
        get {
            return pending
        }
    }
    
    var result: String? { //throws an exception in case something goes wrong or unexpected happens.
        get {             //TO DO: Can we assume the numStack will never be empty? If so, can we do String instead of String? in that case?
            return numStack.top()
        }
    }
    
    var history: String{  //the entirity of the sequence of operations and numbers operated on due to user input
        get {
            return description
        }
        set {
            description = newValue
        }
    }
    
    //where the core algorithm lies. Handles operator precedence, pending results, etc. Actual computations are relayed to operations dictionary as defined earlier
    mutating func performOperation(_ symbol: String){
        if !opStack.empty() && !pending{  //only crunch numbers if we have numbers to crunch in the first place and the user has demanded an operation whose precedence is <= than that of the previous one he/she entered. This logic branch is actually exclusively made for binary operations TBH
            let topOp = opStack.top()!
            if let operation = operations[topOp]{
                switch operation {
                case .constant(_):   //constants will be treated as numbers so they never end up on the opStack but Swift syntax wants all switch statements to be exhaustive so...
                    break
                case .unaryOperation(_):  //like constants, this calculator is not expected to handle something like cos(7*8+ 98) unless you explicity compute 7*8+98 and then call it. but basically all unary operations are handled such that they are performed on the most recent number on the numStack
                    break
                case .binaryOperation(let function):
                    if numStack.size() >= 2 { //can't perform binary op on a single number
                        let top2 = numStack.top()!  //forceful unwrapping can be used. but might not be necessary if I decide to get rid of the optional...
                        numStack.pop()
                        let top1 = numStack.top()!
                        numStack.pop()
                        let num2 = Double(top2)!
                        let num1 = Double(top1)!
                        numStack.push(item: String(function(num1, num2))) //order matters here. e.g. if it was subtraction or division the correct result for "7-5" is "2", where num2 = 7 and num1 = 5
                        opStack.pop()  //get rid of operator whose operation we just performed
                    }
                case .parenthesis(_):  //parenthesis are nothing more than a placeholder to help the user control precedence of operations for his desired computations
                    break
                case .equals:  //handled below
                    break
                case .clear:   //likewise, handled below
                    break
                }
            }
        }
        else {
            if let operation = operations[symbol]{
                switch operation {
                case .constant(let value):
                    numStack.push(item: String(value))  //treat constants like pi and e as numbers
                case .unaryOperation(let function):  //unary ops are easy: simply apply them to most recent value on numStack.
                    if let top = numStack.top(){
                        numStack.pop()
                        if let toNum = Double(top){
                            numStack.push(item: String(function(toNum)))
                        }
                    }
                case .binaryOperation(_):
                    if numStack.size() >= 2 && !opStack.empty(){ //recursively call this function if user has entered an operation that has lower precedence or equal precendence to that of top of opStack. Also note, "(" is not a binary operation but rather a barrier that helps the user maintain his/her desired order of operations.
                        while (!numStack.empty() && !opStack.empty() && opStack.top()! != "(" && precedence[opStack.top()!]! >= precedence[symbol]!){
                            pending = false
                            performOperation(opStack.top()!) //by recursion, all necessary popping are handled by logic of previous branch after doing the necessary computations
                        }
                        if !pending {  //to prevent going too far. stop when we have either consumed everyting on the opstack or we broke out of the while loop after backtracking and encountering an operation with greater precendence
                            pending = true //waiting to see what kind of operations the user will enter next...
                        }
                        
                    }
                    opStack.push(item: symbol) //push the new operation
                case .parenthesis(let bracket):
                    if bracket == "("{
                        opStack.push(item: bracket)
                    }
                    else { //another case where it would make sense to start actually crunching some numbers. anything with a set of parenthesis has precedence
                        pending = false
                        while (!numStack.empty() && opStack.top() != "(" && !opStack.empty()){
                            performOperation(opStack.top()!)  //once again, recursion elegantly takes care of any popping operations we need to perform on our stacks
                        }
                        opStack.pop() //get rid of one layer of parenthesis
                        pending = true  //waiting to see what kind of operations the user will enter next...
                        
                    }
                case .equals: //equals button essentially crunches everything
                    pending = false
                    while (!numStack.empty() && !opStack.empty()){
                        if opStack.top()! == "("{  //this is to handle any extraneous, unmatched parenthesis in a way the user's inferred computation is not mishandled.
                            opStack.pop()
                        }
                        if let top = opStack.top(){
                            performOperation(top) //recursviely delegates work to previous branches
                        }
                    }
                    pending = true
                case .clear: //an ultimatum. destroys everything we have worked so hard for :(
                    while (!numStack.empty() || !opStack.empty()){
                        if (!numStack.empty()){
                            numStack.pop()
                        }
                        if (!opStack.empty()){
                            opStack.pop()
                        }
                    }
                    description = ""
                    numStack.push(item: "0") //push dummy 0 as default value. maintain consistency in accordance with 0 that first appears on screen when app is launched
                }
            }
        }
        if let topNum = numStack.top(){
            description.append(topNum)
        }
        if let topOp = opStack.top(){
            description.append(topOp)
        }
    }
}
