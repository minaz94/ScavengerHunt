//
//  ScavengerHuntTableViewCell.swift
//  ScavengerHunt
//
//  Created by Mina on 3/1/24.
//

import UIKit

class ScavengerHuntTableViewCell: UITableViewCell {

    @IBOutlet weak var scavengerHuntLabel: UILabel!
    @IBOutlet weak var completedImageView: UIImageView!
    
    
    func configureFor(scavengerHunt: ScavengerHunt) {
        scavengerHuntLabel.text = scavengerHunt.title
        scavengerHuntLabel.textColor = scavengerHunt.isComplete ? .secondaryLabel : .label
        completedImageView.image = UIImage(systemName: scavengerHunt.isComplete ? "circle.inset.filled" : "circle")?.withRenderingMode(.alwaysTemplate)
        completedImageView.tintColor = scavengerHunt.isComplete ? .systemBlue : .tertiaryLabel
    }

}
