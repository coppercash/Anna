
# Anna

[![Build Status](https://img.shields.io/travis/coppercash/Anna/master.svg)](https://travis-ci.org/coppercash/Anna)
[![codecov.io](https://codecov.io/gh/coppercash/Anna/branch/master/graphs/badge.svg)](https://codecov.io/github/coppercash/Anna)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Anna.svg)](https://cocoapods.org/pods/Anna)
![Platform](https://img.shields.io/cocoapods/p/Anna.svg)
![License MIT](https://img.shields.io/cocoapods/l/Anna.svg)
![Language](https://img.shields.io/badge/language-Swift%20|%20ObjC-green.svg)

Anna offers an abstraction layer which helps separate the analytic code from other code.

There are two parts in Anna:

1. **Anna.iOS** provides a class named `Analyzer` which plays like a view model in MVVM. It hooks event callbacks from `UIResponder` (also its subclasses) then exposes what it receives to Anna.Core.
2. **Anna.Core** is in JavaScript. It identities every `UIResponder` exposed with a unique path. When events happen on nodes in a path, it runs the registered tasks to 'dig' what happened on the nodes (and up along the path). 

Finally results are sent back to Anna.iOS, where the results could be uploaded a remote server or some analytic service providers.


## How to Use

### Basic Usage

For example, if we want to track the touch-up-inside event from a button on the bottom of our home view controller, we need to register such a task:

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
        self.analyzer.enable(with: "home")
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
    func receive(
        analyticsResult :Any,
        dispatchedBy manager :Manager
    ) {
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

We can notice that some nodes in the tree above have a `Anna.Analyzer` as instance member. With the names given to the analyzers, in **Anna.Core**, this tree results in another tree which is slightly different:

```
app/
└── home/
    └── table/
        └── cell/
            └── delail/
                └── button/
```

The major different starts from node **detail** which belongs to the `MyDetailViewController`. In the **Responder Chain** provided by `UIKit`, the next responder (parent in the tree) of `MyDetailViewController`, is the `UINavigationController`. However, in **Anna.Core**, the parent of **detail** is **cell**, which means that user's focus moves from the **cell** to the **detail**. This behavior is because, from the aspect of analytics, the useful information for every single view usually belongs to the views user paid attention on before. Thus, in **Anna.Core** every path from the root to a node is actually a **Focus Path**.

#### Root Analyzer & Manager

`UIView`s, `UIViewController`s, `UIControl`s and all the other objects in Responder Chain may own a `Anna.Analyzer` if they are supposed to be analyzed, including the root responder - `UIApplicaiontDelegate`.
However, the analyzer of `UIApplicaiontDelegate` is slightly different. It is initialized with a `Anna.Manager`.
Manager acts like port between `Anna.iOS` and `Anna.Core`. It receives events from `Anna.iOS` and returns calculated results into delegate methods.

Config

### Super & Sub Analyzer 

Owner of a super analyzer can add sub analyzers to it by confirming protocol `Anna.AnalyzableObject` and implementing method `subAnalyzableKeys`. In this way, sub analyzers create sub nodes in focus path.

If a analyzer is not added by any other analyzer as sub analyzer, it looks up the responder chain for a super analyzer. In the looking up process, `Anna.FocusPathConstituting.parentConstitutor()` and `Anna.FocusPathConstitutionRedirecting.redirectedConstitutor()` are called to have detailed information about how the super-sub relationship is like. `UIResponder` and most of its subclasses have default implementation for these methods, but they can be override to support custom behavior.

### Task Registration

register

### Available Events

### Observe & Update

### CoreJS

## To-do

