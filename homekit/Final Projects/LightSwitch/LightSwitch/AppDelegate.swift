//
//  AppDelegate.swift
//  HomeKit
//
//  Created by Vijay Sharma on 2018-02-13.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		let navigation = window!.rootViewController! as! UINavigationController
		let target = navigation.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
		navigation.pushViewController(target, animated: false)
		return true
	}

}

