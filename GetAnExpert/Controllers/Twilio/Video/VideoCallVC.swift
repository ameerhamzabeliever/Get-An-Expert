//
//  VideoCallVC.swift
//  GetAnExpert
//
//  Created by Umar Farooq on 19/10/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import TwilioVideo
import SwiftyJSON

class VideoCallVC: UIViewController {
    
    /* MARK:- IBOutlets */
    /// User
    @IBOutlet weak var camImageView  : UIImageView!
    @IBOutlet weak var micImageView  : UIImageView!
    @IBOutlet weak var userVideoView : VideoView!
    /// Participant
    @IBOutlet weak var participantVideoContainerView : UIView!
    
    /* MARK:- Properties */
    var accessToken = ""
    var roomName    = "TestRoom"
    var id = ""
    
    
    var shouldStartVideoCall : Bool = false
    
    // TwilioVideo SDK components
    var room              : Room?
    var camera            : CameraSource?
    var localVideoTrack   : LocalVideoTrack?
    var localAudioTrack   : LocalAudioTrack?
    var remoteParticipant : RemoteParticipant?
    var remoteView        : VideoView?
    
    
    /* MARK:- Lifecycle */
    override func viewDidLoad() {
        super.viewDidLoad()
        initVC()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        userVideoView.isHidden                 = !shouldStartVideoCall
        participantVideoContainerView.isHidden = !shouldStartVideoCall
        
    }
    
    deinit {
        // We are done with camera
        if let camera = self.camera {
            camera.stopCapture()
            self.camera = nil
        }
    }
}

/* MARK:- Methods */
extension VideoCallVC {
    func initVC() {
        if !Helper.isSimulator {
            if shouldStartVideoCall {
                startPreview() /// Start user's camera on userVideoView
                
                camImageView.image = UIImage(named: "camera-on")
            } else {
                camImageView.image = UIImage(named: "camera-off")
            }
            connect(withAccessToken: accessToken)
        }
    }
    
