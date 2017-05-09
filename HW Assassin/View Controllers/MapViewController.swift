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
