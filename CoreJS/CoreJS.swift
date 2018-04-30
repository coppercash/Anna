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
        FileManaging = Anna.FileManaging
}

@objc(CJSFileManaging)
public protocol
    FileManaging
{
    func
        contents(atPath path: String) -> Data?
    func
        fileExists(atPath path: String) -> Bool
}

class
    Native : NSObject, NativeJSExport
{
    weak var
    context :JSContext?
    let
    fileManager :FileManaging,
    workDirectoryURL :URL
    init(
        context :JSContext,
        fileManager :FileManaging,
        workDirectoryURL :URL
        ) {
        self.context = context
        self.fileManager = fileManager
        self.workDirectoryURL = workDirectoryURL
    }
    func
        contains(
        _ id :JSValue
        ) -> NSNumber {
        return (false as NSNumber)
    }
    func
        moduleExports(
        _ id :JSValue
        ) -> JSExport! {
        return nil
    }
    func
        resolvedPath(
        _ id :JSValue,
        _ source :JSValue,
        _ main :JSValue
        ) -> String! {
        let
        workDir = self.workDirectoryURL,
        fileManager = self.fileManager
        guard
            id.isString,
            var
            sub = id.toString(),
            (source.isString || source.isNull),
            let
            parent = source.toString()
            else { return nil }
        
        if sub.hasPrefix("/") {
            return sub
        }
        else if sub.hasPrefix("./") {
            let
            start = sub.index(sub.startIndex, offsetBy: 2)
            sub = sub.substring(from: start)
        }
        sub = (sub as NSString).deletingPathExtension
        let
        cd = source.isNull ? workDir.path : (parent as NSString).deletingLastPathComponent
        var
        filename = ((cd as NSString)
            .appendingPathComponent(sub) as NSString)
            .appendingPathExtension("js")!
        if fileManager.fileExists(atPath: filename) {
            return filename
        }
        filename = ((cd as NSString)
            .appendingPathComponent(sub) as NSString)
            .appendingPathComponent("index.js")
        
        if fileManager.fileExists(atPath: filename) {
            return filename
        }
        return nil
    }
    func
        load(
        _ jspath :JSValue,
        _ exports :JSValue,
        _ require :JSValue,
        _ module :JSValue
        ) {
        guard let
            context = context
            else { return }
        guard
            let
            path = jspath.toString(),
            let
            data = self.fileManager.contents(atPath: path),
            let
            script = String(data: data, encoding: .utf8)
            else
        {
            context.exception = JSValue(
                newErrorFromMessage:
                "Cannot read file at path \(jspath.toString()!).",
                in: context
            )
            return
        }
        let
        decorated =
        """
        (function () {
        return (function (exports, require, module) {
        \(script)
        });
        })();
        """
        let
        _ = context.evaluateScript(
            decorated,
            withSourceURL: URL(fileURLWithPath: path)
            ).call(withArguments: [
                exports,
                require,
                module
                ])
    }
}
@objc protocol
    NativeJSExport : JSExport
{
    func
        contains(
        _ id :JSValue
        ) -> NSNumber
    func
        moduleExports(
        _ id :JSValue
        ) -> JSExport!
    func
        resolvedPath(
        _ id :JSValue,
        _ parent :JSValue,
        _ main :JSValue
        ) -> String!
    func
        load(
        _ path :JSValue,
        _ exports :JSValue,
        _ require :JSValue,
        _ module :JSValue
    )
}

extension
    JSContext
{
    func
        run(
        in workDirectoryURL :URL,
        with fileManager :FileManaging,
        mainScriptURL :URL,
        exceptionHandler : @escaping ((JSContext?, JSValue?) -> Void)
        ) ->JSValue! {
        let
        context = JSContext()!
        context.exceptionHandler = exceptionHandler
        let
        native = Native(
            context: context,
            fileManager: fileManager,
            workDirectoryURL :workDirectoryURL
        )
        let
        data = fileManager.contents(atPath: mainScriptURL.path)!,
        script = String(data: data, encoding: .utf8)
        context.evaluateScript(
            """
const module = { exports: {} };
const exports = module.exports;
"""
        )
        context.evaluateScript(
            script,
            withSourceURL: mainScriptURL
        )
        let
        index = (workDirectoryURL.path as NSString)
            .appendingPathComponent("index.js")
        let
        exports = context
            .evaluateScript("module.exports.run")
            .call(withArguments: [
                index,
                native
                ])
        context.evaluateScript(
            """
delete exports;
delete module;
"""
)
        return exports
    }
}
