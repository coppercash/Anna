//
//  Selector.swift
//  Anna
//
//  Created by William on 17/06/2017.
//
//

import Foundation

/*
 * callWith: > call(with:)
 * callAt: > call(at:)
 * callWithParameterA: > call(parameterA:)
 * tableView:didSelectRowAtIndexPath: > tableView(_:didSelectRowAt:)
 * call:: > call
 */
extension
Selector {
    static let
    prepositions = PrepositionCollection()
    
    var
    methodName :String {
        let name = NSStringFromSelector(self)
        
        // Break the name into components separated by ":"
        // And return "method()" if the selector takes no parameter
        //
        let components = name.components(separatedBy: ":")
        guard
            components.count > 1
            else { return name + "()" }
        
        let (method, first) = components.first!.methodAndFirstParameter
        
        // Collect Labels
        // And return "method" if no label has any character
        //
        var labels = [first]
        labels.append(contentsOf: components[1..<components.count - 1])
        guard
            labels.haveLabels()
            else { return method }
        
        // Transform Labels
        // 1. Substitute "_" for label without any character
        // 2. Uncapitalize the first character
        // 3. Append ":"
        //
        let parameters = labels.map { (label) -> String in
            if label == "" { return "_:" }
            let pruned = label
                .firstUncapitalized()
                .argumentDropped(with: type(of: self).prepositions)
            return pruned + ":"
        }
        
        let result = "\(method)(\(parameters.joined()))"
        return result
    }
}

extension
String {
    var
    methodAndFirstParameter :(String, String) {
        let method :String
        var first :String
        if let with = range(of: "With") {
            method = substring(to: with.lowerBound)
            first = substring(from: with.upperBound)
            if first == "" {
                first = "with"
            }
        }
        else {
            method = self
            first = ""
        }
        
        return (method, first)
    }
    
    func
        firstUncapitalized() ->String {
        guard startIndex < endIndex else { return self }
        let second = index(after: startIndex)
        let uncapitalized = substring(to: second).lowercased() + substring(from: second)
        return uncapitalized 
    }
    
    func
        argumentDropped(with prepositions :PrepositionCollection) ->String {
        let scalars = unicodeScalars
        for range in scalars.backwardCamelSubstringRanges() {
            let substring = String(scalars[range])
            print(substring)
            if prepositions.contains(substring) {
                return String(scalars[scalars.startIndex..<range.upperBound])
            }
        }
        return self
    }
}

extension
String.UnicodeScalarView {
    func
        backwardCamelSubstringRanges() ->AnyIterator<Range<Index>> {
        var end = endIndex
        var start = end
        return AnyIterator {
            var range :Range<Index>? = nil
            while start > self.startIndex {
                start = self.index(before: start)
                if self[start].startsWord() {
                    range = start..<end
                    end = start
                    break
                }
            }
            return range
        }
    }
}

extension
UnicodeScalar {
    static let
    wordStarters :CharacterSet = {
        var starters = CharacterSet.uppercaseLetters
        starters.insert("_")
        return starters
    }()
    
    func
        startsWord() ->Bool {
        return type(of: self).wordStarters.contains(self)
    }
}

extension
Array
where
    Element == String
{
    func haveLabels() ->Bool {
        for label in self {
            if label.startIndex < label.endIndex { return true }
        }
        return false
    }
}

class
PrepositionCollection {
    let set :Set<String>
    init() {
        self.set = Set(type(of: self).prepositions)
    }
    func
        contains(_ preposition :String) ->Bool {
        return set.contains(preposition)
    }
    
    static let
    prepositions = [
        "Aboard",
        "About",
        "Above",
        "Across",
        "Cross",
        "After",
        "Against",
        "Along",
        "Alongside",
        "Amid",
        "Among",
        "Apropos ",
        "Apud ",
        "Around",
        "As",
        "Astride",
        "At",
        "Bar",
        "Before",
        "Behind",
        "Below",
        "Beneath",
        "Beside",
        "Besides",
        "Between",
        "Beyond",
        "But",
        "By",
        "Circa",
        "Come",
        "Despite",
        "Spite",
        "Down",
        "During",
        "Except",
        "For",
        "From",
        "In",
        "Inside",
        "Into",
        "Less",
        "Like",
        "Minus",
        "Near",
        "Of",
        "Off",
        "On",
        "Onto",
        "Opposite",
        "Out",
        "Outside",
        "Over",
        "Past",
        "Per",
        "Short",
        "Since",
        "Than",
        "Through",
        "Throughout",
        "To",
        "Toward",
        "Towards",
        "Under",
        "Underneath",
        "Unlike",
        "Until",
        "Till",
        "Til",
        "Up",
        "Upon",
        "Upside",
        "Versus",
        "Via",
        "With",
        "Within",
        "Without",
        "Worth",
    ]
}

class
PrepositionTrie {
    let root :Node
    
    init() {
        self.root = Node()
        insertPrepositions()
    }
    
    func endIndexByMatching(_ characters :ReversedCollection<String.CharacterView>) ->String.CharacterView.Index?
    {
        var current :Node = root
        for (index, char) in characters.enumerated() {
            print(char)
            guard
                let child = current.child(for: char)
                else { return nil }
            if child.isTerminating {
                return characters.index(characters.startIndex, offsetBy: index).base
            }
            current = child
        }
        return nil
    }
    
    func
        insertPrepositions() {
        for preposision in type(of: self).prepositions {
            insert(preposision.characters.reversed())
        }
    }
    
    func
        insert<Chars>(_ characters :Chars)
        where Chars : Sequence, Chars.Iterator.Element == Character
    {
        var current = root
        for char in characters {
            current = current.getOrCreateChild(for :char)
        }
        current.createChild(for: "\0")
    }
    
    class Node {
        var children = [Character: Node]()
        init() {}
        
        var isTerminating :Bool {
            return children["\0"] != nil
        }
        
        func child(for character :Character) ->Node? {
            return children[character]
        }
        
        func getOrCreateChild(for character :Character) ->Node {
            if children[character] == nil {
                children[character] = Node()
            }
            return children[character]!
        }
        
        func createChild(for character :Character) {
            children[character] = Node()
        }
    }
    
    static let
    prepositions = [
        "Aboard",
        "About",
        "Above",
        "Across",
        "Cross",
        "After",
        "Against",
        "Along",
        "Alongside",
        "Amid",
        "Among",
        "Apropos ",
        "Apud ",
        "Around",
        "As",
        "Astride",
        "At",
        "Bar",
        "Before",
        "Behind",
        "Below",
        "Beneath",
        "Beside",
        "Besides",
        "Between",
        "Beyond",
        "But",
        "By",
        "Circa",
        "Come",
        "Despite",
        "Spite",
        "Down",
        "During",
        "Except",
        "For",
        "From",
        "In",
        "Inside",
        "Into",
        "Less",
        "Like",
        "Minus",
        "Near",
        "Of",
        "Off",
        "On",
        "Onto",
        "Opposite",
        "Out",
        "Outside",
        "Over",
        "Past",
        "Per",
        "Short",
        "Since",
        "Than",
        "Through",
        "Throughout",
        "To",
        "Toward",
        "Towards",
        "Under",
        "Underneath",
        "Unlike",
        "Until",
        "Till",
        "Til",
        "Up",
        "Upon",
        "Upside",
        "Versus",
        "Via",
        "With",
        "Within",
        "Without",
        "Worth",
    ]
}
