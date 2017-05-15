//
//  MapViewController.swift
//  HW Assassin
//
//  Created by Justin Rose on 5/8/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Alamofire

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request: NSFetchRequest<Post> = Post.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        if let posts = (try? AppDelegate.viewContext.fetch(request)){
            for p in posts{
                let annotation = MKPointAnnotation()
                let centerCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(p.latitude), longitude:CLLocationDegrees(p.longitude))
                annotation.coordinate = centerCoordinate
                mapView.addAnnotation(annotation)
                print("Added annotation")
            }
        }
        
        mapView.showAnnotations(mapView.annotations, animated: false)
        mapView.camera.altitude *= 1.4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let dict = UserDefaults.standard.value(forKey: "status") as! [String: Any]
        let game = dict["game"] as! Int64
        let user = (UIApplication.shared.delegate as! AppDelegate).user
        
        if user != nil{
            Alamofire.request("https://hwassassin.hwtechcouncil.com/api/posts/?killed=\(user!.id)&game=\(game)&status=p").responseJSON{ response in
                debugPrint(response)
                
                if let result = response.result.value{
                    let JSON = result as! NSArray
                    print("Response JSON: \(JSON)")
                    
                    if JSON.count > 0 {
                        let postDict = JSON.firstObject!
                        let post = Post.postWithPostInfo(postDict as! [String : Any], inManageObjectContext: AppDelegate.viewContext)
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc : VerifyKillViewController = mainStoryboard.instantiateViewController(withIdentifier: "verify_kill_vc") as! VerifyKillViewController
                        vc.post = post
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        }
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
