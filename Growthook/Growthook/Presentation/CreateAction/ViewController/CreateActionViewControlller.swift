//
//  CreateActionViewControlller.swift
//  Growthook
//
//  Created by Minjoo Kim on 11/22/23.
//

import UIKit

import RxCocoa
import RxSwift
import Then

struct ActionplanModel {
    var index: Int
    var content: String?
}

final class CreateActionViewControlller: BaseViewController {
    
    private let createActionView = CreateActionView()
    private var viewModel = CreateActionViewModel()
    private let disposeBag = DisposeBag()
    private let placeholder = "구체적인 계획을 설정해보세요"
    private var isFolded = true
    private var countPlan = 1
    private var textViewIndex = 0
    private var actionplan: [Int: String] = [:]
    private var status: Bool = false {
        didSet(value) {
            if value == false {
                self.createActionView.confirmButton.isEnabled = true
                self.createActionView.confirmButton.setTitleColor(.green400, for: .normal)
            }
            else {
                self.createActionView.confirmButton.isEnabled = false
                self.createActionView.confirmButton.setTitleColor(.gray300, for: .normal)
            }
        }
    }
    
    var newActionPlan: CreateActionRequest = CreateActionRequest(contents: [])
    
    override func loadView() {
        self.view = createActionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setKeyboardObserver()
        
        viewModel.inputs.getSeedDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    deinit {
        print(#function)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: UIResponder.keyboardWillShowNotification.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: UIResponder.keyboardWillHideNotification.rawValue), object: nil)
    }
    
    override func setRegister() {
        createActionView.createSpecificPlanView.planCollectionView.register(SpecificPlanCollectionViewCell.self, forCellWithReuseIdentifier: SpecificPlanCollectionViewCell.className)
    }
    
    override func setDelegates() {
        createActionView.createSpecificPlanView.planCollectionView.delegate = self
        createActionView.createSpecificPlanView.planCollectionView.dataSource = self
    }
    
    override func bindViewModel() {
        viewModel.outputs.insight
            .bind(onNext: { value in
                self.createActionView.insightView.bindInsight(model: value)
            })
            .disposed(by: disposeBag)
        
        createActionView.insightView.moreButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                switch isFolded {
                case true:
                    self.setDownAnimation()
                case false:
                    self.setUpAnimation()
                }
                self.isFolded.toggle()
            }
            .disposed(by: disposeBag)
        
        createActionView.createSpecificPlanView.plusButton.rx.tap
            .bind {
                self.countPlan += 1
                self.textViewIndex += 1
                self.viewModel.inputs.setCount(count: self.countPlan)
                self.createActionView.createSpecificPlanView.planCollectionView.reloadData()
            }
            .disposed(by: disposeBag)
        
        createActionView.confirmButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                var newdata: [ActionplanModel] = []
                for (key,value) in actionplan {
                    newdata.append(ActionplanModel(index: key, content: value))
                }
                self.viewModel.inputs.postActionPlan(data: newdata)
            }
            .disposed(by: disposeBag)
        
    }
}

extension CreateActionViewControlller: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = UIScreen.main.bounds.width - 36
        let height = 96.0
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
}

extension CreateActionViewControlller: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countPlan
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpecificPlanCollectionViewCell.className, for: indexPath) as? SpecificPlanCollectionViewCell else {
            return SpecificPlanCollectionViewCell()
        }
        let placeholder = "구체적인 계획을 설정해보세요"
        let textView = cell.planTextView
        let data = self.actionplan[countPlan - indexPath.item - 1]
        if data == "" || data == nil || data == placeholder {
            cell.configure(textViewIndex: countPlan - indexPath.item - 1, content: placeholder)
        }
        else {
            cell.configure(textViewIndex: countPlan - indexPath.item - 1, content: data ?? placeholder)
        }
        
        var newIndex: Int = -1
        
        textView.rx.didBeginEditing
            .bind { [weak self] in
                guard let self else { return }
                textView.rxEditingAction.accept(.editingDidBegin)
                textView.modifyBorderLine(with: .green200)
                newIndex = countPlan - indexPath.item - 1
                if textView.text == placeholder {
                    textView.text = nil
                    textView.textColor = .white000
                    textView.font = .fontGuide(.body3_bold)
                }
            }
            .disposed(by: disposeBag)
        
        textView.rx.didEndEditing
            .bind { [weak self] value in
                guard let self else { return }
                textView.rxEditingAction.accept(.editingDidBegin)
                if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || textView.text == placeholder {
                    textView.text = placeholder
                    textView.textColor = .gray300
                    textView.font = .fontGuide(.body3_reg)
                    textView.modifyBorderLine(with: .gray200)
                    self.actionplan.removeValue(forKey: newIndex)
                } else {
                    textView.modifyBorderLine(with: .white000)
                    self.actionplan.updateValue(textView.text, forKey: newIndex)
                }
                
                print("😱😱😱😱😱😱😱😱", self.actionplan)
                self.status = self.actionplan.isEmpty
            }
            .disposed(by: disposeBag)
        textView.rx.text.orEmpty
            .distinctUntilChanged()
            .bind { [weak self] text in
                guard let self else { return }
                if text.isEmpty || text == placeholder {
                    cell.countLabel.text = "00/40"
                } else {
                    cell.countLabel.text = "\(text.count.toTwoDigitsString())/40"
                }
            }
        return cell
    }
}

extension CreateActionViewControlller {
    
    private func setUpAnimation() {
        UIView.animate(withDuration: 0.4, animations: { [self] in
            createActionView.insightView.frame.size.height = 125
            createActionView.insightView.fold()
        })
        createActionView.setFoldingLayout()
    }
    
    private func setDownAnimation() {
        UIView.animate(withDuration: 0.4, animations: { [self] in
            createActionView.insightView.frame.size.height = 153 + 125
            createActionView.insightView.showDetail()
        })
        createActionView.setShowingLayout()
    }
}

extension CreateActionViewControlller {
    
    func setKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.createActionView.createSpecificPlanView.snp.updateConstraints {
                $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(keyboardHeight - view.safeAreaInsets.bottom)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.createActionView.createSpecificPlanView.snp.updateConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func tapBackgroundView(_ sender: Any) {
        view.endEditing(true)
    }
}
