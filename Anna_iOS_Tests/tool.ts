
namespace Event {
  export enum Name {
    Appeared = "ana-appeared",
      Updated = "ana-updated",
  }
  export class Update {
    static 
    KeyPath :string = 'key-path';
    static 
    Value :string = 'value';
  }
}
interface Event {
  name :string;
  attributes :{ [key :string] : any };
}
interface Node {
  path :string;
  parentNode :Node;
  ancestor(distance :number) : Node;
  latestEvent() : Event;
  firstDisplayedTime() : number
  valueFirstDisplayedTime(keyPath :string) : number
  latestValue(keyPath :string) : any;
  isVisible() : boolean;
}

export let first_displayed = (
  node :Node,
  keyPath? :string,
  ancestor :number = 0
) : any => {
  let
  event = node.latestEvent();
  let
  displayedAt = keyPath ? 
    node.valueFirstDisplayedTime(keyPath) : 
    node.firstDisplayedTime();
  if (!(displayedAt === event.attributes.time)) { return undefined; }
  return node.latestValue(keyPath);
}
/*
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
*/
