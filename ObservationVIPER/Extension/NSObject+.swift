//
//  NSObject+.swift
//  ObservationVIPER
//
//  Created by sakiyamaK on 2024/09/21.
//

import Foundation

public protocol Observablable: NSObject {}
public extension Observablable {
    @discardableResult
    func observation<T>(
        tracking: @escaping (() -> T),
        onChange: @escaping ((Self, T) -> Void),
        shouldStop: (() -> Bool)? = nil,
        useInitialValue: Bool = true,
        mainThread: Bool = true
    ) -> Self {
        
        @Sendable func process() {
            onChange(self, tracking())
            
            if let shouldStop, shouldStop() {
                return
            }
            
            self.observation(
                tracking: tracking,
                onChange: onChange,
                shouldStop: shouldStop,
                useInitialValue: useInitialValue,
                mainThread: mainThread
            )
        }
        
        if useInitialValue {
            onChange(self, tracking())
        }
        
        _ = withObservationTracking({
            tracking()
        }, onChange: {
            if mainThread {
                Task { @MainActor in
                    process()
                }
            } else {
                process()
            }
        })
        return self
    }
}

extension NSObject: Observablable { }
