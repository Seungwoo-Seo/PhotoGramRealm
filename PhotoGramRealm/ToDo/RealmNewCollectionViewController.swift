//
//  RealmNewCollectionViewController.swift
//  PhotoGramRealm
//
//  Created by 서승우 on 2023/09/14.
//

import RealmSwift
import SnapKit
import UIKit

final class RealmNewCollectionViewController: UIViewController {

    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, ToDoTable>!

    var list: Results<ToDoTable>!

    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()

        list = realm.objects(ToDoTable.self)

        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        cellRegistration = UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            var content = UIListContentConfiguration.valueCell()
            content.image = itemIdentifier.favorite ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            content.text = itemIdentifier.title
            content.secondaryText = "\(itemIdentifier.detail.count)개의 세부 할 일"
            cell.contentConfiguration = content
        }
    }

    static func layout() -> UICollectionViewLayout {
        let configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        return layout
    }

}

extension RealmNewCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: list[indexPath.item]
        )
        return cell
    }

}
