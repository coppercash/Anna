
class Module {

    static
    _resolveFilename(request, parent) {
        return parent + '/' + request
    }

    static
    _load(request, parent) {
        let
        filename = Module._resolveFilename(request, parent);

        let 
        cachedModule = Module._cache[filename];
        if (cachedModule) {
            return cachedModule.exports;
        }

        if (NativeModule.exists(filename)) {
            return NativeModule.require(filename);
        }

        let
        module = new Module(filename, parent);
        Module._cache[filename] = module;

        hadException = true;
        try {
            module.load(filename);
            hadException = false;
        } finally {
            if (hadException) {
                delete Module._cache[filename];
            }
        }

        return module.exports;
    }

    static 
    _compile() {
       global.require = Module._load
    }
}
