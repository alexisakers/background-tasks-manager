/**
 *  BackgroundExample
 *  Copyright (c) 2019 - present Alexis Aubry. Licensed under the MIT license.
 */

import UIKit

/**
 * Manages an coordinates the execution of background tasks.
 *
 * Use this object to schedule and end task that require extra running time when moves to the
 * background.
 *
 * This object can be called from any thread.
 *
 * You need to call `activate` when the app can execute background tasks again.
 *
 * Ideas for improvement: you can add logging to this class, and attach them to your crash logs
 * when the user reopens the app and there is a crash.
 */

class BackgroundTaskManager {

    /// The shared task manager.
    static let shared = BackgroundTaskManager()

    // MARK: - Internal State

    /// The internal background task managed by the .
    private (set) var managedTask: UIBackgroundTaskIdentifier?

    /// The tasks that are currently running.
    private(set) var tasks: Set<BackgroundTask> = []

    /// The queue that is responsible for managing the state of the object.
    private let isolationQueue = DispatchQueue(label: "fr.alexaubry.BackgroundTaskManager")

    // MARK: - Properties

    /// Whether there are any active tasks running.
    var isActive: Bool {
        return isolationQueue.sync {
            managedTask != nil && managedTask != .invalid
        }
    }

    // MARK: - Handling State Change

    /**
     * Call this method to notify the background task manager that the system accepts
     * starting background tasks again.
     */

    func resume() {
        isolationQueue.sync {
            if managedTask == .invalid {
                managedTask = nil
            }
        }
    }

    // MARK: - Managing Tasks

    /**
     * Begins a new backrgound task associated with the code to run if the task could successfully
     * be scheduled.
     * - parameter task: The description of the task to start.
     * - parameter block: The block to execute if the system allows running background tasks/
     */

    func perform(with task: BackgroundTask, executing block: @escaping (BackgroundTask) -> Void) {
        isolationQueue.sync {
            switch self.managedTask {
            case .invalid?:
                task.expirationHandler()
            case .some:
                block(task)
            case .none:
                guard beginInternalBackgroundTask() else {
                    return task.expirationHandler()
                }

                block(task)
            }
        }
    }

    /**
     * Ends the specified background task, and notifies UIKit in case there are no tasks left.
     * - parameter task: The task that finished executing.
     */

    func endBackgroundTask(_ task: BackgroundTask) {
        isolationQueue.sync {
            tasks.remove(task)

            if let currentTask = managedTask, tasks.isEmpty {
                UIApplication.shared.endBackgroundTask(currentTask)
                managedTask = nil
            }
        }
    }

    // MARK: - UIApplication Wrapper

    /// Attempts to start a UIApplication background task.
    private func beginInternalBackgroundTask() -> Bool {
        let taskID = UIApplication.shared.beginBackgroundTask(withName: "BackgroundTaskManagerTask") {
            self.isolationQueue.sync {
                self.handleExpiration()
            }
        }

        guard taskID != .invalid else {
            handleExpiration()
            return false
        }

        return true
    }

    /// Handles the expiration of the app by blocking new tasks from running.
    private func handleExpiration() {
        for task in self.tasks {
            task.expirationHandler()
            tasks.remove(task)
        }

        if let managedTask = self.managedTask {
            UIApplication.shared.endBackgroundTask(managedTask)
        }

        // Don't set the nil because we don't want to allows starting new tasks.
        self.managedTask = .invalid
    }

}
