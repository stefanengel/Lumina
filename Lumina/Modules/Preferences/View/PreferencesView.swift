import SwiftUI

struct PreferencesView: View {
    @ObservedObject private var viewModel: PreferencesViewModel
    @State var selectedIgnorePattern: IgnorePattern? = nil

    init(viewModel: PreferencesViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        TabView {
            // Settings
            VStack {
                HStack(alignment: .center) {
                    VStack(alignment: .trailing, spacing: 10.0) {
                        Text("Update interval:")
                            .frame(maxHeight: .infinity)
                        Text("Master branch name:")
                            .frame(maxHeight: .infinity)
                        Text("Develop branch name:")
                            .frame(maxHeight: .infinity)
                        Text("Feature branch prefix:")
                            .frame(maxHeight: .infinity)
                        Text("Release branch prefix:")
                            .frame(maxHeight: .infinity)
                        Text("Hotfix branch prefix:")
                            .frame(maxHeight: .infinity)
                        Text("Hide feature branches including:")
                        .frame(maxHeight: .infinity)
                    }
                    VStack(spacing: 10.0) {
                        Stepper("\(viewModel.updateIntervalInSeconds) seconds", value: $viewModel.updateIntervalInSeconds, in: 60...6000)
                        TextField("master", text: $viewModel.masterBranchName)
                        TextField("develop", text: $viewModel.developBranchName)
                        TextField("feature/", text: $viewModel.featureBranchPrefix)
                        TextField("release/", text: $viewModel.releaseBranchPrefix)
                        TextField("hotfix/", text: $viewModel.hotfixBranchPrefix)
                    }
                    .padding(.leading)
                }
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: HorizontalAlignment.leading) {
                    HStack {
                        Text("Ignore branches containing:")
                    }
                    HStack {
                        TextField("Branches containing this substring will be ignored", text: $viewModel.newIgnoreSubstring)
                        Button(action: {
                            self.viewModel.ignoreList.insert(IgnorePattern(pattern: self.viewModel.newIgnoreSubstring))
                            self.viewModel.newIgnoreSubstring = ""
                            debugPrint("Selected: \(self.selectedIgnorePattern?.pattern ?? "none")")
                        }) {
                            Text("Add")
                        }
                        .disabled(viewModel.newIgnoreSubstring == "")
                        Button(action: {
                            if let selected = self.selectedIgnorePattern {
                                self.viewModel.ignoreList.remove(selected)
                                self.selectedIgnorePattern = nil
                            }
                        }) {
                            Text("Delete selected")
                        }
                        .disabled(selectedIgnorePattern == nil)
                    }
                    HStack {
                        List(Array(viewModel.ignoreList)  , id: \.pattern, selection:
                        $selectedIgnorePattern) { substring in
                            IgnorePatternRow(ignorePattern: substring, selectedIgnorePattern: self.$selectedIgnorePattern)
                            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                Button(action: {
                    self.viewModel.saveSettings()
                }) {
                    Text("Save")
                }
                .padding()
            }
            .tabItem({ Text("Settings") })
            .tag(1)


            // Provider
            VStack {
                HStack(alignment: .center) {
                    VStack(alignment: .trailing, spacing: 10.0) {
                        Text("Bitrise base URL:")
                            .frame(maxHeight: .infinity)
                        Text("Bitrise auth token:")
                            .frame(maxHeight: .infinity)
                        Text("Bitrise app slug:")
                            .frame(maxHeight: .infinity)
                    }
                    VStack(spacing: 10.0) {
                        TextField("Bitrise base URL", text: $viewModel.bitriseBaseUrl)
                        TextField("Bitrise auth token", text: $viewModel.bitriseAuthToken)
                        TextField("Bitrise app slug", text: $viewModel.bitriseAppSlug)
                    }
                    .padding(.leading)
                }
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Button(action: {
                    self.viewModel.saveSettings()
                }) {
                    Text("Save")
                }
                .padding()
            }
            .padding()
            .tabItem({ Text("Provider") })
            .tag(0)
        }
    }

    struct PreferencesView_Previews: PreviewProvider {
        static var previews: some View {
            PreferencesView(viewModel: PreferencesViewModel())
        }
    }
}
