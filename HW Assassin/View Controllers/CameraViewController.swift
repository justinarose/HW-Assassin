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
import QuartzCore


class CameraViewController: UIViewController,NextLevelDelegate,NextLevelDeviceDelegate,NextLevelVideoDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var recordImageView: UIImageView!
    var statusView: UIView!
    var timeLeft: Double?
    var startTime: Date?
    var gesture: UILongPressGestureRecognizer!
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let previewView = self.cameraView {
            previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            previewView.backgroundColor = UIColor.black
            NextLevel.shared.previewLayer.frame = previewView.bounds
            previewView.layer.addSublayer(NextLevel.shared.previewLayer)
            
            
            self.gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureRecognizer(_:)))
            self.recordImageView.addGestureRecognizer(gesture)
            self.recordImageView.isUserInteractionEnabled = true
            
            let focusTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleFocusTapGestureRecognizer(_:)))
            focusTapGestureRecognizer.numberOfTapsRequired = 1
            previewView.addGestureRecognizer(focusTapGestureRecognizer)
            
            self.statusView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 2))
            self.statusView.backgroundColor = UIColor.red
            self.view.addSubview(self.statusView)
            
            
            timeLeft = 10.0
            
            NextLevel.shared.delegate = self
            NextLevel.shared.deviceDelegate = self
            NextLevel.shared.videoDelegate = self
            
            // modify .videoConfiguration, .audioConfiguration, .photoConfiguration properties
            // Compression, resolution, and maximum recording time options are available
            NextLevel.shared.videoConfiguration.maximumCaptureDuration = CMTimeMakeWithSeconds(10, 60)
            NextLevel.shared.audioConfiguration.bitRate = 44000
            NextLevel.shared.videoConfiguration.aspectRatio = .square
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated);
        
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
                self.statusView.frame = CGRect(x: 0, y: 0, width: 0, height: 2)
                self.gesture.isEnabled = true
            } catch {
                print("NextLevel, failed to start camera session with error \(error)")
            }
        }
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        
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
        if nextLevel.session == nil {
            do {
                try nextLevel.start()
                self.statusView.frame = CGRect(x: 0, y: 0, width: 0, height: 2)
                self.gesture.isEnabled = true
            } catch {
                print("NextLevel, failed to start camera session with error \(error)")
            }
        }
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
        //print("Started focus")
    }
    
    func nextLevelDidStopFocus(_  nextLevel: NextLevel){
        //print("Stopped focus")
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
        print("Completed clip")
        print("Clip count: \(nextLevel.session!.clips.count) ")
        if self.timeLeft! <= 0{
            self.endCapture()
        }
        
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
    
    
    // MARK: - Long Press Gesture Recognizer Delegate
    func handleLongPressGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            self.startCapture()
            print("Began")
            break
        case .ended:
            print("Ended")
            fallthrough
        case .cancelled:
            print("Cancelled")
            fallthrough
        case .failed:
            print("Failed")
            self.pauseCapture()
            fallthrough
        default:
            break
        }
    }
    
    // MARK: - Helper Functions
    func startCapture() {
        print("Starting capture")
        
        NextLevel.shared.record()
        
        UIView.animate(withDuration: timeLeft!, delay: 0, options: [.curveLinear, .allowUserInteraction], animations: { [unowned self] in
            self.statusView.frame = CGRect(origin: self.statusView.frame.origin, size: CGSize(width: self.view.frame.size.width, height: self.statusView.frame.size.height))
        }){[unowned self] completed in
            if completed{
                print("Finished animation")
                self.pauseCapture()
                self.gesture.isEnabled = false
            }
            else{
                print("Stopped animation")
            }
        }
        
        self.startTime = Date()
    }
    
    func pauseCapture() {
        print("Pausing capture")
        let interval = self.startTime?.timeIntervalSinceNow
        timeLeft = timeLeft! + interval!
        
        self.statusView.layer.removeAllAnimations()
        self.statusView.frame = CGRect(origin: self.statusView.frame.origin, size: CGSize(width: CGFloat((10-timeLeft!)/10.0) * self.view.frame.size.width, height: self.statusView.frame.size.height))
        
        print("Time left \(self.timeLeft!) Interval: \(interval!)")
        print("Total clips \(String(describing: NextLevel.shared.session?.duration.seconds))")
        
        
        NextLevel.shared.pause()
    }
    
    func endCapture(){
        if let session = NextLevel.shared.session {
            
            if session.clips.count > 1 {
                print("Multiple clips")
                NextLevel.shared.session?.mergeClips(usingPreset: AVAssetExportPresetLowQuality, completionHandler: { (url: URL?, error: Error?) in
                    if let videoUrl = url {
                        var fileSize : UInt64 = 0
                        
                        do {
                            //return [FileAttributeKey : Any]
                            let attr = try FileManager.default.attributesOfItem(atPath: videoUrl.path)
                            fileSize = attr[FileAttributeKey.size] as! UInt64
                            
                            //if you convert to NSDictionary, you can get file size old way as well.
                            let dict = attr as NSDictionary
                            fileSize = dict.fileSize()
                        } catch {
                            print("Error: \(error)")
                        }
                        
                        print("File size: \(fileSize) \(String(describing: url))")
                        
                        self.url = videoUrl
                        self.performSegue(withIdentifier: "viewVideo", sender: nil)
                        
                    } else if let _ = error {
                        print("failed to merge clips at the end of capture \(String(describing: error))")
                    }
                })
            } else {
                print("One clip")
                if let videoUrl = NextLevel.shared.session?.lastClipUrl {
                    self.url = videoUrl
                    self.performSegue(withIdentifier: "viewVideo", sender: nil)
                } else {
                    // prompt that the video has been saved
                    let alertController = UIAlertController(title: "Something failed!", message: "Something failed!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    func handleFocusTapGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        let tapPoint = gestureRecognizer.location(in: self.cameraView)
        let previewLayer = NextLevel.shared.previewLayer
        let adjustedPoint = previewLayer.captureDevicePointOfInterest(for: tapPoint)
        NextLevel.shared.focusExposeAndAdjustWhiteBalance(atAdjustedPoint: adjustedPoint)
    }
    
    
    @IBAction func finishedRecordingPressed(_ sender: Any) {
        self.endCapture()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        NextLevel.shared.stop()
        self.timeLeft = 10.0
        
        let vc = segue.destination as! VerifyPostViewController
        vc.url = self.url
        
    }
    

}
