import Cocoa
import SwiftUI

struct SearchField: NSViewRepresentable {
    @Binding var text: String
    private var placeholder: String

    init(text: Binding<String>, placeholder: String) {
        _text = text
        self.placeholder = placeholder
    }

    func makeNSView(context: Context) -> NSVisualEffectView {
        let wrapperView = NSVisualEffectView()
        let searchField = NSSearchField(string: "")
        searchField.delegate = context.coordinator
        searchField.isBordered = false
        searchField.isBezeled = true
        searchField.bezelStyle = .roundedBezel
        searchField.placeholderString = placeholder
        searchField.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.addSubview(searchField)
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: wrapperView.topAnchor),
            searchField.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor),
            searchField.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
            searchField.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor)
        ])
        return wrapperView
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        let searchField = nsView.subviews.first(where: {
            $0 as? NSSearchField != nil
        })
        (searchField as? NSSearchField)?.stringValue = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator { self.text = $0 }
    }

    final class Coordinator: NSObject, NSSearchFieldDelegate {
        var mutator: (String) -> Void

        init(_ mutator: @escaping (String) -> Void) {
            self.mutator = mutator
        }

        func controlTextDidChange(_ notification: Notification) {
            if let textField = notification.object as? NSTextField {
                mutator(textField.stringValue)
            }
        }
    }
}
