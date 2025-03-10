//
//  NetworkingManager.swift
//  iOS Journey
//
//  Created by MacBook on 02/01/25.
//

import UIKit
import Combine

protocol NetworkingService: AnyObject{
    func makeRequest<T: BaseSwiftJSON>(networkParam: NetworkParams)-> AnyPublisher<T, Error>
}

class NetworkingManager: NSObject, URLSessionDelegate, NetworkingService{
    
    private func generateURLRequest(networkParam: NetworkParams) throws -> URLRequest?{
        guard let urlString = URL(string: networkParam.baseURL.rawValue + networkParam.endPoint.rawValue) else{ return nil }
        
        var request = URLRequest(url: urlString)
        
        request.httpMethod = networkParam.method.rawValue
        
        if var parameters = networkParam.parameters{
            
            // for privacy
            parameters.merge(PrivateKeys.privacyCredential){ _,params  in  params}
            parameters.merge(PrivateKeys.privacyLanguage){ _,params  in  params}
            
            printRequestMessage(networkParam: networkParam, mergedParams: parameters)
                        
            switch networkParam.encodingType {
            case .URLEncoding:
                let paramString = parameters.compactMap { (key, value) in
                    return "\(key)=\(value)"
                }.joined(separator: "&")
                request.httpBody = paramString.data(using: .utf8)
                break
            case .JSONEncoding:
                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
                break
            case .MultiPart:
                guard let mimeType = networkParam.mimeType else{
                    throw MultiPartError.invalidMimeType
                }
                let boundary = "Boundary-\(UUID().uuidString)"
                
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                
                do{
                    let body = try createMultiPartBody(parameters: parameters, mimeType: mimeType, boundary: boundary)
                    request.httpBody = body
                }catch{
                    throw error
                }
                break
            }
        }
        switch networkParam.encodingType {
        case .URLEncoding:
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            break
        case .JSONEncoding:
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            break
        case .MultiPart:
            break
        }
        //  request.setValue("Yzk1ZTlkYzAt", forHTTPHeaderField: "Authorization")
        print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        return request
    }
    
    func makeRequest<T: BaseSwiftJSON>(networkParam: NetworkParams)-> AnyPublisher<T, Error>{
        do{
            guard let request = try generateURLRequest(networkParam: networkParam) else{
                return Fail(error: URLError(.badURL))
                    .eraseToAnyPublisher()
            }
            return performRequest(with: request)
        }catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    private func performRequest<T: BaseSwiftJSON>(with request: URLRequest)-> AnyPublisher<T, Error>{
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        return session.dataTaskPublisher(for: request)
            .tryMap { [weak self] output in
                guard let response = output.response as? HTTPURLResponse, 200..<299 ~= response.statusCode else{
                    throw URLError(.badServerResponse)
                }
                self?.printDataToJSON(data: output.data)
                return output.data
            }
            .tryMap{ data in
                let json = JSON_Local(data)
                return T.init(json: json)
            }
            //.decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    private func printDataToJSON(data: Data){
        #if DEBUG
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        print("JSON Response:\n\(jsonString)")
                    }
                } else {
                    print("Data is not a valid JSON object.")
                }
            } catch {
                print("Error converting Data to JSON: \(error.localizedDescription)")
            }
        #else
        #endif
    }
    
    private func printRequestMessage(networkParam: NetworkParams, mergedParams: Parameters?){
        #if DEBUG
            print("BaseURL : \(networkParam.baseURL.rawValue + networkParam.endPoint.rawValue)")
            print("Method : \(networkParam.method.rawValue)")
            if let mergedParams{
                print("Parameters : \(mergedParams)")
            }else{
                print("Empty Parameters")
            }
        #else
        #endif
    }
}

// upload image and video body
extension NetworkingManager{
    
    private func createMultiPartBody(parameters: Parameters, mimeType: MimeType, boundary: String) throws -> Data{
        var body = Data()
        
        for (key, value) in parameters {
            body.appendManual("--\(boundary)\r\n")
            body.appendManual("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendManual("\(value)\r\n")
        }
        
        body.appendManual("--\(boundary)\r\n")
        body.appendManual("Content-Disposition: form-data; name=\"\(mimeType.withName)\"; filename=\"\(mimeType.fileName)\"\r\n")
        body.appendManual("Content-Type: \(mimeType.fileType)\r\n\r\n")
        
        switch mimeType {
            case .image(let image):
                // Convert image to JPEG data
                guard let imageData = image.jpegData(compressionQuality: 0.7) else{
                    throw MultiPartError.invalidImageError
                }
                // Check file size
                if imageData.count > mimeType.fileSizeLimit{
                    throw MultiPartError.fileSizeExceeded
                }
                body.append(imageData)
            
            case .video(let url):
                // Add video data
                do{
                    let videoData = try Data(contentsOf: url)
                    // Check file size
                    if videoData.count > mimeType.fileSizeLimit{
                        throw MultiPartError.fileSizeExceeded
                    }
                    
                    body.append(videoData)
                }catch {
                    throw error
                }
        }
        
        body.appendManual("\r\n")
        
        // End boundary
        body.appendManual("--\(boundary)--\r\n")
        
        return body
    }
}

enum MultiPartError: Error{
    case invalidImageError
    case invalidVideoError
    case fileSizeExceeded
    case invalidMimeType
}

public enum MimeType{
    case image(image: UIImage)
    case video(url: URL)
    
    var fileType: String{
        switch self {
        case .image: return "image/jpeg"
        case .video: return "video/mov"
        }
    }
    
    var fileName: String{
        switch self {
        case .image: return "file.jpeg"
        case .video: return "video.mov"
        }
    }
    
    var withName: String{
        switch self {
        case .image: return "image"
        case .video: return "image"
        }
    }
    var withTypeName: String{
        switch self {
        case .image: return "image"
        case .video: return "video"
        }
    }
        
    var fileSizeLimit: Int{
        switch self{
        case .image: return 5 * 1024 * 1024
        case .video: return 5 * 1024 * 1024
        }
    }
}

extension Data {
    mutating func appendManual(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
