//
//  stack.swift
//  BasicCalculator
//
//  Created by Jack Li on 12/29/17.
//  Copyright © 2017 Jack Li. All rights reserved.
//

import Foundation

//generic stack data structure to faciliatate computations

public struct Stack<Element>{
    private var items : Array<Element>
    init(){
        items = [Element]()
    }
    init(startingElement: Element){  //to solve the "initial 0" problem
        items = [Element]()
        items.append(startingElement)  //for pushing a dummy zero that can be included in computations if user so chooses
    }
    public func empty() -> Bool {
        return items.isEmpty
    }
    public mutating func push(item: Element){
        items.append(item)
    }
    public mutating func pop(){
        if !empty(){
            items.removeLast()
        }
    }
    func size() -> Int {
        return items.count
    }
    func top() -> Element? {
        if let top = items.last{
            return top
        }
        return nil
    }
}



