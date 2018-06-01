
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
  firstDisplayedEvent() : Event;
  valueFirstDisplayedEvent(keyPath :string) : Event
  latestValue(keyPath :string) : any;
  isVisible() : boolean;
}

export let first_displayed = (
  node :Node,
  keyPath? :string
) : any => {
  let
  event = node.latestEvent();
  let
  display = keyPath ? 
    node.valueFirstDisplayedEvent(keyPath) : 
    node.firstDisplayedEvent();
  if (!(display === event)) { return undefined; }
  return keyPath ? node.latestValue(keyPath) : node;
}
