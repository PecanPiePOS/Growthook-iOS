//
//  SpecificPlanCollectionViewCell.swift
//  Growthook
//
//  Created by Minjoo Kim on 12/21/23.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

protocol SendTextDelegate: AnyObject {
    func sendText(index: Int, text: String?)
}

final class SpecificPlanCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: SendTextDelegate?
    private var cellIndexForId: Int?
    private var contents: String?

    
    private let viewModel = CreateActionViewModel()
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    var planTextView = ActionplanTextView(placeholder: "할 일을 구체적으로 계획해보세요", maxLength: 40)
    let countLabel = UILabel()
    
    // MARK: - View Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellIndexForId = 0
        contents = nil
        planTextView.text = nil
    }
}

extension SpecificPlanCollectionViewCell {
    
    // MARK: - UI Components Property
    
    private func setUI() {
        countLabel.do {
            $0.text = "0/40"
            $0.textColor = .gray300
            $0.font = .fontGuide(.detail1_reg)
        }
        
        planTextView.rx.text
            .bind { [weak self] value in
                guard let self else { return }
                guard let index = cellIndexForId else { return }
                self.contents = value
                delegate?.sendText(index: index, text: contents)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Layout Helper
    
    private func setLayout() {
        addSubviews(planTextView, countLabel)
        
        planTextView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(68)
        }
        
        countLabel.snp.makeConstraints {
            $0.top.equalTo(planTextView.snp.bottom).offset(4)
            $0.trailing.equalToSuperview().inset(4)
        }
    }
    
}

extension SpecificPlanCollectionViewCell {
    
    func configure(textViewIndex: Int, content: String?) {
        self.cellIndexForId = textViewIndex
        self.contents = content
        self.planTextView.text = content
        if planTextView.text == nil || planTextView.text == "" {
            self.planTextView.setPlaceholder()
        }
        setBorderAndFont()
    }
    
    func setBorderAndFont() {
        planTextView.setBorderLine()
        planTextView.setFont()
    }
}
