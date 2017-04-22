//
//  CameraViewController.swift
//  HW Assassin
//
//  Created by Justin Rose on 4/19/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit
import NextLevel
import CoreMedia
import AVKit
import AVFoundation


class CameraViewController: UIViewController,NextLevelDelegate,NextLevelDeviceDelegate,NextLevelVideoDelegate {
    @IBOutlet weak var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let previewView = self.cameraView {
            previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            previewView.backgroundColor = UIColor.black
            NextLevel.shared.previewLayer.frame = previewView.bounds
            previewView.layer.addSublayer(NextLevel.shared.previewLayer)
            
            NextLevel.shared.delegate = self
            NextLevel.shared.deviceDelegate = self
            NextLevel.shared.videoDelegate = self
            
            // modify .videoConfiguration, .audioConfiguration, .photoConfiguration properties
            // Compression, resolution, and maximum recording time options are available
            NextLevel.shared.videoConfiguration.maximumCaptureDuration = CMTimeMakeWithSeconds(5, 600)
            NextLevel.shared.audioConfiguration.bitRate = 44000
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let nextLevel = NextLevel.shared
        
        if nextLevel.authorizationStatus(forMediaType: AVMediaTypeVideo) != .authorized{
            nextLevel.requestAuthorization(forMediaType: AVMediaTypeVideo)
        }
        if nextLevel.authorizationStatus(forMediaType: AVMediaTypeAudio) != .authorized{
            nextLevel.requestAuthorization(forMediaType: AVMediaTypeAudio)
        }
        if nextLevel.session == nil {
            do {
                try nextLevel.start()
            } catch {
                print("NextLevel, failed to start camera session with error \(error)")
            }
        }
    }
    
    func checkCameraAuthorization(_ status:AVAuthorizationStatus){
        if status == AVAuthorizationStatus.authorized{
            print("\(status) is authorized")
        }
        else if status == AVAuthorizationStatus.notDetermined{
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo){ granted in
                if granted{
                    print("\(status) granted")
                }
                else{
                    // create the alert
                    let alert = UIAlertController(title: "Not Authorized", message: "Please go to Settings and enable the camera for this app to use this feature.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        else if status == AVAuthorizationStatus.denied{
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo){ granted in
                if granted{
                    print("Camera granted")
                }
                else{
                    // create the alert
                    let alert = UIAlertController(title: "Not Authorized", message: "Please go to Settings and enable the camera for this app to use this feature.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
   
    
    override func viewWillDisappear(_ animated: Bool) {
        //NextLevel.shared.stop()
        //print("Stopping NextLevel")
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        NextLevel.shared.stop()
    }
    
    // MARK: - NextLevelDelegate
    
    // permission
    func nextLevel(_ nextLevel: NextLevel, didUpdateAuthorizationStatus status: NextLevelAuthorizationStatus, forMediaType mediaType: String){
        
    }
    
    // configuration
    func nextLevel(_ nextLevel: NextLevel, didUpdateVideoConfiguration videoConfiguration: NextLevelVideoConfiguration){
        
    }
    
    func nextLevel(_ nextLevel: NextLevel, didUpdateAudioConfiguration audioConfiguration: NextLevelAudioConfiguration){
        
    }
    
    // session
    func nextLevelSessionWillStart(_ nextLevel: NextLevel){
        
    }
    
    func nextLevelSessionDidStart(_ nextLevel: NextLevel){
        
    }
    
    func nextLevelSessionDidStop(_ nextLevel: NextLevel){
        
    }
    
    // session interruption
    func nextLevelSessionWasInterrupted(_ nextLevel: NextLevel){
        
    }
    
    func nextLevelSessionInterruptionEnded(_ nextLevel: NextLevel){
        
    }
    
    // preview
    func nextLevelWillStartPreview(_ nextLevel: NextLevel){
        
    }
    
    func nextLevelDidStopPreview(_ nextLevel: NextLevel){
        
    }
    
    // mode
    func nextLevelCaptureModeWillChange(_ nextLevel: NextLevel){
        
    }
    
    func nextLevelCaptureModeDidChange(_ nextLevel: NextLevel){
        
    }
    
    // MARK: - NextLevelDeviceDelegate
    
    // position, orientation
    func nextLevelDevicePositionWillChange(_ nextLevel: NextLevel){
        
    }
    
    func nextLevelDevicePositionDidChange(_ nextLevel: NextLevel){
        
    }
    
    func nextLevel(_ nextLevel: NextLevel, didChangeDeviceOrientation deviceOrientation: NextLevelDeviceOrientation){
        
    }
    
    // aperture
    func nextLevel(_ nextLevel: NextLevel, didChangeCleanAperture cleanAperture: CGRect){
        
    }
    
    // focus, exposure, white balance
    func nextLevelWillStartFocus(_ nextLevel: NextLevel){
        
    }
    
    func nextLevelDidStopFocus(_  nextLevel: NextLevel){
        
    }
    
    func nextLevelWillChangeExposure(_ nextLevel: NextLevel){
        
    }
    
    func nextLevelDidChangeExposure(_ nextLevel: NextLevel){
        
    }
    
    func nextLevelWillChangeWhiteBalance(_ nextLevel: NextLevel){
        
    }
    
    func nextLevelDidChangeWhiteBalance(_ nextLevel: NextLevel){
        
    }
    
    // MARK: - NextLevelVideoDelegate
    
    // video zoom
    func nextLevel(_ nextLevel: NextLevel, didUpdateVideoZoomFactor videoZoomFactor: Float){
        
    }
    
    // video processing
    func nextLevel(_ nextLevel: NextLevel, willProcessRawVideoSampleBuffer sampleBuffer: CMSampleBuffer){
        
    }
    
    func nextLevel(_ nextLevel: NextLevel, renderToCustomContextWithImageBuffer imageBuffer: CVPixelBuffer, onQueue queue: DispatchQueue){
        
    }
    
    // video recording session
    func nextLevel(_ nextLevel: NextLevel, didSetupVideoInSession session: NextLevelSession){
        
    }
    
    func nextLevel(_ nextLevel: NextLevel, didSetupAudioInSession session: NextLevelSession){
        
    }
    
    func nextLevel(_ nextLevel: NextLevel, didStartClipInSession session: NextLevelSession){
        
    }
    
    func nextLevel(_ nextLevel: NextLevel, didCompleteClip clip: NextLevelClip, inSession session: NextLevelSession){
        
    }
    
    func nextLevel(_ nextLevel: NextLevel, didAppendVideoSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession){
        
    }
    
    func nextLevel(_ nextLevel: NextLevel, didAppendAudioSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession){
        
    }
    
    func nextLevel(_ nextLevel: NextLevel, didSkipVideoSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession){
        
    }
    
    func nextLevel(_ nextLevel: NextLevel, didSkipAudioSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession){
        
    }
    
    func nextLevel(_ nextLevel: NextLevel, didCompleteSession session: NextLevelSession){
        
    }
    
    // video frame photo
    func nextLevel(_ nextLevel: NextLevel, didCompletePhotoCaptureFromVideoFrame photoDict: [String : Any]?){
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
