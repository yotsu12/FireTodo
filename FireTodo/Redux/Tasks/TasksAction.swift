//
// Copyright © Suguru Kishimoto. All rights reserved.
//

import Firebase
import FireSnapshot
import Foundation
import ReSwift

enum TasksAction: Action {
    case updateTasks(tasks: [Snapshot<Model.Task>])
    case updateListener(listener: ListenerRegistration?)

    static func subscribe(userID: String) -> AppThunkAction {
        AppThunkAction { dispatch, _ in
            let listener = Snapshot<Model.Task>.listen(Model.Path.tasks(userID: userID)) { result in
                switch result {
                case let .success(tasks):
                    dispatch(TasksAction.updateTasks(tasks: tasks))
                case let .failure(error):
                    print(error)
                    // error handling
                    dispatch(TasksAction.updateTasks(tasks: []))
                }
            }
            dispatch(TasksAction.updateListener(listener: listener))
        }
    }

    static func unsubscribe() -> AppThunkAction {
        AppThunkAction { dispatch, getState in
            getState()?.tasksState.tasksListener?.remove()
            dispatch(TasksAction.updateListener(listener: nil))
        }
    }

    static func deleteTask(_ task: Snapshot<Model.Task>) -> AppThunkAction {
        AppThunkAction { _, _ in
            task.remove()
        }
    }

    static func toggleTaskCompleted(_ task: Snapshot<Model.Task>) -> AppThunkAction {
        AppThunkAction { _, _ in
            task.data.completed.toggle()
            task.update()
        }
    }
}
