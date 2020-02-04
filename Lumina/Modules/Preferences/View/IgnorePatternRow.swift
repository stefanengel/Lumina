import SwiftUI

struct IgnorePatternRow: View {
    var ignorePattern: IgnorePattern
    @Binding var selectedIgnorePattern: IgnorePattern?

    var body: some View {
        HStack {
            Text("\(ignorePattern.pattern)")
            .padding(3)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .background(self.ignorePattern == selectedIgnorePattern ? Color.blue : Color.clear)
        .onTapGesture {
                self.selectedIgnorePattern = self.ignorePattern
        }
        .padding(-10)
    }
}
