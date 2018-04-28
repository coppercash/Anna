"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var Markup = require("./markup");
var Stage = (function () {
    function Stage(matches, orphans) {
        this.matches = matches;
        this.orphans = orphans;
    }
    Stage.empty = function () {
        return new Stage(Node.emtpy(), Node.emtpy());
    };
    Stage.prototype.tasksMatching = function (name) {
        var matches = this.matches;
        var child = matches.child(name);
        if (!(child)) {
            return [];
        }
        return child.tasks;
    };
    Stage.prototype.matching = function (name) {
        var matches = this.matches, orphans = this.orphans;
        var matched = matches.child(name);
        var merged = matched ? matched.copied() : Node.emtpy();
        var adopted = orphans.child(name);
        if (adopted) {
            merged.merge(adopted);
        }
        return new Stage(merged, orphans);
    };
    Stage.prototype.markup = function (indent) {
        if (indent === void 0) { indent = ''; }
        return this.matches.markup(indent);
    };
    return Stage;
}());
exports.Stage = Stage;
var Node = (function () {
    function Node(children, tasks) {
        this.children = children;
        this.tasks = tasks;
    }
    Node.emtpy = function () {
        return new Node({}, []);
    };
    Node.prototype.copied = function () {
        var node = this;
        var children = {};
        for (var name_1 in node.children) {
            children[name_1] = node.children[name_1].copied();
        }
        var tasks = node.tasks.slice();
        return new Node(children, tasks);
    };
    Node.prototype.merge = function (another) {
        var node = this;
        for (var name_2 in another.children) {
            var others = another.children[name_2];
            if (name_2 in node.children) {
                node.children[name_2].merge(others);
            }
            else {
                node.children[name_2] = others;
            }
        }
    };
    Node.prototype.insert = function (path) {
        var node = this;
        if (!(path.length > 0)) {
            return;
        }
        var name = path[0];
        var child = node.children[name];
        if (!(child)) {
            child = Node.emtpy();
            node.children[name] = child;
        }
        child.insert(path.slice(1));
    };
    Node.prototype.child = function (name) {
        return this.children[name];
    };
    Node.prototype.descendant = function (path) {
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
    Node.prototype.appendTask = function (task) {
        this.tasks.push(task);
    };
    Node.prototype.markup = function (indent) {
        if (indent === void 0) { indent = ''; }
        var children = this.children, tasks = this.tasks;
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
        if (tasks.length > 0) {
            markedChildren.push(new Markup.ArrayMarker('tasks', tasks));
        }
        if (!((childrenCount + tasks.length) > 0)) {
            return '';
        }
        return Markup.markup(Node.nodeName, {}, markedChildren, indent, true);
    };
    Node.nodeName = 'match';
    return Node;
}());
var Builder = (function () {
    function Builder() {
        this.result = Stage.empty();
    }
    Builder.prototype.addMatchTask = function (path, map) {
        var result = this.result;
        var segments = path.split('/');
        var matches;
        if (path.lastIndexOf('/', 0) === 0) {
            matches = result.matches;
            segments = segments.slice(1);
        }
        else {
            matches = result.orphans;
        }
        matches.insert(segments);
        var node = matches.descendant(segments);
        var task = new Task(map, path);
        node.appendTask(task);
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
//# sourceMappingURL=match.js.map