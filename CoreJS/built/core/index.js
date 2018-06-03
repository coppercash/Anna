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
        var resolve = function (identifier) {
            return native.resolvedPath(identifier, (parent ? parent.id : null), (main ? main.id : null));
        };
        var path = resolve(id);
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
            var require = function (identifier) {
                return Module.load(identifier, module, (main || module), native, cache);
            };
            require.cache = cache;
            require.resolve = resolve;
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
    Module.cache = {};
    return Module;
}());
var Core = (function () {
    function Core(native) {
        this.native = native;
        this.makeConsole();
    }
    Core.prototype.makeConsole = function () {
        var native = this.native;
        var console = { log: function (message) { native.log(message); } };
        native.injectGlobal('console', console);
    };
    Core.prototype.require = function (main) {
        return Module.load(main, null, null, this.native, Module.cache);
    };
    return Core;
}());
function run(index, native) {
    var core = new Core(native);
    return core.require(index);
}
exports.run = run;
//# sourceMappingURL=index.js.map