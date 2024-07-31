//
//  CreateSlotsVC.swift
//  GetAnExpert
//
//  Created by Umar Farooq on 27/09/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import SwiftyJSON

class CreateSlotsVC: UIViewController {
    
    /* MARK:- IBoutlets */
    @IBOutlet weak var slotsStackView    : UIStackView!
    @IBOutlet weak var createSlotsButton : UIButton!
    
    ///Collections
    @IBOutlet var weekViews  : [UIView]!
    @IBOutlet var weekLabels : [UILabel]!

    /* MARK:- Properties */
    var allSlots      : [Slots]      = []
    var toAllSlots    : [Slots]      = []
    var dataSource    : [Slots]      = []
    var toDataSource  : [Slots]      = []
    var stackNumber   : Int          = 1
    var selectedDay   : WeekDays     = .monday
    
    var setteledSlots : [SlotsModel] = [
        SlotsModel(day: .monday    , slots: [TimeSlots(identifier: "\(1)-\(WeekDays.monday)"    )]),
        SlotsModel(day: .tuesday   , slots: [TimeSlots(identifier: "\(1)-\(WeekDays.tuesday)"   )]),
        SlotsModel(day: .wednesday , slots: [TimeSlots(identifier: "\(1)-\(WeekDays.wednesday)" )]),
        SlotsModel(day: .thursday  , slots: [TimeSlots(identifier: "\(1)-\(WeekDays.thursday)"  )]),
        SlotsModel(day: .friday    , slots: [TimeSlots(identifier: "\(1)-\(WeekDays.friday)"    )]),
        SlotsModel(day: .saturday  , slots: [TimeSlots(identifier: "\(1)-\(WeekDays.saturday)"  )])
    ]
    
    var toolBar     : UIToolbar      = UIToolbar()
    var pickerView  : UIPickerView   = UIPickerView()
    
    var selectedTextField   : String   = ""
    var selectedTotextField : String = ""
    var pickerViewFromField = ""
    var pickerViewToField   = ""
    
    /* MARK:- Lifecycle */
    override func viewDidLoad() {
        super.viewDidLoad()
        initVC()
    }
}

/* MARK:- Methods */
extension CreateSlotsVC {
    func initVC() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            
            self.weekViews.forEach { (view) in
                view.layer.cornerRadius = view.frame.height / 8
                
                self.addShadow(view)
            }
            
