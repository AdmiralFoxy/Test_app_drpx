//
//  Publisher+Ext.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 02/09/2023.
//

import Combine

extension Publisher {
    
    func call<T: AnyObject>(_ object: T, _ selector: @escaping (T) -> () -> Void) -> AnyCancellable {
        return sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak object] _ in
                if let object = object {
                    selector(object)()
                }
            }
        )
    }
    
    func call<T: AnyObject>(_ object: T, _ selector: @escaping (T) -> (Output) -> Void) -> AnyCancellable {
        return sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak object] value in
                if let object = object {
                    selector(object)(value)
                }
            }
        )
    }
    
    func weakMapper<Object: AnyObject, Result>(
        _ object: Object,
        _ mapper: @escaping (Object) -> (Output) -> Result
    ) -> AnyPublisher<Result, Failure> {
        return compactMap { [weak object] value in
            guard let object = object else { return nil }
            return mapper(object)(value)
        }
        .eraseToAnyPublisher()
    }
    
}
