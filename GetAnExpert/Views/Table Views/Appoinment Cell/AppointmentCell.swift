//
//  AppointmentCell.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 04/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import SwiftyJSON

class AppointmentCell: UITableViewCell {
    
    
    /* MARK:- Outlets */
    @IBOutlet weak var mainView             : UIView!
    @IBOutlet weak var appointmentImageView : UIView!
    @IBOutlet weak var appointmentImage     : UIImageView!
    @IBOutlet weak var title                : UILabel!
    @IBOutlet weak var clientName           : UILabel!
    @IBOutlet weak var statusLabel          : UILabel!
    @IBOutlet weak var buttonsView          : UIStackView!
    @IBOutlet weak var acceptButton         : UIButton!
    @IBOutlet weak var rejectButton         : UIButton!
    
    var isUserProvider = false
    
    /* MARK:- Properties */
    var appointment: AppointmentsModel? {
        didSet {
            config()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setLayout()
    }
    func setLayout() {
        selectionStyle = .none
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            
            self.appointmentImageView.layer.cornerRadius = self.appointmentImageView.bounds.height / 8
            self.mainView.layer.cornerRadius     = self.mainView.bounds.height / 8
            self.acceptButton.layer.cornerRadius = self.acceptButton.bounds.height / 8
            self.rejectButton.layer.cornerRadius = self.rejectButton.bounds.height / 8
        }
    }
    func config() {
        if let appointment = appointment {
            if isUserProvider{
                let strUrl = appointment.user.image
                if let url = URL(string: strUrl.replacingOccurrences(of: " ", with: "%20")) {
                    appointmentImage.kf.setImage(with: url)
                }
                
                title.text      = appointment.service.name
                clientName.text = appointment.user.name
            }
            else{
                let strUrl = appointment.service.image
                if let url = URL(string: strUrl.replacingOccurrences(of: " ", with: "%20")) {
                    appointmentImage.kf.setImage(with: url)
                }
                
                title.text      = appointment.service.name
                clientName.text = appointment.provider.name
            }
        }
    }
}
/* MARK:- Actions*/
extension AppointmentCell{
    
    @IBAction func didTapApprove(_sender: Any){
    }
    
    @IBAction func didTapReject(_sender: Any){
    }

}
