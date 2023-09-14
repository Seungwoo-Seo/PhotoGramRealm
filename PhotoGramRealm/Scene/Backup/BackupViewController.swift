//
//  BackupViewController.swift
//  PhotoGramRealm
//
//  Created by 서승우 on 2023/09/07.
//

import SnapKit
import UIKit
import Zip

final class BackupViewController: BaseViewController {
    let backupButton = {
        let button = UIButton()
        button.backgroundColor = .orange
        return button
    }()
    let restoreButton = {
        let button = UIButton()
        button.backgroundColor = .green
        return button
    }()
    let backupTableView = {
        let tableView = UITableView()
        tableView.rowHeight = 50
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        backupTableView.delegate = self
        backupTableView.dataSource = self
    }

    override func configure() {
        super.configure()

        view.addSubview(backupTableView)
        view.addSubview(backupButton)
        view.addSubview(restoreButton)
        backupButton.addTarget(self, action: #selector(didTapBackupButton), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(didTapRestoreButton), for: .touchUpInside)
    }

    @objc func didTapBackupButton() {
        // 1. 백업하고자 하는 파일들의 경로 배열 생성
        var urlPaths = [URL]()

        // 2. 도큐먼트 위치
        guard let path = documentDirectoryPath() else {
            print("도큐먼트 위치에 오류가 있습니다.")
            return
        }

        // 3. 백업하고자 하는 파일 경로
        let realmFile = path.appendingPathComponent("default.realm")

        // 4. 3번 경로가 유효한 지 확인
        guard FileManager.default.fileExists(atPath: realmFile.path) else {
            print("백업할 파일이 없습니다")
            return
        }

        // 5. 압축하고자 하는 파일을 배열에 추가
        urlPaths.append(realmFile)

        // 6. 압축
        do {
            let zipFilePath = try Zip.quickZipFiles(urlPaths, fileName: "JackArchive")
            print("location: \(zipFilePath)")
        } catch {
            print("압축을 실패했어요")
        }
    }

    @objc func didTapRestoreButton() {
        // archive : 압축 파일
        // asCopy : 도큐먼트에서 파일을 복사해 올 것인지

        // 파일 앱을 통한 복구 진행
        let documentPicker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.archive],
            asCopy: true
        )
        documentPicker.delegate = self
        // 이게 여러개 선택할 수 없게 한거?
        documentPicker.allowsMultipleSelection = false

        present(documentPicker, animated: true)
    }

    override func setConstraints() {
        super.setConstraints()

        backupTableView.snp.makeConstraints { make in
            make.verticalEdges.horizontalEdges.equalToSuperview()
        }

        backupButton.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.top.leading.equalTo(view.safeAreaLayoutGuide)
        }

        restoreButton.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.top.trailing.equalTo(view.safeAreaLayoutGuide)
        }
    }

}

extension BackupViewController: UITableViewDataSource, UITableViewDelegate {

    func fetchZipList() -> [String] {
        var list: [String] = []

        do {
            guard let path = documentDirectoryPath() else {return list}
            // 1. 도큐먼트 위치에 있는 컨텐츠 디렉토리들을 가져오고
            let docs = try FileManager.default.contentsOfDirectory(
                at: path,
                includingPropertiesForKeys: nil
            )
            // 2. 그중 확장자가 zip인 도큐만 걸러내서
            let zip = docs.filter { $0.pathExtension == "zip" }

            // 3. 마지막 path로 짤라서 추가
            for i in zip {
                list.append(i.lastPathComponent)
            }
        } catch {
            print("Error")
        }

        return list
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return fetchZipList().count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = fetchZipList()[indexPath.row]
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        showActivityViewController(fileName: fetchZipList()[indexPath.row])
    }

    func showActivityViewController(fileName: String) {
        guard let path = documentDirectoryPath() else {
            print("도큐먼트 위치에 오류가 있어요")
            return
        }

        let backupFileURL = path.appendingPathComponent(fileName)

        let vc = UIActivityViewController(
            activityItems: [backupFileURL],
            applicationActivities: nil
        )
        present(vc, animated: true)
    }

}

extension BackupViewController: UIDocumentPickerDelegate {

    func documentPickerWasCancelled(
        _ controller: UIDocumentPickerViewController
    ) {
        print(#function)
    }

    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        // 파일 앱 내에 url
        guard let selectedFileURL = urls.first else {
            print("선택한 파일에 오류가 있어여")
            return
        }

        guard let path = documentDirectoryPath() else {
            print("도큐먼트 위치에 오류가 있어요")
            return
        }

        // 도큐먼트 폴더 내 저장할 경로 설정
        let sandboxFileURL = path.appendingPathComponent(selectedFileURL.lastPathComponent)

        // 경로에 복구할 파일(zip)이 이미 있는 지 확인
        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
            let fileURL = path.appendingPathComponent("JackArchive.zip")

            do {
                // overwrite : 덮어쓰기
                try Zip.unzipFile(fileURL, destination: path, overwrite: true, password: nil, progress: { progress in
                    print("progress : \(progress)")
                }, fileOutputHandler: { unzippedFile in
                    print("압축해제 완료 : \(unzippedFile)")
                    exit(0)
                })
            } catch {
                print("압축 해제 실패")
            }

        } else {
            // 경로에 복구할 파일이 없을 때의 대응
            do {
                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)

                let fileURL = path.appendingPathComponent("JackArchive.zip")

                try Zip.unzipFile(fileURL, destination: path, overwrite: true, password: nil, progress: { progress in
                    print("progress : \(progress)")
                }, fileOutputHandler: { unzippedFile in
                    print("압축해제 완료 : \(unzippedFile)")
                    exit(0)
                })
            } catch {
                print("압축 해제 실패")
            }
        }
    }

}
