
# Anna

[![Build Status](https://img.shields.io/travis/coppercash/Anna/master.svg)](https://travis-ci.org/coppercash/Anna)
[![codecov.io](https://codecov.io/gh/coppercash/Anna/branch/master/graphs/badge.svg)](https://codecov.io/github/coppercash/Anna)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Anna.svg)](https://cocoapods.org/pods/Anna)
![Platform](https://img.shields.io/cocoapods/p/Anna.svg)
![License MIT](https://img.shields.io/cocoapods/l/Anna.svg)
![Language](https://img.shields.io/badge/language-Swift%20|%20ObjC-green.svg)

Anna offers an abstraction layer which helps separate the analytic code from other code.

There are two parts in Anna:

1. **Anna.iOS** provides a class named `Analyzer`, which plays like a view model in MVVM. It hooks event callbacks from `UIResponder` (also its subclasses) then exposes what it receives to Anna.Core.
2. **Anna.Core** is in JavaScript. It identities every exposed `UIResponder` with a unique path, which consists of `Node`s. When events happen on `Node`s, it runs the registered tasks to "dig" what happened on the `Node`s (and up along the path). 

Finally results are sent back to **Anna.iOS**, where the results could be uploaded to a remote server or some analytic service providers.


## How to Use

### Basic Usage

For example, if we want to track **did-select** event from a cell in a table view controller, we need to register such a task:

```javascript
/* in MasterViewController.js */

match(
  'master/tableView/cell/did-select',
  (node) => { return { action: 'selected', id: node.path }; }
);
```

Expose `MasterViewController` and its table view to **Anna.Core**:

```swift
import Anna

class MasterViewController: UITableViewController, AnalyzableObject {
    lazy var analyzer: Analyzing = { Analyzer.analyzer(with: self) }()
    static let subAnalyzableKeys: Set<String> = [#keyPath(tableView)]
    deinit {
        self.analyzer.detach()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.analyzer.enable(naming: "master")
    }
}

class AnalyzableTableView : UITableView, Analyzable {
    lazy var analyzer: Analyzing = { Analyzer.analyzer(with: self) }()
    deinit { 
        self.analyzer.detach() 
    }
}
```

Receive the result:

```swift
class AppDelegate: UIResponder, UIApplicationDelegate, Delegate {
    func manager(_ manager :Manager, didSend result :Any) {
        print(result)
        //
        // Supposed to output
        // { //     action = selected;
        //     id = "/master/tableView/cell";
        // }
    }
}
```

### Responder Chain & Focus Path

A classic application structure, which contains master & detail view controller navigated within a navigation controller, may look like this:

```
AppDelegate/
├── Anna.RootAnalyzer/
└── UIWindow/
    └── UINavigationController/
        ├── MasterViewController/
        │   ├── Anna.Analyzer("master")/
        │   └── UITableView/
        │       ├── Anna.Analyzer("table")/
        │       └── TableViewCell/
        │           └── Anna.Analyzer("cell", #)/
        └── DetailViewController/
            ├── Anna.Analyzer("detail")/
            └── UIButton/
                └── Anna.Analyzer("button")/
```

We can notice that some `Node`s in the tree above have a `Analyzer` as instance member. 
With the names given to the `Analyzer`s, in **Anna.Core**, this tree results in another tree which is slightly different:

```
/
└── master/
    └── table/
        └── cell/
            └── delail/
                └── button/
```

The major different starts from `Node` **detail** which belongs to the `DetailViewController`. 
In the **Responder Chain** provided by `UIKit`, the next responder (parent in the tree) of `DetailViewController`, is the `UINavigationController`. 
However, in **Anna.Core**, the parent of **detail** is **cell**, which means that user's focus moves from the **cell** to the **detail**. 
This behavior is because, from the aspect of analytics, the useful information for every single view usually belongs to the views that user paid attention on before. 
Thus, in **Anna.Core** every path from the root to a `Node` is actually a **Focus Path**.

### Analyzer

`Analyzer`s are interface for objects to record events on and perform other interactions with `Node`s in **Anna.Core**.

#### Super-Sub Analyzer & Parent-Child Node

In most cases, an `Analyzer` has a name to identify a keyed relationship between the `Node` it binds and the `Node`'s parent. The name is usually given by its super `Analyzer`. However, sometimes, a `Analyzer`'s super `Analyzer` doesn't have direct access to it, in this case a **standalone** name works as well.

An array of sub `Analyzer`s are given indexes respectively to represent indexed relationships.

Owner of a super `Analyzer` can add sub `Analyzer`s to it by confirming protocol `Anna.AnalyzableObject` and implementing method `subAnalyzableKeys`. In this way, sub `Analyzer`s create sub `Node`s in focus path.

If an `Analyzer` is not added by any other `Analyzer` as sub `Analyzer`, it looks up the responder chain for a super `Analyzer`. 
In the looking up process, `Anna.FocusPathConstituting.parentConstitutor()` and `Anna.FocusPathConstitutionRedirecting.redirectedConstitutor()` are called to derive detailed information about how the super-sub relationship is like. 
`UIResponder` and most of its subclasses have default implementation for these methods, but they can be override to support custom behavior.

#### Root Analyzer & Manager

`UIView`s, `UIViewController`s, `UIControl`s and all the other objects in Responder Chain may own a `Analyzer` if they are supposed to be analyzed, including the root responder - `UIApplicaiontDelegate`.
However, the `Analyzer` of `UIApplicaiontDelegate` is slightly different. It is of class `RootAnalyzer` and initialized with a `Manager`.
`Manager` acts like port between **Anna.iOS** and **Anna.Core**. It receives events from **Anna.iOS** and returns calculated results into delegate methods.

`Manager` starts by running the module which the first parameter `moduleURL` of its initializer points to. 
Its behavior can be altered via attributes of `dependency` (the second parameter).

| Attribute | Description |
| --- | --- |
| `debug` | Set to `true` to automatically reload tasks. |
| `coreJSModuleURL` | Where the CoreJS node module locates. |
| `fileManager` | With which, the CoreJS is able to access the file system. This is convenient to inject a mocked value for this when writing test cases.  |
| `standardOutput` | With which, the CoreJS is able to access the standard output. |

And the results returned by `Manager` can be received in `Manager.delegate`.
The methods in `Manager.delegate` are called asynchronously, so if they are not expected to be called on main thread, configure that via `Manager.delegateQueue`:

| Method | Description |
| --- | --- |
| `manager(_, didSend result)` | Called when a result is calculated out. |
| `manager(_, didCatch error)` | Called when an error that is not handled happens. |

#### Focus Marking

To construct a proper Focus Path, **Anna.iOS** must know which `Analyzer` (and the `Node` it binds) is focused. 
**Anna.iOS** derives focus-relative information from Responder Chain and Touch Event. 
Cases with `UIButton` and `UITableView` are automatically handled. 
However, when touch events are detected by `UITapRecognizer`, `touchesEnded(with event)` and in other custom cases, focus marking need to be handled manually. 
To mark an `Analyzer` focused, we need to call `markFocused()` on it.

#### Methods on Analyzer

There are several kinds of **Analyzer**s which all conform to protocol `Analyzing`.

Available methods on `Analyzing`:

| Method | Description |
| --- | --- |
| `enable(naming name)` | Enable the `Analyzer` to hook its delegate and start recording events with a standalone name. |
| `setSubAnalyzer(_ sub, for key)` | Establish a keyed relationship with another `Analyzer`. The sub `Analyzer` is automatically enabled when the current `Analyzer` enabled. |
| `setSubAnalyzers(_ subs, for key)` | Establish indexed relationships with other `Analyzer`s. The sub `Analyzer`s are automatically enabled when the current `Analyzer` enabled. |
| `record(_ event)` | Record event with a name on the `Analyzer`. |
| `update(_ value, for keyPath)` | Record an **value update** event on the `Analyzer`. |
| `observe(_ observee, for keyPath)` | Start observing an object for the key path. When the value changed, an **value updated** event will be recorded. |
| `detach()` | Terminate all hooking and observing. Usually called in `deinit`. |
| `markFocused()` | Mark the `Analyzer` to be focused, such that the newly enabled `Analyzer`s can be on proper focus path. |

### Analytics Module

The parameter `moduleURL` in `Manager.init` points to entrance (a node module) of our analytic module. 
It finds where the **Anna.Core** module, passes in the location of the **task** module, and returns a configured constructor to **Anna.iOS**.
A classic implementation of an analytic module looks like this:

```javascript
/* In
 * analytic.bundle/
 * └── index.js
 */
module.exports = require('../anna.bundle').configured({
  task: (__dirname + '/task')
});
```

#### Task Registration

The tasks to be registered are in the module where the parameter `task` points to. 
The file `index.js` in the module is guaranteed to be `require`-ed before any `Node`s of focus path created. 
Other files are `require`-ed according to the name space of the object create the focus path `Node`. 
For example, when `DetailViewController` creates a focus path `Node`, `DetailViewController.js` will be `require`-ed. 
Hence all the tasks contained in `DetailViewController.js` will be registered.

To register a task when a specific event triggered on a `Node`, simply call

```
match(
  `focus/path/to/node/event`,
  (node) => { return node.path; }
);
```

`match` is a global function injected by **Anna.Core** before tasks loading process.
The first parameter contains two part. The components before the last one identify the kind of `Node`s we care about. The last component refers to the event we care about.
The **digging** function (the second parameter) returns the result dug out from the `Node`.

#### CoreJS

Inside `Anna.Manager` there is a tiny NodeJS environment called CoreJS.
It is so tiny that only the basic `require` function (includes cache) is implemented. 
CoreJS starts by `requrie`-ing the entrance module, of which the URL is passed in via the first parameter of `Manager.init`.
**Anna.Core** is just a normal module `require`-ed in the entrance module, of which the constructor is assigned to the `exports` and finally returned to **Anna.iOS**.

### Focus Path Node

A `Node` (in **Anna.Core**) keeps references to get its context, mainly speaking its parent `Node` and all other ancestor `Node`s, so it is easy to know from where the user move focus to the current `Node`.

From a more abstract aspect, focus paths represent user's interaction with the application in the **past**. And **past** itself is the object of analytics.

Available attributes and functions on `Node`:

| Attribute | Description |
| --- | --- |
| `nodeName` | The name of the `Node`. |
| `index` | The index |
| `path` | The path to the `Node` from the root. |
| `parentNode` | The parent `Node` of the current `Node`. |
| `ancestor(distance)` | The ancestor `Node` of the current `Node`. It refers to current `Node` if `distance` is 0. |
| `latestEvent()` | The latest event happened on the `Node`. |
| `latestValue(keyPath)` | The latest value updated to the `Node`, identified by `keyPath`. |
| `isVisible()` | If the latest **visibility event** happened on this `Node` is **appeared** not **disappeared**. |
| `firstDisplayedEvent()` | The first **appeared** event happened on this `Node`. |
| `valueFirstDisplayedEvent(keyPath)` | The first event which makes a value visible. It can be either an **appeared** event if the value has existed (not `undefined` nor `null`), or an **updated** event if the `Node` has been visible. |

### Special Events

#### Visibility

**Anna.Core** records every `Node`'s visibility be receiving event **appeared** and **disappeared**.
These two events are generated by hooking `UIKit` objects. 
For example,

+ an `UIView` reports **appeared** when it has a super view, is in a window and not hidden.
+ an `UITableViewCell` reports **appeared** the delegate's `tableView(_ tableView, willDisplay cell, forRowAt indexPath)` is called.
+ an `UIViewController` reports **appeared** when its `viewDidAppeared` is called.

Base the visibility, tasks like analyzing data exposure can be done.
 
#### Update & Observe

Value changes on a `Node` can be tracked by calling `update(_ value, for keyPath)`. An series of value changes on an attribute can be distinguished from one another with the help of key path.

If we want to keep tracking an attribute whenever its value changes, we can call `observe(_ observee, for keyPath)`.

### Debug

Sometimes it gets frustrated when **Anna** doesn't behave as expected, even thought everything is believed to be properly configured.
In this case, we can call `Manager.logSnapshot` to log out a marked up text to the `Manager.dependency.standardOutput` to have all the details of the underlying state.
The **snapshot** contains:

+ all the currently registered focus path `Node`
+ the tasks registered on the `Nodes`
+ the most recent ten events happened on the `Nodes`

An sample of **snapshot**:

```
<__root__ id="105553117049152" class="ana-node" createdAt="1530341056867">
  <master id="105827995931584" class="ana-node" createdAt="1530341056870">
    <ana-appeared class="ana-event" time="1530341056875" />
    <ana-disappeared class="ana-event" time="1530341063401" />
    <tableView id="105827995931808" class="ana-node" createdAt="1530341056872">
      <cell id="105553117261952/0" class="ana-node" createdAt="1530341062226" index="0">
        <match>
          <branches length="1">
            <did-select />
          </branches>
        </match>
        <ana-updated key-path="text" value="2018-06-30 06:44:22 +0000" class="ana-event" time="1530341062227" />
        <ana-appeared class="ana-event" time="1530341062227" />
        <did-select class="ana-event" time="1530341062861" />
```

To call `Manager.logSnapshot` without inserting extra lines into the code base, pause the application and type in **lldb** command:

```lldb
e -l swift -- import MyApp; ((UIApplication.shared.delegate as! AppDelegate).analyzer as! RootAnalyzer).manager.logSnapshot()
```

