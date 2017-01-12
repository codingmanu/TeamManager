
//
//  ExpandedTaskCell.swift
//  TeamManager
//
//  Created by Manuel S. Gomez on 12/27/16.
//  Copyright © 2016 Manuel S. Gomez. All rights reserved.
//

import UIKit

class ExpandedTaskCell: UICollectionViewCell {
    
    var task: Task!
    
    @IBOutlet weak var cellText: UILabel!
    @IBOutlet weak var cellImg: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.red
    }
    
    func configureCell(_ task: Task){
        //We assign which task belong to this cell
        self.task = task
        
        //We define the icon for user or team task
        cellImg.image = UIImage(named: task._type.rawValue)
        
        //Depending on if the task is completed or not, we strike through the text and turn it gray along with the icon
        if task.completed{
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: task._name.appending("aaaaa"))
            attributeString.addAttribute(
                NSStrikethroughStyleAttributeName,
                value: 2,
                range: NSMakeRange(0, attributeString.length))
            
            attributeString.addAttribute(
                NSForegroundColorAttributeName,
                value: UIColor.darkGray,
                range: NSMakeRange(0, attributeString.length))
            //Apply to the label
            cellText.attributedText = attributeString
            cellImg.tintColor = UIColor.darkGray
            self.backgroundColor = UIColor.lightGray
            
        }else{
            cellText.text = task._name
            cellImg.tintColor = UIColor.blue
            self.backgroundColor = UIColor.green
        }
    }
    
}
