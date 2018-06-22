"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var Module = (function () {
    function Module(id, parent, main) {
        this.id = id;
        this.parent = parent;
        this.main = main;
    }
    Module.load = function (id, parent, main, native, cache) {
        if (native.contains(id)) {
            return native.moduleExports(id);
        }
        var path = native.resolvedPath(id, (parent ? parent.id : null), (main ? main.id : null));
        if (!(path)) {
            throw new Error("Cannot resolve path for '" + id + "' required by '" + (parent ? parent.id : 'main') + "'.");
        }
        var cached = cache[path];
        if (cached) {
            return cached.exports;
        }
        var module = new Module(path, parent, main);
        cache[path] = module;
        var threw = true;
        try {
            module.exports = {};
            var require = Module.makeRequire(module, main, native, cache);
            native.load(path, module.exports, require, module);
            threw = false;
        }
        finally {
            if (threw) {
                delete cache[path];
            }
        }
        return module.exports;
    };
    Module.makeRequire = function (parent, main, native, cache) {
        var require = function (identifier) {
            return Module.load(identifier, parent, (main || parent), native, cache);
        };
        require.cache = cache;
        require.resolve = function (identifier) {
            return native.resolvedPath(identifier, (parent ? parent.id : null), (main ? main.id : null));
        };
        return require;
    };
    Module.cache = {};
    return Module;
}());
var Core = (function () {
    function Core(native) {
        this.native = native;
        this.makeRequire();
        this.makeConsole();
    }
    Core.prototype.makeRequire = function () {
        var native = this.native, global = this.native.global;
        global.require = Module.makeRequire(null, null, this.native, Module.cache);
    };
    Core.prototype.makeConsole = function () {
        var native = this.native, global = this.native.global;
        global.console = {
            log: function (message) {
                native.log(message);
            }
        };
    };
    Core.prototype.require = function (main) {
        var require = this.native.global.require;
        return require(main);
    };
    return Core;
}());
function run(index, native) {
    var core = new Core(native);
    return core.require(index);
}
exports.run = run;
//# sourceMappingURL=index.js.map