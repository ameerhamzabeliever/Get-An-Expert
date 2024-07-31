//
//  SelectSlotsVC.swift
//  GetAnExpert
//
//  Created by Umar Farooq on 05/10/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import SwiftyJSON
import SafariServices

class SelectSlotsVC: UIViewController {

    /* MARK:- IBoutlets */
    @IBOutlet weak var slotsStackView    : UIStackView!
    @IBOutlet weak var createSlotsButton : UIButton!
    
    ///Collections
    @IBOutlet var weekViews  : [UIView]!
    @IBOutlet var weekLabels : [UILabel]!
    
    /* MARK:- Properties */
    var userId      : String             = ""
    var serviceId   : String             = ""
    var fullDate  = ""
    var todayDate = ""
    var selectedDate = ""
    var allSlots    : [Slots]            = []
    var toAllSlots  : [Slots]            = []
    var selectedDay : WeekDays           = .monday
    var toolBar     : UIToolbar          = UIToolbar()
    var pickerView  : UIPickerView       = UIPickerView()
    var days        : [[String: String]] = []
    var fromTime = Date()
    var toTime   = Date()
    var currentTime = Date()
    var pickerViewFromField = ""
    var pickerViewToField   = ""
    var fromTimeRow = 0

    
    var weekSlots : [WeekModel] = [
        WeekModel(day: .monday    , slots: []),
        WeekModel(day: .tuesday   , slots: []),
        WeekModel(day: .wednesday , slots: []),
        WeekModel(day: .thursday  , slots: []),
        WeekModel(day: .friday    , slots: []),
        WeekModel(day: .saturday  , slots: [])
    ]
    var toWeekSLots: [WeekModel] = [
        WeekModel(day: .monday    , slots: []),
        WeekModel(day: .tuesday   , slots: []),
        WeekModel(day: .wednesday , slots: []),
        WeekModel(day: .thursday  , slots: []),
        WeekModel(day: .friday    , slots: []),
        WeekModel(day: .saturday  , slots: [])
    ]
    
    var selectedTextField : String   = ""
    var selectedToTextField : String = ""
    /* MARK:- Lifecycle */
    override func viewDidLoad() {
        super.viewDidLoad()
        initVC()
    }

}

/* MARK:- Methods */
extension SelectSlotsVC {
    func initVC() {
        getWeek()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            
            self.weekViews.forEach { (view) in
                view.layer.cornerRadius = view.frame.height / 8
                
                self.addShadow(view)
            }
            
            self.createSlotsButton.layer.cornerRadius = self.createSlotsButton.frame.height / 9
            self.addShadow(self.createSlotsButton)
        }
        
        getSlotsByUserId(userId)
        
        WeekDays.allCases.forEach { (day) in
            if day.rawValue == days[0]["name"] {
                selectedDay = day
                createSlotsButton.accessibilityIdentifier = day.rawValue
            }
        }
        
        toggleWeekButtons(createSlotsButton)
        
