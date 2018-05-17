
export class Node<Key, Value> {
  value? :Value = null;
  children :Map<Key, Node<Key, Value>> = new Map();
  retrieve(
    path :Array<Key>
  ) : Node<Key, Value> {
    var
    index = 0;
    for (
      var index = 0, node :Node<Key, Value> = this;
      index < path.length;
      index += 1
    ) {
      let
      component = path[index];
      node = node.children.get(component);
      if (!(node)) { break; }
    }
    return node;
  }

  insert(
    path :Array<Key>
  ) : Node<Key, Value> {
    if (!(path.length > 0)) {
      throw new Error(`Cannot create node with empty path.`);
    }

    let
    construct = this.constructor as (typeof Node);

    // Create intermedium nodes
    //
    var
    node :Node<Key, Value> = this;
    for (
      var index = 0;
      index < (path.length - 1);
      index += 1
    ) {
      let
      component = path[index];
      var
      child = node.children.get(component);
      if (!(child)) {
        child = new construct();
        node.children.set(component, child);
      }

      node = child;
    }

    // Create target node
    //
    let
    component = path[path.length - 1];
    if (node.children.get(component)) {
      throw new Error(`Cannot override an already exists node with path '${ path }.'`);
    }
    let
    target = new construct() as Node<Key, Value>;
    node.children.set(component, target);
    return target;
  }
}

