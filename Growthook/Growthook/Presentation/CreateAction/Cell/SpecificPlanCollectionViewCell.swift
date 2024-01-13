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
    
    let planTextView = CommonTextViewWithBorder(placeholder: "구체적인 계획을 설정해보세요", maxLength: 40)
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
        planTextView.text = nil
        self.disposeBag = DisposeBag()

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
            .bind { [weak self] text in
                guard let self else {return }
                self.contents = text
            }
            .disposed(by: disposeBag)
        
        planTextView.rxEditingAction
            .bind { [weak self] event in
                guard let self = self, let id = self.cellIndexForId else { return }
                switch event {
                case .editingDidEnd:
                    self.delegate?.sendText(index: id, text: self.contents)
                default:
                    break
                }
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
    
    func configure(textViewIndex: Int, content: String?) {
        self.cellIndexForId = textViewIndex
        guard let content else { return }
        print(content)
        if (content.isEmpty) {
            self.planTextView.text = "구체적인 계획을 설정해보세요"
        }
        self.planTextView.text = content
    }
}
