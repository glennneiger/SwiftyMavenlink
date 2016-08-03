//
//  WorkspaceGroup.swift
//  SwiftyMavenlink
//
//  Created by Mike Maxwell on 6/28/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import ObjectMapper

public struct WorkspaceGroupResultSet: Mappable, MavenlinkResultSet {
    public typealias Result = WorkspaceGroup

    public private(set) var results: [Result]?
    public private(set) var workspaces: [Workspace]?

    public init?(_ map: Map) { }

    mutating public func mapping(map: Map) {
        results <- map["results"]
        workspaces <- map["workspaces"]
    }
}

public struct WorkspaceGroup: Mappable, MavenlinkResource, UniqueResource {
    public private(set) var id: Int?
    public private(set) var name: String?
    public private(set) var company: Bool?
    public private(set) var created_at: NSDate?
    public private(set) var updated_at: NSDate?
    public private(set) var workspace_ids: [Int]?

    public var hashValue: Int { get { return resourceHash(self) } }

    public init?(_ map: Map) { }

    public static var resourceName: String { get { return "workspace_groups" } }

    mutating public func mapping(map: Map) {
        id <- (map["id"], IntFormatter)
        name <- map["name"]
        company <- map["company"]
        created_at <- (map["created_at"], LongDateFormatter)
        updated_at <- (map["updated_at"], LongDateFormatter)
        workspace_ids <- (map["workspace_ids"], IntArrayFormatter)
    }
}

extension WorkspaceGroup {
    public enum Params: RESTApiParams {
        /// Include the workspace IDs contained in each group in the response. 
        case IncludeWorkspaces

        public var paramName: String {
            get {
                switch(self) {
                case .IncludeWorkspaces:
                    return "include"
                }
            }
        }

        public var queryParam: MavenlinkQueryParams {
            get {
                let value: AnyObject
                switch(self) {
                case .IncludeWorkspaces:
                    value = "workspaces"
                }
                return [self.paramName: value]
            }
        }
    }
}


public class WorkspaceGroupService: MavenlinkResourceService<WorkspaceGroupResultSet> {
//    override public class func get(params: MavenlinkQueryParams? = WorkspaceGroup.Params.IncludeWorkspaces.queryParam) -> PagedResultSet<Resource> {
//        return PagedResultSet<Resource>(resource: Resource.resourceName, params: params)
//    }
}