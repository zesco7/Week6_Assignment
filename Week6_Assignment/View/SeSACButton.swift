//
//  SeSACButton.swift
//  Week6_Assignment
//
//  Created by Mac Pro 15 on 2022/09/20.
//

import UIKit

//@IBDesignable, @IBInspectable, @objc @escaping 등 @붙은애들을 swift attribute라고 함
/*@IBDesignable, @IBInspectable
 -. 객체속성적용 체크용도로 사용 가능
 -. @IBDesignable:IB컴파일 시점에 스토리보드에서 실시간으로 객체 속성 적용 확인 가능(처리시간에 따라 적용이 늦게 될 수도 있음)
 -. @IBInspectable: 스토리보드상에서 인스펙터 영역에 속성 설정할 수 있도록 해줌(버튼 클래스에 연결하면 원하는 속성을 적용할 수 있음)
 */

@IBDesignable class SeSACButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @IBInspectable var borderColor: UIColor {
        get { return UIColor(cgColor: layer.borderColor!) }
        set { layer.borderColor = newValue.cgColor }
    }

}
