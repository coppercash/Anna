import * as Identity from './identity';
import * as Match from './match';

export interface Tracking 
{
  receiveResult(result :any) :void;
}

export interface Loading 
{
  matchTasks(
    namespace :string, 
    manager? :Anna
  ) :void;
}

export class Anna implements Identity.Loading
{
  identities :Identity.Tree;
  loader :Loading;
  tracker :Tracking = null;

  constructor(loader :Loading) 
  {
    this.identities = new Identity.Tree(this);
    this.loader = loader;
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

  matchTasks(
    namespace :string
  ) :Identity.Loading.Tasks {
    let
    builder = new Match.Builder();
    this.task.match = (path :string, map :Match.Task.Map) => {
      builder.addMatchTask(path, map);
    };
    this.loader.matchTasks(namespace, this);
    return builder.build();
  }

  task :TaskBuilders = new TaskBuilders();
}

type Map = Match.Task.Map;
export class TaskBuilders
{
  match : (path :string, map :Map) => void;
  constructor() 
  {
    this.match = null;
  }
}

