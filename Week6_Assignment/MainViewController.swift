//
//  MainViewController.swift
//  Week6_Assignment
//
//  Created by Mac Pro 15 on 2022/09/20.
//

import UIKit

import Kingfisher

/*질문
 -. return collectionView == bannerCollectionView ? color.count : numberList[collectionView.tag].count에서 collectionView와 bannerCollectionView를 비교하는 이유? -> 해결: 뷰컨트롤러 안에 콜렉션뷰가 여러개이기 때문에 매개변수로 collectionView사용하여 케이스 구분
 */

/*포인트
 -. 하나의 프로토콜, 메서드에서 여러 컬렉션뷰의 delegate, datasource 연결해주어야 함.
 -. 삼항연산자 사용하면 테이블뷰행별 높이를 다르게 적용할 수 있다.
 */
class MainViewController: UIViewController {

    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var bannerCollectionView: UICollectionView!
    
    let color: [UIColor] = [.red, .systemPink, .lightGray, .yellow, .black]
    
    let numberList : [[Int]] = [
        [Int](100...110),
        [Int](55...75),
        [Int](5000...5006),
        [Int](50...56)
    ]
    
    var episodeList : [[String]] = []
    var titleList : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTableView.delegate = self
        mainTableView.dataSource = self

        bannerCollectionView.delegate = self
        bannerCollectionView.dataSource = self
        bannerCollectionView.register(UINib(nibName: "CardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CardCollectionViewCell")
        bannerCollectionView.collectionViewLayout = collectionViewLayout()
        bannerCollectionView.isPagingEnabled = true //디바이스 너비만큼 이동
        
        //이미지표시 위해 해야 할 일: 1.네트워크 통신 요청 2.배열생성, 데이터담기 3.뷰에 표현하기 4.네트워크 통신 완료 후 뷰 갱신
        TMDBAPIManager.shared.requestImage { posterImage in
            dump(posterImage)
            self.episodeList = posterImage //배열에 배열을 통째로 넣는다?
            self.titleList = TMDBAPIManager.shared.tvList.map { $0.0 } //싱글톤으로 tvList접근 후 튜플값 받아서 빈배열에 넣기
            self.mainTableView.reloadData()
        }
    }
}

//하나의 프로토콜, 메서드에서 여러 컬렉션뷰의 delegate, datasource 연결해주어야 함.(CardCollectionViewCell->MainViewController, contentCollectionView->MainTableViewCell)
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return color.count
        return collectionView == bannerCollectionView ? color.count : episodeList[collectionView.tag].count //콜렉션뷰 갯수를 collectionView.tag에 해당하는 numberList.count만큼 생성
    }
    
    //내부매개변수가 아닌 명확한 아울렛을 사용하는 경우, 셀을 재사용하게 되면 특정 collectionView를 재활용하게 될 수 있음.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath) as? CardCollectionViewCell else { return UICollectionViewCell() }
        
        //cell.cardView.posterImageView.backgroundColor = color[indexPath.item]
        if collectionView == bannerCollectionView {
            cell.cardView.posterImageView.backgroundColor = color[indexPath.item]
        } else {
            let url = URL(string: "\(TMDBAPIManager.shared.imageURL)\(episodeList[collectionView.tag][indexPath.item])")
            cell.cardView.posterImageView.kf.setImage(with: url)
            cell.cardView.contentsLabel.text = ""
            
            //cell.cardView.posterImageView.backgroundColor = collectionView.tag.isMultiple(of: 2) ? .systemGreen : .brown //태그를 사용하여 섹션별 이미지뷰색상 적용
            //cell.cardView.contentsLabel.textColor = .white
            // cell.cardView.contentsLabel.text = "\(numberList[collectionView.tag][indexPath.row])" //태그를 사용하여 섹션인덱스를 지정하고 indexPath를 사용하여 배열인덱스를 지정
        }
        
        return cell
    }
    
    //콜렉션뷰 레이아웃 설정
    func collectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main
            .bounds.width, height: bannerCollectionView.frame.height) //셀가로: 화면가로, 셀세로를 콜렉션뷰 세로만큼으로 지정
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return layout
    }
}

//테이블뷰 하나인경우 내부매개변수 활용하지 않아도 문제 발생하지 않음. 두개 이상이면 매개변수를 구분해주어야 함.
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return episodeList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //테이블뷰에서 콜렉션뷰를 사용하기 때문에 콜렉션뷰에 프로토콜 연결(delegate, datasource)을 해줘야한다.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("MainViewController", #function, indexPath)
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as? MainTableViewCell else { return UITableViewCell() }
        cell.backgroundColor = .yellow
        cell.contentCollectionView.backgroundColor = .lightGray
        cell.contentCollectionView.delegate = self
        cell.contentCollectionView.dataSource = self
        cell.contentCollectionView.register(UINib(nibName: "CardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CardCollectionViewCell")
        cell.contentCollectionView.tag = indexPath.section //태그 설정을 통해 섹션별 개별옵션 설정 가능
        cell.titleLabel.text = titleList[indexPath.section]
        //cell.titleLabel.text = "\(TMDBAPIManager.shared.tvList[indexPath.section].0)"
        //cell.contentCollectionView.contentMode = .scaleToFill
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
}


