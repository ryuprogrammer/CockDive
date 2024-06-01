import Foundation

let ngWords: [String] = [
    "殺", "ころす", "コロス", "死", "しぬ", "虐待", "暴力", "襲う", "暴行", "テロ",
    "爆弾", "誘拐", "武器", "麻薬", "ドラッグ", "売春", "ポルノ", "詐欺", "盗む",
    "犯罪", "セックス", "SEX", "贈収賄", "人身売買", "密輸", "密輸入", "密売",
    "強盗", "窃盗", "泥棒", "銃", "弾薬", "戦争", "クズ", "寄生虫", "ゴミ",
    "役立たず", "無能", "ばか", "アホ", "エロ"
]

extension String {
    func containsNGWord() -> Bool {
        for word in ngWords {
            if self.contains(word) {
                return true
            }
        }
        return false
    }

    func limitTextLength(maxLength: Int) -> String {
        guard maxLength > 0 else { return self }
        if self.count > maxLength - 1 {
            let endIndex = self.index(self.startIndex, offsetBy: maxLength - 1)
            return String(self[..<endIndex]) + "..."
        } else {
            return self
        }
    }
}
