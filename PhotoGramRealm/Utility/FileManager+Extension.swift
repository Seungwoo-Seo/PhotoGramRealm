//
//  FileManager+Extension.swift
//  PhotoGramRealm
//
//  Created by 서승우 on 2023/09/05.
//

import UIKit

extension UIViewController {

    func documentDirectoryPath() -> URL? {
        // 1. 도큐먼트 경로 찾기
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return nil}

        return documentDirectory
    }

    func removeImageFromDocument(fileName: String) {
        // 1. 도큐먼트 경로 찾기
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}

        // 2. 저장할 경로 설정(세부 경로, 이미지를 저장할 위치)
        let fileURL = documentDirectory.appendingPathComponent(fileName)

        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print(error)
        }
    }

    // 도큐먼트 폴더에서 이미지를 가져오는 메서드
    func loadImageFromDocument(fileName: String) -> UIImage {
        // 1. 도큐먼트 경로 찾기
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return UIImage(systemName: "star.fill")!}

        // 2. 저장할 경로 설정(세부 경로, 이미지를 저장할 위치)
        let fileURL = documentDirectory.appendingPathComponent(fileName)

        // 3. 경로에 파일이 유효한지
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)!
        } else {
            return UIImage(systemName: "star.fill")!
        }
    }

    // 도큐먼트 폴더에 이미지를 저장하는 메서드
    func saveImageToDocument(fileName: String, image: UIImage) {
        // 1. 도큐먼트 경로 찾기
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}

        let test = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!

        print("documnet -> ", documentDirectory)
        print("documnet -> ", test)

        // 2. 저장할 경로 설정(세부 경로, 이미지를 저장할 위치)
        let fileURL = documentDirectory.appendingPathComponent(fileName)

        // 3. 이미지 변환
        guard let data = image.jpegData(compressionQuality: 0.5) else {return}

        // 4. 이미지 저장
        do {
            try data.write(to: fileURL)
        } catch let error {
            print("file save error", error)
        }
    }


}
