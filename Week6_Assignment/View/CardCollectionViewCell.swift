//
//  CardCollectionViewCell.swift
//  Week6_Assignment
//
//  Created by Mac Pro 15 on 2022/09/20.
//

import UIKit

//CardView가 UIView속성이기 때문에 UIView를 추가해야함
class CardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cardView: CardView!
    
    //awakeFromNib: 셀재사용때마다 반복되지 않기 때문에 변하지 않는 UI설정가능
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    func setupUI() {
        cardView.backgroundColor = .clear
        cardView.posterImageView.backgroundColor = .lightGray
        cardView.layer.cornerRadius = 10
        cardView.likeButton.tintColor = .systemPink
        
    }
}
