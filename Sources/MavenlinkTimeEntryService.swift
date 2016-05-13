//
//  MavenlinkTimeEntryService.swift
//  SwiftyMavenlink
//
//  Created by Mike Maxwell on 5/10/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper

/// Class for TimeEntry resources in MavenLink
public class TimeEntry: MavenlinkObject {
    // i-vars
    public var id: String?
    public var created_at: NSDate?
    public var updated_at: NSDate?
    public var date_performed: NSDate?
    public var story_id: Int?
    public var time_in_minutes: Int?
    public var billable: Bool?
    public var notes: String?
    public var rate_in_cents: String?
    public var currency: String?
    public var currency_symbol: String?
    public var currency_base_unit: Int?
    public var user_can_edit: Bool?
    public var taxable: Bool?
    public var workspace_id: Int?
    public var user_id: Int?
    public var approved: Bool?

    override public class func resourceName() -> String {
        return "time_entries"
    }

    // Enums
    public enum Params: String {
        case WorkspaceId = "workspace_id"
        case BetweenDate = "date_performed_between"
    }

    public override func mapping(map: Map) {
        id <- map["id"]
        created_at <- (map["created_at"], LongDateFormatter)
        updated_at <- (map["updated_at"], LongDateFormatter)
        date_performed <- (map["date_performed"], ShortDateFormatter)
        story_id <- (map["story_id"], IntFormatter)
        time_in_minutes <- (map["time_in_minutes"], IntFormatter)
        billable <- map["billable"]
        notes <- map["notes"]
        rate_in_cents <- map["rate_in_cents"]
        currency <- map["currency"]
        currency_symbol <- map["currency_symbol"]
        currency_base_unit <- (map["currency_base_unit"], IntFormatter)
        user_can_edit <- map["user_can_edit"]
        taxable <- map["taxable"]
        workspace_id <- (map["workspace_id"], IntFormatter)
        user_id <- (map["user_id"], IntFormatter)
        approved <- map["approved"]
    }
}

// MARK: - REST operations
public class TimeEntryService {
    public class func get(workspace: String?, startDate: NSDate?, endDate: NSDate?) -> MavenlinkResponse<TimeEntry> {
        var params: MavenlinkQueryParams = [:]
        if let workspaceId = workspace {
            params[TimeEntry.Params.WorkspaceId.rawValue] = workspaceId
        }
        if let start = startDate, end = endDate {
            let formatter = MavenlinkLongDateTransform()
            params[TimeEntry.Params.BetweenDate.rawValue] = "\(formatter.transformToJSON(start)):\(formatter.transformToJSON(end))"
        }

        return MavenlinkResponse<TimeEntry>(resource: TimeEntry.resourceName(), params: params)
    }
}