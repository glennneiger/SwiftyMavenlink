//
//  JSONRequest.swift
//  JSONRequest
//
//  Created by Eneko Alonso on 9/12/14.
//  Copyright (c) 2014 Hathway. All rights reserved.
//

import Foundation

public typealias JSONObject = Dictionary<String, AnyObject?>

public enum JSONError: ErrorType {
    case InvalidURL
    case PayloadSerialization

    case RequestFailed
    case NonHTTPResponse
    case ResponseDeserialization
    case UnknownError
}

public enum JSONResult {
    case Success(data: AnyObject?, response: NSHTTPURLResponse)
    case Failure(error: JSONError, response: NSHTTPURLResponse?, body: String?)
}

public extension JSONResult {

    public var data: AnyObject? {
        switch self {
        case .Success(let data, _):
            return data
        case .Failure:
            return nil
        }
    }

    public var arrayValue: [AnyObject] {
        return data as? [AnyObject] ?? []
    }

    public var dictionaryValue: [String: AnyObject] {
        return data as? [String: AnyObject] ?? [:]
    }

    public var httpResponse: NSHTTPURLResponse? {
        switch self {
        case .Success(_, let response):
            return response
        case .Failure(_, let response, _):
            return response
        }
    }

    public var error: ErrorType? {
        switch self {
        case .Success:
            return nil
        case .Failure(let error, _, _):
            return error
        }
    }

}

public class JSONRequest {

    private(set) var request: NSMutableURLRequest?

    public var httpRequest: NSMutableURLRequest? {
        return request
    }

    public init() {
        request = NSMutableURLRequest()
    }

    // MARK: Non-public business logic (testable but not public outside the module)

    func submitAsyncRequest(method: JSONRequestHttpVerb, url: String,
                            queryParams: JSONObject? = nil, payload: AnyObject? = nil,
                            headers: JSONObject? = nil, complete: (result: JSONResult) -> Void) {
        updateRequestUrl(method, url: url, queryParams: queryParams)
        updateRequestHeaders(headers)
        updateRequestPayload(payload)

        let task = NSURLSession.sharedSession().dataTaskWithRequest(request!) {
            (data, response, error) in
            if error != nil {
                let result = JSONResult.Failure(error: JSONError.RequestFailed,
                                                response: response as? NSHTTPURLResponse,
                                                body: self.bodyStringFromData(data))
                complete(result: result)
                return
            }
            let result = self.parseResponse(data, response: response)
            complete(result: result)
        }
        task.resume()
    }

    func submitSyncRequest(method: JSONRequestHttpVerb, url: String, queryParams: JSONObject? = nil,
                           payload: AnyObject? = nil, headers: JSONObject? = nil) -> JSONResult {

        let semaphore = dispatch_semaphore_create(0)
        var requestResult: JSONResult = JSONResult.Failure(error: JSONError.RequestFailed,
                                                           response: nil, body: nil)
        submitAsyncRequest(method, url: url, queryParams: queryParams, payload: payload,
                           headers: headers) { result in
                            requestResult = result
                            dispatch_semaphore_signal(semaphore)
        }
        // Wait for the request to complete
        while dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW) != 0 {
            let intervalDate = NSDate(timeIntervalSinceNow: 0.01) // 10 milliseconds
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: intervalDate)
        }
        return requestResult
    }

    func updateRequestUrl(method: JSONRequestHttpVerb, url: String,
                          queryParams: JSONObject? = nil) {
        request?.URL = createURL(url, queryParams: queryParams)
        request?.HTTPMethod = method.rawValue
    }

    func updateRequestHeaders(headers: JSONObject?) {
        request?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request?.setValue("application/json", forHTTPHeaderField: "Accept")
        if let headers = headers {
            for (headerName, headerValue) in headers {
                if let unwrapped = headerValue {
                    request?.setValue(String(unwrapped), forHTTPHeaderField: headerName)
                }
            }
        }
    }

    func updateRequestPayload(payload: AnyObject?) {
        guard let payload = payload else {
            return
        }
        if NSJSONSerialization.isValidJSONObject(payload) {
            request?.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(payload, options: [])
        }
    }

    func createURL(urlString: String, queryParams: JSONObject?) -> NSURL? {
        let components = NSURLComponents(string: urlString)
        if queryParams != nil {
            if components?.queryItems == nil {
                components?.queryItems = []
            }
            for (key, value) in queryParams! {
                if let unwrapped = value {
                    let encoded = String(unwrapped)
                        .stringByAddingPercentEncodingWithAllowedCharacters(
                            .URLHostAllowedCharacterSet())
                    let item = NSURLQueryItem(name: key, value: encoded)
                    components?.queryItems?.append(item)
                } else {
                    let item = NSURLQueryItem(name: key, value: nil)
                    components?.queryItems?.append(item)
                }
            }
        }
        return components?.URL
    }

    func parseResponse(data: NSData?, response: NSURLResponse?) -> JSONResult {
        guard let httpResponse = response as? NSHTTPURLResponse else {
            return JSONResult.Failure(error: JSONError.NonHTTPResponse, response: nil, body: nil)
        }
        guard data != nil && data!.length > 0 else {
            return JSONResult.Success(data: nil, response: httpResponse)
        }
        let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: [.AllowFragments])
        guard json != nil else {
            return JSONResult.Failure(error: JSONError.ResponseDeserialization,
                                      response: httpResponse,
                                      body: String(data: data!, encoding: NSUTF8StringEncoding))
        }
        return JSONResult.Success(data: json!, response: httpResponse)
    }

    func bodyStringFromData(data: NSData?) -> String? {
        guard let data = data else {
            return nil
        }
        return String(data: data, encoding: NSUTF8StringEncoding)
    }

}
