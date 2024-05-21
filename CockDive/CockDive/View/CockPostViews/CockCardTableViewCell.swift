import UIKit
import SwiftUI

// カスタムテーブルビューセル
class CockCardTableViewCell: UITableViewCell {
    
    private var postData: PostElement?
    private var friendData: UserFriendElement?
    weak var delegate: CockPostViewControllerDelegate?
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        return label
    }()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor(Color.pink)
        return button
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .black
        return button
    }()
    
    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let commentCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // セルのビューをセットアップするメソッド
    private func setupViews() {
        // 各ビューをセルのcontentViewに追加
        contentView.addSubview(iconImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(postImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(likeCountLabel)
        contentView.addSubview(commentCountLabel)
        
        // 各ビューのAuto Layout制約を有効にするためにtranslatesAutoresizingMaskIntoConstraintsをfalseに設定
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        likeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        commentCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 各ビューのレイアウト制約を設定
        NSLayoutConstraint.activate([
            // アイコン画像ビューの制約
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            // contentViewの上端から10ptの位置
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            // contentViewの左端から10ptの位置
            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            // 幅を50ptに設定
            iconImageView.heightAnchor.constraint(equalToConstant: 50),
            // 高さを50ptに設定
            
            // ユーザー名ラベルの制約
            userNameLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            // iconImageViewの垂直中央に揃える
            userNameLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            // iconImageViewの右端から10ptの位置
            
            // 投稿画像ビューの制約
            postImageView.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 10),
            // iconImageViewの下端から10ptの位置
            postImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            // contentViewの左端から10ptの位置
            postImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            // contentViewの右端から10pt内側の位置
            postImageView.heightAnchor.constraint(equalToConstant: 250),
            // 高さを250ptに設定
            
            // タイトルラベルの制約
            titleLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 10),
            // postImageViewの下端から10ptの位置
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            // contentViewの左端から10ptの位置
            
            // いいねボタンの制約
            likeButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            // titleLabelの下端から10ptの位置
            likeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            // contentViewの左端から10ptの位置
            likeButton.widthAnchor.constraint(equalToConstant: 30),
            // 幅を30ptに設定
            likeButton.heightAnchor.constraint(equalToConstant: 30),
            // 高さを30ptに設定
            
            // いいねカウントラベルの制約
            likeCountLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            // likeButtonの垂直中央に揃える
            likeCountLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 5),
            // likeButtonの右端から5ptの位置
            
            // コメントボタンの制約
            commentButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            // likeButtonの垂直中央に揃える
            commentButton.leadingAnchor.constraint(equalTo: likeCountLabel.trailingAnchor, constant: 20),
            // likeCountLabelの右端から20ptの位置
            commentButton.widthAnchor.constraint(equalToConstant: 30),
            // 幅を30ptに設定
            commentButton.heightAnchor.constraint(equalToConstant: 30),
            // 高さを30ptに設定
            
            // コメントカウントラベルの制約
            commentCountLabel.centerYAnchor.constraint(equalTo: commentButton.centerYAnchor),
            // commentButtonの垂直中央に揃える
            commentCountLabel.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: 5),
            // commentButtonの右端から5ptの位置
            
            // コメントカウントラベルのボトムアンカーの制約
            commentCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
            // contentViewの下端から10pt内側の位置
        ])
    }
    
    // セルを設定するメソッド
    func configure(with postData: PostElement, friendData: UserFriendElement?) {
        self.postData = postData
        self.friendData = friendData
        
        // アイコン画像を設定
        if let data = postData.postUserIconImage, let image = UIImage(data: data) {
            iconImageView.image = image
        } else {
            iconImageView.image = UIImage(systemName: "person.circle.fill")
        }
        
        userNameLabel.text = "\(postData.postUserNickName ?? "ニックネーム")さん"
        
        // 投稿画像を設定
        if let data = postData.postImage, let image = UIImage(data: data) {
            postImageView.image = image
        } else {
            postImageView.image = UIImage(systemName: "photo")
        }
        
        titleLabel.text = postData.title
        
        // Likeボタンの設定
        let likeImage = UIImage(systemName: "heart")
        likeButton.setImage(likeImage, for: .normal)
        likeCountLabel.text = "\(postData.likeCount)"
        
        // コメントボタンの設定
        commentButton.setImage(UIImage(systemName: "message"), for: .normal)
        commentCountLabel.text = "\(postData.comment.count)"
        
        // Likeボタンアクション
        likeButton.addTarget(self, action: #selector(handleLikeButtonTapped), for: .touchUpInside)
        
        // コメントボタンアクション
        commentButton.addTarget(self, action: #selector(handleCommentButtonTapped), for: .touchUpInside)
    }
    
    @objc private func handleLikeButtonTapped() {
        guard postData != nil else { return }
        // Likeボタンがタップされたときの処理
        print("ライクがタップされた！")
    }
    
    @objc private func handleCommentButtonTapped() {
        guard let postData = postData else { return }
        delegate?.didSelectPost(postData)
    }
}
