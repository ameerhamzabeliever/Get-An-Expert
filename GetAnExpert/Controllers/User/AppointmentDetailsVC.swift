//
//  AppointmentDetailsVC.swift
//  GetAnExpert
//
//  Created by Office on 17/12/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import SwiftyJSON

class AppointmentDetailsVC: UIViewController {
    
    /*MARK:- OUTLETS */
    
    @IBOutlet weak var providerName     : UILabel!
    @IBOutlet weak var appointmentDate  : UILabel!
    @IBOutlet weak var fromTimeDate     : UILabel!
    @IBOutlet weak var toTimeDate       : UILabel!
    @IBOutlet weak var toTimeSlot       : UILabel!
    @IBOutlet weak var fromTimeSlot     : UILabel!
    @IBOutlet weak var providerAddress  : UILabel!
    @IBOutlet weak var providerAddressTo: UILabel!
    @IBOutlet weak var packageName      : UILabel!
    @IBOutlet weak var packagePrice     : UILabel!
    @IBOutlet weak var serviceImage     : UIImageView!
    @IBOutlet weak var actionView       : UIView!
    
    var Name      = ""
    var Date      = ""
    var toTime    = ""
    var fromTime  = ""
    var address   = ""
    var packName  = ""
    var packPrice = ""
    var serviceImg = ""
    var checkStatus = ""
    var appointment_id = ""
    var alpha : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailData()
        layout()
    }
}

/* MARK:- Actions */

extension AppointmentDetailsVC{
    
    func detailData(){
        
        if alpha == true{
            actionView.alpha = 1
        }
        else{
            actionView.alpha = 0
        }
        
        providerName.text    = Name
        appointmentDate.text = Date
        fromTimeDate.text    = Date
        toTimeDate.text      = Date
        toTimeSlot.text      = toTime
        fromTimeSlot.text    = fromTime
        providerAddress.text = address
        providerAddressTo.text = address
        packageName.text     = packName
        packagePrice.text    = packPrice
        let strURL = serviceImg.replacingOccurrences(of: " ", with: "%20")
        if let url = URL(string: strURL) {
            serviceImage.kf.setImage(with: url)
        }
    }
    
    func layout(){
        serviceImage.layer.cornerRadius = self.serviceImage.bounds.height/2
    }
    
}

/*MARK:- Actions*/

extension AppointmentDetailsVC{
    
    @IBAction func didTapApprove(_ sender: Any){
        checkStatus = "UpComing"
        updateAppointmentStatus()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapReject(_ sender: Any){
        checkStatus = "Rejected"
        updateAppointmentStatus()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapBack(_sender: Any){
        self.navigationController?.popViewController(animated: true)
    }
    
}


/*MARK:- Api*/
extension AppointmentDetailsVC{
    func updateAppointmentStatus(){
        showSpinner(onView: view)
        
        var parameters : [String: Any] = [:]
        let appointmentId = appointment_id
        let status   = checkStatus
        
        parameters["appointmentId"] = appointmentId
        parameters["status"]        = status
        
        NetworkManager.sharedInstance.updateAppointment(parameters: parameters){

            (response) in
            self.removeSpinner()
            switch response.result {
            case .success:
                do {
                    let data = try JSON(data: response.data!)
                    if response.response?.statusCode == 200{
                    }
                }
                catch{
                    print(error.localizedDescription)
                }
            case .failure:
                print(response.response?.statusCode)
            }
        }
        
    }
}
