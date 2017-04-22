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
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var recordImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let previewView = self.cameraView {
            previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            previewView.backgroundColor = UIColor.black
            NextLevel.shared.previewLayer.frame = previewView.bounds
            previewView.layer.addSublayer(NextLevel.shared.previewLayer)
            
            
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureRecognizer(_:)))
            self.recordImageView.addGestureRecognizer(gesture)
            self.recordImageView.isUserInteractionEnabled = true
            
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
        print("Completed capture")
        endCapture()
    }
    
    // video frame photo
    func nextLevel(_ nextLevel: NextLevel, didCompletePhotoCaptureFromVideoFrame photoDict: [String : Any]?){
        
    }
    
    
    // MARK: - Long Press Gesture Recognizer Delegate
    func handleLongPressGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            self.startCapture()
            break
        case .ended:
            fallthrough
        case .cancelled:
            fallthrough
        case .failed:
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
    }
    
    func pauseCapture() {
        print("Pausing capture")
        NextLevel.shared.pause()
    }
    
    func endCapture(){
        if let session = NextLevel.shared.session {
            
            if session.clips.count > 1 {
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
                        
                        print("File size: \(fileSize)")
                        let player = AVPlayer(url: videoUrl)
                        let playerViewController = AVPlayerViewController()
                        playerViewController.player = player
                        self.present(playerViewController, animated: true) {
                            NextLevel.shared.stop()
                            playerViewController.player!.play()
                        }
                    } else if let _ = error {
                        print("failed to merge clips at the end of capture \(String(describing: error))")
                    }
                })
            } else {
                if let videoUrl = NextLevel.shared.session?.lastClipUrl {
                    print("\(videoUrl)")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
