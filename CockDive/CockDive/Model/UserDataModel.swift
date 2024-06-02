import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class UserDataModel {
    /// コレクション名
    private let userCollection: String = "userData"
    private let maxDocSize = 1000000
    private var db = Firestore.firestore()
    private var storage = Storage.storage()

    // MARK: - データ追加
    /// User追加/ 更新
    func addUser(user: UserElement, completion: @escaping (Result<String, Error>) -> Void) {
        // uid取得
        guard let uid = fetchUid() else {
            completion(.failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])))
            return
        }

        // ユーザーデータをFirestoreに保存
        saveUserData(user: user, uid: uid) { result in
            switch result {
            case .success:
                // アイコン画像がある場合はアップロード
                if let iconImage = user.iconImage {
                    self.addUserIconImage(iconImage: iconImage, uid: uid) { result in
                        switch result {
                        case .success(let iconURL):
                            var updatedUser = user
                            updatedUser.iconURL = iconURL
                            self.saveUserData(user: updatedUser, uid: uid) { result in
                                switch result {
                                case .success:
                                    completion(.success(iconURL))
                                case .failure(let error):
                                    completion(.failure(error))
                                }
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    completion(.success(""))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// ユーザーデータを保存
    private func saveUserData(user: UserElement, uid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        var userData = user
        // MARK: 画像サイズが大きい場合はnilにする
        if let imageDataSize = user.iconImage?.count {
            if imageDataSize > maxDocSize {
                // 画像サイズが大きいのでnilにする
                userData.iconImage = nil
            }
        }

        do {
            try db.collection(userCollection).document(uid).setData(from: userData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    /// iconImageを追加/ 更新
    func addUserIconImage(iconImage: Data, uid: String, completion: @escaping (Result<String, Error>) -> Void) {
        // storageに画像をアップロード
        let storageRef = self.storage.reference()

        // iconImageのアップロード
        let iconImageRef = storageRef.child("iconImage/\(uid)/icon.jpg")

        iconImageRef.putData(iconImage, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            iconImageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url.absoluteString))
                } else {
                    completion(.failure(NSError(domain: "DownloadURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL."])))
                }
            }
        }
    }

    // MARK: - データ取得
    /// uid取得
    func fetchUid() -> String? {
        return Auth.auth().currentUser?.uid
    }

    /// uidを指定してuserDataを取得: IconImage以外取得
    func fetchUserData(uid: String) async -> UserElement? {
        do {
            let document = try await db.collection(userCollection).document(uid).getDocument()

            guard document.data() != nil else {
                print("Document does not exist")
                return nil
            }

            let decodedUserData = try document.data(as: UserElement.self)

            // 使用するデータに応じて処理を追加
            print(decodedUserData)
            return decodedUserData
        } catch {
            print("Error fetching user data: \(error)")
        }
        return nil
    }

    /// uidを指定してiconImageを取得
    func fetchIconImage(uid: String) async -> Data? {
        let storageRef = self.storage.reference()
        let iconImageRef = storageRef.child("iconImage/\(uid)/icon.jpg")
        var iconData: Data?
        // アイコン画像をダウンロード
        iconImageRef.getData(maxSize: 10 * 1024 * 1024) { iconImageData, error in
            guard let iconImageData = iconImageData, error == nil else {
                return
            }
            iconData = iconImageData
        }

        return iconData
    }
}
