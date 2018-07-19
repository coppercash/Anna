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
    delegateKey :UnsafeRawPointer { get }
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
    weak var
    safeObservee :Observee?
    required
    init(
        observee: Observee
        ) {
        super.init(
            observee: observee
        )
        self.safeObservee = observee
    }
    func
        resolvedDataSourceProxy(
        _ dataSource :Observee.DataSource
        ) -> DataSourceProxy {
        let
        key = Keys.dataSourceKey
        if
            let
            proxy = objc_getAssociatedObject(
                dataSource,
                key
                ) as? DataSourceProxy
        { return proxy }
        let
        proxy = DataSourceProxy.init(dataSource)
        objc_setAssociatedObject(
            dataSource,
            key,
            proxy,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        return proxy
    }
    func
        resolvedDelegateProxy(
        _ delegate :Observee.Delegate
        ) -> DelegateProxy {
        let
        key = Keys.delegateKey
        if
            let
            proxy = objc_getAssociatedObject(
                delegate,
                key
                ) as? DelegateProxy
        { return proxy }
        let
        proxy = DelegateProxy.init(delegate)
        objc_setAssociatedObject(
            delegate,
            key,
            proxy,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        return proxy
    }
    override func
        observe(_ observee :Observee) {
        super.observe(observee)
        self.setProxies(on: observee)
    }
    func
        setProxies(on observee :Observee) {
        if let dataSource = observee.dataSource {
            observee.dataSource = self.resolvedDataSourceProxy(dataSource) as? Observee.DataSource
        }
        if let delegate = observee.delegate {
            observee.delegate = self.resolvedDelegateProxy(delegate) as? Observee.Delegate
        }
    }
    override func
        deobserve(_ observee :Observee) {
        super.deobserve(observee)
        if let observee = self.safeObservee {
            self.cleanProxies(on: observee)
        }
    }
    func
        cleanProxies(on observee :Observee) {
        if
            let
            delegateProxy = observee.delegate as? DelegateProxy,
            let
            delegate = delegateProxy.safeTarget
        {
            observee.delegate = delegate
        }
        if
            let
            dataSourceProxy = observee.dataSource as? DataSourceProxy,
            let
            dataSource = dataSourceProxy.safeTarget
        {
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
