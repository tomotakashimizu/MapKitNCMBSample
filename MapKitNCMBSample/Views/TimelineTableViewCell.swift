//
//  TimelineTableViewCell.swift
//  MapKitNCMBSample
//
//  Created by 清水智貴 on 2020/10/17.
//

import UIKit

protocol TimelineTableViewCellDelegate {
    func didTapPlacePointButton(tableViewCell: UITableViewCell)
}

class TimelineTableViewCell: UITableViewCell {
    
    var delegate: TimelineTableViewCellDelegate?
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var toPlacePointButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func toPlacePoint() {
        self.delegate?.didTapPlacePointButton(tableViewCell: self)
    }
    
}
