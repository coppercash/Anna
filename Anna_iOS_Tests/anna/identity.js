"use strict";
var __assign = (this && this.__assign) || Object.assign || function(t) {
    for (var s, i = 1, n = arguments.length; i < n; i++) {
        s = arguments[i];
        for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
            t[p] = s[p];
    }
    return t;
};
Object.defineProperty(exports, "__esModule", { value: true });
var Markup = require("./markup");
var Tree = (function () {
    function Tree(loader) {
        this.identities = {};
        this.loader = loader;
    }
    Tree.prototype.rootNodeID = function (ownerID) {
        return this.nodeID(ownerID, Tree.rootName);
    };
    Tree.prototype.nodeID = function (ownerID, name) {
        return new NodeID(ownerID, name);
    };
    Tree.prototype.registerNode = function (nodeID, parentID) {
        var registered = this.node(nodeID);
        if (registered) {
            throw new Error(nodeID + " has already been registered.");
        }
        var parent = null;
        if (parentID) {
            parent = this.node(parentID);
            if (!parent) {
                throw new Error("Cannot find parent " + parentID + ".");
            }
        }
        else {
            if (nodeID.name != Tree.rootName) {
                throw new Error("To be registerd, " + nodeID + " must have a parent.");
            }
        }
        var byName = this.identities[nodeID.ownerID];
        if (!byName) {
            byName = {};
            this.identities[nodeID.ownerID] = byName;
        }
        var node = parent ? parent.fork(nodeID) : new Node(nodeID, null, this.rootMatching());
        byName[nodeID.name] = node;
    };
    Tree.prototype.unregisterNode = function (nodeID) {
        var _this = this;
        var identities = this.identities;
        var node = this.node(nodeID);
        node.children.forEach(function (x) { return _this.unregisterNode(x.id); });
        var owners = identities[nodeID.ownerID];
        delete owners[nodeID.name];
        if (!(Object.keys(owners).length > 0)) {
            delete identities[nodeID.ownerID];
        }
        node.delete();
    };
    Tree.prototype.node = function (nodeID) {
        var byName = this.identities[nodeID.ownerID];
        if (!byName) {
            return null;
        }
        var node = byName[nodeID.name];
        if (!node) {
            return null;
        }
        return node;
    };
    Tree.prototype.rootMatching = function () {
        return this.loader.matchTasks('');
    };
    Tree.rootName = 'ana-root';
    return Tree;
}());
exports.Tree = Tree;
var NodeID = (function () {
    function NodeID(ownerID, name) {
        var _this = this;
        this.toString = function () {
            return "Node(" + _this.name + "\\" + _this.ownerID + ")";
        };
        this.ownerID = ownerID;
        this.name = name;
    }
    return NodeID;
}());
exports.NodeID = NodeID;
var Node = (function () {
    function Node(id, parent, matching) {
        this.properties = { class: Node.className };
        this.subordinates = [];
        this.events = [];
        this.children = new Set();
        this.id = id;
        this.parent = parent;
        this.matching = matching;
    }
    Node.prototype.fork = function (nodeID) {
        var node = this, children = this.children;
        var matching = node.stageMatching(nodeID.name);
        var child = new Node(nodeID, node, matching);
        children.add(child);
        return child;
    };
    Node.prototype.delete = function () {
        var parent = this.parent;
        if (!(parent)) {
            return;
        }
        parent;
    };
    Node.prototype.recordEvent = function (name, properties) {
        var events = this.events, subordinates = this.subordinates;
        var event = new Event(name, properties);
        events.push(event);
        subordinates.push(event);
    };
    Node.prototype.tasksMatchingEvent = function (name) {
        return this.matching.tasksMatching(name);
    };
    Node.prototype.stageMatching = function (name) {
        return this.matching.matching(name);
    };
    Node.prototype.markup = function (indent) {
        if (indent === void 0) { indent = ''; }
        var id = this.id, properties = this.properties, matching = this.matching, subordinates = this.subordinates;
        var children = new Array();
        children.push(matching);
        for (var _i = 0, subordinates_1 = subordinates; _i < subordinates_1.length; _i++) {
            var sub = subordinates_1[_i];
            if (sub instanceof Event) {
                var event_1 = sub;
                children.push(event_1.markable(matching));
            }
            else {
                children.push(sub);
            }
        }
        return Markup.markup(id.name, properties, children, indent);
    };
    Node.prototype.upMarkedAncestors = function () {
        var node = this, parent = this.parent;
        if (!(parent)) {
            return [node.markup(), ''];
        }
        var ancestors = parent.upMarkedAncestors();
        var indent = ancestors[1] + "  ";
        var markup = ancestors[0] + "\n" + node.markup(indent);
        return [markup, indent];
    };
    Node.prototype.snapshot = function () {
        var parent = this.parent;
        if (!(parent)) {
            return this.markup();
        }
        var ancestors = parent.upMarkedAncestors();
        return ancestors[0] + '\n' + this.markup(ancestors[1] + "  ");
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
        this.properties = buffer;
    }
    Event.prototype.markup = function (indent) {
        if (indent === void 0) { indent = ''; }
        return Markup.markup(this.name, this.properties, [], indent, true);
    };
    Event.prototype.markable = function (matching) {
        var tasks = new Markup.ArrayMarker('tasks', matching.tasksMatching(this.name));
        return new Markup.ObjectMarker(this.name, this.properties, [tasks]);
    };
    Event.className = 'ana-event';
    return Event;
}());
exports.Event = Event;
//# sourceMappingURL=identity.js.map