    /// Setup user's video view
    func startPreview() {

        let frontCamera = CameraSource.captureDevice(position: .front)
        let backCamera  = CameraSource.captureDevice(position: .back)

        if (frontCamera != nil || backCamera != nil) {

            let options = CameraSourceOptions { (builder) in
                if #available(iOS 13.0, *) {
                    // Track UIWindowScene events for the key window's scene.
                    // The example app disables multi-window support in the .plist (see UIApplicationSceneManifestKey).
                    if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
                       let windowScene = window.windowScene {
                        builder.orientationTracker = UserInterfaceTracker(scene: windowScene)
                    }
                    
                    ///UIApplication.shared.keyWindow!.windowScene!
                }
            }
            // Preview our local camera track in the local video preview view.
            camera = CameraSource(options: options, delegate: self)
            localVideoTrack = LocalVideoTrack(source: camera!, enabled: true, name: "Camera")

            // Add renderer to video track for local preview
            localVideoTrack!.addRenderer(userVideoView)
            Helper.debugLogs(any: "Video track created")

            
            if (frontCamera != nil && backCamera != nil) {
                // We will flip camera on tap.
                let tapSelector = #selector(didTapFlipCamera)
                let tapGesture  = UITapGestureRecognizer(target: self, action: tapSelector)
                userVideoView.addGestureRecognizer(tapGesture)
            }

            camera!.startCapture(
                device: frontCamera != nil ? frontCamera! : backCamera!
            ) { [weak self] captureDevice, videoFormat, error in
                guard let self = self else { return }
                
                if let error = error {
                    Helper.debugLogs(any: error.localizedDescription, and: "Capture failed")
                } else {
                    self.userVideoView.shouldMirror = (captureDevice.position == .front)
                }
            }
        }
        else {
            Helper.debugLogs(any: "No front or back capture device found!")
        }
    }
    
    /// Setup participant user's video view
    func setupRemoteVideoView() {
        // Creating `VideoView` programmatically
        remoteView = VideoView(frame: CGRect.zero, delegate: self)
        
        guard let remoteView = self.remoteView else { return }
        
        
        participantVideoContainerView.insertSubview(remoteView, at: 0)
        
        // `VideoView` supports scaleToFill, scaleAspectFill and scaleAspectFit
        // scaleAspectFit is the default mode when you create `VideoView` programmatically.
        remoteView.contentMode = .scaleAspectFit
        remoteView.translatesAutoresizingMaskIntoConstraints = false

        let remoteViewConstraints : [NSLayoutConstraint] = [
            remoteView.topAnchor.constraint(
                equalTo: participantVideoContainerView.topAnchor
            ),
            remoteView.leadingAnchor.constraint(
                equalTo: participantVideoContainerView.leadingAnchor
            ),
            remoteView.bottomAnchor.constraint(
                equalTo: participantVideoContainerView.bottomAnchor
            ),
            remoteView.trailingAnchor.constraint(
                equalTo: participantVideoContainerView.trailingAnchor
            )
        ]
        
        NSLayoutConstraint.activate(remoteViewConstraints)
    }
    
    func cleanupRemoteParticipant() {
        if self.remoteParticipant != nil {
            self.remoteView?.removeFromSuperview()
            self.remoteView = nil
            self.remoteParticipant = nil
        }
    }
    
    func renderRemoteParticipant(participant : RemoteParticipant) -> Bool {
        // This example renders the first subscribed RemoteVideoTrack from the RemoteParticipant.
        let videoPublications = participant.remoteVideoTracks
        for publication in videoPublications {
            if let subscribedVideoTrack = publication.remoteTrack,
                publication.isTrackSubscribed {
                setupRemoteVideoView()
                subscribedVideoTrack.addRenderer(self.remoteView!)
                self.remoteParticipant = participant
                return true
            }
        }
        return false
    }

    func renderRemoteParticipants(participants : Array<RemoteParticipant>) {
        for participant in participants {
            // Find the first renderable track.
            if participant.remoteVideoTracks.count > 0,
                renderRemoteParticipant(participant: participant) {
                break
            }
        }
    }
    
    func connect(withAccessToken token: String) {
        // Prepare local media which we will share with Room Participants.
        prepareLocalMedia()
        
        // Preparing the connect options with the access token that we fetched (or hardcoded).
        let connectOptions = ConnectOptions(token: token) { [weak self] builder in
            guard let self = self else { return }
            
            // Use the local media that we prepared earlier.
            builder.audioTracks = self.localAudioTrack != nil ? [self.localAudioTrack!] : [LocalAudioTrack]()
            builder.videoTracks = self.localVideoTrack != nil ? [self.localVideoTrack!] : [LocalVideoTrack]()
            
            // Use the preferred audio codec
            if let preferredAudioCodec = Settings.shared.audioCodec {
                builder.preferredAudioCodecs = [preferredAudioCodec]
            }
            
            // Use the preferred video codec
            if let preferredVideoCodec = Settings.shared.videoCodec {
                builder.preferredVideoCodecs = [preferredVideoCodec]
            }
            
            // Use the preferred encoding parameters
            if let encodingParameters = Settings.shared.getEncodingParameters() {
                builder.encodingParameters = encodingParameters
            }

            // Use the preferred signaling region
            if let signalingRegion = Settings.shared.signalingRegion {
                builder.region = signalingRegion
            }
            
            builder.roomName = self.roomName
        }
        
        // Connect to the Room using the options we provided.
        room = TwilioVideoSDK.connect(options: connectOptions, delegate: self)
        Helper.debugLogs(any: roomName, and: "Attempting to connect to room")
    }
    
    func prepareLocalMedia() {

        // We will share local audio and video when we connect to the Room.

        // Create an audio track.
        if (localAudioTrack == nil) {
            localAudioTrack = LocalAudioTrack(options: nil, enabled: true, name: "Microphone")

            if (localAudioTrack == nil) {
                Helper.debugLogs(any: "Failed to create audio track")
            }
        }

        // Create a video track which captures from the camera.
        if (localVideoTrack == nil) {
            if shouldStartVideoCall {
                self.startPreview()
            }
        }
   }
}

/* MARK:- Actions */
extension VideoCallVC {
    @IBAction func didTapFlipCamera() {
        var newDevice: AVCaptureDevice?

        if let camera = self.camera, let captureDevice = camera.device {
            if captureDevice.position == .front {
                newDevice = CameraSource.captureDevice(position: .back)
            } else {
                newDevice = CameraSource.captureDevice(position: .front)
            }

            if let newDevice = newDevice {
                camera.selectCaptureDevice(newDevice) { [weak self] (captureDevice, videoFormat, error) in
                    guard let self = self else { return }
                    
                    if let error = error {
                        Helper.debugLogs(any: error.localizedDescription, and: "Capture failed")
                    } else {
                        self.userVideoView.shouldMirror = (captureDevice.position == .front)
                    }
                }
            }
        }
    }
    
    @IBAction func didTapDisconnect(_ sender: UIButton) {
        room!.disconnect()
        Helper.debugLogs(any: "Attempting to disconnect from room \(room!.name)")
        updateAppointmentStatus()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func toggleMic(_ sender: UIButton) {
        if (self.localAudioTrack != nil) {
            self.localAudioTrack?.isEnabled = !(self.localAudioTrack?.isEnabled)!
            
            // Update the button title
            if (self.localAudioTrack?.isEnabled == true) {
                micImageView.image = UIImage(named: "mic-on")
            } else {
                micImageView.image = UIImage(named: "mic-off")
            }
        }
    }
    
    @IBAction func didTapDismiss(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func toggleCamers(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.startPreview()
            
            camImageView.image = UIImage(named: "camera-on")
            
            userVideoView.isHidden                 = false
            participantVideoContainerView.isHidden = false
        } else {
            camImageView.image = UIImage(named: "camera-off")
            
            userVideoView.isHidden                 = true
            participantVideoContainerView.isHidden = true
        }
    }
}

/* MARK:- Twilio Room */

/// Room Delegate 
extension VideoCallVC: RoomDelegate {
    func roomDidConnect(room: Room) {
        room.remoteParticipants.forEach({ $0.delegate = self })
        
        showToast(message: "Connected to room \(room.name)")
    }
    
