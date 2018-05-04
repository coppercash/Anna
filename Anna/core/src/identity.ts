import * as Match from './match';
import * as Markup from './markup';

export interface Loading
{
  matchTasks(namespace :string) :Loading.Tasks
}
export namespace Loading
{
  export type Tasks = Match.Stage;
}

export class Tree
{
  root :Node = null;
  identities :{ [id: number]: { [id: string]: Node; }; } = {};
  loader :Loading;

  constructor(
    loader :Loading
  ) {
    this.loader = loader;
  }

  nodeID(ownerID :number, name :string) :NodeID
  {
    return new NodeID(ownerID, name);
  }

  registerNode(
    nodeID :NodeID, 
    parentID? :NodeID
  ) {
    let
    tree = this;
    let
    registered = tree.node(nodeID);
    if (registered) {
      throw new Error(`${ nodeID } has already been registered.`);
    }

    var
    parent :Node = null;
    if (parentID) {
      parent = tree.node(parentID);
      if (!parent) {
        throw new Error(`Cannot find parent ${ parentID }.`);
      }
    }
    else {
      if (tree.root) {
        throw new Error(`To be registerd, ${ nodeID } must have a parent.`);
      }
    }

    let
    node = parent ? parent.fork(nodeID) : new Node(nodeID, null, tree.rootMatching());

    let
    byName = tree.identities[nodeID.ownerID];
    if (!byName) {
      byName = {};
      tree.identities[nodeID.ownerID] = byName;
    }
    byName[nodeID.name] = node;

    if (!(parent)) {
      tree.root = node;
    }
  }

  deregisterNode(
    nodeID :NodeID
  ) {
    let
    tree = this;
    let
    identities = this.identities;
    let
    node = this.node(nodeID);
    if (!(
      node
    )) {
      throw new Error(`Cannot deregister unregistered node ${ nodeID }`);
    }
    node.children.forEach(x => this.deregisterNode(x.id));
    let
    owners = identities[nodeID.ownerID];
    delete owners[nodeID.name];
    if (!(
      Object.keys(owners).length > 0
    )) {
      delete identities[nodeID.ownerID];
    }

    node.delete();
    if (node === tree.root) {
      tree.root = null;
    }
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

  rootMatching() : Match.Stage {
    return this.loader.matchTasks('');
  }

  snapshot() : string {
    return this.root.snapshot();
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
    return `Node(${ this.name }\\${ this.ownerID })`;
  }
}

export class Node implements Markup.Markable
{
  private static
  className = 'ana-node';

  id :NodeID;
  properties :Markup.Markable.Properties = { class: Node.className };
  subordinates :Markup.Markable[] = [];
  events :Event[] = [];
  parent :Node;
  children :Set<Node> = new Set<Node>();
  matching :Match.Stage;

  constructor(
    id :NodeID,
    parent :Node,
    matching :Match.Stage
  ) {
    this.id = id;
    this.parent = parent;
    this.matching = matching;
  }

  fork(
    nodeID :NodeID
  ) :Node {
    let
    node = this, children = this.children, subordinates = this.subordinates;
    let 
    matching = node.stageMatching(nodeID.name);
    let
    child = new Node(nodeID, node, matching);
    children.add(child);
    subordinates.push(child);
    
    return child;
  }

  delete()
  {
    let
    parent = this.parent, deleting = this;
    if (!(
      parent
    )) { return; }
    parent.children.delete(this);
  }

  recordEvent(
    name :string,
    properties :Event.Properties
  ) {
    let
    events = this.events, subordinates = this.subordinates;
    let
    event = new Event(name, properties);
    events.push(event);
    subordinates.push(event);
  }

  tasksMatchingEvent(
    name :string
  ) :Match.Task[]
  {
    return this.matching.tasksMatching(name);
  }

  stageMatching(
    name :string
  ) :Match.Stage {
    return this.matching.matching(name);
  }

  markup(
    indent :string = '',
    alone :boolean = false
  ) :string {
    let
    id = this.id, properties = this.properties, matching = this.matching, subordinates = this.subordinates;
    if (alone) {
      return Markup.markup(id.name, properties, [], indent);
    }
    let
    children = new Array<Markup.Markable>();
    children.push(matching);
    for (let
      sub of subordinates
    ) {
      if (sub instanceof Event) {
        let
        event = sub as Event;
        children.push(event.markable(matching));
      }
      else {
        children.push(sub);
      }
    }
    return Markup.markup(id.name, properties, children, indent);
  }

  upMarkedAncestors() :[string, string]
  {
    let
    node = this, parent = this.parent;
    if (!(
      parent
    )) {
      return [node.markup('', true), ''];
    }
    let
    ancestors = parent.upMarkedAncestors();
    let
    indent = `${ ancestors[1] }  `;
    let
    markup = ancestors[0] + '\n' + node.markup(indent, true);
    return [markup, indent];
  }

  snapshot() :string
  {
    let
    parent = this.parent;
    if (!(
      parent
    )) {
      return this.markup();
    }
    let
    ancestors = parent.upMarkedAncestors();
    return ancestors[0] + '\n' + this.markup(`${ ancestors[1]}  `);
  }
}

export class Event implements Markup.Markable
{
  private static
  className = 'ana-event';

  name :string;
  properties :Event.Properties;
  constructor(
    name :string,
    properties :Event.Properties
  ) {
    this.name = name;
    var
    buffer = { ...properties };
    buffer.class = Event.className;
    this.properties = buffer;
  }

  markup(
    indent :string = '',
  ) :string {
    return Markup.markup(this.name, this.properties, [], indent, true);
  }

  markable(
    matching :Match.Stage
  ) :Markup.Markable {
    let
    tasks = new Markup.ArrayMarker('tasks', matching.tasksMatching(this.name));
    return new Markup.ObjectMarker(this.name, this.properties, [tasks]);
  }
}
export namespace Event
{
  export type Properties = Markup.Markable.Properties;
}

