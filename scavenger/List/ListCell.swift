//
//  ListCell.swift
//  scavenger
//
//  Created by lemonshark on 2023/3/14.
//

import UIKit

class ListCell: UITableViewCell {

    @IBOutlet weak var completedImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(with image: Image) {
        titleLabel.text = image.title
        titleLabel.textColor = image.isComplete ? .secondaryLabel : .label
        completedImageView.image = UIImage(systemName: image.isComplete ? "checkmark.circle" : "circle")?.withRenderingMode(.alwaysTemplate)
        completedImageView.tintColor = image.isComplete ? .systemRed : .systemGreen
    }

}
