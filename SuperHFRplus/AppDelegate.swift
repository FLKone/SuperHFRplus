//
//  AppDelegate.swift
//  SuperHFRplus
//
//  Created by FLK on 06/11/2017.
//

import UIKit

@UIApplicationMain
//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

class AppDelegate: HFRplusAppDelegate, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        print("application didFinishLaunchingWithOptions")
        return super.legacy_application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
