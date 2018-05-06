
interface Event {
  name :string;
  properties :{ [key :string] : any };
}
interface Node {
  events :Event[];
}
type Map = (node :Node) => any

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

