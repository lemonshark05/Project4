//
//  ListCell.swift
//  scavenger
//
//  Created by lemonshark on 2023/3/14.
//

import UIKit

class ListCell: UITableViewCell {

    @IBOutlet weak var completedImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(with task: Image) {
        titleLabel.text = task.title
        titleLabel.textColor = task.isComplete ? .secondaryLabel : .label
        completedImage.image = UIImage(systemName: task.isComplete ? "circle.inset.filled" : "circle")?.withRenderingMode(.alwaysTemplate)
        completedImage.tintColor = task.isComplete ? .systemBlue : .tertiaryLabel
    }

}
