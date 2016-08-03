//
//  Users.swift
//  SwiftyMavenlink
//
//  Created by Mike Maxwell on 6/17/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

public struct UsersResultSet: Mappable, MavenlinkResultSet {
    public typealias Result = Users

    public private(set) var results: [Result]?

    public init?(_ map: Map) { }

    mutating public func mapping(map: Map) {
        results <- map["users"]
    }
}

public struct Users: Mappable, MavenlinkResource, UniqueResource {
    public private(set) var full_name: String?
    public private(set) var photo_path: NSURL?
    public private(set) var email_address: String?
    public private(set) var headline: String?
    public private(set) var account_id: Int?
    public private(set) var id: Int?

    public var hashValue: Int { get { return resourceHash(self) } }

    public init?(_ map: Map) { }

    public static var resourceName: String { get { return "users" } }
    public static var searchable: Bool { get { return false } }

    mutating public func mapping(map: Map) {
        full_name <- map["full_name"]
        photo_path <- (map["photo_path"], URLFormatter)
        email_address <- map["email_address"]
        headline <- map["headline"]
        account_id <- (map["account_id"], IntFormatter)
        id <- (map["id"], IntFormatter)
    }
}

extension Users {
    // Enums
    public enum Params: RESTApiParams {
        // bool
        case OnMyAccount
        // only return users that are active participants in the given Workspace
        case ParticipantIn(workspaceId: Int)
        // only return users that are on the given Account. This filter is not available in conjunction with the on_my_account option.
        case ByAccount(accountId: Int)
        // only return users that are in at least one Workspace as a consultant
        case ConsultantsOnly(enabled: Bool)
        // only return users that are in at least one Workspace as a client
        case ClientsOnly(enabled: Bool)
        // Get a specific user
        case SpecificUsers(userIds: [Int])

        public var paramName: String {
            get {
                switch(self) {
                case .OnMyAccount:
                    return "on_my_account"
                case .ParticipantIn:
                    return "participant_in"
                case .ByAccount:
                    return "account_id"
                case .ConsultantsOnly:
                    return "consultants_only"
                case ClientsOnly:
                    return "clients_only"
                case .SpecificUsers:
                    return "only"
                }
            }
        }

        public var queryParam: MavenlinkQueryParams {
            get {
                let value: AnyObject
                switch(self) {
                case .OnMyAccount:
                    value = true
                case .ParticipantIn(let id):
                    value = id
                case .ByAccount(let id):
                    value = id
                case .ConsultantsOnly:
                    value = true
                case ClientsOnly:
                    value = true
                case .SpecificUsers(let userIds):
                    value = userIds.toJSONString()
                }
                return [self.paramName: value]
            }
        }
    }
}

public class UserService: MavenlinkResourceService<UsersResultSet> {
    public class func getAccountUsers() -> PagedResultSet<Users> {
        return super.get([Users.Params.OnMyAccount])
    }

    public class func getSpecificUsers(userIds: [Int]) -> PagedResultSet<Users> {
        return super.get([Users.Params.SpecificUsers(userIds: userIds)])
    }
}