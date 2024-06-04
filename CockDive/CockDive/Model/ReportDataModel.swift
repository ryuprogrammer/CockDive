import Foundation
import FirebaseFirestore

struct ReportDataModel {
    /// コレクション名
    private let reportDataCollection: String = "reports"
    private var db = Firestore.firestore()

    // MARK: - データ追加
    /// 通報を追加
    func addReport(report: ReportElement) async throws {
        do {
            // ReportElementをエンコード
            let encodedReport = try Firestore.Encoder().encode(report)

            // 新しいドキュメントを作成
            try await db.collection(reportDataCollection).addDocument(data: encodedReport)
        } catch {
            throw error
        }
    }
}
