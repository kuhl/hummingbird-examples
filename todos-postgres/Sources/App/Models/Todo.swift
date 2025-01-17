//===----------------------------------------------------------------------===//
//
// This source file is part of the Hummingbird server framework project
//
// Copyright (c) 2021-2021 the Hummingbird authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See hummingbird/CONTRIBUTORS.txt for the list of Hummingbird authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation
import Hummingbird
import PostgresNIO

final class Todo: HBResponseCodable {
    var id: UUID
    var title: String
    var order: Int?
    var url: String
    var completed: Bool?

    init(id: UUID, title: String, order: Int? = nil, url: String, completed: Bool? = nil) {
        self.id = id
        self.title = title
        self.order = order
        self.url = url
        self.completed = completed
    }

    func update(from edit: EditTodo) {
        if let title = edit.title {
            self.title = title
        }
        if let order = edit.order {
            self.order = order
        }
        if let completed = edit.completed {
            self.completed = completed
        }
    }

    func update(from todo: Todo) {
        self.title = todo.title
        if let order = todo.order {
            self.order = order
        }
        if let completed = todo.completed {
            self.completed = completed
        }
    }
}

struct EditTodo: HBResponseCodable {
    var title: String?
    var order: Int?
    var completed: Bool?
}
