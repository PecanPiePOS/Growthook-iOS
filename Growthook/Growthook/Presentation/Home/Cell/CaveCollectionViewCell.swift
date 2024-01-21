//
//  CaveCollectionViewCell.swift
//  Growthook
//
//  Created by KJ on 11/10/23.
//

import UIKit

import SnapKit
import Then

final class CaveCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let caveImageView = UIImageView()
    private let caveTitle = UILabel()
    
    // MARK: - Properties
    
    var caveId: Int?
    
    // MARK: - View Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CaveCollectionViewCell {
    
    // MARK: - UI Components Property
    
    private func setUI() {
        
        backgroundColor = .clear
        
        caveImageView.do {
            $0.image = ImageLiterals.Home.img_cave
            $0.makeCornerRound(radius: 18)
        }
        
        caveTitle.do {
            $0.font = .fontGuide(.detail2_reg)
            $0.textColor = .white000
        }
    }
    
    // MARK: - Layout Helper
    
    private func setLayout() {
        
        addSubviews(caveImageView, caveTitle)
        
        caveImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(6)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(SizeLiterals.Screen.screenHeight * 64 / 812)
        }
        
        caveTitle.snp.makeConstraints {
            $0.top.equalTo(caveImageView.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Methods
    
    func configureCell(_ model: CaveListResponseDto) {
        caveTitle.text = model.caveName
        caveId = model.caveId
        setCaveImage(model.caveImageIndex)
    }
    
    
    private func setCaveImage(_ index: Int) {
        let image: UIImage
        switch index {
        case 0:
            image = ImageLiterals.Home.img_cave_pink
        case 1:
            image = ImageLiterals.Home.img_cave_night
        case 2:
            image = ImageLiterals.Home.img_cave_sunrise
        case 3:
            image = ImageLiterals.Home.img_cave_sunset
        default:
            return
        }
        caveImageView.image = image
    }
}
