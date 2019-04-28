/**
 *  BackgroundExample
 *  Copyright (c) 2019 - present Alexis Aubry. Licensed under the MIT license.
 */

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        /// Reactivate the background manager when the app is launched in the foreground.
        if application.applicationState == .active {
            BackgroundTaskManager.shared.resume()
        }

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        /// Reactivate the background manager when the app enters the background.
        BackgroundTaskManager.shared.resume()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        /// Reactivate the background manager when the app enters the foreground.
        BackgroundTaskManager.shared.resume()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        /// Reactivate the background manager when the app becomes active.
        BackgroundTaskManager.shared.resume()
    }

}

