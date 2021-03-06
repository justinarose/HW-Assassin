//
//  AppDelegate.swift
//  HW Assassin
//
//  Created by James Kanoff on 3/2/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var user: User?
    var gameId: Int64?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        print("Did finish launching")
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let token = UserDefaults.standard.value(forKey: "token"), let user = UserDefaults.standard.value(forKey: "user"), let status = UserDefaults.standard.value(forKey: "status"){
            print("\(token)")
            print("\(user)")
            print("\(status)")
            let vc: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "in_game_tab_vc")
            
            self.user = User.userWithUserInfo(user as! [String : Any], inManageObjectContext: AppDelegate.viewContext)
            let dict = status as! [String: Any]
            self.gameId = dict["game"] as! Int64!
            
            self.window?.rootViewController = vc
        }
        else{
            print("Doesn't have user or token stored in UserDefaults")
            let vc: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "title_page_vc")
            
            self.window?.rootViewController = vc
        }
        
        let headers = ["Content-Type": "application/json"]
        
        Alamofire.request("https://hwassassin.hwtechcouncil.com/api/games/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
            debugPrint(response)
            
            //to get JSON return value
            if let result = response.result.value {
                let JSON = result as! NSArray
                print("Response JSON: \(JSON)")
                
                for g in JSON as! [[String: AnyObject]]{
                    Game.gameWithGameInfo(g, inManageObjectContext: AppDelegate.viewContext)
                }
                
                print("Created games")
                
                Alamofire.request("https://hwassassin.hwtechcouncil.com/api/users/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
                    debugPrint(response)
                    
                    //to get JSON return value
                    if let result = response.result.value {
                        let JSON = result as! NSArray
                        print("Response JSON: \(JSON)")
                        
                        for u in JSON as! [[String: AnyObject]]{
                            User.userWithUserInfo(u, inManageObjectContext: AppDelegate.viewContext)
                        }
                        
                        print("Created users")
                        
                        Alamofire.request("https://hwassassin.hwtechcouncil.com/api/statuses/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
                            debugPrint(response)
                            
                            //to get JSON return value
                            if let result = response.result.value {
                                let JSON = result as! NSArray
                                print("Response JSON: \(JSON)")
                                
                                for s in JSON as! [[String: AnyObject]]{
                                    UserGameStatus.statusWithStatusInfo(s, inManageObjectContext: AppDelegate.viewContext)
                                }
                                
                                print("Created statuses")
                            }
                        }
                        
                        Alamofire.request("https://hwassassin.hwtechcouncil.com/api/statuses/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
                            debugPrint(response)
                            
                            //to get JSON return value
                            if let result = response.result.value {
                                let JSON = result as! NSArray
                                print("Response JSON: \(JSON)")
                                
                                for s in JSON as! [[String: AnyObject]]{
                                    UserGameStatus.statusWithStatusInfo(s, inManageObjectContext: AppDelegate.viewContext)
                                }
                                
                                print("Created statuses")
                            }
                        }
                        /*
                        if self.user != nil && self.gameId != nil{
                            Alamofire.request("https://hwassassin.hwtechcouncil.com/api/posts/?killed=\(self.user!.id)&game=\(self.gameId!)&status=p").responseJSON{ response in
                                debugPrint(response)
                                
                                if let result = response.result.value{
                                    let JSON = result as! NSArray
                                    print("Response JSON: \(JSON)")
                                    
                                    if JSON.count > 0 {
                                        let postDict = JSON.firstObject!
                                        let post = Post.postWithPostInfo(postDict as! [String : Any], inManageObjectContext: AppDelegate.viewContext)
                                        let vc : VerifyKillViewController = mainStoryboard.instantiateViewController(withIdentifier: "verify_kill_vc") as! VerifyKillViewController
                                        vc.post = post
                                        self.window?.rootViewController?.present(vc, animated: true, completion: nil)
                                    }
                                }
                            }
                        }*/
                    }
                }
            }
        }
        
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if self.user != nil && self.gameId != nil{
            Alamofire.request("https://hwassassin.hwtechcouncil.com/api/posts/?killed=\(self.user!.id)&game=\(self.gameId!)&status=p").responseJSON{ response in
                debugPrint(response)
                
                if let result = response.result.value{
                    let JSON = result as! NSArray
                    print("Response JSON: \(JSON)")
                    
                    if JSON.count > 0 {
                        let postDict = JSON.firstObject!
                        let post = Post.postWithPostInfo(postDict as! [String : Any], inManageObjectContext: AppDelegate.viewContext)
                        let vc : VerifyKillViewController = mainStoryboard.instantiateViewController(withIdentifier: "verify_kill_vc") as! VerifyKillViewController
                        vc.post = post
                        self.window?.rootViewController?.present(vc, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
    }
    
    // MARK: - Cache
    
    lazy var cache: NSCache<NSString, NSData> = {
        let cache = NSCache<NSString, NSData>()
        return cache
    }()
    
    static var cache: NSCache<NSString, NSData> {
        return (UIApplication.shared.delegate as! AppDelegate).cache
    }

    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "HWAssassin")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    static func saveViewContext () {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    static var persistentContainer: NSPersistentContainer {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }
    
    static var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

}

