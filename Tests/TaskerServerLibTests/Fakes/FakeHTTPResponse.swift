//
//  FakeHTTPResponse.swift
//  TaskerServerLibTests
//
//  Created by Marcin Czachurski on 14.02.2018.
//

import Foundation
import PerfectHTTP
import PerfectNet
import Dobby
import SwiftProtobuf

class FakeHTTPResponse: HTTPResponse {

    var request: HTTPRequest = FakeHTTPRequest()
    var status: HTTPResponseStatus = HTTPResponseStatus.ok
    var isStreaming: Bool = false
    var bodyBytes: [UInt8] = []
    var headers: AnyIterator<(HTTPResponseHeader.Name, String)> = AnyIterator { return nil }

    let headerMock = Mock<(HTTPResponseHeader.Name)>()
    let headerStub = Stub<(HTTPResponseHeader.Name), String?>()

    let addHeaderMock = Mock<(HTTPResponseHeader.Name, String)>()
    let setHeaderMock = Mock<(HTTPResponseHeader.Name, String)>()
    let completedMock = Mock<()>()
    let nextMock = Mock<()>()

    init() {
        headerMock.expect(any())
        addHeaderMock.expect(any())
        setHeaderMock.expect(any())
        completedMock.expect(any())
        nextMock.expect(any())
    }

    func header(_ named: HTTPResponseHeader.Name) -> String? {
        headerMock.record(named)

        var value: String?
        do {
            value = try headerStub.invoke(named)
        } catch {
            print("Stub not exist!")
        }

        return value
    }

    func addHeader(_ named: HTTPResponseHeader.Name, value: String) -> Self {
        addHeaderMock.record((named, value))
        return self
    }

    func setHeader(_ named: HTTPResponseHeader.Name, value: String) -> Self {
        setHeaderMock.record((named, value))
        return self
    }

    func push(callback: @escaping (Bool) -> Void) {
        callback(false)
    }

    func completed() {
        completedMock.record(())
    }

    func next() {
        nextMock.record(())
    }
}

enum FakeHTTPResponseError: Error {
    case bodyIsEmpty
}

extension FakeHTTPResponse {

    var body: String? {
        if self.bodyBytes.count != 0 {
            return String(bytes: self.bodyBytes, encoding: .utf8)
        }

        return nil
    }

    func getObjectFromResponseBody<T>(_ type: T.Type) throws -> T where T: SwiftProtobuf.Message {
        if let json = self.body {
            return try T(jsonString: json)
        }

        throw FakeHTTPResponseError.bodyIsEmpty
    }
}
