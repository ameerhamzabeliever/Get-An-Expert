//
//  ScheduleVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 04/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import SwiftyJSON

class ScheduleVC: UIViewController {
    
    /* MARK:- Outlets */
    @IBOutlet weak var ongoingTV : UITableView!
    @IBOutlet weak var pendingTV : UITableView!
    @IBOutlet weak var historyTV : UITableView!
    @IBOutlet weak var rejectedTV: UITableView!
    
    @IBOutlet weak var ongoingLabel : UILabel!
    @IBOutlet weak var pendingLabel : UILabel!
    @IBOutlet weak var historyLabel : UILabel!
    @IBOutlet weak var rejectedLabel: UILabel!
    
    
    var updatedStatus   = ""
    var providerName    = ""
    var appointmentDate = ""
    var fromTimeSlot    = ""
    var toTimeSlot      = ""
    var providerAddress = ""
    var packageName     = ""
    var packagePrice    = ""
    var packageImage    = ""
    var currentTiming   = ""
    var appointment_id  = ""
    var userId          = ""
    var providerId      = ""
    var currentTime = Date()
    var fromTime    = Date()
    var toTime      = Date()
    var upComingArr: [AppointmentsModel] = []
    var rejectedArr: [AppointmentsModel] = []
    var pendingArr : [AppointmentsModel] = []
    var historyArr : [AppointmentsModel] = []
    
    /* MARK:- Properties */
    var appointments: [AppointmentsModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNibs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMyAppointments()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        pendingArr.removeAll()
        upComingArr.removeAll()
        rejectedArr.removeAll()
        historyArr.removeAll()
    }
}

/* MARK:- Methods */
extension ScheduleVC {
    
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
extension ScheduleVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if tableView == pendingTV{
            if pendingArr.count == 0{
                pendingLabel.alpha = 1.0
            }
            else{
                pendingLabel.alpha = 0.0
            }
            return pendingArr.count
        }
        else if tableView == ongoingTV{
            if upComingArr.count == 0{
                ongoingLabel.alpha = 1.0
            }
            else{
                ongoingLabel.alpha = 0.0
            }
            return upComingArr.count
        }
        else if tableView == rejectedTV{
            if rejectedArr.count == 0{
                rejectedLabel.alpha = 1.0
            }
            else{
                rejectedLabel.alpha = 0.0
            }
            return rejectedArr.count
        }
        else if tableView == historyTV{
            if historyArr.count == 0{
                historyLabel.alpha = 1.0
            }
            else{
                historyLabel.alpha = 0.0
            }
            return historyArr.count
        }
        else{
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let appointmentCell = tableView.dequeueReusableCell(
            withIdentifier: Constants.TVCells.APPOINTMENT_CELL
        ) as! AppointmentCell
        
        appointmentCell.isUserProvider = false
            
        let index = indexPath.row
        
        if tableView == ongoingTV {
            appointmentCell.appointment = self.upComingArr[index]
            appointmentCell.buttonsView.alpha = 0.0
            appointmentCell.statusLabel.text  = "UpComing"
            appointmentCell.statusLabel.textColor = .blue
        } else if tableView == pendingTV {
            appointmentCell.appointment = self.pendingArr[index]
            
//            appointmentCell.buttonsView.alpha = 1.0
            appointmentCell.statusLabel.alpha = 0.0
            appointmentCell.acceptButton.tag = index
            appointmentCell.rejectButton.tag = index
        } else if tableView == rejectedTV{
            appointmentCell.appointment = self.rejectedArr[index]
            appointmentCell.buttonsView.alpha = 0.0
            appointmentCell.statusLabel.text  = "Done"
            appointmentCell.statusLabel.textColor = #colorLiteral(red: 0.568627451, green: 0.568627451, blue: 0.6941176471, alpha: 1)
        }
        else if tableView == historyTV{
            appointmentCell.appointment = self.historyArr[index]
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == ongoingTV{
            appointment_id = upComingArr[indexPath.row].id
            userId         = upComingArr[indexPath.row].user.id
            providerId     = upComingArr[indexPath.row].provider.id
            
            providerName = upComingArr[indexPath.row].provider.name
            appointmentDate = upComingArr[indexPath.row].date
            fromTimeSlot = upComingArr[indexPath.row].fromtimeSlot
            toTimeSlot = upComingArr[indexPath.row].toTimeSlot
            providerAddress =
//                appointments[indexPath.row].street
                upComingArr[indexPath.row].city
                + ", " + upComingArr[indexPath.row].country
            packageName = upComingArr[indexPath.row].service.name
            packagePrice = upComingArr[indexPath.row].service.price
            packageImage = upComingArr[indexPath.row].service.image
            
            let date = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            let minutes = calendar.component(.minute, from: date)
            
            currentTiming = "\(hour):\(minutes)"
            currentTime = stringToTime(currentTiming)!
            fromTime = stringToTime(fromTimeSlot)!
            toTime   = stringToTime(toTimeSlot)!
            
            if currentTime == fromTime{
                
                let twilioChatVC = TwilioChatVC(nibName: Constants.ViewControllers.CHAT_VC, bundle: nil)
                twilioChatVC.consumerId = userId
                twilioChatVC.providerId = providerId
                twilioChatVC.id = appointment_id
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
            
            appointment_id  = pendingArr[indexPath.row].id
            
            providerName    = pendingArr[indexPath.row].provider.name
            appointmentDate = pendingArr[indexPath.row].date
            fromTimeSlot    = pendingArr[indexPath.row].fromtimeSlot
            toTimeSlot      = pendingArr[indexPath.row].toTimeSlot
            providerAddress =
    //                appointments[indexPath.row].street
                pendingArr[indexPath.row].city
                + ", " + pendingArr[indexPath.row].country
            packageName  = pendingArr[indexPath.row].service.name
            packagePrice = pendingArr[indexPath.row].service.price
            packageImage = pendingArr[indexPath.row].service.image
            
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
    

}

/* MARK:- API Methods */
extension ScheduleVC {
    func getMyAppointments(){
        showSpinner(onView: view)
        NetworkManager.sharedInstance.getMyAppointments {  [weak self] (response) in
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

    func rowsInTable(){
        for i in 0..<appointments.count{
        updatedStatus = appointments[i].status
        if updatedStatus == "pending"{
            pendingArr.append(appointments[i])
        }
        else if updatedStatus == "UpComing"{
            upComingArr.append(appointments[i])
        }
        else if updatedStatus == "Rejected"{
            rejectedArr.append(appointments[i])
          }
        else if updatedStatus == "History"{
            historyArr.append(appointments[i])
          }
        }
    }
}

/*MARK:- Helpers */

extension ScheduleVC{
    func stringToTime(_ time: String) -> Date? {
        let formatter        = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return formatter.date(from: time)
    }
}
