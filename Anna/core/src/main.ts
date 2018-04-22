import * as Identity from './identity';

export interface Tracking {
  receiveResult(result :any);
}

export class Anna
{
  identities = new Identity.Tree();
  tracker :Tracking = null;

  constructor() 
  {
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
    this.identities.registerNode(id, parentID)
  }

  //    registerNode(
  //        locator :Path.NodeLocator, 
  //        parentLocator :Path.NodeLocator
  //    )
  //    {
  //        let
  //        registered = identities.nodeByLocator(locator)
  //        if (registered) {
  //            return
  //        }
  //        let 
  //        parent = identities.nodeByLocator(parentLocator)
  //        if (!(parent)) {
  //            throw Error('Can not find registered parent node for node named ' + locator.name)
  //        }
  //        let
  //        node = Path.Node(
  //            name: locator.name, 
  //            parent: parent
  //        )
  //        parent.setChildByName(node.name, node)
  //        let
  //        matchings = parent.matchingNodesWithName(node.name)
  //        node.addMatchingNodes(matchings)
  //        identities.addNodeByLocator(locator, node)
  //    }
  //
  //    unregisterNode(locator :Path.NodeLocator)
  //    {
  //        identities.removeNodeByLocator(locator)
  //    }
  //
  recordEvent(
    properties :Identity.Event.Properties,
    nodeID :Identity.NodeID
  )
  {
    let
    node = this.identities.node(nodeID);
    node.recordEvent(properties);
    let
    tasks = node.matchingEventTasks()
    if (!(tasks && tasks.length > 0)) {
      throw Error('Node named ' + node.name + 'is not registered with any events')
    }
    for (let task of tasks) {
      let
      result = task.resultByMapping(node)
      if (this.tracker) {
        this.tracker.receiveResult(result)
      }
    }
  }
}

