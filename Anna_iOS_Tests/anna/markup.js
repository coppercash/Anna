"use strict";
var __extends = (this && this.__extends) || (function () {
    var extendStatics = Object.setPrototypeOf ||
        ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
        function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
function markup(name, properties, children, indent, closed) {
    if (properties === void 0) { properties = {}; }
    if (children === void 0) { children = []; }
    if (indent === void 0) { indent = ''; }
    if (closed === void 0) { closed = false; }
    var buffer = '';
    for (var key in properties) {
        buffer = buffer + " " + key + "=\"" + properties[key] + "\"";
    }
    buffer = indent + "<" + name + buffer;
    if (children.length == 0) {
        buffer = "" + buffer + (closed ? '/>' : '>');
        return buffer;
    }
    buffer = buffer + ">";
    var childIndent = indent + "  ";
    for (var _i = 0, children_1 = children; _i < children_1.length; _i++) {
        var child = children_1[_i];
        var marked = child.markup(childIndent);
        if (!(marked)) {
            continue;
        }
        buffer = buffer + '\n' + marked;
    }
    if (closed) {
        buffer = buffer + '\n' + (indent + "</" + name + ">");
    }
    return buffer;
}
exports.markup = markup;
var NameMarker = (function () {
    function NameMarker(name) {
        this.name = name;
    }
    NameMarker.prototype.markup = function (indent) {
        if (indent === void 0) { indent = ''; }
        return markup(this.name, {}, [], indent, true);
    };
    return NameMarker;
}());
exports.NameMarker = NameMarker;
var ArrayMarker = (function (_super) {
    __extends(ArrayMarker, _super);
    function ArrayMarker(name, elements) {
        var _this = _super.call(this, name) || this;
        _this.elements = elements;
        return _this;
    }
    ArrayMarker.prototype.markup = function (indent) {
        if (indent === void 0) { indent = ''; }
        var name = this.name, elements = this.elements;
        return markup(name, { length: elements.length }, elements, indent, true);
    };
    return ArrayMarker;
}(NameMarker));
exports.ArrayMarker = ArrayMarker;
var ObjectMarker = (function (_super) {
    __extends(ObjectMarker, _super);
    function ObjectMarker(name, properties, children) {
        var _this = _super.call(this, name) || this;
        _this.properties = properties;
        _this.children = children;
        return _this;
    }
    ObjectMarker.prototype.markup = function (indent) {
        if (indent === void 0) { indent = ''; }
        var name = this.name, properties = this.properties, children = this.children;
        return markup(this.name, properties, children, indent, true);
    };
    return ObjectMarker;
}(NameMarker));
exports.ObjectMarker = ObjectMarker;
//# sourceMappingURL=markup.js.map