        weekLabels.forEach { (label) in
            days.forEach { (days) in
                if "n\(days["name"]!)" == label.accessibilityIdentifier ?? "" {
                    label.text = days["onlyDate"]
                }
            }
        }
    }
    
    func addShadow(_ view: UIView){
        view.layer.shadowColor   = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
        view.layer.shadowOffset  = CGSize(width: 2.0, height: 4.0)
        view.layer.shadowRadius  = 16.0
        view.layer.shadowOpacity = 0.32
    }
    
    func createSlots(){
        
        ///MAIN CONTAINER
        let containerStack             = UIStackView()
        containerStack.axis            = .horizontal
        containerStack.alignment       = .fill
        containerStack.distribution    = .fill
        containerStack.spacing         = 10
        
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        
        let constant = SCREEN_WIDTH * 0.0821256
        
        var containerStackConstraints = [NSLayoutConstraint()]
        containerStackConstraints     = [
            containerStack.heightAnchor.constraint(equalToConstant: constant)
        ]
        
        NSLayoutConstraint.activate(containerStackConstraints)
        
        ///SUB CONTAINER
        let subContainerStack          = UIStackView()
        subContainerStack.axis         = .horizontal
        subContainerStack.alignment    = .fill
        subContainerStack.distribution = .fillEqually
        subContainerStack.spacing      = 10
        
        ///FROM CONTAINER AND ELEMENTS
        let fromStack                  = UIStackView()
        fromStack.axis                 = .horizontal
        fromStack.alignment            = .fill
        fromStack.distribution         = .fillProportionally
        fromStack.spacing              = 4
        
        let fromLabel                  = UILabel()
        fromLabel.text                 = "From:"
        fromLabel.font                 = UIFont.systemFont(ofSize: 14.0)
        
        let fromTextField              = UITextField()
        fromTextField.placeholder      = "Select from time"
        fromTextField.font             = UIFont.systemFont(ofSize: 10.0)
        fromTextField.borderStyle      = .roundedRect
        fromTextField.textAlignment    = .center
        
        fromTextField.accessibilityIdentifier = "from-textfield-\(selectedDay.rawValue)"
        pickerViewFromField = fromTextField.accessibilityIdentifier ?? ""
        
        ///TO CONTAINER AND ELEMENTS
        let toStack                    = UIStackView()
        toStack.axis                   = .horizontal
        toStack.alignment              = .fill
        toStack.distribution           = .fill
        toStack.spacing                = 4
        
        let toLabel                    = UILabel()
        toLabel.text                   = "To:"
        toLabel.font                   = UIFont.systemFont(ofSize: 14.0)
        
        let toTextField                = UITextField()
        toTextField.isUserInteractionEnabled = false
        toTextField.placeholder        = "Select to time"
        toTextField.font               = UIFont.systemFont(ofSize: 10.0)
        toTextField.borderStyle        = .roundedRect
        toTextField.textAlignment      = .center
        
        toTextField.accessibilityIdentifier = "to-textfield-\(selectedDay.rawValue)"
        pickerViewToField = toTextField.accessibilityIdentifier ?? ""
        
        ///TEXT FIELD ACTIONS START
        let textFieldSelector          = #selector(didTapTextField(_:))

//        toTextField  .addTarget(self, action: textFieldSelector, for: .editingDidBegin)
        fromTextField.addTarget(self, action: textFieldSelector, for: .editingDidBegin)
        ///TEXT FIELD ACTIONS END
        
        fromStack.addArrangedSubview(fromLabel)
        fromStack.addArrangedSubview(fromTextField)
        
        toStack.addArrangedSubview(toLabel)
        toStack.addArrangedSubview(toTextField)
        
        subContainerStack.addArrangedSubview(fromStack)
        subContainerStack.addArrangedSubview(toStack)
                
        containerStack.addArrangedSubview(subContainerStack)
        
        slotsStackView.addArrangedSubview(containerStack)
    }
    
    func addPickerView() {
        pickerView                  = UIPickerView()
        pickerView.delegate         = self
        pickerView.backgroundColor  = .white
        
        pickerView.setValue(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), forKey: "textColor")
        
        pickerView.autoresizingMask = .flexibleWidth
        pickerView.contentMode      = .center
        
        pickerView.frame = CGRect(
            x      : 0.0,
            y      : SCREEN_HEIGHT - 300,
            width  : SCREEN_WIDTH,
            height : 300
        )
        
        self.view.addSubview(pickerView)
        
        toolBar = UIToolbar(
            frame: CGRect(
                x      : 0.0,
                y      : SCREEN_HEIGHT - 300,
                width  : SCREEN_WIDTH,
                height : 50
            )
        )
        
        toolBar.barStyle = .default
        let doneSelector = #selector(didTapDone(_:))
        toolBar.items    = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done"   , style: .done, target: self, action: doneSelector)
        ]
        
        self.view.addSubview(toolBar)
    }
    
    func removeSlotsView(){
        slotsStackView.arrangedSubviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        createSlots()
        
        self.weekSlots.forEach { (week) in
            if week.day == self.selectedDay {
                self.allSlots = week.slots
            }
        }
        
        self.toWeekSLots.forEach{
            (toWeek) in
            if toWeek.day == self.selectedDay{
                self.toAllSlots = toWeek.slots
            }
        }
    }
}

