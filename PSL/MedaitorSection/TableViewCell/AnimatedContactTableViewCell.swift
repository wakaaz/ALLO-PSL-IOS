//
//  AnimatedContactTableViewCell.swift
//  ImportExportIOSApp
//
//  Created by MacBook on 7/28/20.
//  Copyright © 2020 Usama. All rights reserved.
//

import UIKit

class AnimatedContactTableViewCell: UITableViewCell {
   
    
    @IBOutlet weak var s2: ShimmerView!
    @IBOutlet weak var s3: ShimmerView!
    @IBOutlet weak var s4: ShimmerView!
    @IBOutlet weak var s5: ShimmerView!
    
    @IBOutlet weak var s1: ShimmerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
