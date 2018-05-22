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
        return UIResponderObserver(observee: self, owned: false)
    }
    public func
        tokenByAddingOwnedObserver() -> Reporting {
        return UIResponderObserver(observee: self, owned: true)
    }
}

class
    UIResponderObserver<Observee> : HookingObserver<Observee>
    where Observee : UIResponder
{ }

struct VisibilityEvent : OptionSet {
    let rawValue: Int
    static let appeared = VisibilityEvent(rawValue: 1)
    static let reappeared = VisibilityEvent(rawValue: 2)
    static let disappeared = VisibilityEvent(rawValue: 4)
    var name :String {
        switch self {
        case .appeared:
            return "ana-appeared"
        case .reappeared:
            return "ana-reappeared"
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
    isVisible :Bool = false,
    times :Int = 0
    func
        visibilityEvent(
        with isVisible :Bool
        ) -> VisibilityEvent? {
        guard isVisible != self.isVisible
            else { return nil }
        if isVisible {
            if self.times > 0 {
                return .reappeared
            }
            else {
                return .appeared
            }
        }
        else {
            return .disappeared
        }
    }
    func
        record(
        _ isVisible :Bool
        ) {
        let
        e = self.visibilityEvent(with: isVisible)
        self.isVisible = isVisible
        if isVisible {
            self.times += 1
        }
        guard let
            event = e,
            self.activeEvents.contains(event)
            else { return }
        self.recorder?.recordEventOnPath(
            named: event.name,
            with: nil
        )
    }
}
