
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

### Analyzer & Root

### Manager & Config

### Task & Node

### Available Events

### Observe & Update

### CoreJS

## To-do

