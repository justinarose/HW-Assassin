//
//  CameraViewController.swift
//  HW Assassin
//
//  Created by Justin Rose on 4/19/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit
import NextLevel


class CameraViewController: UIViewController {
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
            NextLevel.shared.photoDelegate = self
            
            // modify .videoConfiguration, .audioConfiguration, .photoConfiguration properties
            // Compression, resolution, and maximum recording time options are available
            NextLevel.shared.videoConfiguration.maxRecordDuration = CMTimeMakeWithSeconds(5, 600)
            NextLevel.shared.audioConfiguration.bitRate = 44000
        

        }

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NextLevel.shared.start()
         NextLevel.shared.record()
    
    }
   
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NextLevel.shared.stop()
        NextLevel.shared.pause()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
