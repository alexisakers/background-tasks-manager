/**
 *  BackgroundExample
 *  Copyright (c) 2019 - present Alexis Aubry. Licensed under the MIT license.
 */

import UIKit

class ViewController: UIViewController {

    var messages: [String] = []

    /// An example method that uses the background task manager to send a message.
    func sendMessage(_ text: String) {
        let workItem = DispatchWorkItem(block: { [weak self] in
            self?.messages.append(text)
        })

        let backrgoundTask = BackgroundTask(name: "SendMessage", expirationHandler: {
            workItem.cancel()
        })

        BackgroundTaskManager.shared.perform(with: backrgoundTask) { task in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                if !workItem.isCancelled {
                    workItem.perform()
                    BackgroundTaskManager.shared.endBackgroundTask(task)
                }
            }
        }
    }

}

