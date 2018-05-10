import * as Identity from './identity';
import * as Track from './track';
import * as Load from './load';

export class Manager
{
  identities :Identity.Tree;
  loader :Identity.Loading;
  tracker :Track.Tracking = null;

  constructor(loader :Identity.Loading) 
  {
    this.identities = new Identity.Tree(loader);
    this.loader = loader;
  }

  static
  execute(
    taskDirectoryPath :string,
    inject :Load.RequiringLoader.Inject,
    receive :Track.InPlaceTracker.Receive
  ) : Manager {
    let
    manager = new Manager(new Load.RequiringLoader(taskDirectoryPath, inject));
    manager.tracker = new Track.InPlaceTracker(receive);
    return manager
  }

  nodeID(
    ownerIDs :number[] | number
  ) : Identity.NodeID {
    if (ownerIDs instanceof Array) {
      return this.identities.nodeID(ownerIDs)
    }
    else if (typeof ownerIDs == 'number') {
      return this.identities.nodeID([ownerIDs as number]);
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
    if (!(
      id instanceof Identity.NodeID 
    )) {
      id = this.nodeID(id);
    }
    if (!(
      parentID instanceof Identity.NodeID 
    )) {
      parentID = this.nodeID(parentID);
    }
    this.identities.registerNode(id, name, parentID);
  }

  deregisterNodes(
    id :Identity.NodeID | number[] | number
  ) {
    if (!(
      id instanceof Identity.NodeID 
    )) {
      id = this.nodeID(id);
    }
    this.identities.deregisterNodes(id);
  }

  recordEvent(
    name :string,
    properties :Identity.Event.Properties,
    nodeID :Identity.NodeID | number[] | number
  )
  {
    let
    identities = this.identities, tracker = this.tracker;
    if (!(
      nodeID instanceof Identity.NodeID 
    )) {
      nodeID = this.nodeID(nodeID);
    }
    let
    node = identities.node(nodeID);
    node.recordEvent(name, properties);
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

