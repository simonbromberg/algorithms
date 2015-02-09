//
//  Miscellaneous.swift
//  InversionCounter
//
//  Created by shim on 2015-02-08.
//  Copyright (c) 2015 Bupkis. All rights reserved.
//

import Foundation

// File contains a disorganized mess of different methods for QuickSort, MergeSort, Karger's MinCut, count split inversions
// Might eventually clean up
class Miscellaneous {
    var numComparisons = 0
    var pivotChoice: PivotChoice = PivotChoice.First
    var al = AdjacencyList()
    var mincut = 9999999
    
func getData()->Array<Int> {
    let myFilePath = NSBundle.mainBundle().pathForResource("QuickSort", ofType: "txt")
    var array = [Int]()
    var error: NSError? = nil
    var content = String(contentsOfFile: myFilePath!, encoding: NSUTF8StringEncoding, error: &error)?.componentsSeparatedByString("\r\n")
    for value in content! {
        array += [value.toInt()!]
    }
    return array
}
    
    // playing around with Swift's inout keyword for passing objects by reference
func testInout(inout array: [Int]) {
    for i in 0..<array.count {
        testNestedInout(&array,i)
    }
}

func testNestedInout(inout array: [Int], _ index: Int) {
    array[index] = array[index]*10 - 5
}

func quickSort(inout array: [Int],_ i:Int,_ k:Int) {
    if i < k {
        var p = partition(&array,i,k)
        numComparisons += k - i
        quickSort(&array, i, p - 1)
        quickSort(&array, p + 1, k)
    }
}

func choosePivot(array: [Int],_ left: Int, _ right: Int) -> Int {
    switch pivotChoice {
    case .First:
        return left
    case .Last:
        return right
    case .MedianOfThree:
        let first = array[left]
        let last = array[right]
        let middleIndex = (right-left)/2 + left
        let middle = array[middleIndex]
        
        var choices = [first,middle, last]
        choices.sort { (a:Int, b:Int) -> Bool in
            return a < b
        }
        switch choices[1] {
        case first:
            return left
        case last:
            return right
        case middle:
            return middleIndex
        default:
            println("error")
            return left
        }
    }
}

func partition(inout A: [Int],_ l: Int,_ r:Int) -> Int {
    
    var pivot = choosePivot(A,l,r)
    var pivotValue = A[pivot]
    A.swap(pivot, l) // move pivot value to beginning of array
    var i = l + 1
    for var j = l + 1; j <= r; j++ {
        if A[j] < pivotValue {
            A.swap(i++,j)
        }
    }
    A.swap(l, i-1)
    return i - 1
}

func countSplitInversions(left A: Array<Int>, right B: Array<Int>) -> (sorted: Array<Int>,inversions: Int) {
    var i = 0, j = 0
    var sorted = Array<Int>()
    let n = A.count + B.count
    var inversions = 0
    for var k = 0; k < n; k++ {
        if i == A.count && j < B.count {
            sorted += [B[j++]]
            continue
        }
        if j == B.count && i < A.count {
            sorted += [A[i++]]
            continue
        }
        
        if A[i] < B[j] {
            sorted += [A[i++]]
        }
        else {
            inversions += A.count - i
            sorted += [B[j++]]
        }
    }
    return (sorted,inversions)
}

func countInversions(arr: Array<Int>) -> (sorted:Array<Int>,inversions:Int) {
    if arr.count <= 1 {
        return (arr,0)
    }
        
    else {
        var half = arr.count / 2 - 1
        var last = arr.count - 1
        var leftArr = Array(arr[0...half])
        var rightArr = Array(arr[half+1...last])
        
        var countLeft = countInversions(leftArr)
        var countRight = countInversions(rightArr)
        var split = countSplitInversions(left: countLeft.sorted, right: countRight.sorted)
        
        return (split.sorted,countLeft.inversions+countRight.inversions+split.inversions)
    }
}


func merge(left A: Array<Int>, right B: Array<Int>) -> Array<Int> {
    var i = 0, j = 0
    var sorted = Array<Int>()
    let n = A.count + B.count
    for var k = 0; k < n; k++ {
        if i == A.count && j < B.count {
            sorted += [B[j++]]
            continue
        }
        if j == B.count && i < A.count {
            sorted += [A[i++]]
            continue
        }
        
        if A[i] < B[j] {
            sorted += [A[i++]]
        }
        else {
            sorted += [B[j++]]
        }
    }
    return sorted
}

func mergeSort(arr: Array<Int>) -> Array<Int> {
    if arr.count <= 1 {
        return arr
    }
        
    else {
        let half = arr.count / 2 - 1
        let last = arr.count - 1
        var leftArr = Array(arr[0...half])
        var rightArr = Array(arr[half+1...last])
        
        return merge(left: mergeSort(leftArr),right: mergeSort(rightArr))
    }
}

func isSorted(arr: Array<Int>) -> Bool {
    for i in 1..<arr.count {
        if arr[i] < arr[i-1] {
            return false
        }
    }
    return true
}
}

extension Array {
    mutating func swap(i: Int, _ j: Int) {
        if i < self.count && j < self.count && i >= 0 && j >= 0 && i != j {
            let I = self[i]
            self[i] = self[j]
            self[j] = I
        }
    }
}