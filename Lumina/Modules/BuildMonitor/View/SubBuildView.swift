import SwiftUI
import BuildStatusChecker

struct SubBuildView: View {
    @ObservedObject var viewModel: SubBuildViewModel
    @State private var opacity = 1.0

    var repeatingAnimation: Animation {
        Animation.linear(duration: 1.0)
           .repeatForever()
    }

    var body: some View {
        VStack {
            Text(viewModel.title)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 5)
        .background(viewModel.backgroundColor)
        .cornerRadius(15)
        .opacity(opacity)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white, lineWidth: 2)
        )
        .onTapGesture {
            self.viewModel.openInBrowser()
        }
        .onAppear() {
            if self.viewModel.isRunning {
                withAnimation(self.repeatingAnimation) { self.opacity = 0.5 }
            }
        }
    }
}

struct SubBuildView_Previews: PreviewProvider {
    static var previews: some View {
        SubBuildView(viewModel: SubBuildViewModel(from: BuildRepresentation(wrapped: Build(id: "asdfghjk", buildNumber: 12345, status: .running, branch: "develop", triggeredAt: Date(), startedAt: nil, url: "https://www.bitrise.io", commitHash: "abc"))))
    }
}
