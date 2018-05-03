
interface Native
{
  contains(id :Module.ID) : boolean;
  moduleExports(id :Module.ID) :Module.Exports;
  resolvedPath(id :Module.ID, parent :Module.ID, main :Module.ID) : string;
  load(path :string, exports :Module.Exports, require :Module.Require, module :Module) :void;
  log(message :string) : void;
  injectGlobal(key :string, value :any) : void;
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
      throw new Error(`Cannot resolve path for ${ id } required by ${ parent ? parent.id : 'main' }.`);
    }

    let
    cached = cache[id];
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
      require = (identifier :Module.ID) => {
        return Module.load(
          identifier, 
          module, 
          (main || module), 
          native, 
          cache
        )
      }
      native.load(path, module.exports, require, module);
      threw = false;
    }
    finally {
      if (threw) {
        delete cache[path];
      }
    }

    return module.exports;
  }
}

class Core {
  native :Native;

  constructor(
    native :Native
  ) {
    this.native = native;
    this.makeConsole();
  }

  makeConsole() {
    let
    native = this.native;
    let
    console = { log: (message :string) => { native.log(message); } };
    native.injectGlobal('console', console);
  }

  require(
    main :string
  ) :Module.Exports {
    return Module.load(
      main,
      null,
      null,
      this.native,
      Module.cache
    ) 
  }
}

export function run(
  index :string, 
  native :Native
) {
  let
  core = new Core(native);
  return core.require(index);
}

