//
//  NetworkManager.swift
//  iOS Journey
//
//  Created by MacBook on 25/09/24.
//

import Foundation
import Combine

protocol PrepareURLService: AnyObject{
    func generateURLService(networkParam: NetworkParameters)-> URLRequest?
}

protocol MakeNetworkService: AnyObject{
    func makeRequest<T: Codable>(networkParam: NetworkParameters)-> AnyPublisher<T, Error>
}

protocol PerformNetworkService: AnyObject{
    func performRequest<T: Codable>(with request: URLRequest, useBackgroundSession: Bool)-> AnyPublisher<T, Error>
}

final class NetworkManager: NSObject, PrepareURLService, MakeNetworkService, PerformNetworkService{
    
    let defaultSession = URLSession.shared
    let backgroundSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.example.app.backgroundSession")
        return URLSession(configuration: configuration)
    }()

    
    func generateURLService(networkParam: NetworkParameters) -> URLRequest? {
        guard let urlString = URL(string: networkParam.baseURL.rawValue + networkParam.endPoints.rawValue) else{ return nil }
        var request = URLRequest(url: urlString)
        request.httpMethod = networkParam.method.rawValue
        if let headers = networkParam.headers{
            request.allHTTPHeaderFields = headers
        }
        if let param = networkParam.parameters{
            
            switch networkParam.encoding {
            case .URLEncoding:
                
                let parameterString = param.compactMap { (key, value) -> String in
                    return "\(key)=\(value)"
                }.joined(separator: "&")
                request.httpBody = parameterString.data(using: .utf8)
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                
            case .JSONEncoding:
                
                request.httpBody = try? JSONSerialization.data(withJSONObject: param)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
        }
        return request
    }
    
    func makeRequest<T: Decodable>(networkParam: NetworkParameters) -> AnyPublisher<T, Error>{
        guard let request = generateURLService(networkParam: networkParam) else{
           return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        return performRequest(with: request)
    }
    
    func performRequest<T: Decodable>(with request: URLRequest, useBackgroundSession: Bool = false) -> AnyPublisher<T, Error>{
        if useBackgroundSession {
            return performRequestInBackgroundSession(with: request)
        }
        return defaultSession.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, 200..<299 ~= response.statusCode else{
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func performRequestInBackgroundSession<T: Decodable>(with request: URLRequest) -> AnyPublisher<T, Error> {
        let delegate = BackgroundSessionDelegate()
        let task = backgroundSession.dataTask(with: request)
        task.resume()

        // Use Combine to handle the delegate's publisher
        return delegate.dataPublisher
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, 200..<299 ~= response.statusCode else{
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

}

extension NetworkManager: URLSessionTaskDelegate{
    
}
class BackgroundSessionDelegate: NSObject, URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate {

    var dataPublisher = PassthroughSubject<(data: Data, response: URLResponse), Error>()
    private var receivedData = Data()
    private var urlResponse: URLResponse?

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData.append(data)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        // Store the response
        self.urlResponse = response
        completionHandler(.allow) // Proceed with receiving data
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            dataPublisher.send(completion: .failure(error))
        } else if let response = urlResponse {
            // Send the collected data and response as a tuple
            dataPublisher.send((data: receivedData, response: response))
            dataPublisher.send(completion: .finished)
        } else {
            dataPublisher.send(completion: .failure(URLError(.unknown)))
        }
    }
}
