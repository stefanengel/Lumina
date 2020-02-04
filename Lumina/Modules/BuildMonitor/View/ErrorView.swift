import SwiftUI

struct ErrorView: View {
    var message: String

    var body: some View {
        HStack {
            Spacer()
            Text(message)
            Spacer()
        }
        .padding(.top, 15)
        .padding(.bottom, 15)
        .background(Color.red)
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(message: "An error occured")
    }
}
