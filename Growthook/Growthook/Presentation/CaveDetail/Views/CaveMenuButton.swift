//
//  CaveMenuButton.swift
//  Growthook
//
//  Created by KJ on 1/10/24.
//

import UIKit

import SnapKit
import Then

final class CaveMenuButton: UIButton {

    // MARK: - UI Components
    
    private lazy var image = UIImage()
    private lazy var title = AttributedString()
    private lazy var color = UIColor()
    
    // MARK: - Initializer

    init(buttonTitle: AttributedString, buttonImage: UIImage) {
        super.init(frame: .zero)
        self.title = buttonTitle
        self.image = buttonImage
        setStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components Property
    
    func setStyle() {
        
        title.font = .fontGuide(.body1_reg)
        
        var config = UIButton.Configuration.filled()
        config.attributedTitle = title
        config.image = image
        config.imagePadding = 12
        config.baseBackgroundColor = .clear
        config.imagePlacement = NSDirectionalRectEdge.leading
        config.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 16, bottom: 0, trailing: SizeLiterals.Screen.screenWidth * 240 / 375)
        configuration = config
    }
}
