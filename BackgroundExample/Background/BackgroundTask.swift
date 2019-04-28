/**
 *  BackgroundExample
 *  Copyright (c) 2019 - present Alexis Aubry. Licensed under the MIT license.
 */

import UIKit

/**
 * Represents a task that you want to perform in the background.
 */

class BackgroundTask: NSObject {

    /// The name of the task.
    let name: String

    /// The expiration handler to execute when the app is about to be suspended.
    let expirationHandler: () -> Void

    /// Creates a new background task.
    init(name: String, expirationHandler: @escaping () -> Void) {
        self.name = name
        self.expirationHandler = expirationHandler
    }

}
