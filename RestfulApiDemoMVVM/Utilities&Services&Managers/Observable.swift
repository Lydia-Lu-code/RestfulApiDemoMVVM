//
//  Observable.swift
//  RestfulApiDemoMVVM
//
//  Created by Lydia Lu on 2024/11/3.
//

import Foundation

// MARK: - Observable.swift
class Observable<T> {
    private var observers = [((T) -> Void)]()
    
    var value: T {
        didSet {
            notifyObservers()
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ observer: @escaping (T) -> Void) {
        observers.append(observer)
        observer(value)
    }
    
    private func notifyObservers() {
        observers.forEach { $0(value) }
    }
}
