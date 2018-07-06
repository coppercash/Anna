//
//  CollectionViewObserver.swift
//  Anna_iOS
//
//  Created by William on 2018/7/6.
//

import UIKit

protocol
OutSourcingView : class {
    associatedtype
    DataSource : NSObjectProtocol
    var
    dataSource :DataSource? { get set }
    associatedtype
    Delegate : NSObjectProtocol
    var
    delegate :Delegate? { get set }
}

protocol
OutSourcingKeys {
    static var
    dataSourceKey :UnsafeRawPointer { get }
    static var
    delegateSourceKey :UnsafeRawPointer { get }
}

// Why reseting flags
// https://github.com/BigZaphod/Chameleon/blob/master/UIKit/Classes/UITableView.m
//
class
    BaseCollectionViewObserver<
    Observee,
    DataSourceProxy,
    DelegateProxy,
    Keys,
    Decorator
    > : UIViewObserver<Observee>
    where
    Observee : UIView,
    Observee : OutSourcingView,
    DataSourceProxy : Proxy<Observee.DataSource>,
    DelegateProxy : Proxy<Observee.Delegate>,
    Keys : OutSourcingKeys,
    Decorator : NSObject
{
    override func
        observe(_ observee: Observee) {
        super.observe(observee)
        if let dataSource = observee.dataSource {
            let
            dataSourceProxy = DataSourceProxy.init(dataSource)
            observee.dataSource = dataSourceProxy as? Observee.DataSource
            let
            key = Keys.dataSourceKey
            objc_setAssociatedObject(
                dataSource,
                key,
                dataSourceProxy,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
        if let delegate = observee.delegate {
            let
            delegateProxy = DelegateProxy.init(delegate)
            observee.delegate = delegateProxy as? Observee.Delegate
            let
            key = Keys.delegateSourceKey
            objc_setAssociatedObject(
                delegate,
                key,
                delegateProxy,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    override func
        deobserve(_ observee: Observee) {
        super.deobserve(observee)
        if
            let
            delegateProxy = observee.delegate as? DelegateProxy,
            let
            delegate = delegateProxy.safeTarget
        {
            let
            key = Keys.delegateSourceKey
            objc_setAssociatedObject(
                delegate,
                key,
                nil,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            observee.delegate = delegate
        }
        if
            let
            dataSourceProxy = observee.dataSource as? DataSourceProxy,
            let
            dataSource = dataSourceProxy.safeTarget
        {
            let
            key = Keys.dataSourceKey
            objc_setAssociatedObject(
                dataSource,
                key,
                nil,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            observee.dataSource = dataSource
        }
    }
    class override var
    decorators :[AnyClass] {
        return super.decorators + [Decorator.self]
    }
}

class
    Proxy<Target : NSObjectProtocol> : NSObject
{
    private weak var
    _target :Target?
    var
    target :Target { return self._target! }
    var
    safeTarget :Target? { return self._target }
    required
    init(_ target :Target) {
        self._target = target
    }
    override func
        conforms(to aProtocol: Protocol) -> Bool {
        return self.target.conforms(to: aProtocol)
    }
    override func
        forwardingTarget(for aSelector: Selector!) -> Any? {
        return self.target
    }
    override func
        responds(to aSelector: Selector!) -> Bool {
        return type(of: self).instancesRespond(to: aSelector) ||
            self.target.responds(to: aSelector)
    }
}
