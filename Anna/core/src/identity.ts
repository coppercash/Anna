
export class Tree
{
  identities :{ [id: number]: { [id: string]: Node; }; } = {};

  rootNodeID(ownerID :number) :NodeID
  {
    return this.nodeID(ownerID, '__root__');
  }

  nodeID(ownerID :number, name :string) :NodeID
  {
    return new NodeID(ownerID, name);
  }

  registerNode(nodeID :NodeID, parentID? :NodeID)
  {
    let
    registered = this.node(nodeID);
    if (registered) {
      throw Error(`${ nodeID } has already been registered.`);
    }

    var
    parent :Node = null;
    if (parentID) {
      parent = this.node(parentID);
      if (!parent) {
        throw Error(`Cannot find parent ${ parentID }.`);
      }
    }
    else {
      if (nodeID.name != '__root__') {
        throw Error(`To be registerd, ${ nodeID } must have a parent.`);
      }
    }

    let
    node = new Node(nodeID.name, parent);
    //    let
    //    matching = loader.allNodesByLoading()
    //    node.addMatchingNodes(matching)

    var
    byName = this.identities[nodeID.ownerID];
    if (!byName) {
      byName = {};
      this.identities[nodeID.ownerID] = byName;
    }
    byName[nodeID.name] = node;
  }

  node(nodeID :NodeID) :Node
  {
    let
    byName = this.identities[nodeID.ownerID];
    if (!byName) {
      return null;
    }
    let
    node = byName[nodeID.name];
    if (!node) {
      return null;
    }
    return node;
  }
}

export class NodeID
{
  ownerID :number;
  name :string;

  constructor(
    ownerID :number,
    name :string
  ) {
    this.ownerID = ownerID;
    this.name = name;
  }

  toString = () : string => {
    return `Node(${this.name}\\this.ownerID)`;
  }
}

export class Node 
{
  name :string;
  parent :Node;
  events :Event[] = [];

  constructor(
    name :string,
    parent :Node
  ) {
    this.name = name;
    this.parent = parent;
  }

  recordEvent(
    properties :Event.Properties
  ) {
    let
    event = new Event(properties)
    this.events.push(event)
  }

  matchingEventTasks() :Task[]
  {
    return [new Task()];
  }
}

export class Event
{
  properties :Event.Properties
  constructor(
    properties :Event.Properties
  ) {
    this.properties = properties
  }
}

export namespace Event
{
  export type Properties = { [name: string]: any; };
}

export class Task
{
  resultByMapping(node :Node) :any
  {
    return node.events[0].properties;
  }
}

