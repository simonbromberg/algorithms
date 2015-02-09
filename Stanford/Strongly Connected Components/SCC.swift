//
//  SCC.swift
//
//  Created by Simon Bromberg on 2014-11-15.

import Foundation

class Graph {
    var nodes = [Int:Node]()
    var count: Int {
        get {
            return nodes.count
        }
    }
    var graphDescription: String {
        get {
            var desc = String()
            for (label, node) in nodes {
                desc += node.description + " " + node.neighboursList + "\n"
            }
            return desc
        }
    }
    var finishingTimes: [Int] {
        get {
            var arr = [Int]()
            for var i = 1; i <= count; i++ {
                var node = self[i]
                arr += [node.finishingTime]
            }
            return arr
        }
    }
    private func addNode(node: Node) {
        nodes[node.label] = node
    }
    func resetExploration() {
        for (label,node) in nodes {
            node.explored = false
        }
    }
    func addNewNodeForLabel(label: Int)-> Node {
        var node = Node(label)
        nodes[label] = node
        return node
    }
    func nodeWithLabel(label: Int) -> Node {
        if var node = nodes[label] {
            return node
        }
        return addNewNodeForLabel(label)
    }
    
    subscript(index:Int) -> Node {
        get {
            var node = nodes[index]
            if node == nil {
                return addNewNodeForLabel(index)
            }
            else {
                return node!
            }
        }
    }
}

class Node {
    var label:Int
    var explored = false
    var leader: Int = -1
    var finishingTime: Int = -1
    var neighbours = Array<Node>()
    var incomingEdges = Array<Node>()
    
    var neighboursList: String {
        get {
            var list = "Out:"
            for (index,node) in enumerate(neighbours) {
                list += "\(node.label)"
                if index < neighbours.count - 1 {
                    list += ","
                }
            }
            
            list += " In:"
            for (index,node) in enumerate(incomingEdges) {
                list += "\(node.label)"
                if index < incomingEdges.count - 1 {
                    list += ","
                }
            }
            return list
        }
    }
    var description: String {
        get {
            return "\(self.label)"
        }
    }
    
    init (_ lbl: Int) {
        label = lbl
    }
    func addNeighbour(node: Node) {
        neighbours += [node]
    }
    func addIncomingEdge(node: Node) {
        incomingEdges += [node]
    }
}

class SCCManager {
    var graph = Graph()
    
    init() {
        getData()
        computeSCC()
    }
    
    func getData() {
        println("getting data")
        
        let myFilePath = NSBundle.mainBundle().pathForResource("SCC", ofType: "txt")
        var error: NSError? = nil

        var workingNode = graph.addNewNodeForLabel(1)
        if let aStreamReader = StreamReader(path: myFilePath!) {
            var index = 0
            while let line = aStreamReader.nextLine() {
                if index % 100000 == 0 {
                    println("loaded in row \(index)")
                }
                var tempArray = line.componentsSeparatedByString(" ")
                let tail = tempArray[0].toInt()!
                let head = tempArray[1].toInt()!
                if tail != workingNode.label {
                    workingNode = graph.nodeWithLabel(tail)
                }
                var headNode = graph.nodeWithLabel(head)
                workingNode.addNeighbour(headNode)
                headNode.addIncomingEdge(workingNode)
                index++
            }
            aStreamReader.close()
        }

        println("Done getting data")
    }
    
    var finishingTime: Int = 0
    var source: Node?
    
    func computeSCC() {
        finishingTime = 0
        source = nil

        println("Starting first (reverse) DFS")
        DFSLoop(nil, reverse: true)
        graph.resetExploration()
        finishingTime = -1

        var order = [Int]()
        for _ in 0..<graph.count {
            order += [-1]
        }
        for i in 1...graph.count {
            let spot = graph[i].finishingTime
            order[graph.count - spot] = i
        }
        println("Starting second DFS")
        DFSLoop(order, reverse: false)
        
        //count groups
        var groups = Dictionary<Int,Int>()
        for (label,node) in graph.nodes {
            var leader = node.leader
            if var groupSize = groups[leader] {
                groups[leader] = ++groupSize
            }
            else {
                groups[leader] = 1
            }
        }
        var i = 0
        for (group,size) in groups {
            println(size)
            i++
        }
    }
    
    func DFSLoop(order: [Int]?,reverse: Bool) {
        for var i = 1; i <= graph.count; i++ {
            if i % 10000 == 0 {
                println("DFS loop \(i)")
            }
            var label: Int
            if order == nil || order!.count == 0{
                label = graph[i].label
            }
            else {
                label = order![i-1]
            }
            var node = graph.nodeWithLabel(label)
            if !node.explored {
                source = node
                DFS(source!, reverse: reverse)
            }
        }
        
    }
    
    func DFS(s: Node, reverse: Bool) {
        s.explored = true
        s.leader = source!.label
        var edges = reverse ? s.incomingEdges : s.neighbours
        for node in edges {
            if !node.explored {
                DFS(node,reverse:reverse)
            }
        }
        finishingTime++
        s.finishingTime = finishingTime
    }
    
}