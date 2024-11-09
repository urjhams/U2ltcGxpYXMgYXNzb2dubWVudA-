//
//  Network.swift
//  Weather15
//
//  Created by Quân Đinh on 09.11.24.
//

import UIKit

enum NetworkError: Error, Equatable {
  case badUrl
  case transportError
  case httpSeverSideError(Data, statusCode: HTTPStatus)
}

enum HTTPStatus: Int {
  case success = 200
  
  case badRequest = 400
  case notAuthorized = 401
  case forbidden = 403
  case notFound = 404
  
  case internalServerError = 500
  
  case unknown = -1
  
  init(_ code: Int) {
    self = HTTPStatus.init(rawValue: code) ?? .unknown
  }
}

extension NetworkError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .badUrl:
      return "This seem not a vail url"
    case .transportError:
      return "There is a transport error"
    case .httpSeverSideError( _,let statusCode):
      return "There is a http server error with status code \(statusCode.rawValue)"
    }
  }
}

class Networking {
  
  /// shared instance of Network class
  static let shared = Networking()
  
  /// network handler closure
  typealias NetworkHandler = (Result<Data, NetworkError>) -> ()
  
  /// Call a POST request. All the error handlers will stop the function immidiately
  /// - Parameters:
  ///   - url: plain string of the url.
  ///   - token: the bearer token
  ///   - params: http request body's parameters.
  ///   - completionHandler: Handling when completion, included success and failure
  public func sendPostRequest(
    session: URLSession = .shared,
    to url: String,
    withBearerToken token: String? = nil,
    parameters params: [String : Any?]? = nil,
    completionHandler: @escaping NetworkHandler
  ) {
    
    guard
      let valid = URL(string: url), UIApplication.shared.canOpenURL(valid),
      let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    else {
      completionHandler(.failure(.badUrl))
      return
    }
    guard let url = URL(string: encodedUrl) else {
      // bad url
      completionHandler(.failure(.badUrl))
      return
    }
    var request = URLRequest(
      url: url,
      cachePolicy: .reloadIgnoringLocalCacheData,
      timeoutInterval: 60.0
    )
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let token = token {
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    if let params = params {
      do {
        let jsonParams = try JSONSerialization.data(withJSONObject: params, options: [])
        request.httpBody = jsonParams
      } catch  {
        debugPrint("Error: unable to add parameters to POST request.")
      }
    }
    
    session.dataTask(with: request) { (data, response, error) in
      if let error = error {
        // handle transport error
        DispatchQueue.main.async {
          completionHandler(.failure(.transportError))
          debugPrint(error.localizedDescription)
        }
        return
      }
      let response = response as! HTTPURLResponse
      let responseBody = data!
      
      let statusCode = HTTPStatus(response.statusCode)
      
      if statusCode != .success {
        // handle HTTP server-side error
        if let _ = String(bytes: responseBody, encoding: .utf8) { } else {
          // Otherwise print a hex dump of the body.
          debugPrint("hex dump of the body")
          debugPrint(responseBody as NSData)
        }
        
        DispatchQueue.main.async {
          completionHandler(.failure(.httpSeverSideError(responseBody, statusCode: statusCode)))
        }
        return
      }
      // success handling
      DispatchQueue.main.async {
        completionHandler(.success(responseBody))
      }
    }.resume()
  }
}