/* MARK:- Actions */
extension SelectSlotsVC {
    @IBAction func toggleWeekButtons(_ sender: UIButton) {
        if sender.accessibilityIdentifier == WeekDays.monday.rawValue {
            weekViews.forEach { (view) in
                if view.accessibilityIdentifier == WeekDays.monday.rawValue {
                    view.backgroundColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                } else {
                    view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                }
            }
            
            weekLabels.forEach { (label) in
                if label.accessibilityIdentifier == "n\(WeekDays.monday.rawValue)" {
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else if label.accessibilityIdentifier == WeekDays.monday.rawValue {
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else {
                    label.textColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                }
            }
            
            for i in 0...5{
                if WeekDays.monday.rawValue == days[i]["name"]{
                    fullDate = days[i]["date"]!
                }
            }
            
            selectedDay = .monday
            removeSlotsView()
        } else if sender.accessibilityIdentifier == WeekDays.tuesday.rawValue {
            weekViews.forEach { (view) in
                if view.accessibilityIdentifier == WeekDays.tuesday.rawValue {
                    view.backgroundColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                } else {
                    view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                }
            }
            
            weekLabels.forEach { (label) in
                if label.accessibilityIdentifier == "n\(WeekDays.tuesday.rawValue)" {
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else if label.accessibilityIdentifier == WeekDays.tuesday.rawValue {
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else {
                    label.textColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                }
            }
            
            for i in 0...5{
                if WeekDays.tuesday.rawValue == days[i]["name"]{
                    fullDate = days[i]["date"]!
                }
            }
            
            selectedDay = .tuesday
            removeSlotsView()
        } else if sender.accessibilityIdentifier == WeekDays.wednesday.rawValue {
            weekViews.forEach { (view) in
                if view.accessibilityIdentifier == WeekDays.wednesday.rawValue {
                    view.backgroundColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                } else {
                    view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                }
            }
            
            weekLabels.forEach { (label) in
                if label.accessibilityIdentifier == "n\(WeekDays.wednesday.rawValue)" {
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else if label.accessibilityIdentifier == WeekDays.wednesday.rawValue {
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else {
                    label.textColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                }
            }
            
            for i in 0...5{
                if WeekDays.wednesday.rawValue == days[i]["name"]{
                    fullDate = days[i]["date"]!
                }
            }
            
            selectedDay = .wednesday
            removeSlotsView()
        } else if sender.accessibilityIdentifier == WeekDays.thursday.rawValue {
            weekViews.forEach { (view) in
                if view.accessibilityIdentifier == WeekDays.thursday.rawValue {
                    view.backgroundColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                } else {
                    view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                }
            }
            
            weekLabels.forEach { (label) in
                if label.accessibilityIdentifier == "n\(WeekDays.thursday.rawValue)" {
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else if label.accessibilityIdentifier == WeekDays.thursday.rawValue {
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else {
                    label.textColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                }
            }
            
            for i in 0...5{
                if WeekDays.thursday.rawValue == days[i]["name"]{
                    fullDate = days[i]["date"]!
                }
            }
            
            selectedDay = .thursday
            removeSlotsView()
        } else if sender.accessibilityIdentifier == WeekDays.friday.rawValue {
            weekViews.forEach { (view) in
                if view.accessibilityIdentifier == WeekDays.friday.rawValue {
                    view.backgroundColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                } else {
                    view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                }
            }
            
            weekLabels.forEach { (label) in
                if label.accessibilityIdentifier == "n\(WeekDays.friday.rawValue)" {
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else if label.accessibilityIdentifier == WeekDays.friday.rawValue {
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else {
                    label.textColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                }
            }
            
            for i in 0...5{
                if WeekDays.friday.rawValue == days[i]["name"]{
                    fullDate = days[i]["date"]!
                }
            }
            
            selectedDay = .friday
            removeSlotsView()
        } else if sender.accessibilityIdentifier == WeekDays.saturday.rawValue {
            weekViews.forEach { (view) in
                if view.accessibilityIdentifier == WeekDays.saturday.rawValue {
                    view.backgroundColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                } else {
                    view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                }
            }
            
            weekLabels.forEach { (label) in
                if label.accessibilityIdentifier == "n\(WeekDays.saturday.rawValue)" {
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else if label.accessibilityIdentifier == WeekDays.saturday.rawValue {
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else {
                    label.textColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                }
            }
            
            for i in 0...5{
                if WeekDays.saturday.rawValue == days[i]["name"]{
                    fullDate = days[i]["date"]!
                }
            }
            
            selectedDay = .saturday
            removeSlotsView()
        }
    }
    
    @IBAction func didTapTextField (_ sender: UITextField) {
        sender.resignFirstResponder()
        
        selectedTextField = sender.accessibilityIdentifier ?? ""
        selectedToTextField = pickerViewToField
        
        addPickerView()
    }
    
    @IBAction func didTapDone (_ sender: UIToolbar) {
        toolBar    .removeFromSuperview()
        pickerView .removeFromSuperview()
    }
    
    @IBAction func didTapBack (_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapBookNow (_ sender: UIButton) {
        let textFields : [UITextField] = Helper.getSubviewsOf(view: slotsStackView)
        
        var fromTF = UITextField()
        var toTF   = UITextField()
        var fromId = ""
        var toId   = ""
        
        textFields.forEach { (textfield) in
            if textfield.accessibilityIdentifier == "from-textfield-\(selectedDay)" {
                fromTF = textfield
            } else if textfield.accessibilityIdentifier == "to-textfield-\(selectedDay)" {
                toTF   = textfield
            }
        }
        
        guard let from = fromTF.text, from != "" else {
            showAlert(message: "Please select from time")
            return
        }

        guard let to = toTF.text, to != "" else {
            showAlert(message: "Please select to time")
            return
        }
            
        allSlots.forEach { (slot) in
            if slot.slot == from {
                fromId = slot.id
            }
        }
        
        toAllSlots.forEach{
            (toSlot) in
            if toSlot.slot == to{
                toId = toSlot.id
            }
        }
        
        guard fromId != "" else {
            showAlert(message: "Invalid from time selected.")
            return
        }
        
        guard toId != "" else {
            showAlert(message: "Invalid to time selected.")
            return
        }
        
        guard fromTime < toTime else{
            showAlert(message: "Invalid to time selected.")
            return
        }
        
        guard serviceId != "" else {
            showAlert(message: "This service isn't valid anymore.")
            return
        }
        
        let parameters: [String: Any] = [
            "package"   : serviceId ,
            "fromTime"  : fromId    ,
            "toTime"    : toId      ,
            "date"      : fullDate
        ]
        
        bookAppointment(parameters)
    }
}

/* MARK:- API Methods */
extension SelectSlotsVC {
    func getSlotsByUserId(_ userId: String) {
        showSpinner(onView: view)
        NetworkManager.sharedInstance.getSlotsByUserId(userId: userId) {  [weak self] (response) in
            guard let self = self else { return }
            
            self.removeSpinner()
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        do {
                            let data  = try JSON(data: response.data!)
                            let slots = data["slots"].arrayValue
                            let toSlots = data["toTime"].arrayValue
//                            let fromSlots = data["fromTime"]
//                            let toSlots = data["toTime"].arrayValue
                            
                            slots.forEach { (slot) in
                                if slot["day"].stringValue == WeekDays.monday.rawValue {
                                    
                                    let monday = slot["slots"].arrayValue.map({Slots(json: $0)})
                                    self.weekSlots[0].slots = monday
                                    
                                } else if slot["day"].stringValue == WeekDays.tuesday.rawValue {
                                    
                                    let tuesday = slot["slots"].arrayValue.map({Slots(json: $0)})
                                    self.weekSlots[1].slots = tuesday
                                    
                                } else if slot["day"].stringValue == WeekDays.wednesday.rawValue {
                                    
                                    let wednesday = slot["slots"].arrayValue.map({Slots(json: $0)})
                                    self.weekSlots[2].slots = wednesday
                                    
                                } else if slot["day"].stringValue == WeekDays.thursday.rawValue {
                                    
                                    let thursday = slot["slots"].arrayValue.map({Slots(json: $0)})
                                    self.weekSlots[3].slots = thursday
                                    
                                } else if slot["day"].stringValue == WeekDays.friday.rawValue {
                                    
                                    let friday = slot["slots"].arrayValue.map({Slots(json: $0)})
                                    self.weekSlots[4].slots = friday
                                    
                                } else if slot["day"].stringValue == WeekDays.saturday.rawValue {
                                    
                                    let saturday = slot["slots"].arrayValue.map({Slots(json: $0)})
                                    self.weekSlots[5].slots = saturday
                                    
                                }
                            }
                            
                            toSlots.forEach { (toSlot) in
                                if toSlot["day"].stringValue == WeekDays.monday.rawValue {
                                    
                                    let ToMonday = toSlot["slots"].arrayValue.map({Slots(json: $0)})
                                    self.toWeekSLots[0].slots = ToMonday
                                    
                                } else if toSlot["day"].stringValue == WeekDays.tuesday.rawValue {
                                    
                                    let toTuesday = toSlot["slots"].arrayValue.map({Slots(json: $0)})
                                    self.toWeekSLots[1].slots = toTuesday
                                    
                                } else if toSlot["day"].stringValue == WeekDays.wednesday.rawValue {
                                    
                                    let toWednesday = toSlot["slots"].arrayValue.map({Slots(json: $0)})
                                    self.toWeekSLots[2].slots = toWednesday
                                    
                                } else if toSlot["day"].stringValue == WeekDays.thursday.rawValue {
                                    
                                    let toThursday = toSlot["slots"].arrayValue.map({Slots(json: $0)})
                                    self.toWeekSLots[3].slots = toThursday
                                    
                                } else if toSlot["day"].stringValue == WeekDays.friday.rawValue {
                                    
                                    let toFriday = toSlot["slots"].arrayValue.map({Slots(json: $0)})
                                    self.toWeekSLots[4].slots = toFriday
                                    
                                } else if toSlot["day"].stringValue == WeekDays.saturday.rawValue {
                                    
                                    let toSaturday = toSlot["slots"].arrayValue.map({Slots(json: $0)})
                                    self.toWeekSLots[5].slots = toSaturday
                                }
                            }
                            
                            self.weekSlots.forEach { (week) in
                                if week.day == self.selectedDay {
                                    self.allSlots = week.slots
                                }
                            }
                            
                            self.toWeekSLots.forEach{
                                (toWeek) in
                                if toWeek.day == self.selectedDay{
                                    self.toAllSlots = toWeek.slots
                                }
                            }
                            
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
    
    func bookAppointment(_ parameters: [String: Any]) {
        showSpinner(onView: view)
        NetworkManager.sharedInstance.bookAppointment(parameters: parameters) {  [weak self] (response) in
            guard let self = self else { return }
            
            self.removeSpinner()
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        let alert = UIAlertController(
                            title          : APP_NAME             ,
                            message        : "Appointment Booked.",
                            preferredStyle : .alert
                        )
                        
                        let okay = UIAlertAction(title: "OK", style: .default) { (_) in
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                        alert.addAction(okay)
                        
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        Helper.debugLogs(any: statusCode, and: "Status Code")
                    }
                }
            case .failure(let error):
                Helper.debugLogs(any: error, and: "Faliure")
            }
        }
    }
}

/* MARK:- PickerView */

///Datasource
extension SelectSlotsVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allSlots.count
    }
}

///Delegate
extension SelectSlotsVC: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if selectedTextField == pickerViewFromField{
        return allSlots[row].slot
        }
        else{
            return toAllSlots[row].slot
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let time          : String        = allSlots[row].slot
        let allTextFields : [UITextField] = Helper.getSubviewsOf(view: slotsStackView)
        
        allTextFields.forEach { (textField) in
            if textField.accessibilityIdentifier == selectedTextField ||
                textField.accessibilityIdentifier == selectedToTextField{
                if let identifier = textField.accessibilityIdentifier {
                    if identifier.contains("from") {
                        
                        fromTimeRow = row
                        textField.text = time
                        fromTime = stringToTime(time)!
                        
                        if todayDate == fullDate{
                            let date = Date()
                            let calendar = Calendar.current
                            let hour = calendar.component(.hour, from: date)
                            let minutes = calendar.component(.minute, from: date)
                            let presentTime = "\(hour):\(minutes)"
                            currentTime = stringToTime(presentTime)!
                            print(currentTime)
                            if currentTime > fromTime{
                                showAlert(message: "Time Selection is invalid")
                            }
                        }
                    }
                    else if identifier.contains("to") {
                        
                        textField.text = toAllSlots[fromTimeRow].slot
                        toTime = stringToTime(toAllSlots[fromTimeRow].slot)!
                    }
                }
            }
        }
    }
}

/* MARK:- Helpers */
extension SelectSlotsVC {
    func stringToTime(_ time: String) -> Date? {
        let formatter        = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return formatter.date(from: time)
    }
    
    func getTimeDifference(from: Date, to: Date) -> Int  {
        let component = Calendar.current.dateComponents([.hour,.minute], from: from, to: to)
        
        if component.hour ?? 0 > 0 {
            return component.hour!
        } else {
            return component.minute ?? 0
        }
        
    }
    
    func getWeek(){
        let calender = Calendar.current
        
        let today = Date()
        
        let weekday = getDayName(forDate: today)
        let date    = calender.component(.day, from: today)
        let month   = calender.component(.month, from: today)
        let year    = calender.component(.year, from: today)
        
        
        let dic = [
            "name" : weekday,
            "onlyDate": "\(date)",
            "date" : "\(date)-\(month)-\(year)"
        ]
        
        self.days.append(dic)
        self.todayDate = dic["date"]!
        
//        self.dateArr.append("\(date)")
//        self.monthArr.append("\(month)")
//        self.yearArr.append("\(year)")
        
        for i in 1...6 {
            if let nextDate = calender.date(byAdding: .day, value: i, to: today) {
                let weekday = getDayName(forDate: nextDate)
                let date    = calender.component(.day, from: nextDate)
                let month   = calender.component(.month, from: nextDate)
                let year    = calender.component(.year, from: nextDate)
                
                if weekday != "na" {
                    let dic = [
                        "name" : weekday,
                        "onlyDate": "\(date)",
                        "date" : "\(date)-\(month)-\(year)"
                    ]
                    
                    self.days.append(dic)
//                    self.dateArr.append("\(date)")
//                    self.monthArr.append("\(month)")
//                    self.yearArr.append("\(year)")
                }
            }
        }
        
    }
    
    func getDayName(forDate date: Date) -> String{
        let weekDay = Calendar.current.component(.weekday, from: date)
        
        switch weekDay {
        case 1:
            return "na"
        case 2:
            return WeekDays.monday.rawValue
        case 3:
            return WeekDays.tuesday.rawValue
        case 4:
            return WeekDays.wednesday.rawValue
        case 5:
            return WeekDays.thursday.rawValue
        case 6:
            return WeekDays.friday.rawValue
        case 7:
            return WeekDays.saturday.rawValue
        default:
            return "na"
        }
    }
}


/* MARK:- Safari Controller */

/// Delegate
extension SelectSlotsVC: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // the user may have closed the SFSafariViewController instance before a redirect
        // occurred. Sync with your backend to confirm the correct state
    }
}
