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
        resolvedPath(
        _ identifier :JSValue,
        _ source :JSValue
        ) -> String? {
        guard let
            context = context
            else { return nil }
        let
        workDir = self.workDirectoryURL,
        fileManager = self.fileManager
        let
        raise = {
            context.exception = JSValue(
                newErrorFromMessage:
                "Cannot resolve path of '\(identifier.toString()!)' for '\(source.toString()!)'.",
                in: context
            )
        }
        guard
            identifier.isString,
            var
            sub = identifier.toString(),
            (source.isString || source.isNull),
            let
            parent = source.toString()
            else {
                raise()
                return nil
        }
        
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
        raise()
        return nil
    }
    
    func
        load(
        _ identifier :JSValue,
        _ source :JSValue
        ) -> JSValue? {
        guard let
            context = context
            else { return nil }

        guard let
            path = self.resolvedPath(
                identifier,
                source
            )
            else { return nil }
        guard
            let
            data = self.fileManager.contents(atPath: path),
            let
            script = String(data: data, encoding: .utf8)
            else
        {
            context.exception = JSValue(
                newErrorFromMessage:
                "Cannot read file at path \(path).",
                in: context
            )
            return nil
        }
        let
        decorated =
        """
        CoreJS._local_require('\(path)', function (exports, require, module) {
        \(script)
        });
        """
        
        return self.context?.evaluateScript(
            decorated,
            withSourceURL: URL(fileURLWithPath: path)
        )
    }
}
@objc protocol
    NativeJSExport : JSExport
{
    func
        load(
        _ identifier :JSValue,
        _ source :JSValue
        ) -> JSValue?
}

extension
    CoreJS.Context
{
    class func
        run(
        in workDirectoryURL :URL,
        with fileManager :FileManaging,
        exceptionHandler : @escaping ((JSContext?, JSValue?) -> Void)
        ) -> CoreJS.Context? {
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
        script =
        """
function CoreJS(context, native) {
  function CoreJS(native) {
    const cache = {};
    this._local_require = function (filename, evaluate) {

      const cached = cache[filename];
      if (cached) { return cached.exports; }

      const module = {
        filename: filename
      };
      cache[filename] = module;

      var threw = true;
      try {
        module.exports = {};
        const require = function(identifier) {
          native.load(identifier, filename);
        }
        evaluate(module.exports, require, module);
        threw = false;
      }
      finally {
        if (threw) {
          delete cache[filename];
        }
      }
      return module.exports;
    };

    const require = function(identifier) {
      return native.load(identifier, null);
    };
    require.cache = cache;

    this._require = require;
    this._cache = cache;
    this._native = native;
    context.CoreJS = this;
  }
  this.CoreJS = new CoreJS(native);
};
CoreJS;
"""
        let
        _ = context
            .evaluateScript(script)
            .call(withArguments: [
                context.globalObject,
                native
                ]
        )
        return context
    }
}