    func roomDidDisconnect(room: Room, error: Error?) {
        self.cleanupRemoteParticipant()
        self.room = nil
        
        /// TODO:- Should dismiss the view after showing alert that the room is disconnected
        
        showToast(message: "Disconnected from room \(room.name)")
    }
    
    func roomDidFailToConnect(room: Room, error: Error) {
        self.room = nil
        
        /// TODO:- Should dismiss the view after showing alert that the room has failed to connect
        
        showToast(message: "Failed to connect to room")
    }

    func roomIsReconnecting(room: Room, error: Error) {
        showToast(message: "Reconnecting to room \(room.name)")
    }

    func roomDidReconnect(room: Room) {
        showToast(message: "Reconnected to room \(room.name)")
    }

    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        participant.delegate = self

        showToast(message: "Participant \(participant.identity) connected")
    }

    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        showToast(message: "Room \(room.name), Participant \(participant.identity) disconnected")
    }
}

/// Remote Participant Delegate
extension VideoCallVC: RemoteParticipantDelegate {
    func remoteParticipantDidPublishVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        // Remote Participant has offered to share the video Track.
        Helper.debugLogs(any: "remoteParticipantDidPublishVideoTrack")
    }

    func remoteParticipantDidUnpublishVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        // Remote Participant has stopped sharing the video Track.
        Helper.debugLogs(any: "remoteParticipantDidUnpublishVideoTrack")
    }

    func remoteParticipantDidPublishAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        // Remote Participant has offered to share the audio Track.
        Helper.debugLogs(any: "remoteParticipantDidPublishAudioTrack")
    }

    func remoteParticipantDidUnpublishAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        // Remote Participant has stopped sharing the audio Track.
        Helper.debugLogs(any: "remoteParticipantDidUnpublishAudioTrack")
    }

    func didSubscribeToVideoTrack(
        videoTrack: RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: RemoteParticipant
    ) {
        // The LocalParticipant is subscribed to the RemoteParticipant's video Track. Frames will begin to arrive now.
        
        Helper.debugLogs(any: "didSubscribeToVideoTrack")
        if (self.remoteParticipant == nil) {
            _ = renderRemoteParticipant(participant: participant)
        }
    }
    
    func didUnsubscribeFromVideoTrack(
        videoTrack: RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: RemoteParticipant
    ) {
        // We are unsubscribed from the remote Participant's video Track. We will no longer receive the
        // remote Participant's video.
        if self.remoteParticipant == participant {
            cleanupRemoteParticipant()

            // Find another Participant video to render, if possible.
            if var remainingParticipants = room?.remoteParticipants,
                let index = remainingParticipants.firstIndex(of: participant) {
                remainingParticipants.remove(at: index)
                renderRemoteParticipants(participants: remainingParticipants)
            }
        }
    }

    func didSubscribeToAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: RemoteParticipant
    ) {
        // We are subscribed to the remote Participant's audio Track. We will start receiving the
        // remote Participant's audio now.
    }
    
    func didUnsubscribeFromAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: RemoteParticipant
    ) {
        // We are unsubscribed from the remote Participant's audio Track. We will no longer receive the
        // remote Participant's audio.
    }

    func remoteParticipantDidEnableVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        
    }

    func remoteParticipantDidDisableVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        
    }

    func remoteParticipantDidEnableAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
       
    }

    func remoteParticipantDidDisableAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
       
    }

    func didFailToSubscribeToAudioTrack(
        publication: RemoteAudioTrackPublication,
        error: Error,
        participant: RemoteParticipant
    ) {
      
    }

    func didFailToSubscribeToVideoTrack(
        publication: RemoteVideoTrackPublication,
        error: Error,
        participant: RemoteParticipant
    ) {
        
    }
}

/// Video View Delegate
extension VideoCallVC: VideoViewDelegate {
    func videoViewDimensionsDidChange(view: VideoView, dimensions: CMVideoDimensions) {
        self.view.setNeedsDisplay()
    }
}

/// Camera Source Delegate
extension VideoCallVC: CameraSourceDelegate {
    func cameraSourceDidFail(source: CameraSource, error: Error) {
        Helper.debugLogs(any: error.localizedDescription, and: "Camera Failed")
    }
}

extension VideoCallVC{
    
    func updateAppointmentStatus(){
        showSpinner(onView: view)
        
        var parameters : [String: Any] = [:]
        let appointmentId = id
        let status   = "Connected"
        
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
