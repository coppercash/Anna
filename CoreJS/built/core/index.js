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
            var require_1 = Module.makeRequire(module, main, native, cache);
            native.load(path, module.exports, require_1, module);
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
function setup(native) {
    makeRequire(native);
    makeConsole(native);
}
exports.setup = setup;
function makeRequire(native) {
    global.require = Module.makeRequire(null, null, native, Module.cache);
}
function makeConsole(native) {
    global.console = {
        log: function (message) {
            native.log(message);
        }
    };
}
//# sourceMappingURL=index.js.map