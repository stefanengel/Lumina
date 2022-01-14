import SwiftUI

struct UsageBarView: View {
    static let barHeight: CGFloat = 20
    let totalAmount: Int
    let usedAmount: Int
    let width: CGFloat
    
    fileprivate func calculateRedBarWidth() -> CGFloat {
        return width / CGFloat(totalAmount) * CGFloat(usedAmount)
    }
    
    var body: some View {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Colors.emerald)
                    .frame(height: 20)
                Rectangle()
                    .fill(Colors.carrot)
                    .frame(width: calculateRedBarWidth(), height: UsageBarView.barHeight)
            }
    }
}

struct UsageBarView_Previews: PreviewProvider {
    static var previews: some View {
        UsageBarView(
            totalAmount: 80,
            usedAmount: 35,
            width: 300
        )
    }
}
