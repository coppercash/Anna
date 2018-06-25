//
//  UIResponder+Hookable.swift
//  Anna_iOS
//
//  Created by William on 2018/5/7.
//

import UIKit

extension
UIResponder : Hookable {
    public func
        tokenByAddingObserver() -> Reporting {
        return UIResponderObserver(observee: self)
    }
}

class
    UIResponderObserver<Observee> : HookingObserver<Observee>
    where Observee : UIResponder
{ }

struct VisibilityEvent : OptionSet {
    let rawValue: Int
    static let appeared = VisibilityEvent(rawValue: 1)
    static let disappeared = VisibilityEvent(rawValue: 2)
    var name :String {
        switch self {
        case .appeared:
            return "ana-appeared"
        case .disappeared:
            return "ana-disappeared"
        default:
            return "ana-unknown"
        }
    }
    
}
class
    VisibilityRecorder : Reporting
{
    weak var
    recorder :Recording?
    let
    activeEvents :VisibilityEvent
    init(
        activeEvents :VisibilityEvent
        ) {
        self.activeEvents = activeEvents
    }
    var
    isVisible :Bool = false
    func
        visibilityEvent(
        with newValue :Bool,
        oldValue :Bool
        ) -> VisibilityEvent? {
        guard newValue != oldValue
            else { return nil }
        return newValue ? .appeared : .disappeared
    }
    func
        record(
        _ isVisible :Bool
        ) {
        let
        e = self.visibilityEvent(
            with: isVisible,
            oldValue: self.isVisible
        )
        self.isVisible = isVisible
        guard let
            event = e,
            self.activeEvents.contains(event)
            else { return }
        self.recorder?.recordEvent(
            named: event.name,
            with: nil
        )
    }
    func
        detach() {
        self.recorder = nil
    }
}
