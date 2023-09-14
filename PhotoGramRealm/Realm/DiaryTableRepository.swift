//
//  DiaryTableRepository.swift
//  PhotoGramRealm
//
//  Created by 서승우 on 2023/09/06.
//

import Foundation
import RealmSwift

protocol DiaryTableRepositoryType: AnyObject {
    func fetch() -> Results<DiaryTable>
    func fetchFilter()
    func createItem(_ item: DiaryTable)
}

class DiaryTableRepository {
    private let realm = try! Realm()

    private func a() { // ==> 다른 파일에서 쓸 일 없고, 클래스 안에서만 쓸 수 있음 ==> 오버라이딩 불가능 => final 처럼 동작
        
    }

    // 설정한 적은 없지만 디폴트로 처음엔 0으로 시작
    // 스키마가 하나라도 변경되면 버전 증가
    func checkSchemaVersion() {
        do {
            let version = try schemaVersionAtURL(realm.configuration.fileURL!)
            print("Schema Version: \(version)")
        } catch {
            print(error)
        }
    }

    func fetch() -> Results<DiaryTable> {
        let data = realm.objects(DiaryTable.self).sorted(byKeyPath: "diaryTitle", ascending: true)
        return data
    }

    func fetchFilter() -> Results<DiaryTable> {
        let result = realm.objects(DiaryTable.self).where {
//             1. 대소문자 구별 없음 - caseInsensitive
//            $0.diaryTitle.contains("제목", options: .caseInsensitive)
//
//             2. Bool
//            $0.diaryLike == true
//
//             3. 사진이 있는 데이터만 불러오기 (diaryPhoto의 nil 여부 판단)
            $0.photo != nil
        }

        return result
    }

    func createItem(_ item: DiaryTable) {
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {

        }
    }

    func updateItem(id: ObjectId, title: String, contents: String) {
        do {
            try realm.write {
                // 예를 들어서 date 같은 컬럼이 있으면 수정할 컬럼 뿐만 아니라 다른 컬럼도 업데이트할 때 써주면 될 듯?
//                realm.create(
//                    DiaryTable(
//                        value: [
//                            "_id": id,
//                            "diaryTitle": title,
//                            "diaryContent": contents
//                        ]
//                    ),
//                    update: .modified
//                )

                let item = DiaryTable(
                    value: [
                        "_id": id,
                        "diaryTitle": title,
                        "diaryContent": contents
                    ]
                )

                realm.add(item, update: .modified)
            }
        } catch {
            print("\(error.localizedDescription)")
        }
    }

}
