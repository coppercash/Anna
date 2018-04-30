import * as Identity from './identity';
import * as Track from './track';
import * as Load from './load';

export class Anna
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
  withCallbacks(
    receive :Track.InPlaceTracker.Receive,
    inject :Load.RequiringLoader.Inject
  ) : Anna {
    let
    manager = new Anna(new Load.RequiringLoader(inject));
    manager.tracker = new Track.InPlaceTracker(receive);
    return manager
  }

  rootNodeID(ownerID :number) :Identity.NodeID 
  {
    return this.identities.rootNodeID(ownerID);
  }

  nodeID(ownerID :number, name :string) :Identity.NodeID
  {
    return this.identities.nodeID(ownerID, name);
  }

  registerNode(
    id :Identity.NodeID, 
    parentID? :Identity.NodeID
  ) {
    this.identities.registerNode(id, parentID);
  }

  unregisterNode(
    id :Identity.NodeID
  ) {
    this.identities.unregisterNode(id);
  }
  
  recordEvent(
    name :string,
    properties :Identity.Event.Properties,
    nodeID :Identity.NodeID
  )
  {
    let
    identities = this.identities, tracker = this.tracker;
    let
    node = identities.node(nodeID);
    node.recordEvent(name, properties);
    let
    tasks = node.tasksMatchingEvent(name);
    if (!(
      tasks && tasks.length > 0
    )) {
      throw new Error(`${ nodeID } is not registered with any events`);
    }
    for ( let 
      task of tasks
    ) {
      let
      result = task.resultByMapping(node);
      if (tracker) {
        tracker.receiveResult(result);
      }
    }
  }
}

