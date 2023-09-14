//
//  ToDoTable.swift
//  PhotoGramRealm
//
//  Created by 서승우 on 2023/09/08.
//

import Foundation
import RealmSwift

class ToDoTable: Object {
    // dynamic은 이전까지 사용됨?
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var title: String
    @Persisted var favorite: Bool

    // To Many Relationship
    @Persisted var detail: List<DetailTable> // []로 초기화 되어 이있는듯?

    // To One Relationship: EmbeddedObject(무조건 옵셔널 필수), 별도의 테이블이 생성되는 형태는 아님
    @Persisted var memo: Memo?

    convenience init(title: String, favorite: Bool) {
        self.init()

        self.title = title
        self.favorite = favorite
    }
}

class DetailTable: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var detail: String
    @Persisted var deadline: Date

    // Inverse Relationship Property (LinkingObjects) (역관계)
    @Persisted(originProperty: "detail") var mainTodo: LinkingObjects<ToDoTable>

    convenience init(detail: String, deadline: Date) {
        self.init()

        self.detail = detail
        self.deadline = deadline
    }
}

// EmbeddedObject를 상속받으면 다른 클래스의 프로퍼티로 사용될 수 잇다
class Memo: EmbeddedObject {
    @Persisted var content: String
    @Persisted var date: Date
}
