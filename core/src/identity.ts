import * as Match from './match';
import * as Markup from './markup';
import * as Trie from './trie';
import * as C from './compatibility';

export class Tree
{
  root :Node = null;
  identities :Identity = new Identity();

  registerNode(
    nodeID :NodeID, 
    parentID :NodeID | null,
    name :string,
    index? :number,
    attributes? :Node.Attributes
  ) {
    let
    tree = this;
    let
    registered = tree.node(nodeID);
    if (registered) {
      throw new Error(`${ nodeID } named '${ name }' has already been registered.`);
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
      parent.fork(nodeID, name, index, attributes) : 
      new Node(nodeID, null, name, index, attributes);

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
    nodes = identities.retrieveAllValues(nodeID.toPath());
    if (!(
      nodes.length > 0
    )) {
      throw new Error(`No nodes were registered with ${ nodeID }`);
    }
    for (let
      node of nodes
    ) {
      node._children.forEach(x => this.deregisterNodes(x._id));

      node.delete();
      tree.removeNode(nodeID);
      if (node === tree.root) {
        delete tree.root
      }
    }
  }

  node(
    nodeID :NodeID
  ) : Node {
    let 
    identity = this.identities.retrieve(nodeID.toPath());
    return identity ? identity.value : null;
  }

  setNode(
    node :Node, 
    nodeID :NodeID
  ) {
    let
    identities = this.identities;
    let
    identity = identities.insert(nodeID.toPath());
    identity.value = node;
  }

  removeNode(
    nodeID :NodeID
  ) {
    this.identities.delete(nodeID.toPath());
  }

  addMatchTasks(
    tasks :Match.Stage
  ) {
    let
    root = this.root;
    if (!(root)) {
      throw new Error(`Cannot add match tasks to a identity tree without a root node.`);
    }
    root.traverseWithStage(
      tasks, 
      (node, stage) => { 
        node._matching.merge(stage); 
      }
    );
  }

  subtractMatchTasks(
    tasks :Match.Stage
  ) {
    let
    root = this.root;
    if (!(root)) {
      throw new Error(`Cannot subtract match tasks from a identity tree without a root node.`);
    }
    root.traverseWithStage(
      tasks, 
      (node, stage) => { 
        node._matching.drop(stage); 
      }
    );
  }

  snapshot() : string {
    return this.root.snapshot();
  }
}

export class NodeID
{
  ownerID :number;
  keyPath :string[];

  constructor(
    ownerID :number,
    keyPath :string[] = []
  ) {
    this.ownerID = ownerID;
    this.keyPath = keyPath;
  }

  toString = () : string => {
    return `Node(${ this.briefRepresentation() })`;
  }

  briefRepresentation() : string {
    return this.toPath().join('/');
  }

  toPath() : string[] {
    let
    path = [this.ownerID.toString()];
    this.keyPath.forEach(e => path.push(e));
    return path;
  }
}

class Identity extends Trie.Node<string, Node> implements Markup.Markable {

  markup(
    indent :string = '',
  ) :string {
    let
    node = this.value;
    let
    name = node ? node._name : '_';
    var
    children = new Array<Markup.Markable>();
    this.children.forEach(v => children.push(v as Identity));
    return Markup.markup(name, {}, children, indent, true);
  }
}

export namespace Node {
  export type Attributes = { [name: string]: any; };
}
export class Node implements Markup.Markable
{
  private static
  className = 'ana-node';

  _id :NodeID;
  _parent :Node;
  _children :Set<Node> = new Set<Node>();
  _name :string;
  _index :number;
  _path :string;
  _attributes :Node.Attributes;

  _matching :Match.Stage = Match.Stage.empty();
  
  _lastetEvent :Event = null;
  _latestValues :{ [keyPath :string] : Value } = {};
  _isVisible :boolean = false;
  _firstDisplayedEvent :Event;
  _events :Event[] = [];

  constructor(
    id :NodeID,
    parent :Node | null,
    name :string,
    index? :number,
    attributes? :Node.Attributes
  ) {
    this._id = id;
    this._parent = parent;
    this._path = parent ? `${ parent.path }/${ name }` : '';
    this._name = name;
    this._index = index;
    let
    attrs = {
      id: id.briefRepresentation(),
      class: Node.className,
      createdAt: Date.now(),
    } as Node.Attributes;
    if (attributes) {
      C.object_assign(attrs, attributes);
    }
    if (index !== undefined && index !== null) {
      attrs.index = index;
    }
    this._attributes = attrs;
  }

  fork(
    nodeID :NodeID,
    name :string,
    index? :number,
    attributes? :Node.Attributes
  ) :Node {
    let
    node = this, children = this._children;
    let
    child = new Node(nodeID, node, name, index, attributes);
    children.add(child);
    let 
    matching = node.stageMatching(name);
    child._matching.merge(matching);
    
    return child;
  }

  delete()
  {
    let
    parent = this._parent, deleting = this;
    if (!(
      parent
    )) { return; }
    parent._children.delete(this);
  }

