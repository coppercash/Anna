//
//  Selector.swift
//  Anna
//
//  Created by William on 17/06/2017.
//
//

import Foundation

/*
 * U > U()
 * call > call()
 *
 * UP: > U(P:)
 * callWith: > call(with:)
 * callAt: > call(at:)
 *
 * UPN: > U(P:)
 * goToBed: > go(to:) (> goTo:)
 * callWithPhoneNumber: > call(phoneNumber:)
 *
 * UPNPN: > UPN(P:)
 * goToBedAtTime: > goToBed(at:) (> goToBedAt:)
 *
 * TN: > T(N:)
 * X callPhoneNumber: > call(phoneNumber:) (> callWithPhoneNumber:)
 *
 * TNPN: > TN(P:)
 * selectRowAtIndex: > selectRow(at:) (> selectRowAt:)
 *
 * *:UP: > *(*:UP:)
 * view:didTouchAround: > view(_:didTouchAround:)
 *
 * *:UPN: > N(_:UP:)
 * view:didTouchAroundPoint: > view(_:didTouchAround:)
 *
 * *:UPNPN: > N(_:UPNP:)
 * view:didTouchAreaAroundPoint: > view(_:didTouchAreaAround:)
 *
 * *:TN: > *(_:T:)
 * X tableView:didSelectRow: > tableView(_:didSelect:)
 *
 * *:TNPN: > *(_:TNP:)
 * tableView:didSelectRowAtIndexPath: > tableView(_:didSelectRowAt:)
 *
 * ?
 * call:: > call
 */
extension
Selector {
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
                .argumentDropped()
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
        let prepositions = PrepositionCollection.shared
        let scalars = unicodeScalars
        var method = self, first = ""
        for range in scalars.backwardCamelSubstringRanges() {
            let substring = String(scalars[range])
            if prepositions.contains(substring) {
                method = String(scalars[scalars.startIndex..<range.lowerBound])
                first = ((substring == "With") && (range.upperBound != scalars.endIndex)) ?
                    String(scalars[range.upperBound..<scalars.endIndex]) :
                    String(scalars[range])
                break
            }
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
        argumentDropped() ->String {
        let prepositions = PrepositionCollection.shared
        let scalars = unicodeScalars
        for range in scalars.backwardCamelSubstringRanges() {
            let substring = String(scalars[range])
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

protocol
IndexedString {
    var startIndex :String.Index { get }
    var endIndex :String.Index { get }
}
extension
String : IndexedString {}

extension
Array
where
    Element : IndexedString
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
    shared = PrepositionCollection()
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
