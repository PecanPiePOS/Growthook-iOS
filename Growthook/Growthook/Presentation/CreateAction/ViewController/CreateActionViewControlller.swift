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

protocol InsightDetailReloadDelegate: AnyObject {
    func reloadAfterPost()
}

struct ActionplanModel {
    var index: Int
    var content: String?
}

final class CreateActionViewControlller: BaseViewController {

    weak var delegate: InsightDetailReloadDelegate?
    
    private let createActionView = CreateActionView()
    private var viewModel = CreateActionViewModel()
    private let disposeBag = DisposeBag()
    private let placeholder = "할 일을 구체적으로 계획해보세요"
    private var isFolded = true
    private var countPlan = 1
    private var textViewIndex = 0
    private var actionplan: [Int: String] = [:]
    private var status: Bool = false {
        willSet(value) {
            if value == true {
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
    var seedId: Int = 0
        
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
        
        viewModel.inputs.setSeedId(seedId: self.seedId)
        
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
                print(self.countPlan)
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
                self.navigationController?.popViewController(animated: true)
                self.delegate?.reloadAfterPost()
            }
            .disposed(by: disposeBag)
        
        createActionView.navigationBar.backButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.navigationController?.popViewController(animated: true)
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
        cell.delegate = self
        let placeholder = "할 일을 구체적으로 계획해보세요"
        let textView = cell.planTextView
        let data = self.actionplan[countPlan - indexPath.item - 1]
        if data == "" || data == nil || data == placeholder {
            cell.configure(textViewIndex: countPlan - indexPath.item - 1, content: nil)
        }
        else {
            cell.configure(textViewIndex: countPlan - indexPath.item - 1, content: data ?? "")
        }
        
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

extension CreateActionViewControlller: SendTextDelegate {
    
    func sendText(index: Int, text: String?) {
        guard let text = text else { return }
        if text == "" || text == placeholder {
            self.actionplan.removeValue(forKey: index)
        }
        else {
            self.actionplan.updateValue(text, forKey: index)
        }
        self.status = self.actionplan.count > 0
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
