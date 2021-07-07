//
//  PublicacionTableViewCell.swift
//  reSearch
//
//  Created by Jennifer Ruiz on 01/07/21.
//

import UIKit

class PublicacionTableViewCell: UITableViewCell {

    @IBOutlet weak var perfilImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var fechaLabel: UILabel!
    
    @IBOutlet weak var puublishImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
