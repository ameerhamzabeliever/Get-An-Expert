//
//  AppointmentVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 04/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import SwiftyJSON

class AppointmentVC: UIViewController {
    
    /* MARK:- Outlets */
    @IBOutlet weak var ongoingTV : UITableView!
    @IBOutlet weak var pendingTV : UITableView!
    @IBOutlet weak var historyTV : UITableView!
    @IBOutlet weak var rejectedTV: UITableView!
    
    @IBOutlet weak var ongoingLabel : UILabel!
    @IBOutlet weak var pendingLabel : UILabel!
    @IBOutlet weak var historyLabel : UILabel!
    @IBOutlet weak var rejectedLabel: UILabel!
    
    /* MARK:- Properties */
    var appointments: [AppointmentsModel] = []
    var onGoingAppointments: [AppointmentsModel] = []
    var pendingAppointments: [AppointmentsModel] = []
    var rejectedAppointments: [AppointmentsModel] = []
    var historyAppointments: [AppointmentsModel] = []
    var appointment_id  = ""
    var updatedStatus   = ""
    var checkStatus     = ""
    var providerName    = ""
    var appointmentDate = ""
    var fromTimeSlot    = ""
    var toTimeSlot      = ""
    var providerAddress = ""
    var packageName     = ""
    var packagePrice    = ""
    var packageImage    = ""
    var currentTiming   = ""
    var userId          = ""
    var providerId      = ""
    var example = 0
    var appointmentIndex = 0
    var currentTime = Date()
    var fromTime    = Date()
    var toTime      = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNibs()
    }
    override func viewWillAppear(_ animated: Bool) {
        getMyAppointments()
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        appointments.removeAll()
        pendingAppointments.removeAll()
        onGoingAppointments.removeAll()
        rejectedAppointments.removeAll()
        historyAppointments.removeAll()
    }
    @IBAction func didTapApprove(_ sender: UIButton){
        let index = sender.tag
        appointment_id = pendingAppointments[index].id
        checkStatus = "UpComing"
        updateAppointmentStatus()
    }
    @IBAction func didTapReject(_ sender: UIButton){
        let index = sender.tag
        appointment_id = pendingAppointments[index].id
        checkStatus = "Rejected"
        updateAppointmentStatus()
    }
}

/* MARK:- Methods */
extension AppointmentVC {
    func registerNibs(){
        
        self.ongoingTV.register(
            UINib(
                nibName: Constants.TVCells.APPOINTMENT_CELL,
                bundle: nil),
            forCellReuseIdentifier: Constants.TVCells.APPOINTMENT_CELL
        )
        self.pendingTV.register(
            UINib(
                nibName: Constants.TVCells.APPOINTMENT_CELL,
                bundle: nil),
            forCellReuseIdentifier: Constants.TVCells.APPOINTMENT_CELL
        )
        self.historyTV.register(
            UINib(
                nibName: Constants.TVCells.APPOINTMENT_CELL,
                bundle: nil),
            forCellReuseIdentifier: Constants.TVCells.APPOINTMENT_CELL
        )
        
        self.rejectedTV.register(
            UINib(
                nibName: Constants.TVCells.APPOINTMENT_CELL,
                bundle: nil),
            forCellReuseIdentifier: Constants.TVCells.APPOINTMENT_CELL
        )
        
    }
}

