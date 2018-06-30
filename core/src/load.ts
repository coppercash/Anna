import * as Match from './match'
import * as Task from './task'

export namespace RequiringLoader 
{
  export type Config = { [key :string] : any };
  export type Match = (
      path :string | string[], 
      map :Match.Task.Map
    ) => void 
}
export class RequiringLoader implements Task.Loading
{
  taskModulePath :string;
  global :{ [key :string] : any };
  config :RequiringLoader.Config
  constructor(
    taskModulePath :string,
    gloabl :{ [key :string] : any },
    config :RequiringLoader.Config
  ) {
    this.taskModulePath = taskModulePath;
    this.global = global;
    this.config = config;
  }
  matchTasks(
    namePath :string[]
  ) :Task.Loading.Tasks {
    let
    taskModulePath = this.taskModulePath;
    let
    path = `${ taskModulePath }/${ namePath.join('/') }.js`;
    let
    builder = new Match.Builder();
    let
    match :RequiringLoader.Match = (path, map) => {
      let
      paths :string[]
      if (path instanceof Array) {
        paths = path
      }
      else {
        paths = [path]
      }
      for (let path of paths) {
        builder.addMatchTask(path, map);
      }
    }
    try {
      this.preRequire(match);
      this.require(path);
    }
    finally {
      this.postRequire();
    }
    return builder.build();
  }
  preRequire(
    match :RequiringLoader.Match
  ) {
    this.inject('match', match);
  }
  postRequire() {
    this.inject('match', undefined);
  }
  inject(
    key :string, 
    value :RequiringLoader.Match
  ) {
    let
    global = this.global;
    if (value === undefined) {
      delete global[key];
    }
    else {
      global[key] = value;
    }
  }
  require(
    name :string
  ) : any {
    let
    require = this.global.require as any,
      config = this.config,
      debug = config ? config['debug'] : undefined;
    if (debug === true) {
      delete require.cache[require.resolve(name)];
    }
    var
    exports = undefined;
    try {
      exports = require(name);
    }
    catch {
      exports = undefined;
    }
    return exports;
  }
}

namespace InPlaceLoader
{
  export type Match = (path :string, map :Match.Task.Map) => void;
  export type Load = (match :Match, namePath? :string[]) => void;
}
export class InPlaceLoader implements Task.Loading
{
  load :InPlaceLoader.Load
  constructor(
    load :InPlaceLoader.Load
  ) {
    this.load = load;
  }
  matchTasks(
    namePath :string[]
  ) :Task.Loading.Tasks {
    let
    load = this.load;
    let
    builder = new Match.Builder();
    let
    match = (path :string, map :Match.Task.Map) : void => {
      builder.addMatchTask(path, map);
    }
    load(match, namePath);

    return builder.build();
  }
}

