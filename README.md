
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

For example, if we want to track the **touch-up-inside** event from a button on the bottom of our home view controller, we need to register such a task:

```javascript
/* in task/MyHomeViewController.js */

match(
  'home/bottomButton/touch-up-inside',
  (node) => {action: 'click', id: node.path}
);
```

Expose `MyHomeViewController` and its bottom button to Anna.Core:

```swift
import Anna

class MyHomeViewController : UIViewController, AnalyzableObject {
    lazy let bottomButton :MyButton = MyButton()
    func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.bottomButton)
        self.analyzer.enable(naming: "home")
    }
    lazy var analyzer :Analyzing = { Analyzer.analyzer(with: self) }()
    static let subAnalyzableKeys = Set([#keyPath(bottomButton)])
}

class MyButton : UIButton, Analyzable {
    lazy var analyzer :Analyzing = { Analyzer.analyzer(with: self) }()
}
```

Receive the result:

```swift
class MyTracker : Tracker {
    func receive(analyticsResult :Any, dispatchedBy manager :Manager) {
        print(analyticsResult)
        //
        // Supposed to output {'action' : 'click', 'id' : '/myApp/home/bottomButton'}
    }
}
```

### Responder Chain & Focus Path

A classic application structure, which contains master & detail view controller navigated within a navigation controller, may look like this:

```
MyAppDelegate/
├── Anna.Analyzer("app")/
└── UIWindow/
    └── UINavigationController/
        ├── MyHomeViewController/
        │   ├── Anna.Analyzer("home")/
        │   └── MyTableView/
        │       ├── Anna.Analyzer("table")/
        │       └── MyDetailTableViewCell/
        │           └── Anna.Analyzer("cell", #)/
        └── MyDetailViewController/
            ├── Anna.Analyzer("detail")/
            └── MyButton/
                └── Anna.Analyzer("button")/
```

We can notice that some `Node`s in the tree above have a `Analyzer` as instance member. 
With the names given to the analyzers, in **Anna.Core**, this tree results in another tree which is slightly different:

```
app/
└── home/
    └── table/
        └── cell/
            └── delail/
                └── button/
```

The major different starts from `Node` **detail** which belongs to the `MyDetailViewController`. 
In the **Responder Chain** provided by `UIKit`, the next responder (parent in the tree) of `MyDetailViewController`, is the `UINavigationController`. 
However, in **Anna.Core**, the parent of **detail** is **cell**, which means that user's focus moves from the **cell** to the **detail**. 
This behavior is because, from the aspect of analytics, the useful information for every single view usually belongs to the views user paid attention on before. 
Thus, in **Anna.Core** every path from the root to a `Node` is actually a **Focus Path**.

### Analyzer

`Analyzer`s are interface for objects to record events on and perform other interactions `Node`s in **Anna.Core**.

#### Super-Sub Analyzer & Parent-Child Node

In most cases, an `Analyzer` has a name to identify a keyed relationship between the `Node` it binds and the `Node`'s parent. The name is usually given by its super `Analyzer`. However, sometimes, a super `Analyzer` doesn't have direct access to its sub `Analyzer`s, in this case a **standalone** name works as well.

An array of sub `Analyzer`s are given indexes respectively to represent indexed relationships.

Owner of a super `Analyzer` can add sub `Analyzer`s to it by confirming protocol `Anna.AnalyzableObject` and implementing method `subAnalyzableKeys`. In this way, sub `Analyzer`s create sub `Node`s in focus path.

If an `Analyzer` is not added by any other `Analyzer` as sub `Analyzer`, it looks up the responder chain for a super `Analyzer`. 
In the looking up process, `Anna.FocusPathConstituting.parentConstitutor()` and `Anna.FocusPathConstitutionRedirecting.redirectedConstitutor()` are called to derive detailed information about how the super-sub relationship is like. 
`UIResponder` and most of its subclasses have default implementation for these methods, but they can be override to support custom behavior.

#### Root Analyzer & Manager

`UIView`s, `UIViewController`s, `UIControl`s and all the other objects in Responder Chain may own a `Analyzer` if they are supposed to be analyzed, including the root responder - `UIApplicaiontDelegate`.
However, the `Analyzer` of `UIApplicaiontDelegate` is slightly different. It is initialized with a `Manager`.
`Manager` acts like port between **Anna.iOS** and **Anna.Core**. It receives events from **Anna.iOS** and returns calculated results into delegate methods.

`Manager`'s behavior can be configured via attributes of `Dependency`:

| Attributes | Description |
| --- | --- |
| `moduleURL` | Where the entrance module is located. |
| `taskModuleURL` | Where the tasks to be registered located. Defaults to `moduleURL/task` |
| `config` | A dictionary to configure **Anna.Core**'s behavior. |
| `callbackQueue` | On which the methods of `Manager.Delegate` are called. |

`config` to **Anna.Core**:

| Attributes | Description |
| --- | --- |
| `debug` | Set to `true` to automatically reload tasks. |

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

### Task Registration

The tasks to be registered are in the module pointed to by `Manager.dependency.taskModuleURL`. 
The file `index.js` is guaranteed to be `require`-ed before any `Node`s of focus path created. 
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

`match` is a global function injected by `Anna.Core` before tasks loading process.
The first parameter contains two part. The components before the last identifies the kind of `Node`s we care about. The last component refer to the event we want to hook.
The **digging** function returns the result dug out from the `Node`.

### Focus Path Node

A `Node` (in `Anna.Core`) keeps references to get its context, mainly speaking its parent `Node` and all other ancestor `Node`s, so it is easy to know from where the user move focus to the current `Node`.

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

`Anna.Core` records every `Node`'s visibility be receiving event **appeared** and **disappeared**.
These two events are generated by hooking `UIKit` objects. 
For example,

+ an `UIView` reports **appeared** when it has a super view, is in a window and not hidden.
+ an `UITableViewCell` reports **appeared** the delegate's `tableView(_ tableView, willDisplay cell, forRowAt indexPath)` is called.
+ an `UIViewController` reports **appeared** when its `viewDidAppeared` is called.

Base the visibility, tasks like analyzing data exposure can be done.
 
#### Update & Observe

Value changes on a `Node` can be tracked by calling `update(_ value, for keyPath)`. An series of value changes on an attribute can be distinguished from one another with the help of key path.

If we want to keep tracking an attribute whenever its value changes, we can call `observe(_ observee, for keyPath)`.

### CoreJS

Inside `Anna.Manager` there is a tiny NodeJS environment called CoreJS.
It is so tiny that only the basic `require` function (includes cache) is implemented. 
CoreJS starts running by `requrie`-ing the entrance module, of which the URL is passed in via the first parameter of method `run`, and returns the `exports`.
`Anna.Core` is just a normal module `require`-ed in the entrance module, of which the constructor is assigned to the `exports` and finally called by `Anna.Manager`.

CoreJS's behavior can be configured via following attributes of `CoreJS.Dependency`:

| Attribute | Description |
| --- | --- |
| `handleException` | The closure to receive uncaught exception. |
| `logger` | The delegate to receive message passed to `console.log`. |
| `nodePathURLs` | Same with `NODE_PATH`. CoreJS will search those URLs for modules if they are not found elsewhere. |
| `fileManager` | Base on this `fs` is implemented. Defaults to `FileManager.defaultManager` if not set. |
| `coreModuleURL` | Where the JavaScript part of CoreJS is located. Defaults to `main/bundle/corejs.bundle` |

### Debug

