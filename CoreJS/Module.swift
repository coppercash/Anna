//
//  Module.swift
//  Anna_iOS
//
//  Created by William on 2018/6/27.
//

import Foundation

class
Module
{
    let
    fileManager :FileManaging,
    core :Set<String>,
    global :Set<URL>
    
    init(
        fileManager :FileManaging,
        core :Set<String>,
        global :Set<URL>
        ) {
        self.fileManager = fileManager
        self.core = core
        self.global = global
    }
    func
        resolve(
        x :String,
        from module :URL?
        ) throws -> String {
        let
        core = self.core

        if core.contains(x) {
            return x
        }
        //
        // x is not a core module
        
        let
        isAbsolute = x.hasPrefix("/"),
        base :URL
        if isAbsolute {
            base = URL(fileURLWithPath: "/")
        }
        else {
            guard let module = module
                else { throw ResolveError.noBase }
            base = module
        }

        guard isAbsolute
            || x.hasPrefix("./")
            || x.hasPrefix("../")
            else {
                let
                resolved = try self.resolve(
                    nodeModule: x,
                    with: base.deletingLastPathComponent()
                    ).standardized.path
                return resolved
        }
        //
        // x is not a node module

        let
        absolute = base.appendingPathComponent(
            isAbsolute ? String(x.dropFirst()) : x
        )
        guard
            let
            resolved =
            (try? self.resolve(file: absolute))
                ?? (try? self.resolve(directory: absolute))
            else { throw ResolveError.notFound }
        
        return resolved.standardized.path
    }
    func
        resolve(
        file :URL
        ) throws -> URL {
        let
        fs = self.fileManager
        var
        isDirecotry = false as ObjCBool
        if fs.fileExists(
            atPath: file.path,
            isDirectory: &isDirecotry
            ) {
            if isDirecotry.boolValue == false {
                return file
            }
        }
        return try self.resolve(
            file: file,
            extending: ["js", "json", "node"]
        )
    }
    func
        resolve(
        file :URL,
        extending extensions:[String]
        ) throws -> URL {
        let
        fs = self.fileManager
        for ext in extensions {
            let
            extended = file.appendingPathExtension(ext)
            var
            isDirecotry = false as ObjCBool
            if fs.fileExists(
                atPath: extended.path,
                isDirectory: &isDirecotry
                ) {
                if isDirecotry.boolValue == false {
                    return extended
                }
            }
        }
        throw ResolveError.notFound
    }
    func
        resolve(
        directory :URL
        ) throws -> URL {
        return try self.resolveIndex(in: directory)
    }
    func
        resolveIndex(
        in directory :URL
        ) throws -> URL {
        return try self.resolve(
            file: directory.appendingPathComponent("index"),
            extending: ["js", "json", "node"]
        )
    }
    func
        resolve(
        nodeModule :String,
        with start :URL
        ) throws -> URL {
        let
        dirs = self.nodeModulesPaths(with: start)
        for dir in dirs {
            let
            absolute = dir.appendingPathComponent(nodeModule)
            if
                let
                resolved =
                (try? resolve(file: absolute))
                    ?? (try? resolve(directory: absolute))
            { return resolved }
        }
        throw ResolveError.notFound
    }
    func
        nodeModulesPaths(
        with start :URL
        ) -> [URL] {
        var
        paths = Array(self.global)
        func
            _backtrack(
            _ current :URL,
            _ paths : inout [URL]
            ) {
            let
            tail = current.lastPathComponent
            guard tail != "/"
                else { return }
            if tail != "node_modules" {
                paths.append(current.appendingPathComponent("node_modules"))
            }
            _backtrack(
                current.deletingLastPathComponent(),
                &paths
            )
        }
        _backtrack(start, &paths)
        return paths
    }
}

enum
    ResolveError : Error
{
    case noBase, notFound
}

extension String {
    func fileURL() -> URL {
       return URL(fileURLWithPath: self)
    }
}

