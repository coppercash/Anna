From:[libextobjc](https://github.com/jspahrsummers/libextobjc)

The Extended Objective-C library extends the dynamism of the Objective-C programming language to support additional patterns present in other programming languages (including those that are not necessarily object-oriented).

libextobjc is meant to be very modular – most of its classes and modules can be used with no more than one or two dependencies.

# Features

libextobjc currently includes the following features:

 * **Safe categories**, using EXTSafeCategory, for adding methods to a class without overwriting anything already there (identifying conflicts for you).
 * **Concrete protocols**, using EXTConcreteProtocol, for providing default implementations of the methods in a protocol.
 * **Simpler and safer key paths**, using EXTKeyPathCoding, which automatically checks key paths at compile-time.
 * **Compile-time checking of selectors** to ensure that an object declares a given selector, using EXTSelectorChecking.
 * **Easier use of weak variables in blocks**, using `@weakify`, `@unsafeify`, and `@strongify` from the EXTScope module.
 * **Scope-based resource cleanup**, using `@onExit` in the EXTScope module, for automatically cleaning up manually-allocated memory, file handles, locks, etc., at the end of a scope.
 * **Algebraic data types** generated completely at compile-time, defined using EXTADT.
 * **Synthesized properties for categories**, using EXTSynthesize.
 * **Block-based coroutines**, using EXTCoroutine.
 * **EXTNil, which is like `NSNull`, but behaves much more closely to actual `nil`** (i.e., doesn't crash when sent unrecognized messages).
 * **Lots of extensions** and additional functionality built on top of `<objc/runtime.h>`, including extremely customizable method injection, reflection upon object properties, and various functions to extend class hierarchy checks and method lookups.

The [experimental](https://github.com/jspahrsummers/libextobjc/tree/experimental)
branch contains additional features that may be interesting, but are not
considered stable or safe for production use. Check out the headers for more
information.


# Adding to your project


# License

Released under the MIT License. See the
[LICENSE](LICENSE)
file for more information.

# Requirements

libextobjc must be built with ARC enabled, and many of its macros require ARC in the calling files as well. MRC usage is not supported.
