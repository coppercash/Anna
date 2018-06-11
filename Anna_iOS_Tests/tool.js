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
exports.first_displayed = function (node, keyPath) {
    var event = node.latestEvent();
    var display = keyPath ?
        node.valueFirstDisplayedEvent(keyPath) :
        node.firstDisplayedEvent();
    if (!(display === event)) {
        return undefined;
    }
    return keyPath ? node.latestValue(keyPath) : node;
};
