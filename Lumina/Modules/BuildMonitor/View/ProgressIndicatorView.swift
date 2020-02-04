import SwiftUI
import AppKit

struct ProgressIndicatorView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSProgressIndicator {
        let indicator = NSProgressIndicator()

        indicator.controlSize = .regular
        indicator.isIndeterminate = true
        indicator.style = .spinning
        indicator.startAnimation(self)

        return indicator
    }

    func updateNSView(_ textView: NSProgressIndicator, context: Context) {
    }
}
