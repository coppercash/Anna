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
  identities :Identity = new Identity();
  loader :Loading;

  constructor(
    loader :Loading
  ) {
    this.loader = loader;
  }
  
  nodeID(
    ownerIDs :number[]
  ) : NodeID {
    return new NodeID(ownerIDs)
  }

  registerNode(
    nodeID :NodeID, 
    name :string,
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
    node = parent ? 
      parent.fork(nodeID, name) : 
      new Node(nodeID, name, null, tree.rootMatching());

    tree.setNode(node, nodeID);
    if (!(parent)) {
      tree.root = node;
    }
  }

  deregisterNodes(
    nodeID :NodeID
  ) {
    let
    tree = this;
    let
    identities = this.identities;
    let
    nodes = identities.nodes(nodeID.ownerIDs);
    if (!(
      nodes.length > 0
    )) {
      throw new Error(`No nodes were registered with ${ nodeID }`);
    }
    for (let
      node of nodes
    ) {
      node.children.forEach(x => this.deregisterNodes(x.id));

      node.delete();
      tree.removeNode(nodeID);
      if (node === tree.root) {
        tree.root = null;
      }
    }
  }

  node(
    nodeID :NodeID
  ) : Node {
    let 
    identity = this.identities.descendant(nodeID.ownerIDs);
    return identity ? identity.node : null;
  }

  setNode(
    node :Node, 
    nodeID :NodeID
  ) {
    let
    ownerIDs = nodeID.ownerIDs;
    var
    index = 0;
    var
    identity :Identity = this.identities;
    while (index < ownerIDs.length) {
      let
      ownerID = ownerIDs[index];
      var
      child = identity.child(ownerID);
      if (!(
        child
      )) { 
        child = new Identity();
        identity.setChild(child, ownerID);
      }
      identity = child;
      index += 1;
    }
    identity.node = node;
  }

  removeNode(
    nodeID :NodeID
  ) {
    let
    ownerIDs = nodeID.ownerIDs;
    var
    index = 1;
    var
    parent :Identity = this.identities;
    var
    identity :Identity = parent.child(nodeID.ownerIDs[0]);
    while (index < ownerIDs.length) {
      let
      ownerID = ownerIDs[index];
      parent = identity;
      identity = identity.child(ownerID);
      index += 1;
    }
    parent.removeChild(ownerIDs[ownerIDs.length - 1]);
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
  ownerIDs :number[];

  constructor(
    ownerIDs :number[]
  ) {
    this.ownerIDs = ownerIDs;
  }

  toString = () : string => {
    let
    ownerIDs = this.ownerIDs;
    var
    buffer = `Node(${ ownerIDs[0] }`;
    var
    index = 1;
    while (index < ownerIDs.length) {
      buffer += `\\${ ownerIDs[index] }`;
      index += 1;
    }
    buffer += ')';
    return buffer;
  }
}

class Identity implements Markup.Markable {
  node :Node = null;
  children :{ [ownerID :number] : Identity } = {};

  child(
    ownerID :number
  ) : Identity {
    return this.children[ownerID];
  }

  setChild(
    child :Identity,
    ownerID :number
  ) {
    this.children[ownerID] = child;
  }

  removeChild(
    ownerID :number
  ) {
    delete this.children[ownerID];
  }

  descendant(
    ownerIDs :number[]
  ) : Identity {
    var
    index = 0;
    var
    identity :Identity = this;
    while (index < ownerIDs.length) {
      let
      ownerID = ownerIDs[index];
      identity = identity.child(ownerID);
      if (!(
        identity
      )) { break; }
      index += 1;
    }
    return identity;
  }

  nodes(
    ownerIDs :number[]
  ) : Node[] {
    var
    buffer = new Array<Node>();
    this.descendant(ownerIDs).collectNodes(buffer);
    return buffer;
  }

  collectNodes(
    buffer :Node[]
  ) {
    let
    node = this.node, children = this.children;
    if (node) {
      buffer.push(node);
    }
    for (let 
      key in children
    ) {
      let
      child = children[key];
      child.collectNodes(buffer);
    }
  }

  markup(
    indent :string = '',
  ) :string {
    let
    node = this.node;
    let
    name = node ? node.name : '_';
    var
    children = new Array<Markup.Markable>();
    for (let
      key in this.children
    ) {
      children.push(this.children[key]);
    }
    return Markup.markup(name, {}, children, indent, true);
  }
}

export class Node implements Markup.Markable
{
  private static
  className = 'ana-node';

  id :NodeID;
  name :string;
  properties :Markup.Markable.Properties = { class: Node.className };
  subordinates :Markup.Markable[] = [];
  events :Event[] = [];
  parent :Node;
  children :Set<Node> = new Set<Node>();
  matching :Match.Stage;
  
  _indexAmongSiblings :number = Number.MAX_SAFE_INTEGER;

  constructor(
    id :NodeID,
    name :string,
    parent :Node,
    matching :Match.Stage
  ) {
    this.id = id;
    this.name = name;
    this.parent = parent;
    this.matching = matching;
  }

  fork(
    nodeID :NodeID,
    name :string
  ) :Node {
    let
    node = this, children = this.children, subordinates = this.subordinates;
    let 
    matching = node.stageMatching(name);
    let
    child = new Node(nodeID, name, node, matching);
    child._indexAmongSiblings = children.size;
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
    name = this.name, properties = this.properties, matching = this.matching, subordinates = this.subordinates;
    if (alone) {
      return Markup.markup(name, properties, [], indent);
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
    return Markup.markup(name, properties, children, indent);
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

  get indexAmongSiblings() : number {
    return this._indexAmongSiblings;
  }
  get nodeName() : string {
    return this.name;
  }
  get parentNode() : Node {
    return this.parent;
  }
  get attributes() : Markup.Markable.Properties {
    return this.properties;
  }

  latestValueForKeyPath(
    keyPath :string
  ) : any {
    for (let
      event of this.events
    ) {
      if (!(
        (event.name == 'ana-value-updated') &&
        (event.properties['key-path'] == keyPath)
      )) { continue; }
      return event.properties['value'];
    }
    return undefined;
  }
  get latestEvent() : Event {
    let
    events = this.events;
    if (!(
      events.length > 0
    )) { return null; } 
    return events[events.length - 1];
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
  get nodeName() : string {
    return this.name;
  }
  get attributes() : Event.Properties {
    return this.properties;
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
    children = new Array<Markup.Markable>();
    let
    tasks = matching.tasksMatching(this.name);
    if (tasks.length > 0) {
      children.push(new Markup.ArrayMarker('tasks', tasks));
    }
    return new Markup.ObjectMarker(this.name, this.properties, children);
  }
}
export namespace Event
{
  export type Properties = Markup.Markable.Properties;
}

