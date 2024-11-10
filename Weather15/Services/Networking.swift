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
  case badFormat
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
    case .httpSeverSideError( _, let statusCode):
      return "There is a http server error with status code \(statusCode.rawValue)"
    case .badFormat:
      return "The response body is in the wrong format"
    }
  }
}

class Networking {
  
  /// shared instance of Network class
  static let shared = Networking()
  
  /// Call a POST request. All the error handlers will stop the function immidiately
  /// - Parameters:
  ///   - session: The URL session to use.
  ///   - url: plain string of the url.
  ///   - token: the bearer token
  ///   - params: http request body's parameters.
  ///   - completionHandler: Handling when completion, included success and failure
  public func sendPostRequest<T: Codable>(
    _ objectType: T.Type,
    session: URLSession = .shared,
    to url: String,
    withBearerToken token: String? = nil,
    parameters params: [String : Any?]? = nil,
    completionHandler: @escaping (Result<T, NetworkError>) -> ()
  ) {
    
    guard
      let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
      let url = URL(string: encodedUrl), UIApplication.shared.canOpenURL(url)
    else {
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
      let jsonParams = try? JSONSerialization.data(withJSONObject: params, options: [])
      request.httpBody = jsonParams
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
        
        DispatchQueue.main.async {
          completionHandler(.failure(.httpSeverSideError(responseBody, statusCode: statusCode)))
        }
        return
      }
      // success handling
      DispatchQueue.main.async {
        do {
          let object = try JSONDecoder().decode(objectType.self, from: responseBody)
          completionHandler(.success(object))
        } catch {
          completionHandler(.failure(.badFormat))
        }
      }
    }.resume()
  }
}
