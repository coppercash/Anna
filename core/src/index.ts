import * as Identity from './identity';
import * as Track from './track';
import * as Load from './load';
import * as Task from './task';
import * as C from './compatibility';

namespace Manager {
  export type Config = { [key :string]: any };
  export interface Dependency {
    taskModulePath :string;
    inject :Load.RequiringLoader.Inject;
    require :Load.RequiringLoader.Require;
    receive :Track.InPlaceTracker.Receive;
    config? :Manager.Config
  }
}
export class Manager
{
  identities :Identity.Tree = new Identity.Tree();
  loadedTasks :Task.Tree = new Task.Tree();
  loader :Task.Loading;
  tracker :Track.Tracking = null;
  config :Manager.Config = {};

  constructor(
    loader :Task.Loading, 
    config? :Manager.Config
  ) {
    this.loader = loader;
    if (config) {
      this.config = config;
    }
  }

  static
  run(
    dependency :Manager.Dependency
  ) : Manager {
    let
    taskModulePath = dependency.taskModulePath,
      inject = dependency.inject, 
      require = dependency.require,
      receive = dependency.receive, 
      config = dependency.config;

    let
    _require = (config && config.debug) ? 
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
    nodeID :Identity.NodeID | number[] | number,
    namespace? :string
  )
  {
    let
    identities = this.identities, 
      tracker = this.tracker;

    // Record event
    //
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

    // Load Task
    //
    this.loadTasks(['index'], ['.']);
    if (namespace) {
      let
      namePath = this.namePath(namespace);
      this.loadTasks(namePath);
    }

    // Match Task
    //
    let
    tasks = node.tasksMatchingEvent(name);
    for (let 
      task of tasks
    ) {
      let
      result = task.resultByMapping(node);
      if (tracker && (result !== undefined)) {
        tracker.receiveResult(result);
      }
    }
  }

  namePath(
    namespace :string
  ) : string[] {
    if (
      C.string_starts_with(namespace, '.') ||
      C.string_ends_with(namespace, '.')
    ) {
      throw new Error(`Cannot load tasks with invalid namespace '${ namespace }'.`);
    }

    let
    namePath = namespace.split('.');
    return namePath;
  }

  loadTasks(
    namePath :string[],
    cachePath? :string[]
  ) {
    let
    identities = this.identities, 
      loadedTasks = this.loadedTasks,
      config = this.config, 
      loader = this.loader;

    if (!(cachePath)) {
      cachePath = namePath;
    }

    let
    loaded = loadedTasks.retrieve(cachePath);
    if (!(loaded)) {
      let
      tasks = loader.matchTasks(namePath);
      identities.addMatchTasks(tasks);
      loadedTasks.insert(cachePath).value = tasks;
    }
    else if (config.debug) {
      identities.subtractMatchTasks(loaded.value);
      let
      tasks = loader.matchTasks(namePath);
      identities.addMatchTasks(tasks);
      loaded.value = tasks;
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
    if (name == 'ana-updated') {
      keyValue = `(${ properties['key-path'] }: ${ properties['value'] })`;
    }
    else {
      keyValue = '';
    }
    return Error(`Cannot record event '${ name }${ keyValue }' on unregistered node '${ nodeID }'.`);
  }
}

