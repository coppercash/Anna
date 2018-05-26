
interface Event {
  name :string;
  properties :{ [key :string] : any };
}
interface Node {
  events :Event[];
  parentNode :Node;
}
type Map = (node :Node) => any

type Digger = (node :Node) => any
/*
export let first_displayed = (
  node :Node,
  keyPath :string,
  ancestor :number = 0
) : any => {
  let
  ancestor = node_parent(node, ancestor);
  if (!(ancestor)) { return undefined; }
  let
  last = node_last_value_update(ancestor, keyPath, ancestor.events.length);
  if (!(last)) { return undefined };
  let
  lAppearance = node_last_event_after(node, last[0].attributes.time, node.events.length);
  if (!(lAppearance)) { return undefined };
  let
  lValue = last[0].attributes.value;
  let
  second = node_last_value_update(ancestor, keyPath, last[1]);
  if (!(second)) { return lValue; }
  let
  sAppearance = node_last_event_after(node, second[0].attributes.time, lAppearance[1])
  if (!(sAppearance)) { return lValue; }
  let
  sValue = second[0].attributes.value;

  return lValue == sValue ? undefined : lValue;
}
*/

export let whenDisplays = (
  keyPath :string, 
  map :(node :Node, value :any) => any
) : Map => {
  return (node) => {
    var
    isVisible :boolean = undefined;
    var
    value :any = undefined;
    for (
      let event of node.events
    ) {
      if (event.name == 'ana-appeared') {
        if (!(isVisible === undefined)) { continue; }
        isVisible = true;
      }
      else if (
        (event.name == 'ana-value-updated') &&
        (event.properties['key-path'] == keyPath) 
      ) {
        if (!(value == undefined)) { continue; }
        value = event.properties['value'];
      }
      if (
        (isVisible !== undefined) &&
        (value != undefined)
      ) { break; }
    }
    if (!(
      (isVisible === true) &&
      (value != undefined)
    )) {
      return undefined;
    } 
    else {
      return map(node, value);
    }
  }
}

