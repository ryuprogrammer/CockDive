import SwiftUI

struct FollowButtonView: View {
    @Binding var showIsFollow: Bool
    @Binding var isFollowButtonDisabled: Bool
    var hapticsManager: HapticsManager
    var profileVM: ProfileViewModel
    var showUser: UserElement

    var body: some View {
        HStack {
            Spacer()
            Button {
                isFollowButtonDisabled = true
                hapticsManager.playHapticPattern()
                Task {
                    await profileVM.followUser(friendUid: showUser.id ?? "")
                    profileVM.checkIsFollow(friendUid: showUser.id ?? "")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isFollowButtonDisabled = false
                }
            } label: {
                StrokeButtonUI(
                    text: showIsFollow ? "フォロー中" : "フォロー" ,
                    size: .small,
                    isFill: showIsFollow ? true : false
                )
                .foregroundStyle(Color.white.opacity(isFollowButtonDisabled ? 0.7 : 0.0))
            }
            .disabled(isFollowButtonDisabled)
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}
