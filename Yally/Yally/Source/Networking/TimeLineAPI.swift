//
//  TimeLineAPI.swift
//  Yally
//
//  Created by 이가영 on 2020/10/19.
//

import Foundation
import RxSwift

class TimeLineAPI {

    private let httpClient = HTTPClient()

    func getTimeLine() -> Observable<StatusCode> {
        httpClient.get(.timeLine, params: nil).map {
            response, _ -> StatusCode in
            switch response.statusCode {
            case 200:
                return .ok
            case 404:
                return .noHere
            default:
                return .fault
            }
        }
    }

    func createPost(_ sound: String, _ content: String, _ img: String, _ hashtag: String) -> Observable<StatusCode> {
        httpClient.post(.createPost, params: ["sound":sound, "content":content, "img":img, "hashtag":hashtag]).map { response, _  -> StatusCode in
            switch response.statusCode {
            case 201:
                return .ok1
            default:
                return .fault
            }
        }
    }

    func postDetailPost() -> Observable<StatusCode> {
        httpClient.post(.detailPost, params: nil).map { response, _ -> StatusCode in
            switch response.statusCode {
            case 200:
                return .ok
            case 404:
                return .noHere
            default:
                return .fault
            }
        }
    }

    func postDetailComment() -> Observable<StatusCode> {
        httpClient.get(.detailPostComment, params: nil).map {response, _ -> StatusCode in
            switch response.statusCode {
            case 200:
                return .ok
            default:
                return .fault
            }
        }
    }

    func deletePost() -> Observable<StatusCode> {
        httpClient.delete(.deletePost, params: nil).map {response, _ -> StatusCode in
            switch response.statusCode {
            case 204:
                return .ok
            case 404:
                return .noHere
            default:
                return .fault
            }
        }
    }

    func updatePost(_ sound: String, _ content: String, _ img: String, _ hashtag: String) -> Observable<StatusCode> {
        httpClient.put(.updatePost, params: ["sound":sound, "content":content, "img":img, "hashtag":hashtag]).map {response, _ -> StatusCode in
            switch response.statusCode {
            case 201:
                return .ok1
            case 404:
                return .noHere
            default:
                return .fault
            }
        }
    }
    
    func postComment(_ file: String, _ content: String) -> Observable<StatusCode> {
        httpClient.post(.postComment, params: ["file":file, "content":content]).map {response, _ -> StatusCode in
            switch response.statusCode {
            case 201:
                return .ok1
            case 404:
                return .noHere
            default:
                return .fault
            }
        }
    }
    
    func deleteComment() -> Observable<StatusCode> {
        httpClient.delete(.deleteComment, params: nil).map {response, _ -> StatusCode in
            switch response.statusCode {
            case 204:
                return .ok
            case 404:
                return .noHere
            default:
                return .fault
            }
        }
    }
    
    func postYally() -> Observable<StatusCode> {
        httpClient.get(.postYally, params: nil).map {response, _ -> StatusCode in
            switch response.statusCode {
            case 200:
                return .ok
            case 404:
                return .noHere
            default:
                return .fault
            }
        }
    }
    
    func deleteYally() -> Observable<StatusCode> {
        httpClient.delete(.cancelYally, params: nil).map {response, _ -> StatusCode in
            switch response.statusCode {
            case 204:
                return .ok
            case 404:
                return .noHere
            default:
                return .fault
            }
        }
    }
}
