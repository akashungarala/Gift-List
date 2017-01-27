//
//  GiftCustomCell.swift
//  final
//
//  Created by Akash Ungarala on 8/9/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit

class GiftCustomCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
