//
//  DetailViewController.swift
//  PhotoGramRealm
//
//  Created by 서승우 on 2023/09/05.
//

import RealmSwift
import UIKit

final class DetailViewControll: BaseViewController {

    let titleTextField = {
        let textField = WriteTextField()
        textField.placeholder = "제목을 입력해주세요"
        return textField
    }()

    let contentTextField = {
        let textField = WriteTextField()
        textField.placeholder = "내용을 입력해주세요"
        return textField
    }()

    var data: DiaryTable?

    let repository = DiaryTableRepository()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func configure() {
        super.configure()

        view.addSubview(titleTextField)
        view.addSubview(contentTextField)

        guard let data = data else {return}

        titleTextField.text = data.diaryTitle
        contentTextField.text = data.contents

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "수정",
            style: .plain,
            target: self,
            action: #selector(didTapRightBarButon)
        )
    }

    @objc
    func didTapRightBarButon() {
        guard let data else {return}

        repository.updateItem(id: data._id, title: titleTextField.text!, contents: contentTextField.text!)

    }

    override func setConstraints() {
        super.setConstraints()

        titleTextField.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(50)
            make.center.equalTo(view)
        }

        contentTextField.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(50)
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).offset(60)
        }
    }

}
