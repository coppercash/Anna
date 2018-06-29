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
        nodePathURLs :Set<URL>? = nil
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
    @objc(fileExistsAtPath:isDirectory:)
    func
        fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool
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
    module :Module,
    fileManager :FileManaging,
    standardOutput :FileHandling
    init(
        context :JSContext,
        fileManager :FileManaging,
        standardOutput :FileHandling,
        paths :Set<URL>
        ) {
        self.module = Module(
            fileManager: fileManager,
            core: [],
            global: paths
        )
        self.context = context
        self.fileManager = fileManager
        self.standardOutput = standardOutput
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
        _ parent :JSValue,
        _ main :JSValue
        ) -> String! {
        guard let id = id.string() else { return nil }
        let
        module = (parent.url() ?? main.url())?.deletingLastPathComponent()
        return try? self.module.resolve(
            x: id, from:
            module
        )
    }
    func
        load(
        _ jspath :JSValue,
        _ exports :JSValue,
        _ require :JSValue,
        _ module :JSValue
        ) {
        guard
            let
            context = self.context,
            let
            url = jspath.url()
            else { return }
        self.module.loadScript(
            at: url,
            to: context,
            exports: exports,
            require: require,
            module: module
        )
    }
    func
        log(
        _ string :String
        ) {
        guard let data = (string + "\n").data(using: .utf8) else { return }
        self.standardOutput.write(data)
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
        paths = dependency?.nodePathURLs ?? Set(),
        native = Native(
            context: context,
            fileManager: fileManager,
            standardOutput: standardOutput,
            paths: paths
        )
        
        let
        mainScriptPath = try native.module.resolve(
            x: moduleURL.path,
            from: nil
        ),
        require = context.evaluateScript("""
(function() { return function () {}; })();
""") as JSValue,
        module = context.evaluateScript("""
(function() { return { exports: {} }; })();
""") as JSValue,
        exports = module.forProperty("exports") as JSValue
        native.module.loadScript(
            at: URL(fileURLWithPath: mainScriptPath),
            to: context,
            exports: exports,
            require: require,
            module: module
        )
        exports
            .forProperty("setup")
            .call(withArguments: [native])
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
    func
        string() -> String? {
        let
        value = self
        guard value.isString else { return nil }
        return value.toString()
    }
    func
        url() -> URL? {
        let
        value = self
        guard value.isString else { return nil }
        return URL(fileURLWithPath: value.toString())
    }
}
