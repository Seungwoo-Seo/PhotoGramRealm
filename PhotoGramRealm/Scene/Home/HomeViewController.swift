//
//  HomeViewController.swift
//  PhotoGramRealm
//
//  Created by jack on 2023/09/03.
//

import UIKit
import SnapKit
import RealmSwift

class HomeViewController: BaseViewController {
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.rowHeight = 100
        view.delegate = self
        view.dataSource = self
        view.register(PhotoListTableViewCell.self, forCellReuseIdentifier: PhotoListTableViewCell.reuseIdentifier)
        return view
    }()

    var tasks: Results<DiaryTable>!
    let repository = DiaryTableRepository()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 데이터를 한번이라도 가져오기만 한다면 데이터를 앞으로 신경 쓸 일 없이 사용 가능
        // 옵져버블 한거지 한마디로
//        print(realm.configuration.fileURL)
        tasks = repository.fetch()

        repository.checkSchemaVersion()

        print(tasks)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    override func configure() {
        view.addSubview(tableView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(plusButtonClicked))
        
        let sortButton = UIBarButtonItem(title: "정렬", style: .plain, target: self, action: #selector(sortButtonClicked))
        let filterButton = UIBarButtonItem(title: "필터", style: .plain, target: self, action: #selector(filterButtonClicked))
        let backupButton = UIBarButtonItem(title: "백업", style: .plain, target: self, action: #selector(backupButtonClicked))
        navigationItem.leftBarButtonItems = [sortButton, filterButton, backupButton]
    }
    
    override func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    @objc func plusButtonClicked() {
        navigationController?.pushViewController(AddViewController(), animated: true)
    }
    
    @objc func backupButtonClicked() {
        navigationController?.pushViewController(BackupViewController(), animated: true)
    }
    
    
    @objc func sortButtonClicked() {
        
    }
    
    @objc func filterButtonClicked() {
        tasks = repository.fetchFilter()
        tableView.reloadData()
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoListTableViewCell.reuseIdentifier) as? PhotoListTableViewCell else { return UITableViewCell() }

        let data = tasks[indexPath.row]

        cell.titleLabel.text = data.diaryTitle
        cell.contentLabel.text = "컨텐츠 레이블 컨텐츠 레이블 컨텐츠 레이블 컨텐츠 레이블 컨텐츠 레이블"
        cell.dateLabel.text = "데이트 레이블 데이트 레이블 데이트 레이블 데이트 레이블"

        cell.diaryImageView.image = loadImageFromDocument(fileName: "jack_\(data._id).jpg")

//        // String -> URL -> Data -> UIImage
//        // realm이 글로벌 쓰레드에 사용되면 트랜잭션에 이슈가 있을 수 있기 때문에 에러가 난다
//        // 그래서 따로 빼줌
//        let diaryPhoto = data.diaryPhoto ?? ""
//
//        // 1. 셀 서버통신 용량이 크다면 로드가 오래 걸릴 수 있음
//        // 2. 이미지를 미리 UIImage 형식으로 반환하고, 셀에서 UIImage를 바로 보여주자!
//        // => 재사용 매커니즘을 효율적으로 사용하지 못할 수도 있고, UIImage 배열 구성 자체가 오래 걸릴 수 있음
//        DispatchQueue.global().async {
//            if let url = URL(string: diaryPhoto), let data = try? Data(contentsOf: url) {
//
//                DispatchQueue.main.async {
//                    cell.diaryImageView.image = UIImage(data: data)
//                }
//            }
//        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = tasks[indexPath.row]

        let vc = DetailViewControll()
        vc.data = data
        navigationController?.pushViewController(
            vc,
            animated: true
        )


        // Realm Delete
//        removeImageFromDocument(fileName: "jack_\(data._id).jpg")
//
//        try! realm.write {
//            realm.delete(data)
//        }

//        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let like = UIContextualAction(style: .normal, title: nil) { action, view, completion in
            print("좋아요 선택~~~~!!!~!~!~!~!~!~!~")
        }

        let sample = UIContextualAction(style: .normal, title: "테스트") { action, view, completion in
            print("테스트 선택~~~~!!!~!~!~!~!~!~!~")
        }

        like.backgroundColor = .orange
        like.image = UIImage(systemName: "star.fill")

        return UISwipeActionsConfiguration(actions: [like, sample])
    }

}
