//
//  NetworkMocking.swift
//  Weather15Tests
//
//  Created by Quân Đinh on 09.11.24.
//

import XCTest
@testable import Weather15

class MockURLProtocol: URLProtocol {
  static var response: (data: Data?, urlResponse: HTTPURLResponse?, error: Error?)?
  
  override class func canInit(with request: URLRequest) -> Bool {
    true
  }
  
  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }
  
  override func startLoading() {
    defer {
      client?.urlProtocolDidFinishLoading(self)
    }
    guard let _ = request.url else {
      client?.urlProtocol(self, didFailWithError: NetworkError.badUrl)
      return
    }
    
    guard let (data, urlResponse, error) = Self.response else {
      client?.urlProtocol(self, didFailWithError: NetworkError.transportError)
      return
    }
    
    if let error {
      client?.urlProtocol(self, didFailWithError: error)
      return
    }
    
    if let urlResponse {
      client?.urlProtocol(
        self,
        didReceive: urlResponse,
        cacheStoragePolicy: .notAllowed
      )
    }
    
    if let data {
      client?.urlProtocol(self, didLoad: data)
    }
  }
  
  override func stopLoading() {}
}
