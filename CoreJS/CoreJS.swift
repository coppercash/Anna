//
//  CoreJS.swift
//  Anna_iOS
//
//  Created by William on 2018/4/19.
//

import Foundation
import JavaScriptCore

public struct
    CoreJS
{
    public typealias
        Context = JSContext
    public typealias
        Dependencies = Anna.Dependencies
    public typealias
        FileManaging = Anna.FileManaging
}

@objc(CJSFileManaging)
public protocol
    FileManaging
{
    func
        contents(atPath path: String) -> Data?
}

public class
    Dependencies
{
    var
    fileManager :FileManaging? = nil
}

extension
    CoreJS.Context
{
    class func
        run(_ mainScriptURL :URL, with :Dependencies)
        -> CoreJS.Context?
    {
        let
        context = JSContext()
        let
        r = context?.evaluateScript("eval(\'var a = 123; a;\')")
        let
        a = context?.evaluateScript("new Set([1, 2, 3]);")
        return context
    }
}
