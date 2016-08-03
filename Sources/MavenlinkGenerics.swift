//
//  MavenlinkGenerics.swift
//  SwiftyMavenlink
//
//  Created by Mike Maxwell on 6/24/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation


public protocol RESTApiParams {
    var queryParam: MavenlinkQueryParams { get }
    var paramName: String { get }
}

public enum GenericParams: RESTApiParams {
    case Only(_: Int)
    case Search(_: String)

    public var paramName: String {
        get {
            switch(self) {
            case .Only:
                return "only"
            case .Search:
                return "search"
            }
        }
    }

    public var queryParam: MavenlinkQueryParams {
        get {
            let value: AnyObject
            switch(self) {
            case .Only(let id):
                value = id
            case .Search(let searchString):
                value = searchString
            }
            return [self.paramName: value]
        }
    }
}

func paramsReducer(accumulator: MavenlinkQueryParams, current: RESTApiParams) -> MavenlinkQueryParams {
    var new = accumulator
    new += current.queryParam
    return new
}


/////////////////////
public protocol UniqueResource: Hashable {
    var id: Int? { get }
    var hashValue: Int { get }
}

public func ==<T where T:UniqueResource>(lhs: T, rhs: T) -> Bool {
    return lhs.id == rhs.id
}

func resourceHash<T where T:UniqueResource>(arg: T) -> Int {
    return arg.id ?? 0
}

/////////////////////
public protocol MavenlinkResource {
    static var resourceName: String { get }
}

public protocol MavenlinkResultSet {
    associatedtype Result: MavenlinkResource
}
