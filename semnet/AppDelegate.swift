//
//  AppDelegate.swift
//  semnet
//
//  Created by ceyda on 27/11/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit
import Alamofire

let userBaseURL = "http://107.170.24.239:9000/v1/user/"
let friendBaseURL = "http://107.170.24.239:9000/v1/friend/"
let contentBaseURL = "http://107.170.24.239:9000/v1/content/"
let searchBaseURL = "http://107.170.24.239:9000/v1/search/"

let loginEndpoint: String = userBaseURL + "/login"
let userCreateEndpoint: String = userBaseURL + "/create"
let userGetEndpoint: String = userBaseURL + "/get"
let userImageUploadEndpoint: String = userBaseURL + "/upload"
let userImageDownloadEndpoint: String = userBaseURL + "/download"
let userListAllEndpoint: String = userBaseURL + "/queryAllUsers"
let userSearchEndpoint: String = userBaseURL + "/query"
let userUpdateEndpoint: String = userBaseURL + "/update"

let friendListEndpoint: String = friendBaseURL + "/listFriends"
let friendAddEndpoint: String = friendBaseURL + "/addFriend"
let friendRemoveEndpoint: String = friendBaseURL + "/removeFriend"

let contentListEndpoint: String = contentBaseURL + "/list"
let contentGetEndpoint: String = contentBaseURL + "/get"
let contentCreateEndpoint: String = contentBaseURL + "/create"
let contentDownloadEndpoint: String = contentBaseURL + "/downloadContent"
let contentUploadEndpoint: String = contentBaseURL + "/upload"
let contentLikeEndpoint: String = contentBaseURL + "/like"
let contentUnlikeEndpoint: String = contentBaseURL + "/unlike"
let commentListEndpoint: String = contentBaseURL + "/listComments"
let commentAddEndpoint: String = contentBaseURL + "/addComment"
let commentDeleteEndpoint: String = contentBaseURL + "/removeComment"
let commentTagEndpoint: String = contentBaseURL + "/tag"

let searchLabelEndpoint: String = searchBaseURL + "/queryLabel"
let searchTagsEndpoint: String = searchBaseURL + "/querySearchString"
let searchContentEndpoint: String = searchBaseURL + "/searchContent"
let searchUserEndpoint: String = searchBaseURL + "/searchUser"
let searchAllTagsEndpoint: String = searchBaseURL + "/queryAllTags"

let screenWidth = UIScreen.main.bounds.width;
let screenHeight = UIScreen.main.bounds.height;

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        login()//call login
        
        window?.backgroundColor = .white
        
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
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func login() {
        
        // remember user's login
        let authToken : String? = UserManager.sharedInstance.getToken()
        
        // if logged in
        if authToken != nil {
            let userId = UserManager.sharedInstance.getUserId()
            
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let myTabBar = storyboard.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
            self.window?.rootViewController = myTabBar
            
            FriendManager.sharedInstance.loadFriendlist(userId: userId!) { (response) in
                    if(response.0){
                        FriendManager.sharedInstance.myFriendArray = response.1
                    }
                }
            }
        }
        
    }
    




