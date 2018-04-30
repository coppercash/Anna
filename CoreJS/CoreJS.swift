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
    fileManager :FileManaging
    init(
        context :JSContext,
        fileManager :FileManaging
        ) {
        self.context = context
        self.fileManager = fileManager
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
        _ js_id :JSValue,
        _ js_parent :JSValue,
        _ js_main :JSValue
        ) -> String! {
        let
        fileManager = self.fileManager
        guard
            js_id.isString,
            let
            id = js_id.toString(),
            (js_parent.isString || js_parent.isNull),
            (js_main.isString || js_main.isNull)
            else { return nil }
        let
        parent = js_parent.isString ? js_parent.toString() : nil

        if id.hasPrefix("/") {
            return id
        }
        
        let
        cd :String
        if let
            parent = parent {
            cd = (parent as NSString).deletingLastPathComponent
        }
        else {
            return nil
        }
        //
        // cd is a folder
        // id is either './name', '../name.js' or '.././../'
        
        if
            id.hasSuffix(".js") {
            return (cd as NSString).appendingPathComponent(id)
        }
        let
        name = (id as NSString).deletingPathExtension
        //
        // id is a folder or a file without extension

        let
        lookup = [
            ((cd as NSString)
                .appendingPathComponent(name) as NSString)
                .appendingPathExtension("js")!,
            (((cd as NSString)
                .appendingPathComponent("node_modules") as NSString)
                .appendingPathComponent(name) as NSString)
                .appendingPathComponent("index.js")
        ]
        for path in lookup {
            if fileManager.fileExists(atPath: path) {
                return path
            }
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
            fileManager: fileManager
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
