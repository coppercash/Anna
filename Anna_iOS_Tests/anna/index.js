"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var Identity = require("./identity");
var Match = require("./match");
var Anna = (function () {
    function Anna(loader) {
        this.tracker = null;
        this.task = new TaskBuilders();
        this.identities = new Identity.Tree(this);
        this.loader = loader;
    }
    Anna.prototype.rootNodeID = function (ownerID) {
        return this.identities.rootNodeID(ownerID);
    };
    Anna.prototype.nodeID = function (ownerID, name) {
        return this.identities.nodeID(ownerID, name);
    };
    Anna.prototype.registerNode = function (id, parentID) {
        this.identities.registerNode(id, parentID);
    };
    Anna.prototype.unregisterNode = function (id) {
        this.identities.unregisterNode(id);
    };
    Anna.prototype.recordEvent = function (name, properties, nodeID) {
        var identities = this.identities, tracker = this.tracker;
        var node = identities.node(nodeID);
        node.recordEvent(name, properties);
        var tasks = node.tasksMatchingEvent(name);
        if (!(tasks && tasks.length > 0)) {
            throw new Error(nodeID + " is not registered with any events");
        }
        for (var _i = 0, tasks_1 = tasks; _i < tasks_1.length; _i++) {
            var task = tasks_1[_i];
            var result = task.resultByMapping(node);
            if (tracker) {
                tracker.receiveResult(result);
            }
        }
    };
    Anna.prototype.matchTasks = function (namespace) {
        var builder = new Match.Builder();
        this.task.match = function (path, map) {
            builder.addMatchTask(path, map);
        };
        this.loader.matchTasks(namespace, this);
        return builder.build();
    };
    return Anna;
}());
exports.Anna = Anna;
var TaskBuilders = (function () {
    function TaskBuilders() {
        this.match = null;
    }
    return TaskBuilders;
}());
exports.TaskBuilders = TaskBuilders;
//# sourceMappingURL=index.js.map