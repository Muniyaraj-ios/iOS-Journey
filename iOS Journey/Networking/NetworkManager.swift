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
    func performRequest<T: Codable>(with request: URLRequest)-> AnyPublisher<T, Error>
}

final class NetworkManager: PrepareURLService, MakeNetworkService, PerformNetworkService{
    
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
    
    func performRequest<T: Decodable>(with request: URLRequest) -> AnyPublisher<T, Error>{
        return URLSession.shared.dataTaskPublisher(for: request)
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
