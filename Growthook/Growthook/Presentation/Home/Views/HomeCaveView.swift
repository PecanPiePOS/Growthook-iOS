//
//  HomeCaveView.swift
//  Growthook
//
//  Created by KJ on 11/10/23.
//

import UIKit

import SnapKit
import Then
import RxCocoa
import RxSwift

final class HomeCaveView: BaseView {
    
    // MARK: - UI Components
    
    private let userLabel = UILabel()
    private let seedView = UILabel()
    private let seedImage = UIImageView()
    let seedCountLabel = UILabel()
    let notificationButton = UIButton()
    lazy var caveCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    lazy var caveEmptyView = UIView()
    private lazy var caveEmptyTextLabel = UILabel()
    private let caveLineView = UIView()
    let addCaveButton = UIButton()
    private let underLineView = UIView()
    private let flowLayout = UICollectionViewFlowLayout()
    
    // MARK: - Properties
    
    private let userName: String = UserDefaults.standard.string(forKey: I18N.Auth.nickname) ?? ""
    
    // MARK: - UI Components Property
    
    override func setStyles() {
        
        backgroundColor = .clear
        
        userLabel.do {
            $0.text = "\(userName)\(I18N.Home.userCave)"
            $0.font = .fontGuide(.head1)
            $0.textColor = .white000
        }
        
        seedView.do {
            $0.backgroundColor = .green400
            $0.makeCornerRound(radius: 28 / 2)
        }
        
        seedImage.do {
            $0.image = ImageLiterals.Component.icn_seed_light
        }
        
        seedCountLabel.do {
            $0.font = .fontGuide(.detail2_bold)
            $0.textColor = .white000
        }
        
        notificationButton.do {
            $0.setImage(ImageLiterals.Home.icn_noti_check, for: .normal)
        }
        
        caveCollectionView.do {
            $0.isScrollEnabled = true
            $0.backgroundColor = .clear
            $0.showsHorizontalScrollIndicator = false
        }
        
        caveLineView.do {
            $0.backgroundColor = .white000
        }
        
        addCaveButton.do {
            $0.setImage(ImageLiterals.Home.btn_add_cave, for: .normal)
        }
        
        underLineView.do {
            $0.backgroundColor = .gray400
        }
        
        flowLayout.do {
            $0.scrollDirection = .horizontal
            $0.itemSize = CGSize(width: (SizeLiterals.Screen.screenWidth * 86) / 375,
                                 height: (SizeLiterals.Screen.screenHeight * 96) / 812)
            $0.minimumLineSpacing = 0
            $0.minimumInteritemSpacing = 0
        }
        
        caveEmptyView.do {
            $0.backgroundColor = .clear
        }
        
        caveEmptyTextLabel.do {
            $0.text = I18N.Home.emptyCave
            $0.font = .fontGuide(.detail1_reg)
            $0.textColor = .gray200
        }
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        
        addSubviews(userLabel, seedView, notificationButton, caveCollectionView,
                    caveLineView, addCaveButton, underLineView,
                    caveEmptyView)
        seedView.addSubviews(seedImage, seedCountLabel)
        caveEmptyView.addSubviews(caveEmptyTextLabel)
        
        userLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.leading.equalToSuperview().inset(18)
        }
        
        notificationButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14)
            $0.trailing.equalToSuperview().inset(8)
            $0.size.equalTo(48)
        }
        
        seedView.snp.makeConstraints {
            $0.top.equalTo(userLabel)
            $0.trailing.equalTo(notificationButton.snp.leading).offset(2)
            $0.width.equalTo(61)
            $0.height.equalTo(28)
        }
        
        seedImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(11)
            $0.size.equalTo(19)
        }
        
        seedCountLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(seedImage.snp.trailing).offset(4)
        }
        
        addCaveButton.snp.makeConstraints {
            $0.top.equalTo(seedView.snp.bottom).offset(28)
            $0.trailing.equalToSuperview().inset(12)
            $0.size.equalTo(62)
        }
        
        caveLineView.snp.makeConstraints {
            $0.top.equalTo(addCaveButton)
            $0.trailing.equalTo(addCaveButton.snp.leading).offset(SizeLiterals.Screen.screenWidth * -18 / 375)
            $0.width.equalTo(1)
            $0.height.equalTo(62)
        }
        
        caveCollectionView.snp.makeConstraints {
            $0.top.equalTo(userLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(8)
            $0.trailing.equalTo(caveLineView.snp.leading).offset(-9)
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 96 / 812)
        }
        
        underLineView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        caveEmptyView.snp.makeConstraints {
            $0.top.equalTo(userLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(8)
            $0.trailing.equalTo(caveLineView.snp.leading).offset(-9)
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 96 / 812)
        }
        
        caveEmptyTextLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
    }
}
