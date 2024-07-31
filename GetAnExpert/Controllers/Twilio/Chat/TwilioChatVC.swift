//
//  TwilioChatVC.swift
//  GetAnExpert
//
//  Created by Umar Farooq on 20/10/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import SwiftyJSON
import TwilioChatClient

class TwilioChatVC: UIViewController {
    
    /* MARK:- IBOutlets */
    @IBOutlet weak var messageTableView : UITableView!
    @IBOutlet weak var messageTextView  : GrowingTextView!
    
    var id = ""
    var app_Status = ""
    var providerId = ""
    var consumerId = ""
    
    /* MARK:- Lazy Properties */
    lazy var leftCellNib: UINib = {
        return UINib(nibName: Constants.TVCells.LEFT_CHAT_CELL, bundle: nil)
    }()
    
    lazy var rightCellNib: UINib = {
        return UINib(nibName: Constants.TVCells.RIGHT_CHAT_CELL, bundle: nil)
    }()
    
    /* MARK:- Properties */
    var token       : String = ""
    var isConnected : Bool   = false
    /// Twilio SDK Components

    let channelManager : ChannelManager = ChannelManager()
    
    /* MARK:- Life Cycle */
    override func viewDidLoad() {
        super.viewDidLoad()
        initVC()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startConnection()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.app_Status = "History"
        updateAppointmentStatus()
        channelManager.shutdown()
    }
}

/* MARK:-  Methods */
extension TwilioChatVC {
    func initVC() {
        channelManager.uniqueChannelName = "\(providerId)-\(id)-\(consumerId)"
        channelManager.delegate = self

        registerNibs()
    }
    
    func registerNibs(){
        messageTableView.register(leftCellNib, forCellReuseIdentifier: Constants.TVCells.LEFT_CHAT_CELL)
        messageTableView.register(rightCellNib, forCellReuseIdentifier: Constants.TVCells.RIGHT_CHAT_CELL)
        
        /// Table View Setup
        messageTableView.rowHeight            = UITableView.automaticDimension
        messageTableView.estimatedRowHeight   = 600
        
        messageTableView.contentInsetAdjustmentBehavior = .never
        
        messageTableView.reloadData()
    }
    
    func startConnection(){
        let myName = Constants.sharedInstance.USER?.name ?? ""
        channelManager.login(myName) { [weak self] success in
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                if success {
                    self.showToast(message: "Joined channel succesfully.")
                } else {
                    Helper.debugLogs(any: "Failed to joined channel.")
                }
                
                self.isConnected = success
            }
        }
    }
    
    private func scrollToBottomMessage() {
        if channelManager.messages.count == 0 {
            return
        }
        let bottomMessageIndex = IndexPath(
            row: channelManager.messages.count - 1,
            section: 0
        )
        messageTableView.scrollToRow(at: bottomMessageIndex, at: .bottom, animated: true)
    }
    
    func startCall(
        isVideoCall flag: Bool,
        withToken token: String,
        inRoom room: String
    ) {
        let videoCallVC = VideoCallVC(nibName: Constants.ViewControllers.VIDEO_CALL_VC, bundle: nil)
       
        videoCallVC.roomName             = room
        videoCallVC.accessToken          = token
        videoCallVC.shouldStartVideoCall = flag
        videoCallVC.id = id
        navigationController?.pushViewController(videoCallVC, animated: true)
    }
}

/* MARK:-  Actions */
extension TwilioChatVC {
    @IBAction func didTapVoiceCall(_ sender: UIButton) {
        startCall(isVideoCall: false, withToken: channelManager.token, inRoom: "Appointment")
    }
    
    @IBAction func didTapVideoCall(_ sender: UIButton) {
        /// TOOD:- PASS PARTNER ID AND NOT MINE
//        let myID = Constants.sharedInstance.USER?.id ?? ""
//        getVideoCallToken(forPartner: myID)
        
        startCall(isVideoCall: true, withToken: channelManager.token, inRoom: "Appointment")
    }
    
    @IBAction func didTapDismiss(_ sender: UIButton) {
//        self.showAlert(message: "You will not be able to join this meeting again")
        navigationController?.popViewController(animated: true )
    }
    
    @IBAction func didTapSend(_ sender: UIButton) {
        if isConnected {
            guard let message = messageTextView.text, message != "" else { return }
            
            channelManager.sendMessage(
                message,
                completion: { [weak self] (result, _) in
                    guard let self = self else { return }
                    
                    if result.isSuccessful() {
                        self.app_Status = "Connected"
                        self.updateAppointmentStatus()
                        self.messageTextView.text = ""
                        self.messageTextView.resignFirstResponder()
                    } else {
                        Helper.debugLogs(any: "Failed to send message")
                    }
                }
            )
        }
    }
}

/* MARK:- Growing Text View */

/// Delegate
extension TwilioChatVC: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(
            withDuration           : 0.3,
            delay                  : 0.0,
            usingSpringWithDamping : 0.7,
            initialSpringVelocity  : 0.7,
            options                : [.curveLinear],
        animations: { [weak self] in
            guard let self = self else { return }
            
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

/* MARK:- Table View */

/// Datasource
extension TwilioChatVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelManager.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row     = indexPath.row
        let message = channelManager.messages[row]
        let myName  = Constants.sharedInstance.USER?.name ?? ""
        
        if message.author != myName {
            let leftCell = tableView.dequeueReusableCell(
                withIdentifier: Constants.TVCells.LEFT_CHAT_CELL
            ) as! LeftChatCell

            leftCell.messageLabel.text = message.body

            return leftCell
        } else {
            let rightCell = tableView.dequeueReusableCell(
                withIdentifier: Constants.TVCells.RIGHT_CHAT_CELL
            ) as! RightChatCell

            rightCell.messageLabel.text = message.body

            return rightCell
        }
    }
}

/// Delegate
extension TwilioChatVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

/* MARK:- Twilio */

/// Channel Manager Delegate
extension TwilioChatVC: ChannelManagerDelegate {
    func reloadMessages() {
        messageTableView.reloadData()
    }

    func receivedNewMessage() {
        scrollToBottomMessage()
    }
}

extension TwilioChatVC{
    
    func updateAppointmentStatus(){
        showSpinner(onView: view)
        
        var parameters : [String: Any] = [:]
        let appointmentId = id
        let status        = app_Status
        
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
//                        if self.app_Status == "History"{
//                            self.navigationController?.popViewController(animated: true)
//                        }
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
