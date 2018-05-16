import * as Identity from './identity';
import * as Track from './track';
import * as Load from './load';

namespace Manager {
  export type Config = { [key :string]: any };
}
export class Manager
{
  identities :Identity.Tree;
  loader :Identity.Loading;
  tracker :Track.Tracking = null;
  config :Manager.Config;

  constructor(
    loader :Identity.Loading, 
    config? :Manager.Config
  ) {
    this.identities = new Identity.Tree();
    this.loader = loader;
    this.config = config || {};
  }

  static
  execute(
    taskModulePath :string,
    inject :Load.RequiringLoader.Inject,
    require :Load.RequiringLoader.Require,
    receive :Track.InPlaceTracker.Receive,
    config? :Manager.Config
  ) : Manager {
    let
    _require = config.debug ? 
      (identifier :string) => {
        delete (require as any).cache[(require as any).resolve(identifier)];
        return require(identifier);
      } : require;
    let
    manager = new Manager(
      new Load.RequiringLoader(
        taskModulePath, 
        inject,
        _require
      ),
      config
    );
    manager.tracker = new Track.InPlaceTracker(receive);
    return manager
  }

  nodeID(
    id :Identity.NodeID | number[] | number, 
  ) : Identity.NodeID {
    if (id instanceof Identity.NodeID) {
      return id;
    }
    else if (id instanceof Array) {
      return this.identities.nodeID(id);
    }
    else if (typeof id == 'number') {
      return this.identities.nodeID([id]);
    }
    else {
      return null;
    }
  }

  registerNode(
    id :Identity.NodeID | number[] | number, 
    name :string,
    parentID? :Identity.NodeID | number[] | number
  ) {
    this.identities.registerNode(
      this.nodeID(id), 
      name, 
      this.nodeID(parentID)
    );
  }

  deregisterNodes(
    id :Identity.NodeID | number[] | number
  ) {
    this.identities.deregisterNodes(
      this.nodeID(id)
    );
  }

  recordEvent(
    name :string,
    properties :Identity.Event.Properties,
    nodeID :Identity.NodeID | number[] | number
  )
  {
    let
    identities = this.identities, 
      tracker = this.tracker, 
      config = this.config, 
      loader = this.loader;
    nodeID = this.nodeID(nodeID);
    let
    node = identities.node(nodeID);
    if (!(node)) { 
      throw RecordingError.eventOnUnregistered(
        name,
        properties,
        nodeID
      )
    }
    node.recordEvent(name, properties);

    let
    namespace = null;
    let
    every = identities.root.matching;
    let
    added = every.isEmpty ? null : every;
    if (!(added)) {
      let
      tasks = loader.matchTasks(namespace);
      identities.addMatchTasks(tasks);
    }
    else if (config.debug) {
      identities.subtractMatchTasks(added);
      let
      tasks = loader.matchTasks(namespace);
      identities.addMatchTasks(tasks);
    }

    let
    tasks = node.tasksMatchingEvent(name);
    for ( let 
      task of tasks
    ) {
      let
      result = task.resultByMapping(node);
      if (tracker && (result !== undefined)) {
        tracker.receiveResult(result);
      }
    }
  }

  logSnapshot() {
    console.log(this.identities.snapshot());
  }
}

class RecordingError {
  static
  eventOnUnregistered(
    name :string,
    properties :Identity.Event.Properties,
    nodeID :Identity.NodeID
  ) : Error {
    let
    keyValue :string;
    if (name == 'ana-value-updated') {
      keyValue = `(${ properties['key-path'] }: ${ properties['value'] })`;
    }
    else {
      keyValue = '';
    }
    return Error(`Cannot record event '${ name }${ keyValue }' on unregistered node '${ nodeID }'.`);
  }
}