            self.createSlotsButton.layer.cornerRadius = self.createSlotsButton.frame.height / 9
            self.addShadow(self.createSlotsButton)
        }
        getAllSlots()
        getUserSlots()
        
        let tapSelector = #selector(didTapParentView(sender:))
        let tapGesture  = UITapGestureRecognizer(target: self, action: tapSelector)
        
        view.addGestureRecognizer(tapGesture)
    }
    
    func addShadow(_ view: UIView){
        view.layer.shadowColor   = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
        view.layer.shadowOffset  = CGSize(width: 2.0, height: 4.0)
        view.layer.shadowRadius  = 16.0
        view.layer.shadowOpacity = 0.32
    }
    
    func createSlots(isFirstStack flag: Bool, from: String? = nil, to: String? = nil){
        setteledSlots.enumerated().forEach { (index,week) in
            if week.day == selectedDay {
                var needsToAppend = true
                ///TODO:- This is adding an extra slot don't know why?
                setteledSlots[index].slots.enumerated().forEach { (sIndex, slots) in
                    if slots.identifier == "\(stackNumber)-\(selectedDay.rawValue)" {
                        needsToAppend = false
                    }
                }
                
                if needsToAppend {
                    setteledSlots[index].slots.append(
                        TimeSlots(identifier: "\(stackNumber)-\(selectedDay.rawValue)")
                    )
                }
            }
        }
        
        ///MAIN CONTAINER
        let containerStack             = UIStackView()
        containerStack.axis            = .horizontal
        containerStack.alignment       = .fill
        containerStack.distribution    = .fill
        containerStack.spacing         = 10
        
        containerStack.accessibilityIdentifier                   = "stack-\(stackNumber)-\(selectedDay.rawValue)"
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
        fromStack.distribution         = .fill
        fromStack.spacing              = 4
        
        let fromLabel                  = UILabel()
        fromLabel.text                 = "From:"
        fromLabel.font                 = UIFont.systemFont(ofSize: 14.0)
        
        let fromTextField              = UITextField()
        fromTextField.placeholder      = "Select from time"
        fromTextField.font             = UIFont.systemFont(ofSize: 10.0)
        fromTextField.borderStyle      = .roundedRect
        fromTextField.textAlignment    = .center
        fromTextField.tag              = stackNumber
        fromTextField.text             = from ?? ""
        
        fromTextField.accessibilityIdentifier = "from-textfield-\(stackNumber)-\(selectedDay.rawValue)"
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
        toTextField.tag                = stackNumber
        toTextField.text               = to ?? ""
        
        toTextField.accessibilityIdentifier = "to-textfield-\(stackNumber)-\(selectedDay.rawValue)"
        pickerViewToField = toTextField.accessibilityIdentifier ?? ""
        
        ///TEXT FIELD ACTIONS START
        let textFieldSelector          = #selector(didTapTextField(_:))

//        toTextField  .addTarget(self, action: textFieldSelector, for: .editingDidBegin)
        fromTextField.addTarget(self, action: textFieldSelector, for: .editingDidBegin)
        ///TEXT FIELD ACTIONS END
        
        ///REMOVE AND ADDITION BUTTON START
        let addRemoveButton = UIButton()
        
        if flag {
            addRemoveButton.setImage(UIImage(named: "add"), for: .normal)
            
            addRemoveButton.tag = stackNumber
            let addSelector     = #selector(didTapAddNewSlot(_:))
            addRemoveButton.addTarget(self, action: addSelector, for: .touchUpInside)
        } else {
            addRemoveButton.setImage(UIImage(named: "remove"), for: .normal)
            
            addRemoveButton.tag = stackNumber
            let addSelector     = #selector(didTapRemoveSlot(_:))
            addRemoveButton.addTarget(self, action: addSelector, for: .touchUpInside)
        }
        
        addRemoveButton.translatesAutoresizingMaskIntoConstraints = false
        
        var addRemoveButtonConstraints = [NSLayoutConstraint()]
        addRemoveButtonConstraints     = [
            addRemoveButton.widthAnchor.constraint(equalToConstant: constant)
        ]
        
        NSLayoutConstraint.activate(addRemoveButtonConstraints)
        ///REMOVE AND ADDITION BUTTON END
        
        fromStack.addArrangedSubview(fromLabel)
        fromStack.addArrangedSubview(fromTextField)
        
        toStack.addArrangedSubview(toLabel)
        toStack.addArrangedSubview(toTextField)
        
        subContainerStack.addArrangedSubview(fromStack)
        subContainerStack.addArrangedSubview(toStack)
                
        containerStack.addArrangedSubview(subContainerStack)
        containerStack.addArrangedSubview(addRemoveButton)
        
        slotsStackView.addArrangedSubview(containerStack)
        
        stackNumber += 1
    }
    
    func createDaySlots(){
        setteledSlots.forEach { (week) in
            if week.day == selectedDay {
                week.slots.enumerated().forEach { (index,slots) in
                    stackNumber = index + 1
                    if index == 0 {
                        createSlots(isFirstStack: true, from: slots.from, to: slots.to)
                    } else {
                        createSlots(isFirstStack: false, from: slots.from, to: slots.to)
                    }
                }
            }
        }
    }
    
    func removeSlot(withIdentifier identifier: String) {
        slotsStackView.arrangedSubviews.forEach { (view) in
            if view.accessibilityIdentifier == identifier {
                view.removeFromSuperview()
                
                stackNumber -= 1
            }
        }
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
    
    func removeAllSlots(){
        slotsStackView.arrangedSubviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        stackNumber = 1
                
        switch selectedDay {
        case .monday:
            setteledSlots.forEach { (week) in
                if week.day == .monday {
                    if week.slots.count > 0 {
                        stackNumber = week.slots.count
                        createDaySlots()
                    } else {
                        createSlots(isFirstStack: true)
                    }
                }
            }
        case .tuesday:
            setteledSlots.forEach { (week) in
                if week.day == .tuesday {
                    if week.slots.count > 0 {
                        createDaySlots()
                    } else {
                        createSlots(isFirstStack: true)
                    }
                }
            }
        case .wednesday:
            setteledSlots.forEach { (week) in
                if week.day == .wednesday {
                    if week.slots.count > 0 {
                        createDaySlots()
                    } else {
                        createSlots(isFirstStack: true)
                    }
                }
            }
        case .thursday:
            setteledSlots.forEach { (week) in
                if week.day == .thursday {
                    if week.slots.count > 0 {
                        createDaySlots()
                    } else {
                        createSlots(isFirstStack: true)
                    }
                }
            }
        case .friday:
            setteledSlots.forEach { (week) in
                if week.day == .friday {
                    if week.slots.count > 0 {
                        createDaySlots()
                    } else {
                        createSlots(isFirstStack: true)
                    }
                }
            }
        case .saturday:
            setteledSlots.forEach { (week) in
                if week.day == .saturday {
                    if week.slots.count > 0 {
                        createDaySlots()
                    } else {
                        createSlots(isFirstStack: true)
                    }
                }
            }
        }
    }
}