/* MARK:- TableView Delegate & Datasource */
extension AppointmentVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == pendingTV{
            if pendingAppointments.count == 0{
                pendingLabel.alpha = 1.0
            }
            else{
                pendingLabel.alpha = 0.0
            }
            return pendingAppointments.count
        }
        else if tableView == ongoingTV{
            if onGoingAppointments.count == 0{
                ongoingLabel.alpha = 1.0
            }
            else{
                ongoingLabel.alpha = 0.0
            }
            return onGoingAppointments.count
        }
        else if tableView == rejectedTV{
            if rejectedAppointments.count == 0{
                rejectedLabel.alpha = 1.0
            }
            else{
                rejectedLabel.alpha = 0.0
            }
            return rejectedAppointments.count
        }
        else if tableView == historyTV{
            if historyAppointments.count == 0{
                historyLabel.alpha = 1.0
            }
            else{
                historyLabel.alpha = 0.0
            }
            return historyAppointments.count
        }
        else{
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let appointmentCell = tableView.dequeueReusableCell(
            withIdentifier: Constants.TVCells.APPOINTMENT_CELL
        ) as! AppointmentCell
            
        appointmentCell.isUserProvider = true
        
        if tableView == ongoingTV {
            appointmentCell.appointment = self.onGoingAppointments[indexPath.row]
            appointmentCell.buttonsView.alpha = 0.0
            appointmentCell.statusLabel.text  = "UpComing"
            appointmentCell.statusLabel.textColor = .blue
        } else if tableView == pendingTV {
            appointmentCell.appointment = self.pendingAppointments[indexPath.row]
            
            appointmentCell.buttonsView.alpha = 1.0
            appointmentCell.statusLabel.alpha = 0.0
            appointmentCell.acceptButton.tag = indexPath.row
            appointmentCell.rejectButton.tag = indexPath.row
            appointmentCell.acceptButton.addTarget(self,
                                                   action: #selector(didTapApprove),
                                                   for: .touchUpInside)
            appointmentCell.rejectButton.addTarget(self,
                                                   action: #selector(didTapReject),
                                                   for: .touchUpInside)
        } else if tableView == rejectedTV{
            appointmentCell.appointment = self.rejectedAppointments[indexPath.row]
            appointmentCell.buttonsView.alpha = 0.0
            appointmentCell.statusLabel.text  = "Done"
            appointmentCell.statusLabel.textColor = #colorLiteral(red: 0.568627451, green: 0.568627451, blue: 0.6941176471, alpha: 1)
        }
        else if tableView == historyTV{
            appointmentCell.appointment = self.historyAppointments[indexPath.row]
            appointmentCell.buttonsView.alpha = 0.0
            appointmentCell.statusLabel.text  = "Done"
            appointmentCell.statusLabel.textColor = #colorLiteral(red: 0.568627451, green: 0.568627451, blue: 0.6941176471, alpha: 1)
        }
        
        return appointmentCell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == ongoingTV{
            return self.ongoingTV.bounds.height/2
        }
        else if tableView == pendingTV{
            return self.pendingTV.bounds.height/2
        }
        else if tableView == historyTV{
            return self.historyTV.bounds.height/2
        }
        else if tableView == rejectedTV{
            return self.rejectedTV.bounds.height/2
        }
        else{
            return self.ongoingTV.bounds.height/2
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if tableView == ongoingTV{
            appointment_id  = onGoingAppointments[indexPath.row].id
            userId = onGoingAppointments[indexPath.row].user.id
            providerId = onGoingAppointments[indexPath.row].provider.id
            
            providerName    = onGoingAppointments[indexPath.row].user.name
            appointmentDate = onGoingAppointments[indexPath.row].date
            fromTimeSlot    = onGoingAppointments[indexPath.row].fromtimeSlot
            toTimeSlot      = onGoingAppointments[indexPath.row].toTimeSlot
            providerAddress =
    //                appointments[indexPath.row].street
                onGoingAppointments[indexPath.row].user.address.city
                + ", " + onGoingAppointments[indexPath.row].user.address.country
            packageName  = onGoingAppointments[indexPath.row].service.name
            packageName  = onGoingAppointments[indexPath.row].service.name
            packagePrice = onGoingAppointments[indexPath.row].service.price
            packageImage = onGoingAppointments[indexPath.row].service.image
            
            let date = Date()
            let calendar = Calendar.current
            let hour     = calendar.component(.hour, from: date)
            let minutes  = calendar.component(.minute, from: date)
            
            currentTiming = "\(hour):\(minutes)"
            currentTime   = stringToTime(currentTiming)!
            fromTime      = stringToTime(fromTimeSlot)!
            toTime        = stringToTime(toTimeSlot)!
            
            if currentTime == fromTime{
                
                let twilioChatVC = TwilioChatVC(nibName: Constants.ViewControllers.CHAT_VC, bundle: nil)
                twilioChatVC.consumerId = userId
                twilioChatVC.providerId = providerId
                twilioChatVC.id  = appointment_id
                navigationController?.pushViewController(twilioChatVC, animated: true)
            }
            else if currentTime > fromTime && currentTime <= toTime{
                
                let twilioChatVC = TwilioChatVC(nibName: Constants.ViewControllers.CHAT_VC, bundle: nil)
                twilioChatVC.consumerId = userId
                twilioChatVC.providerId = providerId
                twilioChatVC.id = appointment_id
                navigationController?.pushViewController(twilioChatVC, animated: true)
            }
            else{
                let appointmentDetailVc =  MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.APPOINTMENT_DETAIL_VC) as! AppointmentDetailsVC

                appointmentDetailVc.alpha        = false
                appointmentDetailVc.Name         = providerName
                appointmentDetailVc.Date         = appointmentDate
                appointmentDetailVc.toTime       = toTimeSlot
                appointmentDetailVc.fromTime     = fromTimeSlot
                appointmentDetailVc.address      = providerAddress
                appointmentDetailVc.packName     = packageName
                appointmentDetailVc.packPrice    = packagePrice
                appointmentDetailVc.serviceImg   = packageImage

                self.navigationController?.pushViewController(appointmentDetailVc, animated: true)
            }
        }
        else if tableView == pendingTV{
            appointmentIndex = indexPath.row
            
            appointment_id  = pendingAppointments[appointmentIndex].id
            
            providerName    = pendingAppointments[appointmentIndex].user.name
            appointmentDate = pendingAppointments[appointmentIndex].date
            fromTimeSlot    = pendingAppointments[appointmentIndex].fromtimeSlot
            toTimeSlot      = pendingAppointments[appointmentIndex].toTimeSlot
            providerAddress =
    //                appointments[indexPath.row].street
                pendingAppointments[appointmentIndex].user.address.city
                + ", " + pendingAppointments[appointmentIndex].user.address.country
            packageName  = pendingAppointments[appointmentIndex].service.name
            packagePrice = pendingAppointments[appointmentIndex].service.price
            packageImage = pendingAppointments[appointmentIndex].service.image
            
            let appointmentDetailVc =  MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.APPOINTMENT_DETAIL_VC) as! AppointmentDetailsVC
            
            appointmentDetailVc.alpha        = false
            appointmentDetailVc.appointment_id = appointment_id
            appointmentDetailVc.Name         = providerName
            appointmentDetailVc.Date         = appointmentDate
            appointmentDetailVc.toTime       = toTimeSlot
            appointmentDetailVc.fromTime     = fromTimeSlot
            appointmentDetailVc.address      = providerAddress
            appointmentDetailVc.packName     = packageName
            appointmentDetailVc.packPrice    = packagePrice
            appointmentDetailVc.serviceImg   = packageImage

            self.navigationController?.pushViewController(appointmentDetailVc, animated: true)
        }
    }
}

