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
                Form {
                    Section(content: {
                        TextField("Master branch name", text: $viewModel.masterBranchName)
                        TextField("Develop branch name", text: $viewModel.developBranchName)
                        TextField("Feature branch prefix", text: $viewModel.featureBranchPrefix)
                        TextField("Release branch prefix", text: $viewModel.releaseBranchPrefix)
                        TextField("Hotfix branch prefix", text: $viewModel.hotfixBranchPrefix)
                    }, header: {
                        Text("Branch configuration")
                    })
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
                        List(Array(viewModel.ignoreList), id: \.pattern, selection:
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
                Form {
                    Section(content: {
                        TextField("Bitrise base URL", text: $viewModel.bitriseBaseUrl)
                        TextField("Bitrise auth token", text: $viewModel.bitriseAuthToken)
                        TextField("Bitrise app slug", text: $viewModel.bitriseAppSlug)
                        TextField("Bitrise org slug", text: $viewModel.bitriseOrgSlug)

                    }, header: {
                        Text("Bitrise configuration")
                    })
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
