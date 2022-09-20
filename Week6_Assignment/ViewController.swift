//
//  ViewController.swift
//  Week6_Assignment
//
//  Created by Mac Pro 15 on 2022/09/17.
//

import UIKit

import Alamofire //KakaoAPIManager를 통해 싱글톤 사용하면 ViewController에서는 라이브러리 사용안해도 됨
import SwiftyJSON //KakaoAPIManager를 통해 싱글톤 사용하면 ViewController에서는 라이브러리 사용안해도 됨

/*포인트
 -. 파일 대신 클래스로 테이블뷰 셀 생성하여 연결 가능
 -. APIManager사용하여 네트워크 통신: 코드 반복 제거 가능
 -. 삼항연산자 사용하여 섹션별 다른 데이터 표시
 -. 문자열 대체 메서드 사용(replacingOccurrences): html tag 제거 가능
 -. 바버튼, 삼항연산자 사용하여 numberOfLines 조정
 */

class ViewController: UIViewController {
    
    var blogList: [String] = []
    var cafeList: [String] = []
    var isExpanded = false //false면 두줄, true면 0줄
    
    @IBOutlet weak var testTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testTableView.delegate = self
        testTableView.dataSource = self
        testTableView.rowHeight = UITableView.automaticDimension //모든 셀에 유동적사이즈 적용
        
        print(#function, "START")
        searchBlog() //viewDidLoad실행할 때 requestBlog메서드를 먼저 실행하고 화면을 띄운다. 그러면 그 상태에서 메서드는 실행됐으나 네트워크통신 데이터는 받지 않은 상태이므로 빈화면이 뜨는 것임. 그래서 화면 갱신을 해주어야함. 네트워크 요청 할 때 데이터크기에 따라서 어떤 데이터가 먼저 올지 알 수 없다.
        
    }
    
    @IBAction func expandCell(_ sender: UIBarButtonItem) {
        isExpanded = !isExpanded //기존 데이터에 다른 bool타입 데이터 대입
        testTableView.reloadData()
    }
    
    func searchBlog() {
        KakaoAPIManager.shared.callRequest2(type: .blog, query: "고래밥") { json in
            
            print(json)
            
            for item in json["documents"].arrayValue {
                self.blogList.append(item["contents"].stringValue)
            }
            
            self.searchCafe()
        }
    }
    
    func searchCafe() {
        KakaoAPIManager.shared.callRequest2(type: .cafe, query: "고래밥") { json in
            
            print(json)
            
            for item in json["documents"].arrayValue {
                //self.cafeList.append(item["contents"].stringValue)
                
                //html tag 삭제하려면?  1. html tag 기능 활용 <>, </> 2. 문자열 대체 메서드: replacingOccurrences
                let value = item["contents"].stringValue.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
                self.cafeList.append(value)
            }
            print(self.blogList)
            print(self.cafeList)
            
            self.testTableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 
        return section == 0 ? blogList.count : cafeList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "블로그 검색결과" : "카페 검색결과"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "kakaoCell", for: indexPath) as? kakaoCell else { return UITableViewCell() }
        
        cell.testLabel.numberOfLines = isExpanded ? 0 : 2
        cell.testLabel.text = indexPath.section == 0 ? blogList[indexPath.row] : cafeList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension //조건에 따라 셀에 유동적사이즈 적용(섹션별)
    }
}

class kakaoCell: UITableViewCell { //파일이 아니라 클래스로 테이블뷰 셀 생성하여 연결
    @IBOutlet weak var testLabel: UILabel!
}
