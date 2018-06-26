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
    public typealias
        FileHandling = Anna.FileHandling

    @objc(CJSDependency) @objcMembers
    public class
        Dependency : NSObject
    {
        public typealias
        ExceptionHandler = (JSContext?, Error?) -> Void
        public var
        moduleURL :URL? = nil,
        fileManager :FileManaging? = nil,
        standardOutput :FileHandling? = nil,
        exceptionHandler :ExceptionHandler? = nil,
        nodePathURLs :Set<URL>? = nil,
        globalModules :Dictionary<String, URL>? = nil
    }
}

@objc(CJSFileManaging)
public protocol
    FileManaging
{
    @objc(contentsAtPath:)
    func
        contents(atPath path: String) -> Data?
    @objc(fileExistsAtPath:)
    func
        fileExists(atPath path: String) -> Bool
}
extension FileManager : CoreJS.FileManaging {}

@objc(CJSFileHandling)
public protocol
    FileHandling
{
    @objc(writeData:)
    func
        write(_ data: Data) -> Void
}
extension FileHandle : CoreJS.FileHandling {}

class
    Native : NSObject, NativeJSExport
{
    weak var
    context :JSContext?
    let
    fileManager :FileManaging,
    standardOutput :FileHandling,
    globalModules :[String : URL],
    paths :Set<URL>
    init(
        context :JSContext,
        fileManager :FileManaging,
        standardOutput :FileHandling,
        globalModules :[String : URL],
        paths :Set<URL>
        ) {
        self.context = context
        self.fileManager = fileManager
        self.standardOutput = standardOutput
        self.globalModules = globalModules
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
        fileManager = self.fileManager,
        globalModules = self.globalModules
        
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
        
        if let url = globalModules[id] {
            return url
                .appendingPathComponent("index")
                .appendingPathExtension("js")
                .path
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
        url = URL(fileURLWithPath: path),
        decorated = String(format: ("""
(function () { return (
  function (exports, require, module, __filename, __dirname) {
    %@
  }
); })();
"""), script)
        let
        _ = context
            .evaluateScript(
                decorated,
                withSourceURL: url
            )
            .call(withArguments: [
                exports,
                require,
                module,
                url.path,
                url.deletingLastPathComponent().path
                ]
        )
    }
    func
        log(
        _ string :String
        ) {
        guard let data = (string + "\n").data(using: .utf8) else { return }
        self.standardOutput.write(data)
    }

    func
        __lookupPaths(
        for identifier :String,
        under directory :String
        ) -> [String] {
        var
        result = [] as [String]
        let
        paths = self.paths.map { $0.path } + [directory]
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
        log(
        _ string :String
    )
}

extension
    JSContext
{
    func
        setup(
        with dependency :CoreJS.Dependency? = nil
        ) throws {
        let
        context = self
        context.name = "CoreJS"
        if let handle = dependency?.exceptionHandler {
            context.exceptionHandler = { handle( $0, $1?.error()) }
        }
        context.globalObject.setValue(
            context.globalObject,
            forProperty: "global"
        )

        let
        fileManager = dependency?.fileManager ?? FileManager.default,
        standardOutput = dependency?.standardOutput ?? FileHandle.standardOutput,
        moduleURL = dependency?.moduleURL ??
            Bundle.main
                .bundleURL
                .appendingPathComponent("corejs")
                .appendingPathExtension("bundle"),
        globalModules = dependency?.globalModules ?? [:],
        paths = dependency?.nodePathURLs ?? Set(),
        native = Native(
            context: context,
            fileManager: fileManager,
            standardOutput: standardOutput,
            globalModules: globalModules,
            paths: paths
        )

        let
        mainScriptURL = moduleURL
            .appendingPathComponent("index")
            .appendingPathExtension("js")
        guard let
            data = fileManager.contents(atPath: mainScriptURL.path)
            else { throw FileError.coreModuleNotFound }
        let
        script = String(data: data, encoding: .utf8)
        
        context.evaluateScript("""
var module = { exports: {} };
var exports = module.exports;
""")
        context.evaluateScript(
            script,
            withSourceURL: mainScriptURL
        )
        context
            .globalObject
            .forProperty("exports")
            .forProperty("setup")
            .call(withArguments: [native])
        context.evaluateScript("""
delete exports;
delete module;
""")
    }
    func
        require(
        _ identifier :String
        ) -> JSValue! {
        return self
            .globalObject
            .forProperty("require")
            .call(withArguments: [identifier])
    }
}

extension
    JSValue
{
    func
        error() -> Error? {
        let
        jsValue = self
        guard
            let
            name = jsValue.forProperty("name").toString(),
            let
            message = jsValue.forProperty("message").toString(),
            let
            stack = jsValue.forProperty("stack").toString()
            else { return nil }
        return NSError(
            domain: name,
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey: message,
                NSLocalizedFailureReasonErrorKey: stack,
            ]
        )
    }
}
enum
    FileError : Error
{
    case coreModuleNotFound
}

