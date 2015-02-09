//
//  HashTables.swift
//  InversionCounter
//
//  Created by shim on 2014-11-29.
//  Copyright (c) 2014 Bupkis. All rights reserved.
//

import Foundation

extension String {
    subscript (i: Int) -> String {
        return String(Array(self)[i])
    }
}

enum HeapType {
    case Min
    case Max
}

class Heap {
    var description: String {
        get {
            if self.count == 0 {
                return "Heap is empty \n"
            }
            var output = String()
            var rowLength = 1
            var count = 0
            for (index,i) in enumerate(heap) {
                output += "\(i)"
                count++
                if count == rowLength && index != self.count - 1 {
                    output += "\n"
                    rowLength = rowLength * 2
                    count = 0
                }
                else {
                    output += " "
                }
            }
            output += "\n"
            return output
        }
    }
    
    var type = HeapType.Min
    init(type t: HeapType) {
        type = t
    }
    
    var heap = [Int]()
    subscript(index: Int) -> Int? {
        get {
            if index > heap.count {
                return nil
            }
            return heap[index - 1]
        }
        set {
            if newValue != nil {
                heap[index - 1] = newValue!
            }
        }
    }
    
    var count: Int {
        get {
            return heap.count
        }
    }
    
    func insert(value: Int) {
        heap += [value]
        bubbleUp()
    }
    
    func bubbleUp() {
        var i = heap.count
        if i == 1 {
            return //nothing to fix if heap is only root
        }
        var parent: Int
        var child: Int
        do {
            child = self[i]!
            parent = self[i/2]!
            if !checkRelationship(parent: parent, child: child) {
                swapUp(parentIndex:i,childIndex: i/2)
                i = i / 2
            }
            else {
                break
            }
        } while i > 1
    }
    
    func swapUp(parentIndex p: Int, childIndex c: Int) {
        var childValue = self[c]
        self[c] = self[p]
        self[p] = childValue
    }
    
    func extractRoot()->Int? {
        var root = self[1]
        if root == nil {
            return root
        }
        swapUp(parentIndex: 1, childIndex: heap.count)
        heap.removeLast()
        bubbleDown()
        return root
    }
    
    func bubbleDown() {
        var i = 1
        if count <= 1 {
            return
        }
        do {
            var parent = self[i]!
            var childIndex = reapHeapChild(i)
            if childIndex == nil { //no kids, no need to keep bubbling down
                break
            }
            if !checkRelationship(parent: parent, child: self[childIndex!]!) {
                swapUp(parentIndex: i, childIndex: childIndex!)
                i = childIndex!
            }
            else {
                break
            }
        } while i <= heap.count
    }
    
    func reapHeapChild(parent: Int) -> Int? { //choose child that most satisfies heap relationship (max or min)
        var child: Int?
        var childIndex = parent * 2
        child = self[childIndex]
        if child == nil {
            return nil //no children exist
        }
        var child2 = self[childIndex + 1] //get other child if exists
        if child2 == nil {
            return childIndex //doesn't exist, return other one
        }
        else if checkRelationship(parent: child2!, child: child!) {
            childIndex++
        }
        return childIndex
    }
    
    func checkRelationship(#parent: Int, child: Int) -> Bool {
        switch type {
        case .Min:
            return parent <= child
        case .Max:
            return parent >= child
        }
    }
}
class MedianMaintenance {
    var rawData = [Int]()
    var H_low = Heap(type: HeapType.Max)
    var H_high = Heap(type: HeapType.Min)
    var addedValues = [Int]()
    var medianSum: Int = 0
    init() {
        getData()
    }
    func getData() {
        let myFilePath = NSBundle.mainBundle().pathForResource("Median", ofType: "txt")
        
        if let aStreamReader = StreamReader(path: myFilePath!) {
            while var line = aStreamReader.nextLine()? {
                line = line.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                var value = line.toInt()!
                rawData += [value]
            }
        }
        println("Done getting data")
    }
    func solveMedianMaintenance() -> Int {
        medianSum = 0
        for val in rawData {
            insert(val)
            var median = getMedian()
            medianSum += median

        }
        return medianSum
    }
    
    func getMedian()-> Int {
        let l = H_low.count
        let h = H_high.count
        var k = l + h
        var median: Int
        if k % 2 == 0 {
            median = H_low[1]!
        }
        else {
            if l > h { //can't be equal because then the sum would be even
                median = H_low[1]!
            }
            else {
                median = H_high[1]!
            }
        }
//        println("max low: \(maxLow ?? -1) minHigh: \(minHigh ?? -1) count:\(k)")
//        println(addedValues.sorted({ (t1:Int, t2:Int) -> Bool in
//            return t1 < t2
//        }))
        return median
    }
    
    func insert(val: Int) {
        var maxLow = H_low[1]
        var minHigh = H_high[1]
        if maxLow == nil || val <= maxLow! {
            H_low.insert(val)
        }
        else {
            H_high.insert(val)
        }
        
        //check invariant
        let countLow = H_low.count
        let countHigh = H_high.count
        
        if abs(countLow - countHigh) > 1 {
            if (countLow > countHigh) {
                var lowRoot = H_low.extractRoot()
                H_high.insert(lowRoot!)
            }
            else {
                var highRoot = H_high.extractRoot()
                H_low.insert(highRoot!)
            }
        }
    }
}

class TwoSum {
    var hashTable = [Int64:Bool]()
    var negativeTable = [Int64:Bool]()
    init() {
        getData()
        var index = 0
    }
    
    func getData() {
        let myFilePath = NSBundle.mainBundle().pathForResource("sum2", ofType: "txt")
        
        if let aStreamReader = StreamReader(path: myFilePath!) {
            var index = 0
            while let line = aStreamReader.nextLine() {
                var value = Int64(line.toInt()!)
                if value < 0 {
                    negativeTable[value] = true
                }
                else {
                    hashTable[value] = true
                }
            }
        }
        println("Got data for TwoSum \(hashTable.count)")
    }
    func solve2Sum() -> Int {
        var total = 0
//        var index = 0
        for t in -10000..<0 {
//            var start = NSDate()
            for (x,_) in hashTable {
                var diff = Int64(t) - x
                if diff == x {
                    continue
                }
                if let y = negativeTable[diff] {
                    total++
                    break
                }
                if t % 100 == 0 {
                    println("\(t) \(total)")
                }
            }
        }
        println("done negatives \(total)")
        for t in 0...10000 {
            for (x,_) in negativeTable {
                var diff = Int64(t) - x
                if diff == x {
                    continue
                }
                if let y = hashTable[diff] {
                    total++
                    break
                }
                if t % 100 == 0 {
                    println("\(t) \(total)")
                }
            }
        }
        return total
    }
}