/* MARK:- API Methods */
extension AppointmentVC {
    func getMyAppointments(){
        showSpinner(onView: view)
        NetworkManager.sharedInstance.getProviderAppointments {  [weak self] (response) in
            guard let self = self else { return }
            
            self.removeSpinner()
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        do {
                            let data          = try JSON(data: response.data!)
                            self.appointments = data["appointments"].arrayValue.map({
                                 AppointmentsModel(json: $0)
                            })
                            
                            self.rowsInTable()
                            self.pendingTV.reloadData()
                            self.ongoingTV.reloadData()
                            self.rejectedTV.reloadData()
                            self.historyTV.reloadData()
                            
                        } catch {
                            Helper.debugLogs(any: error.localizedDescription, and: "Caught Error")
                        }
                    } else {
                        Helper.debugLogs(any: statusCode, and: "Status Code")
                    }
                }
            case .failure(let error):
                Helper.debugLogs(any: error, and: "Faliure")
            }
            
        }
    }
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
                        
                        self.appointments.removeAll()
                        self.pendingAppointments.removeAll()
                        self.onGoingAppointments.removeAll()
                        self.rejectedAppointments.removeAll()
                        self.historyAppointments.removeAll()
                        
                        self.getMyAppointments()
                        
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
    func rowsInTable(){
        for i in 0..<appointments.count{
        updatedStatus = appointments[i].status
        
        if updatedStatus == "pending"{
            pendingAppointments.append(appointments[i])
        }
        else if updatedStatus == "UpComing"{
            onGoingAppointments.append(appointments[i])
        }
        else if updatedStatus == "Rejected"{
            rejectedAppointments.append(appointments[i])
          }
        else if updatedStatus == "History"{
            historyAppointments.append(appointments[i])
          }
        }
    }
}

/*MARK:- Helpers */

extension AppointmentVC{
    func stringToTime(_ time: String) -> Date? {
        let formatter        = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return formatter.date(from: time)
    }
}
