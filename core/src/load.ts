import * as Match from './match'
import * as Task from './task'

export namespace RequiringLoader 
{
  export type Inject = (key :string, value :any) => void;
  export type Require = (name :string) => any;
  export type Match = (
      path :string | string[], 
      map :Match.Task.Map
    ) => void 
}
export class RequiringLoader implements Task.Loading
{
  taskModulePath :string;
  inject :RequiringLoader.Inject;
  require :RequiringLoader.Require;
  constructor(
    taskModulePath :string,
    inject :RequiringLoader.Inject,
    require :RequiringLoader.Require
  ) {
    this.taskModulePath = taskModulePath;
    this.inject = inject;
    this.require = require;
  }

  matchTasks(
    namePath :string[]
  ) :Task.Loading.Tasks {
    let
    taskModulePath = this.taskModulePath, require = this.require;
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
      require(path);
    }
    finally {
      this.postRequire();
    }
    return builder.build();
  }

  preRequire(match :RequiringLoader.Match) {
    let 
    inject = this.inject;
    inject('match', match);
  }

  postRequire() {
    this.inject('match', undefined);
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

