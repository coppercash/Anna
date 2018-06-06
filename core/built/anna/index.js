(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.Anna = f()}})(function(){var define,module,exports;return (function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
function copy_of_set(set) {
    var copy = new Set();
    set.forEach(function (e) { copy.add(e); });
    return copy;
}
exports.copy_of_set = copy_of_set;
function array_from_set(set) {
    var array = new Array();
    set.forEach(function (e) { array.push(e); });
    return array;
}
exports.array_from_set = array_from_set;
function string_starts_with(haystack, needle) {
    return haystack.lastIndexOf(needle, 0) === 0;
}
exports.string_starts_with = string_starts_with;
function string_ends_with(haystack, needle) {
    return haystack.indexOf(needle, haystack.length - needle.length) !== -1;
}
exports.string_ends_with = string_ends_with;
function object_assign(target, source) {
    for (var _i = 0, _a = Object.keys(source); _i < _a.length; _i++) {
        var key = _a[_i];
        target[key] = source[key];
    }
    return target;
}
exports.object_assign = object_assign;
function object_remove_all(target) {
    for (var _i = 0, _a = Object.keys(target); _i < _a.length; _i++) {
        var key = _a[_i];
        delete target[key];
    }
}
exports.object_remove_all = object_remove_all;

},{}],2:[function(require,module,exports){
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
var __assign = (this && this.__assign) || Object.assign || function(t) {
    for (var s, i = 1, n = arguments.length; i < n; i++) {
        s = arguments[i];
        for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
            t[p] = s[p];
    }
    return t;
};
Object.defineProperty(exports, "__esModule", { value: true });
var Match = require("./match");
var Markup = require("./markup");
var Trie = require("./trie");
var C = require("./compatibility");
var Tree = (function () {
    function Tree() {
        this.root = null;
        this.identities = new Identity();
    }
    Tree.prototype.registerNode = function (nodeID, parentID, name, index, attributes) {
        var tree = this;
        var registered = tree.node(nodeID);
        if (registered) {
            throw new Error(nodeID + " named '" + name + "' has already been registered.");
        }
        var parent = null;
        if (parentID) {
            parent = tree.node(parentID);
            if (!parent) {
                throw new Error("Cannot find parent " + parentID + ".");
            }
        }
        else {
            if (tree.root) {
                throw new Error("To be registerd, " + nodeID + " must have a parent.");
            }
        }
        var node = parent ?
            parent.fork(nodeID, name, index, attributes) :
            new Node(nodeID, null, name, index, attributes);
        tree.setNode(node, nodeID);
        if (!(parent)) {
            tree.root = node;
        }
    };
    Tree.prototype.deregisterNodes = function (nodeID) {
        var _this = this;
        var tree = this;
        var identities = this.identities;
        var nodes = identities.retrieveAllValues(nodeID.toPath());
        if (!(nodes.length > 0)) {
            throw new Error("No nodes were registered with " + nodeID);
        }
        for (var _i = 0, nodes_1 = nodes; _i < nodes_1.length; _i++) {
            var node = nodes_1[_i];
            node._children.forEach(function (x) { return _this.deregisterNodes(x._id); });
            node.delete();
            tree.removeNode(nodeID);
            if (node === tree.root) {
                delete tree.root;
            }
        }
    };
    Tree.prototype.node = function (nodeID) {
        var identity = this.identities.retrieve(nodeID.toPath());
        return identity ? identity.value : null;
    };
    Tree.prototype.setNode = function (node, nodeID) {
        var identities = this.identities;
        var identity = identities.insert(nodeID.toPath());
        identity.value = node;
    };
    Tree.prototype.removeNode = function (nodeID) {
        this.identities.delete(nodeID.toPath());
    };
    Tree.prototype.addMatchTasks = function (tasks) {
        var root = this.root;
        if (!(root)) {
            throw new Error("Cannot add match tasks to a identity tree without a root node.");
        }
        root.traverseWithStage(tasks, function (node, stage) {
            node._matching.merge(stage);
        });
    };
    Tree.prototype.subtractMatchTasks = function (tasks) {
        var root = this.root;
        if (!(root)) {
            throw new Error("Cannot subtract match tasks from a identity tree without a root node.");
        }
        root.traverseWithStage(tasks, function (node, stage) {
            node._matching.drop(stage);
        });
    };
    Tree.prototype.snapshot = function () {
        return this.root.snapshot();
    };
    return Tree;
}());
exports.Tree = Tree;
var NodeID = (function () {
    function NodeID(ownerID, keyPath) {
        if (keyPath === void 0) { keyPath = []; }
        var _this = this;
        this.toString = function () {
            return "Node(" + _this.briefRepresentation() + ")";
        };
        this.ownerID = ownerID;
        this.keyPath = keyPath;
    }
    NodeID.prototype.briefRepresentation = function () {
        return this.toPath().join('/');
    };
    NodeID.prototype.toPath = function () {
        var path = [this.ownerID.toString()];
        this.keyPath.forEach(function (e) { return path.push(e); });
        return path;
    };
    return NodeID;
}());
exports.NodeID = NodeID;
var Identity = (function (_super) {
    __extends(Identity, _super);
    function Identity() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    Identity.prototype.markup = function (indent) {
        if (indent === void 0) { indent = ''; }
        var node = this.value;
        var name = node ? node._name : '_';
        var children = new Array();
        this.children.forEach(function (v) { return children.push(v); });
        return Markup.markup(name, {}, children, indent, true);
    };
    return Identity;
}(Trie.Node));
var Node = (function () {
    function Node(id, parent, name, index, attributes) {
        this._children = new Set();
        this._matching = Match.Stage.empty();
        this._lastetEvent = null;
        this._latestValues = {};
        this._isVisible = false;
        this._events = [];
        this._id = id;
        this._parent = parent;
        this._path = parent ? parent.path + "/" + name : '';
        this._name = name;
        this._index = index;
        var attrs = {
            id: id.briefRepresentation(),
            class: Node.className,
            createdAt: Date.now(),
        };
        if (attributes) {
            C.object_assign(attrs, attributes);
        }
        if (index !== undefined && index !== null) {
            attrs.index = index;
        }
        this._attributes = attrs;
    }
    Node.prototype.fork = function (nodeID, name, index, attributes) {
        var node = this, children = this._children;
        var child = new Node(nodeID, node, name, index, attributes);
        children.add(child);
        var matching = node.stageMatching(name);
        child._matching.merge(matching);
        return child;
    };
    Node.prototype.delete = function () {
        var parent = this._parent, deleting = this;
        if (!(parent)) {
            return;
        }
        parent._children.delete(this);
    };
    Node.prototype.recordEvent = function (name, properties) {
        var event = new Event(name, properties);
        this._appendEvent(event);
        this._lastetEvent = event;
        switch (name) {
            case Event.Name.Updated:
                this._updateValue(properties[Event.Update.Value], properties[Event.Update.KeyPath], event);
                break;
            case Event.Name.Appeared:
                this._recordAppearance(true, event);
                break;
            case Event.Name.Disappeared:
                this._recordAppearance(false, event);
                break;
            default:
                break;
        }
    };
    Node.prototype._appendEvent = function (event) {
        var events = this._events;
        events.push(event);
        if (events.length > 10) {
            events.shift();
        }
    };
    Node.prototype._updateValue = function (value, keyPath, event) {
        var latestValues = this._latestValues;
        var container = latestValues[keyPath];
        if (!(container)) {
            container = new Value();
            latestValues[keyPath] = container;
        }
        var old = container.value;
        var equals = (value == old) || ((value != undefined) &&
            (old != undefined) &&
            (value.toString() === old.toString()));
        if (!(equals === false)) {
            return;
        }
        container.value = value;
        if (this._isVisible) {
            container.firstDisplayedEvent = event;
        }
        else {
            delete container.firstDisplayedEvent;
        }
    };
    Node.prototype._recordAppearance = function (isVisible, event) {
        var wasVisible = this._isVisible;
        if (!(isVisible !== wasVisible)) {
            return;
        }
        this._isVisible = isVisible;
        if (!(isVisible)) {
            return;
        }
        if (!(this._firstDisplayedEvent)) {
            this._firstDisplayedEvent = event;
        }
        var latestValues = this._latestValues;
        for (var _i = 0, _a = Object.keys(latestValues); _i < _a.length; _i++) {
            var key = _a[_i];
            var container = latestValues[key];
            if (!(container.firstDisplayedEvent == undefined)) {
                continue;
            }
            container.firstDisplayedEvent = event;
        }
    };
    Node.prototype.tasksMatchingEvent = function (name) {
        var tasks = this._matching.tasksMatching(name);
        return C.array_from_set(tasks);
    };
    Node.prototype.stageMatching = function (name) {
        return this._matching.matching(name);
    };
    Node.prototype.traverseWithStage = function (stage, handle) {
        var children = this._children;
        children.forEach(function (current) {
            var match = stage.matching(current._name);
            current.traverseWithStage(match, handle);
        });
        handle(this, stage);
    };
    Node.prototype.markup = function (indent, alone) {
        if (indent === void 0) { indent = ''; }
        if (alone === void 0) { alone = false; }
        var name = this._name, attributes = this.attributes, matching = this._matching, events = this._events, children = this._children;
        if (alone) {
            return Markup.markup(name, attributes, [], indent);
        }
        var subs = new Array();
        subs.push(new Match.Stage.DigestMarker(matching));
        events.forEach(function (event) { return subs.push(event.markable(matching)); });
        children.forEach(function (child) { return subs.push(child); });
        return Markup.markup(name, attributes, subs, indent);
    };
    Node.prototype.upMarkedAncestors = function () {
        var node = this, parent = this._parent;
        if (!(parent)) {
            return [node.markup('', true), ''];
        }
        var ancestors = parent.upMarkedAncestors();
        var indent = ancestors[1] + "  ";
        var markup = ancestors[0] + '\n' + node.markup(indent, true);
        return [markup, indent];
    };
    Node.prototype.snapshot = function () {
        var parent = this._parent;
        if (!(parent)) {
            return this.markup();
        }
        var ancestors = parent.upMarkedAncestors();
        return ancestors[0] + '\n' + this.markup(ancestors[1] + "  ");
    };
    Object.defineProperty(Node.prototype, "nodeName", {
        get: function () {
            return this._name;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(Node.prototype, "index", {
        get: function () {
            return this._index;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(Node.prototype, "parentNode", {
        get: function () {
            return this._parent;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(Node.prototype, "attributes", {
        get: function () {
            return this._attributes;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(Node.prototype, "path", {
        get: function () {
            return this._path;
        },
        enumerable: true,
        configurable: true
    });
    Node.prototype.latestEvent = function () {
        return this._lastetEvent;
    };
    Node.prototype.latestValue = function (keyPath) {
        var container = this._latestValues[keyPath];
        return container ? container.value : undefined;
    };
    Node.prototype.firstDisplayedEvent = function () {
        return this._firstDisplayedEvent;
    };
    Node.prototype.valueFirstDisplayedEvent = function (keyPath) {
        var container = this._latestValues[keyPath];
        return container ? container.firstDisplayedEvent : undefined;
    };
    Node.prototype.isVisible = function () {
        return this._isVisible;
    };
    Node.prototype.ancestor = function (length) {
        if (length === void 0) { length = 0; }
        var current = this;
        for (var left = length; current && left > 0; left -= 1) {
            current = current.parentNode;
        }
        return current;
    };
    Node.className = 'ana-node';
    return Node;
}());
exports.Node = Node;
var Event = (function () {
    function Event(name, properties) {
        this.name = name;
        var buffer = __assign({}, properties);
        buffer.class = Event.className;
        buffer.time = Date.now();
        this.properties = buffer;
    }
    Object.defineProperty(Event.prototype, "nodeName", {
        get: function () {
            return this.name;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(Event.prototype, "attributes", {
        get: function () {
            return this.properties;
        },
        enumerable: true,
        configurable: true
    });
    Event.prototype.markup = function (indent) {
        if (indent === void 0) { indent = ''; }
        return Markup.markup(this.name, this.properties, [], indent, true);
    };
    Event.prototype.markable = function (matching) {
        return new Markup.ObjectMarker(this.name, this.properties, []);
    };
    Event.className = 'ana-event';
    return Event;
}());
exports.Event = Event;
(function (Event) {
    var Name;
    (function (Name) {
        Name["Updated"] = "ana-updated";
        Name["Appeared"] = "ana-appeared";
        Name["Disappeared"] = "ana-disappeared";
    })(Name = Event.Name || (Event.Name = {}));
    var Update = (function () {
        function Update() {
        }
        Update.KeyPath = 'key-path';
        Update.Value = 'value';
        return Update;
    }());
    Event.Update = Update;
})(Event = exports.Event || (exports.Event = {}));
exports.Event = Event;
var Value = (function () {
    function Value() {
    }
    return Value;
}());

},{"./compatibility":1,"./markup":5,"./match":6,"./trie":9}],3:[function(require,module,exports){
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var Identity = require("./identity");
var Track = require("./track");
var Load = require("./load");
var Task = require("./task");
var C = require("./compatibility");
var Manager = (function () {
    function Manager(loader, config) {
        this.identities = new Identity.Tree();
        this.loadedTasks = new Task.Tree();
        this.tracker = null;
        this.config = {};
        this.loader = loader;
        if (config) {
            this.config = config;
        }
    }
    Manager.run = function (dependency) {
        var taskModulePath = dependency.taskModulePath, inject = dependency.inject, require = dependency.require, receive = dependency.receive, config = dependency.config;
        var _require = (config && config.debug) ?
            function (identifier) {
                delete require.cache[require.resolve(identifier)];
                return require(identifier);
            } : require;
        var manager = new Manager(new Load.RequiringLoader(taskModulePath, inject, _require), config);
        manager.tracker = new Track.InPlaceTracker(receive);
        return manager;
    };
    Manager.prototype.nodeID = function (id) {
        if (id instanceof Identity.NodeID) {
            return id;
        }
        else if (id instanceof Array) {
            return id.length > 0 ?
                new Identity.NodeID(id[0], id.slice(1)) : null;
        }
        else if (typeof id == 'number') {
            return new Identity.NodeID(id);
        }
        else {
            return null;
        }
    };
    Manager.prototype.registerNode = function (id, parentID, name, index, namespace, attributes) {
        var nID = this.nodeID(id), pID = this.nodeID(parentID);
        try {
            this.identities.registerNode(nID, pID, name, index, attributes);
        }
        catch (e) {
            if (!(nID.keyPath.length > 0)) {
                throw e;
            }
        }
        this.loadTasks(['index'], ['.']);
        if (namespace) {
            var namePath = this.namePath(namespace);
            this.loadTasks(namePath);
        }
    };
    Manager.prototype.deregisterNodes = function (id) {
        this.identities.deregisterNodes(this.nodeID(id));
    };
    Manager.prototype.recordEvent = function (name, properties, nodeID) {
        var identities = this.identities, tracker = this.tracker;
        nodeID = this.nodeID(nodeID);
        var node = identities.node(nodeID);
        if (!(node)) {
            throw RecordingError.eventOnUnregistered(name, properties, nodeID);
        }
        node.recordEvent(name, properties);
        if (!(tracker)) {
            return;
        }
        var tasks = node.tasksMatchingEvent(name);
        var exception = undefined;
        for (var _i = 0, tasks_1 = tasks; _i < tasks_1.length; _i++) {
            var task = tasks_1[_i];
            try {
                var result = task.resultByMapping(node);
                if (result !== undefined) {
                    tracker.receiveResult(result);
                }
            }
            catch (e) {
                exception = e;
            }
        }
        if (exception) {
            throw exception;
        }
    };
    Manager.prototype.namePath = function (namespace) {
        if (C.string_starts_with(namespace, '.') ||
            C.string_ends_with(namespace, '.')) {
            throw new Error("Cannot load tasks with invalid namespace '" + namespace + "'.");
        }
        var namePath = namespace.split('.');
        return namePath;
    };
    Manager.prototype.loadTasks = function (namePath, cachePath) {
        var identities = this.identities, loadedTasks = this.loadedTasks, config = this.config, loader = this.loader;
        if (!(cachePath)) {
            cachePath = namePath;
        }
        var loaded = loadedTasks.retrieve(cachePath);
        if (!(loaded)) {
            var tasks = loader.matchTasks(namePath);
            identities.addMatchTasks(tasks);
            loadedTasks.insert(cachePath).value = tasks;
        }
        else if (config.debug) {
            var tasks = loader.matchTasks(namePath);
            identities.subtractMatchTasks(loaded.value);
            identities.addMatchTasks(tasks);
            loaded.value = tasks;
        }
    };
    Manager.prototype.logSnapshot = function () {
        console.log(this.identities.snapshot());
    };
    return Manager;
}());
exports.Manager = Manager;
var RecordingError = (function () {
    function RecordingError() {
    }
    RecordingError.eventOnUnregistered = function (name, properties, nodeID) {
        var keyValue;
        if (name == Identity.Event.Name.Updated) {
            keyValue = "(" + properties[Identity.Event.Update.KeyPath] + ": " + properties[Identity.Event.Update.Value] + ")";
        }
        else {
            keyValue = '';
        }
        return Error("Cannot record event '" + name + keyValue + "' on unregistered node '" + nodeID + "'.");
    };
    return RecordingError;
}());

},{"./compatibility":1,"./identity":2,"./load":4,"./task":7,"./track":8}],4:[function(require,module,exports){
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var Match = require("./match");
var RequiringLoader = (function () {
    function RequiringLoader(taskModulePath, inject, require) {
        this.taskModulePath = taskModulePath;
        this.inject = inject;
        this.require = require;
    }
    RequiringLoader.prototype.matchTasks = function (namePath) {
        var taskModulePath = this.taskModulePath, require = this.require;
        var path = taskModulePath + "/" + namePath.join('/') + ".js";
        var builder = new Match.Builder();
        var match = function (path, map) {
            var paths;
            if (path instanceof Array) {
                paths = path;
            }
            else {
                paths = [path];
            }
            for (var _i = 0, paths_1 = paths; _i < paths_1.length; _i++) {
                var path_1 = paths_1[_i];
                builder.addMatchTask(path_1, map);
            }
        };
        try {
            this.preRequire(match);
            require(path);
        }
        catch (_a) { }
        finally {
            this.postRequire();
        }
        return builder.build();
    };
    RequiringLoader.prototype.preRequire = function (match) {
        var inject = this.inject;
        inject('match', match);
    };
    RequiringLoader.prototype.postRequire = function () {
        this.inject('match', undefined);
    };
    return RequiringLoader;
}());
exports.RequiringLoader = RequiringLoader;
var InPlaceLoader = (function () {
    function InPlaceLoader(load) {
        this.load = load;
    }
    InPlaceLoader.prototype.matchTasks = function (namePath) {
        var load = this.load;
        var builder = new Match.Builder();
        var match = function (path, map) {
            builder.addMatchTask(path, map);
        };
        load(match, namePath);
        return builder.build();
    };
    return InPlaceLoader;
}());
exports.InPlaceLoader = InPlaceLoader;

},{"./match":6}],5:[function(require,module,exports){
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
        buffer = "" + buffer + (closed ? ' />' : '>');
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

},{}],6:[function(require,module,exports){
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var Markup = require("./markup");
var C = require("./compatibility");
var Stage = (function () {
    function Stage(matches, orphans) {
        this.matches = matches;
        this.orphans = orphans;
    }
    Stage.empty = function () {
        return new Stage(MatchNode.emtpy(), MatchNode.emtpy());
    };
    Object.defineProperty(Stage.prototype, "isEmpty", {
        get: function () {
            return this.matches.isEmpty && this.orphans.isEmpty;
        },
        enumerable: true,
        configurable: true
    });
    Stage.prototype.tasksMatching = function (name) {
        var matches = this.matches;
        var child = matches.child(name);
        if (!(child)) {
            return new Set();
        }
        return child.tasks;
    };
    Stage.prototype.matching = function (name) {
        var matches = this.matches, orphans = this.orphans;
        var matched = matches.child(name);
        var merged = matched ? matched.copied() : MatchNode.emtpy();
        var adopted = orphans.child(name);
        if (adopted) {
            merged.merge(adopted);
        }
        return new Stage(merged, orphans);
    };
    Stage.prototype.merge = function (another) {
        this.matches.merge(another.matches);
        this.orphans.merge(another.orphans);
    };
    Stage.prototype.drop = function (another) {
        this.matches.drop(another.matches);
        this.orphans.drop(another.orphans);
    };
    Stage.prototype.markup = function (indent) {
        if (indent === void 0) { indent = ''; }
        var children = [
            new Node.NamedMarker(this.matches, 'matches'),
            new Node.NamedMarker(this.orphans, 'orphans'),
        ];
        return Markup.markup('stage', {}, children, indent, true);
    };
    return Stage;
}());
exports.Stage = Stage;
(function (Stage) {
    var DigestMarker = (function () {
        function DigestMarker(stage) {
            this.stage = stage;
        }
        DigestMarker.prototype.markup = function (indent) {
            if (indent === void 0) { indent = ''; }
            return (new Node.DigestMarker(this.stage.matches)).markup(indent);
        };
        return DigestMarker;
    }());
    Stage.DigestMarker = DigestMarker;
})(Stage = exports.Stage || (exports.Stage = {}));
exports.Stage = Stage;
var Node;
(function (Node) {
    var DigestMarker = (function () {
        function DigestMarker(node) {
            this.node = node;
        }
        DigestMarker.prototype.markup = function (indent) {
            if (indent === void 0) { indent = ''; }
            var children = this.node.children, tasks = this.node.tasks;
            var markedChildren = new Array();
            var branches = new Array();
            var childrenCount = 0;
            for (var key in children) {
                branches.push(new Markup.NameMarker(key));
                childrenCount += 1;
            }
            if (childrenCount > 0) {
                markedChildren.push(new Markup.ArrayMarker('branches', branches));
            }
            if (tasks.size > 0) {
                markedChildren.push(new Markup.ArrayMarker('tasks', C.array_from_set(tasks)));
            }
            if (!((childrenCount + tasks.size) > 0)) {
                return '';
            }
            return Markup.markup('match', {}, markedChildren, indent, true);
        };
        DigestMarker.nodeName = 'match';
        return DigestMarker;
    }());
    Node.DigestMarker = DigestMarker;
    var NamedMarker = (function () {
        function NamedMarker(node, name) {
            this.node = node;
            this.name = name;
        }
        NamedMarker.prototype.markup = function (indent) {
            var _this = this;
            if (indent === void 0) { indent = ''; }
            var tasks = this.node.tasks;
            var children = Object
                .keys(this.node.children)
                .map(function (x) {
                return new Node.NamedMarker(_this.node.children[x], x);
            });
            if (tasks.size > 0) {
                children.push(new Markup.ArrayMarker('tasks', C.array_from_set(tasks)));
            }
            return Markup.markup(this.name, {}, children, indent, true);
        };
        return NamedMarker;
    }());
    Node.NamedMarker = NamedMarker;
})(Node = exports.Node || (exports.Node = {}));
var MatchNode = (function () {
    function MatchNode(children, tasks) {
        this.children = children;
        this.tasks = tasks;
    }
    MatchNode.emtpy = function () {
        return new MatchNode({}, new Set());
    };
    Object.defineProperty(MatchNode.prototype, "isEmpty", {
        get: function () {
            return (Object.keys(this.children).length == 0) && this.tasks.size == 0;
        },
        enumerable: true,
        configurable: true
    });
    MatchNode.prototype.copied = function () {
        var tasks = this.tasks, children = this.children;
        var cCopy = {};
        for (var name_1 in children) {
            cCopy[name_1] = children[name_1].copied();
        }
        var tCopy = C.copy_of_set(tasks);
        return new MatchNode(cCopy, tCopy);
    };
    MatchNode.prototype.merge = function (another) {
        var tasks = this.tasks, children = this.children;
        var union = C.copy_of_set(tasks);
        another.tasks.forEach(function (e) { return union.add(e); });
        this.tasks = union;
        for (var name_2 in another.children) {
            var others = another.children[name_2];
            var mine = children[name_2];
            if (mine) {
                mine.merge(others);
            }
            else {
                children[name_2] = others.copied();
            }
        }
    };
    MatchNode.prototype.drop = function (another) {
        var tasks = this.tasks, children = this.children;
        var diff = C.copy_of_set(tasks);
        another.tasks.forEach(function (e) { return diff.delete(e); });
        this.tasks = diff;
        for (var name_3 in another.children) {
            var others = another.children[name_3];
            var mine = children[name_3];
            if (!(mine)) {
                continue;
            }
            mine.drop(others);
            if (mine.isEmpty) {
                delete children[name_3];
            }
        }
    };
    MatchNode.prototype.insert = function (path) {
        var node = this;
        if (!(path.length > 0)) {
            return;
        }
        var name = path[0];
        var child = node.children[name];
        if (!(child)) {
            child = MatchNode.emtpy();
            node.children[name] = child;
        }
        child.insert(path.slice(1));
    };
    MatchNode.prototype.child = function (name) {
        return this.children[name];
    };
    MatchNode.prototype.descendant = function (path) {
        var node = this;
        if (!(path.length > 0)) {
            return node;
        }
        var name = path[0];
        if (!(name in node.children)) {
            return null;
        }
        return node.children[name].descendant(path.slice(1));
    };
    MatchNode.prototype.addTask = function (task) {
        this.tasks.add(task);
    };
    MatchNode.prototype.markup = function (indent) {
        if (indent === void 0) { indent = ''; }
        return (new Node.NamedMarker(this, 'match')).markup(indent);
    };
    return MatchNode;
}());
var Builder = (function () {
    function Builder() {
        this.result = Stage.empty();
    }
    Builder.prototype.addMatchTask = function (path, map) {
        var result = this.result;
        var segments = path.split('/');
        var matches;
        if (C.string_starts_with(path, '/')) {
            matches = result.matches;
            segments = segments.slice(1);
        }
        else {
            matches = result.orphans;
        }
        matches.insert(segments);
        var node = matches.descendant(segments);
        var task = new Task(map, path);
        node.addTask(task);
    };
    Builder.prototype.build = function () {
        return this.result;
    };
    return Builder;
}());
exports.Builder = Builder;
var Task = (function () {
    function Task(map, path) {
        this.map = map;
        this.path = path;
    }
    Task.prototype.resultByMapping = function (node) {
        return this.map(node);
    };
    Task.prototype.markup = function (indent) {
        if (indent === void 0) { indent = ''; }
        var path = this.path;
        return Markup.markup(Task.nodeName, { path: path }, [], indent, true);
    };
    Task.nodeName = 'task';
    return Task;
}());
exports.Task = Task;

},{"./compatibility":1,"./markup":5}],7:[function(require,module,exports){
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
var Trie = require("./trie");
var Tree = (function (_super) {
    __extends(Tree, _super);
    function Tree() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    return Tree;
}(Trie.Node));
exports.Tree = Tree;

},{"./trie":9}],8:[function(require,module,exports){
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var InPlaceTracker = (function () {
    function InPlaceTracker(receive) {
        this.receive = receive;
    }
    InPlaceTracker.prototype.receiveResult = function (result) {
        this.receive(result);
    };
    return InPlaceTracker;
}());
exports.InPlaceTracker = InPlaceTracker;

},{}],9:[function(require,module,exports){
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var Node = (function () {
    function Node() {
        this.value = null;
        this.children = new Map();
    }
    Node.prototype.get = function (key) {
        return this.children.get(key);
    };
    Node.prototype.retrieve = function (path) {
        var index = 0;
        for (var index = 0, node = this; index < path.length; index += 1) {
            var component = path[index];
            node = node.children.get(component);
            if (!(node)) {
                break;
            }
        }
        return node;
    };
    Node.prototype.insert = function (path) {
        if (!(path.length > 0)) {
            throw new Error("Cannot create node with empty path.");
        }
        var construct = this.constructor;
        var node = this;
        for (var index = 0; index < (path.length - 1); index += 1) {
            var component_1 = path[index];
            var child = node.children.get(component_1);
            if (!(child)) {
                child = new construct();
                node.children.set(component_1, child);
            }
            node = child;
        }
        var component = path[path.length - 1];
        if (node.children.get(component)) {
            throw new Error("Cannot override an already exists node with path '" + path + ".'");
        }
        var target = new construct();
        node.children.set(component, target);
        return target;
    };
    Node.prototype.delete = function (path) {
        if (!(path.length > 0)) {
            return;
        }
        var index = 1, parent = this, current = parent.get(path[0]);
        while (index < path.length) {
            var key = path[index];
            parent = current;
            current = current.get(key);
            index += 1;
        }
        var lastKey = path[path.length - 1];
        parent.children.delete(lastKey);
    };
    Node.prototype.retrieveAllValues = function (path) {
        var buffer = new Array();
        var node = this.retrieve(path);
        this._collect_values(node, buffer);
        return buffer;
    };
    Node.prototype._collect_values = function (node, buffer) {
        var _this = this;
        if (!(node)) {
            return;
        }
        var children = node.children, value = node.value;
        if (value) {
            buffer.push(value);
        }
        if (children) {
            children.forEach(function (v) { return _this._collect_values(v, buffer); });
        }
    };
    return Node;
}());
exports.Node = Node;

},{}]},{},[3])(3)
});
