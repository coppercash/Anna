
interface Native
{
  contains(id :Module.ID) : boolean;
  moduleExports(id :Module.ID) :Module.Exports;
  resolvedPath(id :Module.ID, parent :Module.ID, main :Module.ID) : string;
  load(path :string, exports :Module.Exports, require :Module.Require, module :Module) :void;
  log(message :string) : void;
}

namespace Module
{
  export type Cache = { [name :string] : Module };
  export type Exports = any;
  export type ID = string;
  export type Require = (id :ID) => Exports;
}
class Module
{
  id :Module.ID;
  parent :Module;
  main :Module; 
  exports :Module.Exports;

  constructor(
    id :Module.ID,
    parent :Module,
    main :Module
  ) {
    this.id = id;
    this.parent = parent;
    this.main = main;
  }

  static
  cache :Module.Cache = {};
  static
  load(
    id :Module.ID, 
    parent :Module, 
    main :Module, 
    native :Native, 
    cache :Module.Cache
  ) {
    if (native.contains(id)) {
      return native.moduleExports(id);
    }

    let
    path = native.resolvedPath(
      id, 
      (parent ? parent.id : null), 
      (main ? main.id : null)
    );
    if (!(path)) {
      throw new Error(`Cannot resolve path for '${ id }' required by '${ parent ? parent.id : 'main' }'.`);
    }

    let
    cached = cache[path];
    if (cached) {
      return cached.exports;
    }

    let
    module = new Module(path, parent, main)
    cache[path] = module;

    var 
    threw = true;
    try {
      module.exports = {};
      let 
      require = Module.makeRequire(
          module, 
          main, 
          native, 
          cache
      );
      native.load(
        path, 
        module.exports, 
        require, 
        module
      );
      threw = false;
    }
    finally {
      if (threw) {
        delete cache[path];
      }
    }

    return module.exports;
  }
  static
  makeRequire(
    parent :Module, 
    main :Module, 
    native :Native, 
    cache :Module.Cache
  ) : Module.Require {
    let
    require = (identifier :Module.ID) => {
      return Module.load(
        identifier, 
        parent, 
        (main || parent), 
        native, 
        cache
      )
    }
    (require as any).cache = cache;
    (require as any).resolve = (identifier :Module.ID) => {
      return native.resolvedPath(
        identifier, 
        (parent ? parent.id : null), 
        (main ? main.id : null)
      );
    }
    return require;
  }
}

export function setup(
  native :Native
) {
  makeRequire(native);
  makeConsole(native);
}

function makeRequire(
  native :Native
) {
  (global as any).require = Module.makeRequire(
    null,
    null,
    native,
    Module.cache
  );
}

function makeConsole(
  native :Native
) {
  (global as any).console = { 
    log: (message :string) => { 
      native.log(message); 
    } 
  };
}
