import * as Identity from './identity'
import * as Markup from './markup';

type Matches = Node;
export class Stage implements Markup.Markable
{
  matches :Matches;
  orphans :Matches;

  constructor(
    matches :Matches,
    orphans :Matches
  ) {
    this.matches = matches;
    this.orphans = orphans;
  }

  static
  empty()
  {
    return new Stage(Node.emtpy(), Node.emtpy());
  }
  get isEmpty() :boolean {
    return this.matches.isEmpty && this.orphans.isEmpty;
  }

  tasksMatching(
    name :string
  ) :Set<Task> {
    let
    matches = this.matches;
    let
    child = matches.child(name);
    if (!(
      child
    )) {
      return new Set();
    }
    return child.tasks;
  }

  matching(
    name :string
  ): Stage {
    let
    matches = this.matches, orphans = this.orphans;
    let
    matched = matches.child(name);
    let
    merged = matched ? matched.copied() : Node.emtpy();
    let
    adopted = orphans.child(name);
    if (adopted) {
      merged.merge(adopted);
    }
    return new Stage(merged, orphans);
  }

  merge(
    another :Stage
  ) {
    this.matches.merge(another.matches);
    this.orphans.merge(another.orphans);
  }

  drop(
    another :Stage
  ) {
    this.matches.drop(another.matches);
    this.orphans.drop(another.orphans);
  }

  markup(
    indent :string = ''
  ) :string {
    return this.matches.markup(indent);
  }
}

type Children = { [name :string] : Node; };
class Node implements Markup.Markable
{
  children :Children;
  tasks :Set<Task>;

  constructor(
    children :Children,
    tasks :Set<Task>
  ) {
    this.children = children;
    this.tasks = tasks;
  }

  static
  emtpy()
  {
    return new Node({}, new Set());
  }
  get isEmpty() :boolean {
    return (Object.keys(this.children).length == 0) && this.tasks.size == 0;
  }

  copied()
  {
    let
    tasks = this.tasks, children = this.children;
    let
    cCopy :Children = {};
    for (let 
      name in children
    ) {
      cCopy[name] = children[name].copied();
    }
    let
    tCopy = new Set(tasks);
    return new Node(cCopy, tCopy);
  }

  merge(
    another :Node
  ) {
    let
    tasks = this.tasks, children = this.children;

    let
    union = new Set(tasks);
    let
    iterableTasks = another.tasks.values();
    var
    task = iterableTasks.next().value;
    while (task) {
      union.add(task);
      task = iterableTasks.next().value;
    }
    this.tasks = union;

    for (let 
      name in another.children
    ) {
      let
      others = another.children[name];
      let
      mine = children[name];
      if (mine) {
        mine.merge(others);
      }
      else {
        children[name] = others.copied();
      }
    }
  }

  drop(
    another :Node
  ) {
    let
    tasks = this.tasks, children = this.children;

    let
    diff = new Set(tasks);
    let
    iterableTasks = tasks.values();
    var
    task = iterableTasks.next().value;
    while (task) {
      diff.delete(task);
      task = iterableTasks.next().value;
    }
    this.tasks = diff;

    for (let 
      name in another.children
    ) {
      let 
      others = another.children[name];
      let
      mine = children[name];
      if (!(mine)) { continue; }
      mine.drop(others);
      if (mine.isEmpty) {
        delete children[name];
      }
    }
  }

  /**
   * Insert a node to the position in the tree where the path describes.
   */
  insert(
    path :string[]
  ) {
    let
    node = this;
    if (!(
      path.length > 0
    )) {
      return;
    }
    let
    name = path[0];
    var
    child = node.children[name];
    if (!(
      child
    )) {
      child = Node.emtpy();
      node.children[name] = child;
    }
    child.insert(path.slice(1));
  }

  child(
    name :string
  ) :Node {
    return this.children[name];
  }

  descendant(
    path :string[]
  ) :Node {
    let
    node = this;
    if (!(
      path.length > 0
    )) {
      return node;
    }
    let
    name = path[0];
    if (!(
      name in node.children
    )) {
      return null;
    }
    return node.children[name].descendant(path.slice(1));
  }

  addTask(
    task :Task
  ) {
    this.tasks.add(task);
  }

  private static
  nodeName = 'match';
  markup(
    indent :string = ''
  ) :string {
    let
    children = this.children, tasks = this.tasks;
    let
    markedChildren = new Array<Markup.Markable>();
    let
    branches = new Array<Markup.NameMarker>();
    var
    childrenCount = 0;
    for (let 
      key in children
    ) {
      branches.push(new Markup.NameMarker(key));
      childrenCount += 1;
    }
    if (childrenCount > 0) {
      markedChildren.push(new Markup.ArrayMarker(
        'branches', 
        branches
      ));
    }
    if (tasks.size > 0) {
      markedChildren.push(new Markup.ArrayMarker(
        'tasks',
        Array.from(tasks)
      ));
    }

    if (!(
      (childrenCount + tasks.size) > 0
    )) {
      return '';
    }
    return Markup.markup(Node.nodeName, {}, markedChildren, indent, true);
  }
}

export class Builder 
{
  result = Stage.empty();

  addMatchTask(path :string, map :Task.Map)
  {
    let
    result = this.result;
    var
    segments = path.split('/');
    let
    matches :Matches;
    if (path.lastIndexOf('/', 0) === 0) {
      matches = result.matches;
      segments = segments.slice(1);
    }
    else {
      matches = result.orphans;
    }
    matches.insert(segments);
    let
    node = matches.descendant(segments);
    let
    task = new Task(map, path);
    node.addTask(task);
  }

  build() :Stage 
  {
    return this.result;
  }
}

export class Task implements Markup.Markable
{
  map :Task.Map;
  path :string;

  constructor(
    map :Task.Map,
    path :string
  ) {
    this.map = map;
    this.path = path;
  }

  resultByMapping(node :Task.Node) :any
  {
    return this.map(node);
  }

  private static
  nodeName = 'task';
  markup(
    indent :string = ''
  ) :string {
    let
    path = this.path;
    return Markup.markup(Task.nodeName, { path: path }, [], indent, true);
  }
}

export namespace Task
{
  export type Node = Identity.Node;
  export type Map = (node :Node) => any;
}

