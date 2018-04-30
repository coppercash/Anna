import * as Match from './match'
import * as Identity from './identity'

declare let require : (name :string) => any;
export namespace RequiringLoader 
{
  export type Inject = (key :string, value :any) => void;
}
export class RequiringLoader implements Identity.Loading
{
  inject :RequiringLoader.Inject;
  constructor(
    inject :RequiringLoader.Inject
  ) {
    this.inject = inject;
  }

  matchTasks(
    namespace :string
  ) :Identity.Loading.Tasks {
    let
    path = `tasks/index.js`;
    let
    builder = new Match.Builder();
    this.preRequire(builder);
    require(path);
    this.postRequire();
    return builder.build();
  }

  preRequire(builder :Match.Builder) {
    let 
    inject = this.inject;
    let
    match = (path :string, map :Match.Task.Map) : void => {
      builder.addMatchTask(path, map);
    }
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

