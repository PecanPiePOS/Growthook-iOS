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
            print(value,"???????")
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
    
//    private var count: Int = 0 {
//        didSet(value) {
//            print(value,"???????")
//            if value > 0 {
//                self.createActionView.confirmButton.isEnabled = true
//                self.createActionView.confirmButton.setTitleColor(.green400, for: .normal)
//            }
//            else {
//                self.createActionView.confirmButton.isEnabled = false
//                self.createActionView.confirmButton.setTitleColor(.gray300, for: .normal)
//            }
//        }
//    }
//    private var actionPlanData: [ActionplanModel] = [ActionplanModel(index: 0, content: "")] {
//        didSet(value) {
//            confirmStatus = false
//            value.forEach {
//                guard let content = $0.content else { return }
//                if !content.isEmpty && content != "" && content != placeholder {
//                    confirmStatus = true
//                }
//            }
//        }
//    }
//    private var confirmStatus: Bool = false {
//        didSet(value) {
//            switch value {
//            case true:
//                self.createActionView.confirmButton.isEnabled = true
//                self.createActionView.confirmButton.setTitleColor(.green400, for: .normal)
//            case false:
//                self.createActionView.confirmButton.isEnabled = false
//                self.createActionView.confirmButton.setTitleColor(.gray300, for: .normal)
//            }
//        }
//    }

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
//                var newData = Array(self.actionplan.reversed())
//                print(newData,"aiaiaiai")
//                var newData = Array(self.actionPlanData.reversed())
//                newData.append(contentsOf: [self.textViewIndex: ""])
                
//                (.init(index: self.textViewIndex, content: "구체적인 계획을 설정해보세요"))
//                self.actionPlanData = Array(newData.reversed())
                print(self.actionplan, "143")
//                actionplan.ke
                self.createActionView.createSpecificPlanView.planCollectionView.reloadData()
            }
            .disposed(by: disposeBag)
        
        createActionView.confirmButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                print("완료버튼누름")
                var newdata: [ActionplanModel] = []
//                for i in 0... actionplan.count {
//                    actionplan.values
//                }
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
//        let newIndex = countPlan - indexPath.item - 1
//        print(newIndex, "rrrr")
        let data = self.actionplan[countPlan - indexPath.item - 1]
        if data == "" || data == nil || data == placeholder {
            cell.configure(textViewIndex: countPlan - indexPath.item - 1, content: placeholder)
        }
        else {
            cell.configure(textViewIndex: countPlan - indexPath.item - 1, content: data ?? placeholder)
        }
//        cell.delegate = self
        
    var newIndex: Int = -1
        
        textView.rx.didBeginEditing
            .bind { [weak self] in
                guard let self else { return }
                textView.rxEditingAction.accept(.editingDidBegin)
                textView.modifyBorderLine(with: .green200)
                newIndex = countPlan - indexPath.item - 1
                print(newIndex)
                if textView.text == placeholder {
                    textView.text = nil
                    textView.textColor = .white000
                    textView.font = .fontGuide(.body3_bold)
                }
            }
            .disposed(by: disposeBag)
        
//        textView.rx.didBeginEditing
//            .asObservable()

//            .flatMapLatest( {
//                newIndex = countPlan - indexPath.item - 1
//            })
//            .flatMapLatest()
//            .flatMapLatest {
//                print($0)
//                   newIndex = countPlan - indexPath.item - 1
//                   print(newIndex, "didBeginEditing")
//            }
//            .bind { [weak self] value in
//                guard let self else { return }
//                newIndex = countPlan - indexPath.item - 1
//                print(newIndex, "didBeginEditing")
                
