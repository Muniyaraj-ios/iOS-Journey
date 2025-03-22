//
//  NetworkParams.swift
//  iOS Journey
//
//  Created by Munish on  19/03/25.
//

import Foundation

public struct NetworkParams{
    var baseURL: APIURL
    var endPoint: APIEndPoints
    var method: HTTPMethod
    var parameters: Parameters?
    var mimeType: MimeType? = nil
    //var headers: HTTPHeaders?
    var encodingType: EncodingType = .URLEncoding
    
}

public enum EncodingType{
    case URLEncoding
    case JSONEncoding
    case MultiPart
}

public enum APIRequestSendType{
    case normal
    case image
    case video
}

extension NetworkParams{
    
    func generateURLRequest() throws -> URLRequest?{
        
        guard let urlString = URL(string: baseURL.rawValue + endPoint.endPath) else{ return nil }
        
        var request = URLRequest(url: urlString)
        
        request.httpMethod = method.rawValue
        
        if var parameters = parameters{
            
            // for privacy
            parameters.merge(PrivateKeys.privacyCredential){ _,params  in  params}
            parameters.merge(PrivateKeys.privacyLanguage){ _,params  in  params}
                                    
            switch encodingType {
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
                guard let mimeType = mimeType else{
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
        switch encodingType {
        case .URLEncoding:
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            break
        case .JSONEncoding:
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            break
        case .MultiPart:
            break
        }
        request.setValue(PrivateKeys.pexels_private_key, forHTTPHeaderField: "Authorization")
        //print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        return request
    }
    
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
