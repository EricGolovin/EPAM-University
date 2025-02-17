//
//  HomeworkCell.swift
//  MemoryManagementHomework
//
//  Created by Dmytro Kolesnyk2 on 14.05.2020.
//  Copyright © 2020 Dmytro Kolesnyk. All rights reserved.
//

import UIKit

class HomeworkCell: UITableViewCell {
    enum Const {
        enum Layout {
            static let defaultCellHeightConstraint: CGFloat = 100
        }
    }
    var homeworkImage: UIImage? {
        didSet {
            cellImageView.image = homeworkImage
            reloadAction?()
        }
    }
    
    var reloadAction: (()->())?
    var cellImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupSubview()
        setupAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview() {
        addSubview(cellImageView)
        cellImageView.contentMode = .scaleAspectFill
    }
    
    private func setupAutoLayout() {
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cellImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            cellImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            cellImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            cellImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            cellImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: Const.Layout.defaultCellHeightConstraint)
        ])
    }
}
