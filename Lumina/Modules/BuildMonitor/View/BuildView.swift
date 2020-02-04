import SwiftUI

struct BuildView: View {
    private var viewModel: BuildViewModel
    @State var isRunning: Bool = false
    @State private var opacity = 1.0

    var repeatingAnimation: Animation {
        Animation.linear(duration: 1.0)
           .repeatForever()
    }

    init(viewModel: BuildViewModel) {
        self.viewModel = viewModel
        self.isRunning = viewModel.isRunning
    }

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text("\(viewModel.title)")
                .font(.system(size: 20))
                Text("\(viewModel.triggeredAt)")
                .font(.system(size: 12))
                VStack {
                    if viewModel.subtitle != nil {
                        Text("\(viewModel.subtitle!)")
                        .font(.system(size: 12))
                    }
                }
            }
            Spacer()
        }
        .padding(.top, 15)
        .padding(.bottom, 15)
        .background(viewModel.backgroundColor)
        .cornerRadius(15)
        .opacity(opacity)
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

struct BuildView_Previews: PreviewProvider {
    static var previews: some View {
        BuildView(viewModel: BuildViewModel(title: "Test Build", triggeredAt: "Triggered at", subtitle: "This is a subtitle", backgroundColor: .green, url: ""))
    }
}
