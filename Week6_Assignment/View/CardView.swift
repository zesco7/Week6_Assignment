//
//  CardView.swift
//  Week6_Assignment
//
//  Created by Mac Pro 15 on 2022/09/20.
//

import UIKit

//Safe Area Layout Guide 체크해제
//size type 변경: inferred -> freeform
//애플이 정해놓은 SFSymbol에 대해서만 preferred symbol configuration 적용가능(사이즈 등)
//뷰컨트롤러에 구애받지않고

/*Xml Interface Builder 커스텀 클래스 지정 방법
 1. UIView에 연결
 2. File's owner에 연결//상대적으로 자유도가 높고 확장성이 크다.
 */

//IB UI초기화 구문과 코드초기화 구문은 다르다.(IB UI초기화 구문: required init, 코드초기화 구문: ovveride init)

protocol A {
    func example()
    init()
}

class CardView: UIView {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var contentsLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    //클래스파일에 xib파일을 연결해주는 작업 필요: 클래스 파일이 xib파일의 File's Owner랑만 연결되어있고 하위 뷰랑은 연결 안되어있기 때문)
    required init?(coder: NSCoder) { //required 붙어있으면 프로토콜내에서 초기화 등록 된것임
        super.init(coder: coder)
        
        let view = UINib(nibName: "CardView", bundle: nil).instantiate(withOwner: self).first as! UIView //first는 xib파일안에 뷰 중 어떤 뷰를 쓸지 지정하는 의미
        view.frame = bounds
        view.backgroundColor = .lightGray
        self.addSubview(view) //CardView파일에 view를 추가해달라는 의미
    }
}
