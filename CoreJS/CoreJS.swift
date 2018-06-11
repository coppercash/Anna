//
//  CoreJS.swift
//  Anna_iOS
//
//  Created by William on 2018/4/19.
//

import Foundation
import JavaScriptCore

enum FileError : Error
{
    case coreNotFound
}

public struct
    CoreJS
{
    public typealias
        Context = JSContext
    public typealias
        FileManaging = Anna.FileManaging
    public typealias
        Logging = Anna.Logging

    @objc(CJSDependency) @objcMembers
    public class
        Dependency : NSObject
    {
        public var
        coreModuleURL :URL? = nil,
        fileManager :FileManaging? = nil,
        logger :Logging? = nil,
        handleException : ((JSContext?, JSValue?) -> Void)? = nil,
        nodePathURLs :[URL]? = nil
        
        func
            resolvedCoreModuleURL() throws -> URL {
            if let
                url = self.coreModuleURL
            { return url }
            let
            bundle = Bundle(for: type(of: self))
            guard let
                url = bundle.url(
                    forResource: "corejs",
                    withExtension: "bundle"
                )
                else { throw FileError.coreNotFound }
            return url
        }
        
        func
            resolvedFileManager() -> FileManaging {
            return self.fileManager ?? FileManager.default
        }
    }
}

extension
    FileManager : CoreJS.FileManaging
{ }

@objc(CJSFileManaging)
public protocol
    FileManaging
{
    func
        contents(atPath path: String) -> Data?
    func
        fileExists(atPath path: String) -> Bool
}

@objc(CJSLogging)
public protocol
    Logging
{
    func
        log(_ string :String)
}

class
    Native : NSObject, NativeJSExport
{
    weak var
    context :JSContext?
    let
    fileManager :FileManaging,
    paths :[String]
    var
    logger :Logging? = nil
    init(
        context :JSContext,
        fileManager :FileManaging,
        paths :[String]
        ) {
        self.context = context
        self.fileManager = fileManager
        self.paths = paths
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
        
        if id.hasPrefix("/") {
            return id
        }
        
        guard let
            parent = js_parent.isString ? js_parent.toString() : nil
            else { return nil }
        let
        cd = (parent as NSString).deletingLastPathComponent
        //
        // cd is a folder
        // id is kind of './name', '../name.js' or 'name'
        
        if
            id.hasPrefix("../") ||
                id.hasPrefix("./")
        {
            var
            absolute = (cd as NSString).appendingPathComponent(id)
            if (id as NSString).pathExtension == "" {
                absolute = (absolute as NSString).appendingPathExtension("js")!
            }
            return (absolute as NSString).standardizingPath
        }
        
        guard
            (id as NSString).pathExtension == ""
            else { return nil }
        //
        // id is a folder

        let
        lookup = self.__lookupPaths(
            for: id,
            under: cd
        )
        for path in lookup {
            if fileManager.fileExists(atPath: path) {
                return (path as NSString).standardizingPath
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
    func
        injectGlobal(
        _ key :String,
        _ value :JSValue
        ) {
        guard let global = self.context?.globalObject
            else { return }
        if value.isUndefined {
            global.deleteProperty(key)
        }
        else {
            global.setValue(value, forProperty: key)
        }
    }
    func
        log(
        _ string :String
        ) {
        self.logger?.log(string)
    }
    
    func
        __lookupPaths(
        for identifier :String,
        under directory :String
        ) -> [String] {
        var
        result = [] as [String]
        let
        paths = self.paths + [directory]
        for path in paths {
            result.append(
                (((path as NSString)
                    .appendingPathComponent("node_modules") as NSString)
                    .appendingPathComponent(identifier) as NSString)
                    .appendingPathComponent("index.js")
            )
        }
        return result;
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
    func
        injectGlobal(
        _ key :String,
        _ value :JSValue
    )
    func
        log(
        _ string :String
    )
}

extension
    JSContext
{
    func
        run(
        _ moduleURL :URL,
        with dependency :CoreJS.Dependency = Dependency()
        ) throws ->JSValue! {
        let
        context = self
        context.name = "CoreJS"
        context.exceptionHandler = dependency.handleException
        let
        fileManager = dependency.resolvedFileManager(),
        mainScriptURL = try dependency.resolvedCoreModuleURL().appendingPathComponent("index.js")
        let
        native = Native(
            context: context,
            fileManager: fileManager,
            paths: dependency.nodePathURLs?.map { $0.path } ?? []
        )
        native.logger = dependency.logger
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
        index = (moduleURL.path as NSString)
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

extension
    NSError
{
    convenience
    init(with jsValue :JSValue) {
        var
        userInfo = [String : String]()
        if let message = jsValue.forProperty("message").toString() {
            userInfo[NSLocalizedDescriptionKey] = message
        }
        if let stack = jsValue.forProperty("stack").toString() {
            userInfo[NSLocalizedFailureReasonErrorKey] = stack
        }
        self.init(
            domain: jsValue.forProperty("name").toString(),
            code: -1,
            userInfo: userInfo
        )
    }
}
