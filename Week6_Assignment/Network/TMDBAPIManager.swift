//
//  TMDBAPIManager.swift
//  Week6_Assignment
//
//  Created by Mac Pro 15 on 2022/09/21.
//

import Foundation

import Alamofire
import SwiftyJSON

class TMDBAPIManager {
    static let shared = TMDBAPIManager()
    private init() { }
    
    let tvList = [
        ("환혼", 135157),
        ("이상한 변호사 우영우", 197067),
        ("인사이더", 135655),
        ("미스터 션사인", 75820),
        ("스카이 캐슬", 84327),
        ("사랑의 불시착", 94796),
        ("이태원 클라스", 96162),
        ("호텔 델루나", 90447)
    ]
    let imageURL = "https://image.tmdb.org/t/p/w500"
    
    func callRequest(query: Int, completionHandler: @escaping ([String]) -> () ) {
        print(#function)
        let seasonURL = "https://api.themoviedb.org/3/tv/\(query)/season/1?api_key=\(APIKey.tmdb)&language=ko-KR"
        
        AF.request(seasonURL, method: .get).validate().responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                var stillArray = Array<String>()
//                for data in json["episodes"].arrayValue {
//                    let still_path = data["still_path"].stringValue
//                    stillArray.append(still_path)
//                }
                
                let still_path = json["episodes"].arrayValue.map { $0["still_path"].stringValue } //map으로 반복문 대체
                
                print(stillArray)
                //dump(self.tvList) //배열갯수 안내, 이차원배열요소 표시(계층 데이터요소 다룰때 편리함)
                completionHandler(still_path) //json대신 배열화 시킨 still_path를 클로저 인자로 전달

            case .failure(let error):
                print(error)
            }
        }
    }
    
    //completionHandler반복문처리시 문제발생가능성있음: 1.통신결과 순서보장 안됨 2.통신 언제 끝날지 모름 3.서버에 요청제한 있으면 차단될수있음
    //첫번째 쿼리에만 self없는 이유? 클로저구문에 속해있으면 self로 구분해주어야 하는데 첫번째 쿼리는 클로저구문에 포함되지 않았기 때문
    //async,await사용하면 중괄호 적게쓰면서 처리할 수 있음
    //같은 클래스내부이지만 만들어둔 싱글톤패턴 사용해서 처리
    func requestImage(completionHandler: @escaping ([[String]]) -> ()) {
        
        var posterList: [[String]] = []
        
        TMDBAPIManager.shared.callRequest(query: tvList[0].1) { value in
            posterList.append(value)

            TMDBAPIManager.shared.callRequest(query: self.tvList[1].1) { value in
                posterList.append(value)

                TMDBAPIManager.shared.callRequest(query: self.tvList[2].1) { value in
                    posterList.append(value)
                   
                    TMDBAPIManager.shared.callRequest(query: self.tvList[3].1) { value in
                        posterList.append(value)
                     
                        TMDBAPIManager.shared.callRequest(query: self.tvList[4].1) { value in
                            posterList.append(value)
                           
                            TMDBAPIManager.shared.callRequest(query: self.tvList[5].1) { value in
                                posterList.append(value)
                                
                                TMDBAPIManager.shared.callRequest(query: self.tvList[6].1) { value in
                                    posterList.append(value)
                                    
                                    TMDBAPIManager.shared.callRequest(query: self.tvList[7].1) { value in
                                        posterList.append(value)
                                        completionHandler(posterList)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
