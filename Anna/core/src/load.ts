import * as Match from './match'
import * as Identity from './identity'

declare let require : (name :string) => any;
export namespace RequiringLoader 
{
  export type Inject = (key :string, value :any) => void;
  export type Match = (
      path :string | string[], 
      map :Match.Task.Map
    ) => void 
}
export class RequiringLoader implements Identity.Loading
{
  taskDirectoryPath :string;
  inject :RequiringLoader.Inject;
  constructor(
    taskDirectoryPath :string,
    inject :RequiringLoader.Inject
  ) {
    this.taskDirectoryPath = taskDirectoryPath;
    this.inject = inject;
  }

  matchTasks(
    namespace :string
  ) :Identity.Loading.Tasks {
    let
    taskDirectoryPath = this.taskDirectoryPath;
    let
    path = `${ taskDirectoryPath }/index.js`;
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
    this.preRequire(match);
    require(path);
    this.postRequire();
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
  export type Load = (match :Match) => void;
}
export class InPlaceLoader implements Identity.Loading
{
  load :InPlaceLoader.Load
  constructor(
    load :InPlaceLoader.Load
  ) {
    this.load = load;
  }
  matchTasks(
    namespace :string
  ) :Identity.Loading.Tasks {
    let
    load = this.load;
    let
    builder = new Match.Builder();
    let
    match = (path :string, map :Match.Task.Map) : void => {
      builder.addMatchTask(path, map);
    }
    load(match);

    return builder.build();
  }
}

