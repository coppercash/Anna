import * as Identity from './identity'
import * as Markup from './markup';
import * as C from './compatibility';

export class Stage implements Markup.Markable
{
  matches :Stage.Matches;
  orphans :Stage.Matches;

  constructor(
    matches :Stage.Matches,
    orphans :Stage.Matches
  ) {
    this.matches = matches;
    this.orphans = orphans;
  }

  static empty() {
    return new Stage(MatchNode.emtpy(), MatchNode.emtpy());
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
    merged = matched ? matched.copied() : MatchNode.emtpy();
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
    indent :string = '',
  ) :string {
    let
    children = [
      new Node.NamedMarker(this.matches, 'matches'),
      new Node.NamedMarker(this.orphans, 'orphans'),
    ];
    return Markup.markup(
      'stage', 
      {}, 
      children, 
      indent, 
      true
    );
  }
}
export namespace Stage {
  export type Matches = MatchNode;
  export class DigestMarker implements Markup.Markable {
    stage :Stage;
    constructor(
      stage :Stage
    ) {
      this.stage = stage;
    }
    markup(
      indent :string = '',
    ) :string {
      return (new Node.DigestMarker(this.stage.matches)).markup(indent);
    }
  }
}

export namespace Node {
  export type Children = { [name :string] : MatchNode; };

  export class DigestMarker implements Markup.Markable {
    node :MatchNode;
    constructor(
      node :MatchNode
    ) {
      this.node = node;
    }
    private static
    nodeName = 'match';
    markup(
      indent :string = ''
    ) :string {
      let
      children = this.node.children, tasks = this.node.tasks;
      let
      markedChildren = new Array<Markup.Markable>();
      let
      branches = new Array<Markup.Markable>();
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
          C.array_from_set(tasks)
        ));
      }

      if (!(
        (childrenCount + tasks.size) > 0
      )) {
        return '';
      }
      return Markup.markup(
        'match',
        {}, 
        markedChildren, 
        indent, 
        true
      );
    }
  }

  export class NamedMarker implements Markup.Markable {
    node :MatchNode;
    name :string;
    constructor(
      node :MatchNode,
      name :string
    ) {
      this.node = node;
      this.name = name;
    }
    markup(
      indent :string = '',
    ) :string {
      let
      tasks = this.node.tasks;
      let
      children :Markup.Markable[] = Object
        .keys(this.node.children)
        .map((x) => {
          return new Node.NamedMarker(this.node.children[x], x);
        });
      if (tasks.size > 0) {
        children.push(
          new Markup.ArrayMarker(
            'tasks', 
            C.array_from_set(tasks)
          )
        );
      }
      return Markup.markup(
        this.name,
        {},
        children,
        indent,
        true
      )
    }
  }
}

class MatchNode implements Markup.Markable
{
  children :Node.Children;
  tasks :Set<Task>;

  constructor(
    children :Node.Children,
    tasks :Set<Task>
  ) {
    this.children = children;
    this.tasks = tasks;
  }

  static emtpy() {
    return new MatchNode({}, new Set());
  }
  get isEmpty() :boolean {
    return (Object.keys(this.children).length == 0) && this.tasks.size == 0;
  }

  copied()
  {
    let
    tasks = this.tasks, children = this.children;
    let
    cCopy :Node.Children = {};
    for (let 
      name in children
    ) {
      cCopy[name] = children[name].copied();
    }
    let
    tCopy = C.copy_of_set(tasks);
    return new MatchNode(cCopy, tCopy);
  }

  merge(
    another :MatchNode
  ) {
    let
    tasks = this.tasks, children = this.children;

    let
    union = C.copy_of_set(tasks);
    another.tasks.forEach(e => union.add(e));
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
    another :MatchNode
  ) {
    let
    tasks = this.tasks, children = this.children;

    let
    diff = C.copy_of_set(tasks);
    another.tasks.forEach(e => diff.delete(e));
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
      child = MatchNode.emtpy();
      node.children[name] = child;
    }
    child.insert(path.slice(1));
  }

  child(
    name :string
  ) :MatchNode {
    return this.children[name];
  }

  descendant(
    path :string[]
  ) :MatchNode {
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

  markup(
    indent :string = ''
  ) :string {
    return (new Node.NamedMarker(this, 'match')).markup(indent);
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
    matches :Stage.Matches;
    if (C.string_starts_with(path, '/')) {
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

export namespace Task
{
  export type Node = Identity.Node;
  export type Map = (node :Node) => any;
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

