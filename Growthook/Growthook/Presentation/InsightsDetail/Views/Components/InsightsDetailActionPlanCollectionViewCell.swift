//
//  InsightsDetailActionPlanCollectionViewCell.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/14/24.
//

import UIKit

import RxCocoa
import RxSwift

final class InsightsDetailActionPlanCollectionViewCell: UICollectionViewCell {
    
    private let seedImageView = UIImageView()
    private let contentLabel = UILabel()
    let menuButton = UIButton()
    private let completeButton = UIButton()
    
    var disposeBag = DisposeBag()
    lazy var rxMenuButtonTapControl: ControlEvent<Void> = menuButton.rx.tap
    lazy var rxCompleteButtonTapControl: ControlEvent<Void> = completeButton.rx.tap
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setStyles()
        setLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InsightsDetailActionPlanCollectionViewCell {

    private func setStyles() {
        backgroundColor = .gray900
        makeCornerRound(radius: 12)
        makeBorder(width: 1, color: .gray300)
        
        seedImageView.do {
            $0.image = ImageLiterals.Home.btn_scrap_light_off
            $0.contentMode = .scaleAspectFit
        }
        
        contentLabel.do {
            $0.font = .fontGuide(.body3_bold)
            $0.textColor = .white000
            $0.numberOfLines = 2
        }
        
        menuButton.do {
            $0.setImage(UIImage(named: "EllipsisWith2Dots"), for: .normal)
            $0.contentMode = .scaleAspectFit
        }
        
        completeButton.do {
            $0.setTitle("완료하기", for: .normal)
            $0.titleLabel?.font = .fontGuide(.detail2_bold)
            $0.setTitleColor(.white000, for: .normal)
            $0.setBackgroundColor(.green400, for: .normal)
            $0.makeCornerRound(radius: 15)
        }
    }
    
    private func setLayout() {
        addSubviews(
            seedImageView, contentLabel, menuButton,
            completeButton
        )
        
        seedImageView.snp.makeConstraints {
            $0.size.equalTo(48)
            $0.top.leading.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints {
            $0.leading.equalTo(seedImageView.snp.trailing)
            $0.top.equalToSuperview().inset(14)
            $0.trailing.equalToSuperview().inset(85)
        }
        
        menuButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.size.equalTo(48)
        }
        
        completeButton.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview().inset(12)
            $0.height.equalTo(30)
            $0.width.equalTo(68)
        }
    }
}

extension InsightsDetailActionPlanCollectionViewCell {
    
    func setContent(of content: String) {
        contentLabel.text = content
    }
    
    func setIsCompleted(_ completed: Bool) {
        completeButton.isEnabled = !completed
        completeButton.setBackgroundColor(completed ? .gray400: .green400, for: .normal)
    }
}
