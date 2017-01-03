//
//  TaskCell.swift
//  TeamManager
//
//  Created by Manuel S. Gomez on 12/27/16.
//  Copyright © 2016 Manuel S. Gomez. All rights reserved.
//

import UIKit

class TaskCell: UICollectionViewCell {
    
    var task: Task!
    
    @IBOutlet weak var cellText: UILabel!
    @IBOutlet weak var cellImg: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureCell(_ task: Task){
        self.task = task
        cellText.text = task._name
        cellImg.image = UIImage(named: task._type.rawValue)
    }

}
