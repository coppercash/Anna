"use strict";
exports.__esModule = true;
exports.whenDisplays = function (keyPath, map) {
    return function (node) {
        var isVisible = undefined;
        var value = undefined;
        for (var _i = 0, _a = node.events; _i < _a.length; _i++) {
            var event_1 = _a[_i];
            if (event_1.name == 'ana-appeared') {
                if (!(isVisible === undefined)) {
                    continue;
                }
                isVisible = true;
            }
            else if ((event_1.name == 'ana-updated') &&
                (event_1.properties['key-path'] == keyPath)) {
                if (!(value == undefined)) {
                    continue;
                }
                value = event_1.properties['value'];
            }
            if ((isVisible !== undefined) &&
                (value != undefined)) {
                break;
            }
        }
        if (!((isVisible === true) &&
            (value != undefined))) {
            return undefined;
        }
        else {
            return map(node, value);
        }
    };
};
