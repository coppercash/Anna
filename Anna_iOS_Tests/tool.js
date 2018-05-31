"use strict";
exports.__esModule = true;
var Event;
(function (Event) {
    var Name;
    (function (Name) {
        Name["Appeared"] = "ana-appeared";
        Name["Updated"] = "ana-updated";
    })(Name = Event.Name || (Event.Name = {}));
    var Update = /** @class */ (function () {
        function Update() {
        }
        Update.KeyPath = 'key-path';
        Update.Value = 'value';
        return Update;
    }());
    Event.Update = Update;
})(Event || (Event = {}));
exports.first_displayed = function (node, keyPath, ancestor) {
    if (ancestor === void 0) { ancestor = 0; }
    var event = node.latestEvent();
    var displayedAt = keyPath ?
        node.valueFirstDisplayedTime(keyPath) :
        node.firstDisplayedTime();
    if (!(displayedAt === event.attributes.time)) {
        return undefined;
    }
    return node.latestValue(keyPath);
};
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