//                Student(score: ReplaySubject<Int>.createUnbounded())
//            }
//            .disposed(by: disposeBag)
      
        textView.rx.didEndEditing
            .bind { [weak self] value in
                guard let self else { return }
                
//                let newIndex = countPlan - indexPath.item - 1
                textView.rxEditingAction.accept(.editingDidBegin)
                print(newIndex, "newIndex")
                if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || textView.text == placeholder {
                    textView.text = placeholder
                    textView.textColor = .gray300
                    textView.font = .fontGuide(.body3_reg)
                    textView.modifyBorderLine(with: .gray200)
                    self.actionplan.removeValue(forKey: newIndex)
//                } else if textView.text == placeholder {
                } else {
                    textView.modifyBorderLine(with: .white000)
                    self.actionplan.updateValue(textView.text, forKey: newIndex)
//                    self.actionPlanData.remove(at: indexPath.row)
//                    self.actionPlanData.insert(ActionplanModel(index: indexPath.row, content: textView.text), at: indexPath.row)
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
//
//        textView.rx.text.orEmpty
//            .distinctUntilChanged()
//            .bind { [weak self] text in
//                
//                guard let self else { return }
//                
////                if text.isEmpty {
////                        textView.text = "구체적인 계획을 설정해보세요"
////                }
//                
//                if(text != "구체적인 계획을 설정해보세요" || !text.isEmpty || text != "" || !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty){
//                    
//                    self.createActionView.confirmButton.isEnabled = true
//                    self.createActionView.confirmButton.setTitleColor(.green400, for: .normal)
//                    self.actionPlanData.remove(at: indexPath.row)
//                    self.actionPlanData.insert(CollViewModel(index: indexPath.row, content: text), at: indexPath.row)
//                    print("😱😱😱😱😱😱😱😱", self.actionPlanData)
//                }
//                else {
//                    self.createActionView.confirmButton.isEnabled = false
//                    self.createActionView.confirmButton.setTitleColor(.gray300, for: .normal)
//                }
//            }
//            .disposed(by: disposeBag)
//        
//        textView.rx.didBeginEditing
//            .bind { [weak self] in
//            guard let self else { return }
//                if textView.text.isEmpty {
//                    textView
//                }
//                else {
//                    textView.textColor = .white000
//                }
//        }
//        .disposed(by: disposeBag)
//            
//        textView.rx.didEndEditing
//            .bind { [weak self] in
//                guard let self else { return }
//                    if textView.text.isEmpty {
//                        textView
//                    }
//                    else {
//                        textView.textColor = .white000
//                    }
//            }
//            .disposed(by: disposeBag)
        
        // 위에 주석 해제
        
        
        
        
        
        
        //        textView.rx.textInput.text
        //            .orEmpty
        //            .asDriver()
//            .drive(onNext: { [weak self] text in
//                guard let self else { return }
//                print(text, "??")
//                if(text != "구체적인 계획을 설정해보세요" || !text.isEmpty || text != "" || !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty){
                    
//                    self.createActionView.confirmButton.isEnabled = true
//                    self.createActionView.confirmButton.setTitleColor(.green400, for: .normal)
//                    self.actionPlanData.remove(at: indexPath.row)
//                    self.actionPlanData.insert(CollViewModel(index: indexPath.row, content: text), at: indexPath.row)
//                    print("😱😱😱😱😱😱😱😱", self.actionPlanData)
//                }
//                else {
//                    self.createActionView.confirmButton.isEnabled = false
//                    self.createActionView.confirmButton.setTitleColor(.gray300, for: .normal)
//                }
//            })
//            .disposed(by: cell.disposeBag)
        
        
        
        
        // 아래 주석 해제
//
//        textView.rx.didEndEditing
//            .bind {
//                if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || cell.planTextView.text == "" {
//                    textView.text = "구체적인 계획을 설정해보세요"
////                    cell.planTextView.textColor = .gray400
////                    cell.planTextView.font = .fontGuide(.body3_reg)
////                    cell.planTextView.modifyBorderLine(with: .gray200)
//            } else {
//                print("있슴")
//                textView.textColor = .white000
//                textView.modifyBorderLine(with: .white000)
//                textView.font = .fontGuide(.body3_reg)
//            }
//        }
//        .disposed(by: disposeBag)
        return cell
    }
//    
//
//    private func setActionplanData(data: [ActionplanModel]) {
//        let placeholder = "구체적인 계획을 설정해보세요"
//        for i in 0 ... (data.count) {
//            if data[i].content != placeholder {
//                newActionPlan.contents.append(data[i].content ?? "")
//            }
//        }
//    }
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
