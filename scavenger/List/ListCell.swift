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
    func configure(with image: Image) {
        titleLabel.text = image.title
        titleLabel.textColor = image.isComplete ? .secondaryLabel : .label
        completedImage.image = UIImage(systemName: image.isComplete ? "circle.inset.filled" : "circle")?.withRenderingMode(.alwaysTemplate)
        completedImage.tintColor = image.isComplete ? .systemBlue : .tertiaryLabel
    }

}
