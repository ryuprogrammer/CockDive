import SwiftUI
import CoreData

struct ImageCalendarView: View {
    // 表示されている月
    @Binding var showingDate: Date
    // 投稿データ
    @Binding var showMyPostData: [(day: Int, posts: [MyPostModel])]

    var body: some View {
        ScrollView {
            // 月の切り替えボタンと現在の月の表示
            HStack {
                // 前の月へのボタン
                Button {
                    showingDate = showingDate.previousMonth()
                } label: {
                    StrokeButtonUI(text: "\(showingDate.previousMonth().month())月", size: .small, isFill: false)
                }

                // 現在の月の表示
                StrokeButtonUI(text: showingDate.yearAndMonth(), size: .small, isFill: true)

                // 次の月へのボタン
                Button {
                    showingDate = showingDate.nextMonth()
                } label: {
                    StrokeButtonUI(text: "\(showingDate.nextMonth().month())月", size: .small, isFill: false)
                }
            }
            .padding(.top)

            // 曜日の表示 (月火水木金土日)
            HStack {
                ForEach(0..<Weekday.allCases.count, id: \.self) { week in
                    Text(Weekday(rawValue: week)?.name ?? "")
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 5)

            ZStack {
                // 日付と投稿画像のグリッド表示
                LazyVGrid(columns: Array(repeating: GridItem(), count: 7), spacing: 5) {
                    ForEach(0..<showingDate.numberOfDaysInMonth + showingDate.weekdayOfFirstDay.rawValue, id: \.self) { index in
                        if index < showingDate.weekdayOfFirstDay.rawValue {
                            Spacer()
                        } else {
                            let showDay = index - showingDate.weekdayOfFirstDay.rawValue + 1
                            SmallImageView(day: showDay, posts: Binding(
                                get: { getPosts(for: showDay) },
                                set: { _ in }
                            ))
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .animation(.linear, value: showingDate)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 5)

                if showMyPostData.isEmpty {
                    Text("記録はありません")
                        .font(.mainFont(size: 30))
                        .foregroundStyle(Color.mainColor)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundStyle(Color.whiteBlack)
                                .blur(radius: 20)
                        )
                }
            }
        }
    }

    // 指定した日付の投稿をすべて取得する関数
    private func getPosts(for day: Int) -> [MyPostModel] {
        return showMyPostData.first(where: { $0.day == day })?.posts ?? []
    }
}

struct ImageCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let samplePosts = [
            (day: 1, posts: [createSamplePost(context: context, id: "1", title: "Sample 1", memo: "Memo 1")]),
            (day: 3, posts: [createSamplePost(context: context, id: "2", title: "Sample 2", memo: "Memo 2")]),
            (day: 15, posts: [createSamplePost(context: context, id: "3", title: "Sample 3", memo: "Memo 3")])
        ]
        VStack {
            ImageCalendarView(showingDate: .constant(Date()), showMyPostData: .constant(samplePosts))

            ImageCalendarView(showingDate: .constant(Date()), showMyPostData: .constant([]))
        }
    }

    static func createSamplePost(context: NSManagedObjectContext, id: String, title: String, memo: String) -> MyPostModel {
        let post = MyPostModel(context: context)
        post.id = id
        post.title = title
        post.memo = memo
        post.createAt = Date()
        return post
    }
}
