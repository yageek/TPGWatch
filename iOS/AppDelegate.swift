//
//  AppDelegate.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 04.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import UIKit
import CoreData
import TPGSwift
import WatchConnectivity
import ProcedureKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var proxy: WatchProxy?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        applyAppearance()

        #if DEBUG
            LogManager.severity = .verbose
        #else
            LogManager.severity = .fatal
        #endif

        API.Key = TPGKey
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        tryWatchConnection()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        Store.shared.save()
    }

    // MARK: - Core Data stack

}

// MARK: App Delegate UI Default

extension AppDelegate {

    func applyAppearance() {

        applyDefaultNavigationBar()
        applyDefaulTableViewCell()
    }

    func applyDefaultNavigationBar() {

        let navBar = UINavigationBar.appearance()

        if #available(iOS 11, *) {
            navBar.barTintColor = UIColor.appOrange()
            navBar.barStyle = .black
            navBar.tintColor = UIColor.white
            navBar.titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.white]
        } else {
            navBar.barTintColor = UIColor.appOrange()
            navBar.barStyle = .black
            navBar.tintColor = UIColor.white
            navBar.titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.white]
        }
    }

    func applyDefaulTableViewCell() {

        let cell = UITableView.appearance()
        cell.tintColor = UIColor.appOrange()
    }

    func tryWatchConnection() {
        if proxy == nil {
            proxy = WatchProxy.shared
        }
    }

}
