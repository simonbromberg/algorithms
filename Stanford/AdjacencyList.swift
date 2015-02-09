//
//  AdjacencyList.swift
//  InversionCounter
//
//  Created by shim on 2014-11-08.
//  Copyright (c) 2014 Bupkis. All rights reserved.
//
import Foundation

class Vertex {
    init (index: Int, adjacentVertices: [Int]) {
        self.vertexLabel = index
        self.indices = [index]
        self.adjacentVertices = adjacentVertices
    }
    func mergeWith(vertex: Vertex) {
        self.indices += vertex.indices
        self.adjacentVertices += vertex.adjacentVertices
        for var index = self.adjacentVertices.count - 1; index >= 0; index-- { //remove self loops
            let edge = self.adjacentVertices[index]
            if contains(self.indices,edge) {
                self.adjacentVertices.removeAtIndex(index)
            }
        }
    }
    var vertexLabel: Int
    var indices:[Int] //labels of vertices merged into this vertex
    var adjacentVertices: [Int]
    
    func randomEdge()-> (fromVertex:Int,toVertex:Int) {
        var randomIndex = Int(arc4random_uniform(UInt32(self.adjacentVertices.count)))
        
        return (self.vertexLabel,self.adjacentVertices[randomIndex])
    }
}
class AdjacencyList {
    var adjacencyList = [Int:Vertex]()
    init () {
        adjacencyList = AdjacencyList.getData()
    }
//    func randomVertex() -> Vertex {
//        let index = Int(arc4random_uniform(UInt32(self.adjacencyList.count)))
//        return adjacencyList[index]!
//    }
    class func getData()->[Int:Vertex] {
        let myFilePath = NSBundle.mainBundle().pathForResource("kargerMinCut", ofType: "txt")
        var error: NSError? = nil
        var content = String(contentsOfFile: myFilePath!, encoding: NSUTF8StringEncoding, error: &error)?.componentsSeparatedByString("\r\n")
        var dic = [Int:Vertex]()
        for row in content! {
            var tempArray = row.componentsSeparatedByString("\t")//
            var rowArray = Array<Int>()
            for value in tempArray {
                if let intValue = value.toInt() {
                    rowArray += [intValue]
                }
                
            }
            var vertex = Vertex(index: rowArray[0], adjacentVertices: Array(rowArray[1..<rowArray.count]))
            dic[rowArray[0]] = vertex
        }
        return dic
    }
    
    func rContract() -> [Int:Vertex] {
        var contractedGraph = AdjacencyList.getData()// self.adjacencyList
//        var removedVertices = [Int]()
        var loopRunCount = 0
        while(contractedGraph.count > 2) {
            let randVertIndex = Int(arc4random_uniform(UInt32(contractedGraph.count)))
            var edge = Array(contractedGraph.values)[randVertIndex].randomEdge()
            var v1 = contractedGraph[edge.fromVertex]
            var v2 = contractedGraph[edge.toVertex]
            if v1 == nil || v2 == nil {
                println("ERROR from:\(edge.fromVertex) to:\(edge.toVertex)")
                if v1 == nil {
                    println("from is nil")
                }
                if (v2 == nil) { println("to is nil")}
            }
            v1!.mergeWith(v2!)
            contractedGraph[v1!.vertexLabel] = v1!
            contractedGraph.removeValueForKey(v2!.vertexLabel)
//            removedVertices += [v2!.vertexLabel]
            
            for (label, vertex) in contractedGraph { // redirect references
                for (index, vertexLabel) in enumerate(vertex.adjacentVertices) {
                    if vertexLabel == v2!.vertexLabel {
                        vertex.adjacentVertices[index] = v1!.vertexLabel
//                        println("\(v2!.vertexLabel) switched to \(v1!.vertexLabel) in \(vertex.vertexLabel) ")
                    }
                }
                contractedGraph[label] = vertex
            }

//            println("removed \(v2!.vertexLabel) merged into \(v1!.vertexLabel)")
//            println("count: \(contractedGraph.count)")
            loopRunCount++
        }
        
        return contractedGraph
    }
    
    func countCrossingEdges(#contractedGraph: [Int:Vertex]) -> Int {
        var values = Array(contractedGraph.values)
        var set1 = values[0].indices
        var set2 = values[1].indices
        var crossingEdges = 0

        for label in set1 {
            var vertex = adjacencyList[label]!
            var adjacent = vertex.adjacentVertices
            for i in adjacent {
                if contains(set2,i) {
                    crossingEdges++
                }
            }
        }
        return crossingEdges
    }
}
