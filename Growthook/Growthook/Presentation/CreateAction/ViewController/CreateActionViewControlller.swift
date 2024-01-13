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

struct CollViewModel {
    var index: Int
    var content: String?
}

final class CreateActionViewControlller: BaseViewController {
    
    private let createActionView = CreateActionView()
    private var viewModel = CreateActionViewModel()
    private let disposeBag = DisposeBag()
    
    private var isFolded = true
    private var countPlan = 1
    private var textViewIndex = 0
    private var actionPlanData: [CollViewModel] = [CollViewModel(index: 0, content: "")]
    
    
    override func loadView() {
        self.view = createActionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setKeyboardObserver()
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
                var newData = Array(self.actionPlanData.reversed())
                newData.append(.init(index: self.textViewIndex, content: ""))
                self.actionPlanData = Array(newData.reversed())
                self.createActionView.createSpecificPlanView.planCollectionView.reloadData()
            }
            .disposed(by: disposeBag)
        
        createActionView.createSpecificPlanView.planCollectionView.rx.itemSelected
            .subscribe(onNext: { index in
                print("\(index.section) \(index.row)")
            })
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
        let textView = cell.planTextView
        let data = self.actionPlanData[indexPath.item]
        cell.configure(textViewIndex: data.index, content: data.content)
        cell.delegate = self
        textView.rx.textInput.text
            .orEmpty
            .asDriver()
            .drive(onNext: { [weak self] text in
                if(text != "구체적인 계획을 설정해보세요"){
                    self?.actionPlanData.remove(at: indexPath.row)
                    self?.actionPlanData.insert(CollViewModel(index: indexPath.row, content: text), at: indexPath.row)
                    print("😱😱😱😱😱😱😱😱", self?.actionPlanData ?? "")
                }
            })
            .disposed(by: cell.disposeBag)
        
        cell.planTextView.rx.didEndEditing
            .bind {
                if cell.planTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    cell.planTextView.text = "구체적인 계획을 설정해보세요"
                    cell.planTextView.textColor = .gray400
                    cell.planTextView.font = .fontGuide(.body3_reg)
                    cell.planTextView.modifyBorderLine(with: .gray200)
            } else {
                print("있슴")
                cell.planTextView.textColor = .white000
                cell.planTextView.modifyBorderLine(with: .white000)
                cell.planTextView.font = .fontGuide(.body3_reg)
            }
        }
        .disposed(by: disposeBag)
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

extension CreateActionViewControlller: SendTextDelegate {
    
    func sendText(index: Int, text: String?) {
        guard let firstIndex = self.actionPlanData.firstIndex(where: { $0.index == index }) else { return }
        self.actionPlanData[firstIndex] = .init(index: index, content: text)
        self.createActionView.createSpecificPlanView.planCollectionView.reloadData()
    }
}

extension CreateActionViewControlller: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        print(textView.text ?? "","????")
    }
}