  recordEvent(
    name :string,
    properties :Event.Properties
  ) {
    let
    event = new Event(name, properties);
    this._appendEvent(event);
    this._lastetEvent = event;
    switch (name) {
      case Event.Name.Updated:
        this._updateValue(
          properties[Event.Update.Value],
          properties[Event.Update.KeyPath],
          event
        );
        break;
      case Event.Name.Appeared:
        this._recordAppearance(
          true,
          event
        );
        break;
      case Event.Name.Disappeared:
        this._recordAppearance(
          false,
          event
        );
        break;
      default:
        break;
    }
  }
  _appendEvent(
    event :Event
  ) {
    let
    events = this._events;
    events.push(event);
    if (events.length > 10) {
      events.shift();
    }
  }
  _updateValue(
    value :any,
    keyPath :string,
    event :Event
  ) {
    let
    latestValues = this._latestValues;
    var
    container = latestValues[keyPath];
    if (!(container)) {
      container = new Value();
      latestValues[keyPath] = container;
    }
    let
    old = container.value;
    let
    equals = (value == old) || (
      (value != undefined) && 
      (old != undefined) &&
      (value.toString() === old.toString())
    ); // TODO: Have a better equality checking method
    if (!(equals === false)) { return; }

    container.value = value;
    if (this._isVisible) {
      container.firstDisplayedEvent = event;
    }
    else {
      delete container.firstDisplayedEvent;
    }
  }
  _recordAppearance(
    isVisible :boolean,
    event :Event
  ) {
    let
    wasVisible = this._isVisible;
    if (!(isVisible !== wasVisible)) { return; }

    this._isVisible = isVisible;

    if (!(
      isVisible
    )) { return; }
    if (!(this._firstDisplayedEvent)) {
      this._firstDisplayedEvent = event;
    }
    let
    latestValues = this._latestValues;
    for (let
      key of Object.keys(latestValues)
    ) {
      let
      container = latestValues[key];
      if (!(container.firstDisplayedEvent == undefined)) { continue; }
      container.firstDisplayedEvent = event;
    }
  }

  tasksMatchingEvent(
    name :string
  ) :Match.Task[]
  {
    let
    tasks = this._matching.tasksMatching(name);
    return C.array_from_set(tasks);
  }

  stageMatching(
    name :string
  ) :Match.Stage {
    return this._matching.matching(name);
  }

  traverseWithStage(
    stage :Match.Stage,
    handle :(node :Node, stage :Match.Stage) => void
  ) {
    let
    children = this._children;
    children.forEach((current) => {
      let
      match = stage.matching(current._name);
      current.traverseWithStage(match, handle);
    });

    handle(this, stage);
  }

  markup(
    indent :string = '',
    alone :boolean = false
  ) :string {
    let
    name = this._name, 
      attributes = this.attributes, 
      matching = this._matching,
      events = this._events,
      children = this._children;
    if (alone) {
      return Markup.markup(name, attributes, [], indent);
    }
    let
    subs = new Array<Markup.Markable>();
    subs.push(new Match.Stage.DigestMarker(matching));
    events.forEach(event => subs.push(event.markable(matching)));
    children.forEach(child => subs.push(child));
    return Markup.markup(name, attributes, subs, indent);
  }

  upMarkedAncestors() :[string, string]
  {
    let
    node = this, parent = this._parent;
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
    parent = this._parent;
    if (!(
      parent
    )) {
      return this.markup();
    }
    let
    ancestors = parent.upMarkedAncestors();
    return ancestors[0] + '\n' + this.markup(`${ ancestors[1]}  `);
  }

  get nodeName() : string {
    return this._name;
  }
  get index() : number {
    return this._index;
  }
  get parentNode() : Node {
    return this._parent;
  }
  get attributes() : Markup.Markable.Properties {
    return this._attributes;
  }
  get path() : string {
    return this._path;
  }
  
  latestEvent() : Event {
    return this._lastetEvent;
  }
  latestValue(
    keyPath :string
  ) : any {
    let
    container = this._latestValues[keyPath];
    return container ? container.value : undefined;
  }
  firstDisplayedEvent() : Event {
    return this._firstDisplayedEvent;
  }
  valueFirstDisplayedEvent(
    keyPath :string
  ) : Event {
    let
    container = this._latestValues[keyPath];
    return container ? container.firstDisplayedEvent : undefined;
  }
  isVisible() : boolean {
    return this._isVisible;
  }
  ancestor(
    length :number = 0
  ) : Node {
    var 
    current = this as Node;
    for (
      var left = length;
      current && left > 0;
      left -= 1
    ) {
      current = current.parentNode;
    }
    return current;
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
    buffer.time = Date.now();
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
    /*
    let
    children = new Array<Markup.Markable>();
    let
    tasks = matching.tasksMatching(this.name);
    if (tasks.size > 0) {
      children.push(
        new Markup.ArrayMarker(
          'tasks', 
          C.array_from_set(tasks)
        )
      );
    }
    */
    return new Markup.ObjectMarker(this.name, this.properties, []);
  }
}
export namespace Event
{
  export type Properties = Markup.Markable.Properties;
  export enum Name {
    Updated = "ana-updated",
      Appeared = "ana-appeared",
      Disappeared = "ana-disappeared",
  }
  export class Update {
    static 
    KeyPath :string = 'key-path';
    static 
    Value :string = 'value';
  }
}

class Value {
  value :any;
  firstDisplayedEvent :Event;
}

