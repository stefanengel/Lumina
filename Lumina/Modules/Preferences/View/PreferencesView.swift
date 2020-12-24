import SwiftUI

struct PreferencesView: View {
    @ObservedObject private var viewModel: PreferencesViewModel
    @State var selectedIgnorePattern: IgnorePattern? = nil
    @State var selectedWorkflow: String? = nil

    @State var sliderValue = 60.0
    var minSliderValue = 60.0
    var maxSliderValue = 600.00

    init(viewModel: PreferencesViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        TabView {
            // Settings
            VStack {
                HStack(alignment: .center) {
                    VStack(alignment: .trailing, spacing: 10.0) {
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
                    }
                    VStack(spacing: 10.0) {
                        TextField("master", text: $viewModel.masterBranchName)
                            .frame(maxHeight: .infinity)
                        TextField("develop", text: $viewModel.developBranchName)
                            .frame(maxHeight: .infinity)
                        TextField("feature/", text: $viewModel.featureBranchPrefix)
                            .frame(maxHeight: .infinity)
                        TextField("release/", text: $viewModel.releaseBranchPrefix)
                            .frame(maxHeight: .infinity)
                        TextField("hotfix/", text: $viewModel.hotfixBranchPrefix)
                            .frame(maxHeight: .infinity)
                    }
                    .padding(.leading)
                }
                .padding(.horizontal)
//                .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: HorizontalAlignment.leading) {
                    Toggle(isOn: $viewModel.disableSeasonalDecorations) {
                        Text("Disable seasonal decorations")
                    }
                    .padding(.vertical)

                    HStack {
                        VStack {
                            Text("Update interval:")
                                .frame(maxHeight: .infinity)
                        }
                        VStack {
                            Stepper("\(viewModel.updateIntervalInSeconds) seconds", value: $viewModel.updateIntervalInSeconds, in: 60...6000)
                        }
                    }
                    .padding(.bottom, 10.0)
//                    .fixedSize(horizontal: false, vertical: true)

                    // Ignore branches
                    HStack {
                        Text("Ignore branches containing:")
                    }
                    HStack {
                        TextField("Branches containing this substring will be ignored", text: $viewModel.newIgnoreSubstring)
                        Button(action: {
                            self.viewModel.ignoreList.insert(IgnorePattern(pattern: self.viewModel.newIgnoreSubstring))
                            self.viewModel.newIgnoreSubstring = ""
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
                        .frame(minHeight: 200)
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                Button(action: {
                    self.viewModel.saveSettings()
                }) {
                    Text("Apply")
                }
                .padding()
            }
            .padding(.top, 10.0)
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
                            .frame(maxHeight: .infinity)
                        TextField("Bitrise auth token", text: $viewModel.bitriseAuthToken)
                            .frame(maxHeight: .infinity)
                        TextField("Bitrise app slug", text: $viewModel.bitriseAppSlug)
                            .frame(maxHeight: .infinity)
                    }
                    .padding(.leading)
                }
                .padding(.horizontal)
                .padding(.bottom, 10.0)
//                .fixedSize(horizontal: false, vertical: true)

                Toggle(isOn: $viewModel.groupByBuildNumber) {
                    Text("Group triggered builds by parent build number")
                }
                .padding(.vertical)

                // Workflows
                HStack {
                    Text("Workflows to consider:")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    TextField("Branches running with this workflow will be considered", text: $viewModel.newWorkflowString)
                    Button(action: {
                        self.viewModel.workflowList.insert( self.viewModel.newWorkflowString)
                        self.viewModel.newWorkflowString = ""
                    }) {
                        Text("Add")
                    }
                    .disabled(viewModel.newWorkflowString == "")
                    Button(action: {
                        if let selected = self.selectedWorkflow {
                            self.viewModel.workflowList.remove(selected)
                            self.selectedWorkflow = nil
                        }
                    }) {
                        Text("Delete selected")
                    }
                    .disabled(selectedWorkflow == nil)
                }
                HStack {
                    List(Array(viewModel.workflowList), id: \.self, selection:
                    $selectedWorkflow) { workflow in
                        Text(workflow)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    .frame(minHeight: 200)
                }

                Button(action: {
                    self.viewModel.saveSettings()
                }) {
                    Text("Apply")
                }
                .padding()
            }
            .padding()
            .tabItem({ Text("Provider") })
            .tag(0)
        }
        .frame(minHeight: 600)
        .padding(.top)
    }

    struct PreferencesView_Previews: PreviewProvider {
        static var previews: some View {
            PreferencesView(viewModel: PreferencesViewModel())
        }
    }
}