/* MARK:- Actions */
extension CreateSlotsVC {
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
                if label.accessibilityIdentifier == WeekDays.monday.rawValue {
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else {
                    label.textColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                }
            }
            
            selectedDay = .monday
            removeAllSlots()
        } else if sender.accessibilityIdentifier == WeekDays.tuesday.rawValue {
            weekViews.forEach { (view) in
                if view.accessibilityIdentifier == WeekDays.tuesday.rawValue {
                    view.backgroundColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                } else {
                    view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                }
            }
            
            weekLabels.forEach { (label) in
                if label.accessibilityIdentifier == WeekDays.tuesday.rawValue {
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else {
                    label.textColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                }
            }
            
            selectedDay = .tuesday
            removeAllSlots()
        } else if sender.accessibilityIdentifier == WeekDays.wednesday.rawValue {
            weekViews.forEach { (view) in
                if view.accessibilityIdentifier == WeekDays.wednesday.rawValue {
                    view.backgroundColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                } else {
                    view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                }
            }
            
            weekLabels.forEach { (label) in
                if label.accessibilityIdentifier == WeekDays.wednesday.rawValue {
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else {
                    label.textColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                }
            }
            
            selectedDay = .wednesday
            removeAllSlots()
        } else if sender.accessibilityIdentifier == WeekDays.thursday.rawValue {
            weekViews.forEach { (view) in
                if view.accessibilityIdentifier == WeekDays.thursday.rawValue {
                    view.backgroundColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                } else {
                    view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                }
            }
            
            weekLabels.forEach { (label) in
                if label.accessibilityIdentifier == WeekDays.thursday.rawValue {
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else {
                    label.textColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                }
            }
            
            selectedDay = .thursday
            removeAllSlots()
        } else if sender.accessibilityIdentifier == WeekDays.friday.rawValue {
            weekViews.forEach { (view) in
                if view.accessibilityIdentifier == WeekDays.friday.rawValue {
                    view.backgroundColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                } else {
                    view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                }
            }
            
            weekLabels.forEach { (label) in
                if label.accessibilityIdentifier == WeekDays.friday.rawValue {
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else {
                    label.textColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                }
            }
            
            selectedDay = .friday
            removeAllSlots()
        } else if sender.accessibilityIdentifier == WeekDays.saturday.rawValue {
            weekViews.forEach { (view) in
                if view.accessibilityIdentifier == WeekDays.saturday.rawValue {
                    view.backgroundColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                } else {
                    view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                }
            }
            
            weekLabels.forEach { (label) in
                if label.accessibilityIdentifier == WeekDays.saturday.rawValue {
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else {
                    label.textColor = #colorLiteral(red: 0.2862745098, green: 0.4901960784, blue: 0.9764705882, alpha: 1)
                }
            }
            
            selectedDay = .saturday
            removeAllSlots()
        }
    }
    
    @IBAction func didTapAddNewSlot(_ sender: UIButton) {
        if stackNumber == 6 {
            self.showAlert(message: "You've reached maximum number of slots")
        } else {
            var shouldCreateSlot = true
            
            setteledSlots.forEach { (week) in
                if week.day == selectedDay {
                    if let slot = week.slots.last {
                        if slot.from == "" || slot.to == "" {
                            shouldCreateSlot = false
                        }
                    }
                }
            }
            
            if shouldCreateSlot {
                createSlots(isFirstStack: false)
            } else {
                self.showAlert(message: "Please fill the last slot first.")
            }
        }
    }
    
    @IBAction func didTapRemoveSlot(_ sender: UIButton) {
        removeSlot(withIdentifier: "stack-\(sender.tag)-\(selectedDay.rawValue)")
        
        setteledSlots.enumerated().forEach { (index,week) in
            if week.day == selectedDay {
                let identifier = "\(sender.tag)-\(selectedDay.rawValue)"
                setteledSlots[index].slots.enumerated().forEach { (sIndex, slot) in
                    if slot.identifier == identifier {
                        setteledSlots[index].slots.remove(at: sIndex)
                    }
                }
            }
        }
        
        Helper.debugLogs(any: setteledSlots)
    }
    
    @IBAction func didTapTextField (_ sender: UITextField) {
        sender.resignFirstResponder()
        
        selectedTextField = sender.accessibilityIdentifier ?? ""
        selectedTotextField = pickerViewToField
        
        addPickerView()
    }
    
    @IBAction func didTapDone (_ sender: UIToolbar) {
        toolBar    .removeFromSuperview()
        pickerView .removeFromSuperview()
    }
    
    @IBAction func didTapBack (_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapCreateSlots (_ sender: UIButton) {
        var mondayIndex     : Int               = 0
        var mondaySlots     : [String]          = []
        var mondayChunks    : [[String: Any]]   = []
        
        var tuesdayIndex    : Int               = 0
        var tuesdaySlots    : [String]          = []
        var tuesdayChunks   : [[String: Any]]   = []
        
        var wednesdayIndex  : Int               = 0
        var wednesdaySlots  : [String]          = []
        var wednesdayChunks : [[String: Any]]   = []
        
        var thursdayIndex   : Int               = 0
        var thursdaySlots   : [String]          = []
        var thursdayChunks  : [[String: Any]]   = []
        
        var fridayIndex     : Int               = 0
        var fridaySlots     : [String]          = []
        var fridayChunks    : [[String: Any]]   = []
        
        var saturdayIndex   : Int               = 0
        var saturdaySlots   : [String]          = []
        var saturdayChunks  : [[String: Any]]   = []
        
        setteledSlots.forEach { (week) in
            week.slots.forEach { (slot) in
                
                if slot.from != "" && slot.to != "" {
                    switch week.day {
                    case .monday:
                        let parameter: [String: Any] = [
                            "index"     : "\(mondayIndex)",
                            "from"      : slot.fromId,
                            "to"        : slot.toId,
                            "toIndex"   : slot.toIndex,
                            "fromIndex" : slot.fromIndex
                        ]
                        
                        mondayChunks.append(parameter)
                        
                        mondayIndex += 1
                    case .tuesday:
                        let parameter: [String: Any] = [
                            "index"     : "\(tuesdayIndex)",
                            "from"      : slot.fromId,
                            "to"        : slot.toId,
                            "toIndex"   : slot.toIndex,
                            "fromIndex" : slot.fromIndex
                        ]
                        
                        tuesdayChunks.append(parameter)
                        
                        tuesdayIndex += 1
                    case .wednesday:
                        let parameter: [String: Any] = [
                            "index"     : "\(wednesdayIndex)",
                            "from"      : slot.fromId,
                            "to"        : slot.toId,
                            "toIndex"   : slot.toIndex,
                            "fromIndex" : slot.fromIndex
                        ]
                        
                        wednesdayChunks.append(parameter)
                        
                        wednesdayIndex += 1
                    case .thursday:
                        let parameter: [String: Any] = [
                            "index"     : "\(thursdayIndex)",
                            "from"      : slot.fromId,
                            "to"        : slot.toId,
                            "toIndex"   : slot.toIndex,
                            "fromIndex" : slot.fromIndex
                        ]
                        
                        thursdayChunks.append(parameter)
                        
                        thursdayIndex += 1
                    case .friday:
                        let parameter: [String: Any] = [
                            "index"     : "\(fridayIndex)",
                            "from"      : slot.fromId,
                            "to"        : slot.toId,
                            "toIndex"   : slot.toIndex,
                            "fromIndex" : slot.fromIndex
                        ]
                        
                        fridayChunks.append(parameter)
                        
                        fridayIndex += 1
                    case .saturday:
                        let parameter: [String: Any] = [
                            "index"     : "\(saturdayIndex)",
                            "from"      : slot.fromId,
                            "to"        : slot.toId,
                            "toIndex"   : slot.toIndex,
                            "fromIndex" : slot.fromIndex
                        ]
                        
                        saturdayChunks.append(parameter)
                        
                        saturdayIndex += 1
                    }
                }
                
                allSlots.enumerated().forEach { (index,item) in
                    if index >= slot.fromIndex && index <= slot.toIndex {
                        if slot.from != "" && slot.to != "" {
                            switch week.day {
                            case .monday:
                                mondaySlots.append(item.id)
                            case .tuesday:
                                tuesdaySlots.append(item.id)
                            case .wednesday:
                                wednesdaySlots.append(item.id)
                            case .thursday:
                                thursdaySlots.append(item.id)
                            case .friday:
                                fridaySlots.append(item.id)
                            case .saturday:
                                saturdaySlots.append(item.id)
                            }
                        }
                    }
                }
                
                toAllSlots.enumerated().forEach { (index,item) in
                    if index >= slot.fromIndex && index <= slot.toIndex {
                        if slot.from != "" && slot.to != "" {
                            switch week.day {
                            case .monday:
                                mondaySlots.append(item.id)
                            case .tuesday:
                                tuesdaySlots.append(item.id)
                            case .wednesday:
                                wednesdaySlots.append(item.id)
                            case .thursday:
                                thursdaySlots.append(item.id)
                            case .friday:
                                fridaySlots.append(item.id)
                            case .saturday:
                                saturdaySlots.append(item.id)
                            }
                        }
                    }
                }
            }
        }
        
        let monday  : [String: Any] = [
            "day"         : WeekDays.monday.rawValue,
            "slots"       : mondaySlots,
            "slotsChunks" : mondayChunks
        ]
        let tuesday  : [String: Any] = [
            "day"         : WeekDays.tuesday.rawValue,
            "slots"       : tuesdaySlots,
            "slotsChunks" : tuesdayChunks
        ]
        let wednesday  : [String: Any] = [
            "day"         : WeekDays.wednesday.rawValue,
            "slots"       : wednesdaySlots,
            "slotsChunks" : wednesdayChunks
        ]
        let thursday  : [String: Any] = [
            "day"         : WeekDays.thursday.rawValue,
            "slots"       : thursdaySlots,
            "slotsChunks" : thursdayChunks
        ]
        let friday  : [String: Any] = [
            "day"         : WeekDays.friday.rawValue,
            "slots"       : fridaySlots,
            "slotsChunks" : fridayChunks
        ]
        let saturday  : [String: Any] = [
            "day"         : WeekDays.saturday.rawValue,
            "slots"       : saturdaySlots,
            "slotsChunks" : saturdayChunks
        ]
        
        let parameters: [String: Any] = [
            "slots" : [
                monday   ,
                tuesday  ,
                wednesday,
                thursday ,
                friday   ,
                saturday
            ]
        ]
    
        createSlots(parameters)
    }
    
    @IBAction func didTapParentView ( sender: UITapGestureRecognizer) {
        toolBar    .removeFromSuperview()
        pickerView .removeFromSuperview()
    }
}

/* MARK:- API Methods */
extension CreateSlotsVC {
    func getAllSlots(){
        showSpinner(onView: view)
        NetworkManager.sharedInstance.getAllSlots {  [weak self] (response) in
            guard let self = self else { return }
            
            self.removeSpinner()
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        do {
                            let data        = try JSON(data: response.data!)
                            self.allSlots   = data["fromTime"].arrayValue.map({Slots(json: $0)})
                            self.toAllSlots = data["toTime"].arrayValue.map({Slots(json: $0)})
                            self.dataSource = self.allSlots
                            self.toDataSource = self.toAllSlots
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
    
    func getUserSlots() {
        showSpinner(onView: view)
        NetworkManager.sharedInstance.getMySlots {  [weak self] (response) in
            guard let self = self else { return }
            
            self.removeSpinner()
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        do {
                            let data  = try JSON(data: response.data!)
                            let slots = data["slots"].arrayValue
                            
                            if slots.count > 0 {
                                self.setteledSlots.enumerated().forEach { (index,_) in
                                    self.setteledSlots[index].slots.removeAll()
                                }
                                
                                slots.forEach { (slot) in
                                    let day = slot["day"].stringValue
                                        
                                    if day == WeekDays.monday.rawValue {
                                        let monday = slot["slotsChunks"].arrayValue.map({TimeSlots(json: $0)})
                                        
                                        self.setteledSlots.enumerated().forEach { (index,week) in
                                            if week.day.rawValue == WeekDays.monday.rawValue {
                                                self.setteledSlots[index].slots = monday
                                                
                                                self.setteledSlots[index].slots.enumerated().forEach { (i,_) in
                                                    self.stackNumber = i + 1
                                                    self.setteledSlots[index].slots[i].identifier = "\(self.stackNumber)-\(WeekDays.monday.rawValue)"
                                                }
                                            }
                                        }
                                    } else if day == WeekDays.tuesday.rawValue {
                                        let tuesday = slot["slotsChunks"].arrayValue.map({TimeSlots(json: $0)})
                                        
                                        self.setteledSlots.enumerated().forEach { (index,week) in
                                            if week.day.rawValue == WeekDays.tuesday.rawValue {
                                                self.setteledSlots[index].slots = tuesday
                                                
                                                self.setteledSlots[index].slots.enumerated().forEach { (i,_) in
                                                    self.stackNumber = i + 1
                                                    self.setteledSlots[index].slots[i].identifier = "\(self.stackNumber)-\(WeekDays.tuesday.rawValue)"
                                                }
                                            }
                                        }
                                    } else if day == WeekDays.wednesday.rawValue {
                                        let wednesday = slot["slotsChunks"].arrayValue.map({TimeSlots(json: $0)})
                                        
                                        self.setteledSlots.enumerated().forEach { (index,week) in
                                            if week.day.rawValue == WeekDays.wednesday.rawValue {
                                                self.setteledSlots[index].slots = wednesday
                                                
                                                self.setteledSlots[index].slots.enumerated().forEach { (i,_) in
                                                    self.stackNumber = i + 1
                                                    self.setteledSlots[index].slots[i].identifier = "\(self.stackNumber)-\(WeekDays.wednesday.rawValue)"
                                                }
                                            }
                                        }
                                    } else if day == WeekDays.thursday.rawValue {
                                        let thursday = slot["slotsChunks"].arrayValue.map({TimeSlots(json: $0)})
                                        
                                        self.setteledSlots.enumerated().forEach { (index,week) in
                                            if week.day.rawValue == WeekDays.thursday.rawValue {
                                                self.setteledSlots[index].slots = thursday
                                                
                                                self.setteledSlots[index].slots.enumerated().forEach { (i,_) in
                                                    self.stackNumber = i + 1
                                                    self.setteledSlots[index].slots[i].identifier = "\(self.stackNumber)-\(WeekDays.thursday.rawValue)"
                                                }
                                            }
                                        }
                                    } else if day == WeekDays.friday.rawValue {
                                        let friday = slot["slotsChunks"].arrayValue.map({TimeSlots(json: $0)})
                                        
                                        self.setteledSlots.enumerated().forEach { (index,week) in
                                            if week.day.rawValue == WeekDays.friday.rawValue {
                                                self.setteledSlots[index].slots = friday
                                                
                                                self.setteledSlots[index].slots.enumerated().forEach { (i,_) in
                                                    self.stackNumber = i + 1
                                                    self.setteledSlots[index].slots[i].identifier = "\(self.stackNumber)-\(WeekDays.friday.rawValue)"
                                                }
                                            }
                                        }
                                    } else if day == WeekDays.saturday.rawValue {
                                        let saturday = slot["slotsChunks"].arrayValue.map({TimeSlots(json: $0)})
                                        
                                        self.setteledSlots.enumerated().forEach { (index,week) in
                                            if week.day.rawValue == WeekDays.saturday.rawValue {
                                                self.setteledSlots[index].slots = saturday
                                                
                                                self.setteledSlots[index].slots.enumerated().forEach { (i,_) in
                                                    self.stackNumber = i + 1
                                                    self.setteledSlots[index].slots[i].identifier = "\(self.stackNumber)-\(WeekDays.saturday.rawValue)"
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                                
                                self.createDaySlots()
                            } else {
                                self.createSlots(isFirstStack: true)
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
    
    func createSlots(_ parameters: [String: Any]) {
        showSpinner(onView: view)
        NetworkManager.sharedInstance.createSlots(parameters: parameters) {  [weak self] (response) in
            guard let self = self else { return }
            
            self.removeSpinner()
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        let alert = UIAlertController(
                            title          : APP_NAME       ,
                            message        : "Slots Created",
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
extension CreateSlotsVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
}

///Delegate
extension CreateSlotsVC: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if selectedTextField == pickerViewToField{
            return toDataSource[row].slot
        }
        else {
            return dataSource[row].slot
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let id            : String        = dataSource[row].id
        let time          : String        = dataSource[row].slot
        let to_Id         : String        = toDataSource[row].id
        let to_Time       : String        = toDataSource[row].slot
        let allTextFields : [UITextField] = Helper.getSubviewsOf(view: slotsStackView)
        
        allTextFields.forEach { (textField) in
            if textField.accessibilityIdentifier == selectedTextField ||
                textField.accessibilityIdentifier == selectedTotextField{
                if let identifier = textField.accessibilityIdentifier {
                    if identifier.contains("from") {
                        setteledSlots.enumerated().forEach { (index,week) in
                            if week.day == selectedDay {
                                setteledSlots[index].slots.enumerated().forEach { (sIndex,slot) in
                                    if sIndex == 0 {
                                        if slot.identifier == "\(textField.tag)-\(selectedDay.rawValue)" {
                                            setteledSlots[index].slots[sIndex].from      = time
                                            setteledSlots[index].slots[sIndex].fromIndex = row
                                            setteledSlots[index].slots[sIndex].fromId    = id
                                            textField.text = time
                                        }
                                    } else {
                                        if slot.identifier == "\(textField.tag)-\(selectedDay.rawValue)" {
                                            if let from = stringToTime(setteledSlots[index].slots[sIndex - 1].to),
                                               let to   = stringToTime(time) {
                                                if getTimeDifference(from: from, to: to) > 0 {
                                                    setteledSlots[index].slots[sIndex].from      = time
                                                    setteledSlots[index].slots[sIndex].fromIndex = row
                                                    setteledSlots[index].slots[sIndex].fromId    = id
                                                    textField.text = time
                                                } else {
                                                    self.showAlert(
                                                        message: "Please select time greater then the last time slot."
                                                    )
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else if identifier.contains("to") {
                        setteledSlots.enumerated().forEach { (index,week) in
                            if week.day == selectedDay {
                                setteledSlots[index].slots.enumerated().forEach { (sIndex,slot) in
                                    if slot.identifier == "\(textField.tag)-\(selectedDay.rawValue)" {
                                        if slot.from != "" {
                                            if let from = stringToTime(setteledSlots[index].slots[sIndex].from),
                                               let to   = stringToTime(to_Time) {
                                                
                                                if getTimeDifference(from: from, to: to) > 0 {
                                                    setteledSlots[index].slots[sIndex].to  = toDataSource[setteledSlots[index].slots[sIndex].fromIndex].slot
                                                    
                                                    setteledSlots[index].slots[sIndex].toIndex = setteledSlots[index].slots[sIndex].fromIndex
                                                    
                                                    setteledSlots[index].slots[sIndex].toId    = toDataSource[setteledSlots[index].slots[sIndex].fromIndex].id
                                                    textField.text = toDataSource[setteledSlots[index].slots[sIndex].fromIndex].slot
                                                } else {
                                                    self.showAlert(
                                                        message: "Please select time greater then the from time."
                                                    )
                                                }
                                                
                                            }
                                        } else {
                                            self.showAlert(message: "Please select the from time first.")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

/* MARK:- Helpers */
extension CreateSlotsVC {
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
}
