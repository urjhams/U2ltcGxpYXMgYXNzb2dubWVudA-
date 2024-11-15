//
//  NetworkingTest.swift
//  Weather15Tests
//
//  Created by Quân Đinh on 09.11.24.
//

import XCTest
@testable import Weather15

final class NetworkingTests: XCTestCase {
  
  struct SampleCodable: Codable, Equatable {
    var value: String
  }
  
  var network: Networking!
  var session: URLSession!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
  }
  
  override func setUp() {
    super.setUp()
    
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    session = URLSession(configuration: config)
    
    network = Networking()
  }
  
  override func tearDownWithError() throws {
    network = nil
    session = nil
    MockURLProtocol.response = nil
    try super.tearDownWithError()
  }
  
  override func tearDown() {
    network = nil
    session = nil
    MockURLProtocol.response = nil
    super.tearDown()
    
  }
}

extension NetworkingTests {
  
  func testSendPostRequest_BadUrlError() {
    let expectation = expectation(description: "Completion handler called")
    
    network.sendPostRequest(
      String.self,
      session: session,
      to: "invalid_url"
    ) { result in
      switch result {
      case .success:
        XCTFail("Expected failure, but got success.")
      case .failure(let error):
        XCTAssertEqual(error, .badUrl)
      }
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 0.5)
  }
  
  func testSendPostRequest_HttpServerSideError() {
    let responseData = "Server Error".data(using: .utf8)
    let response = HTTPURLResponse(
      url: URL(string: "https://example.com")!,
      statusCode: 500,
      httpVersion: nil,
      headerFields: nil
    )
    MockURLProtocol.response = (data: responseData, urlResponse: response, error: nil)
    
    let expectation = expectation(description: "Completion handler called")
    
    network.sendPostRequest(
      String.self,
      session: session,
      to: "https://example.com"
    ) { result in
      switch result {
      case .success:
        XCTFail("Expected failure, but got success.")
      case .failure(let error):
        if case .httpSeverSideError(let data, let statusCode) = error {
          XCTAssertEqual(data, responseData)
          XCTAssertEqual(statusCode, .internalServerError)
        } else {
          XCTFail("Expected HTTP server-side error.")
        }
      }
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 0.5)
  }
  
  func testSendPostRequest_TransportError() {
    let transportError = NetworkError.transportError
    MockURLProtocol.response = (data: nil, urlResponse: nil, error: transportError)
    
    let expectation = expectation(description: "Completion handler called")
    
    network.sendPostRequest(
      String.self, 
      session: session, 
      to: "https://example.com"
    ) { result in
      switch result {
      case .success:
        XCTFail("Expected failure, but got success.")
      case .failure(let error):
        XCTAssertEqual(error, .transportError)
      }
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 0.5)
  }
  
  func testRequestParam() {
    let token = "JustTheToken"
    let object = SampleCodable(value: token)
    let response = HTTPURLResponse(
      url: URL(string: "https://example.com")!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: ["Authorization" : "Bearer \(token)"]
    )
    
    MockURLProtocol.response = (data: try! object.toJSON(), urlResponse: response, error: nil)
    
    let expectation = expectation(description: "Completion handler called")
    
    network.sendPostRequest(
      SampleCodable.self,
      session: session,
      to: "https://example.com",
      withBearerToken: token
    ) { result in
      switch result {
      case .success (let data):
        XCTAssertEqual(data.value, token)
      case .failure:
        XCTFail("Expected success, but got failure.")
      }
      expectation.fulfill()
    }
    waitForExpectations(timeout: 0.5)
  }
  
  func testSendPostRequest_Success() {
    let string = "{\"key\":\"value\"}"
    let object = SampleCodable(value: string)
    let response = HTTPURLResponse(
      url: URL(string: "https://example.com")!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    )
    
    MockURLProtocol.response = (
      data: try! object.toJSON(),
      urlResponse: response, error: nil
    )
    
    let expectation = expectation(description: "Completion handler called")

    network.sendPostRequest(
      SampleCodable.self,
      session: session,
      to: "https://example.com",
      parameters: ["key": "value"]
    ) { result in
      switch result {
      case .success(let data):
        XCTAssertEqual(data, object)
      case .failure:
        XCTFail("Expected success, but got failure.")
      }
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 0.5)
  }
}
