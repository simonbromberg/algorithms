//
//  Dijkstra.swift
//  InversionCounter
//
//  Created by shim on 2014-11-22.
//  Copyright (c) 2014 Bupkis. All rights reserved.
//

import Foundation

class WeightedGraph {
    var nodes = [Int:WeightedNode]()
    var count: Int {
        get {
            return nodes.count
        }
    }
    func addNodeToGraph(node: WeightedNode) {
        nodes[node.label] = node;
    }
    subscript(index: Int)-> WeightedNode {
        get {
            var node = nodes[index]
            if node == nil {
                node = WeightedNode(index)
                nodes[index] = node
            }
            return node!
        }
        set {
            nodes[index] = newValue;
        }
    }
    func printDescription() {
        for (_,node) in nodes {
            println(node.description)
        }
    }
}
class WeightedNode  {
    var label: Int
    var neighbours:[(tail:WeightedNode,weight:Int)] = []
    init(_ l: Int) {
        label = l;
    }
    func addNeighbour(node: WeightedNode,weight w: Int) {
        //check if node already exists in neighbours?
        neighbours += [(tail:node,weight:w)]
    }
    var neighbourDescription: String {
        var output = String()
        let last = neighbours.count - 1
        for (index,node) in enumerate(neighbours) {
            output += "\(node.tail.label)(\(node.weight))"
            if index < last {
                output += ", "
            }
        }
        return output
    }
    var description: String {
        get {
            return "\(label): \(neighbourDescription)"
        }
    }
}
class Dijkstra {
    var graph = WeightedGraph()
    init() {
        getData()
        computeShortestPaths()
    }
    func getData() {
        println("getting data")
        let myFilePath = NSBundle.mainBundle().pathForResource("dijkstraData", ofType: "txt")
        var error: NSError? = nil
        
        if let aStreamReader = StreamReader(path: myFilePath!) {
            var index = 0
            while let line = aStreamReader.nextLine() {
                var row = line.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                var label = row[0].toInt()!
                var node = graph[label]
                for i in 1..<row.count {
                    var pair = row[i]
                    if !pair.isEmpty {
                        var tup = pair.componentsSeparatedByString(",");
                        var tail = tup[0].toInt()!
                        var weight = tup[1].toInt()!
                        node.addNeighbour(graph[tail], weight: weight)
                    }
                }
            }
        }
        println("imported data")
//        graph.printDescription()
    }
    func computeShortestPaths() {
        var seenNodes = [1]
        var A: [Int:Int] = [1:0] //save shortest path distances
        var B:[Int:[Int]] = [1:[1]] //save shortest paths
        while seenNodes.count != graph.count {
            var l = Int.max
            var destination: Int = 0
            var head = 0
            for label in seenNodes {
                var node = graph[label]
                for edge in node.neighbours {
                    var tail = edge.tail.label
                    if contains(seenNodes,tail) {
                        continue
                    }
                    var crit = A[label]! + edge.weight
                    if crit < l {
                        l = crit
                        destination = tail
                        head = label
                    }
                }
            }
            if destination != 0 {
                A[destination] = l
                seenNodes += [destination]
                B[destination] = B[head]! + [destination]
                //                    println("Added \(destination)")
            }
        }
        var assigned = [7,37,59,82,99,115,133,165,188,197]
        for lbl in assigned {
            println("\(lbl):\(A[lbl]!)")
            println(B[lbl]!)
        }
//        println(A)
//        println(B)
    }
    
}