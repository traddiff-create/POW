import SwiftUI

struct ApplicationNavigationView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            CohortListView(path: $path)
                .navigationDestination(for: Cohort.self) { cohort in
                    ApplyFormView(cohort: cohort, path: $path)
                }
                .navigationDestination(for: CohortApplication.self) { application in
                    ApplicationStatusView(application: application)
                }
        }
    }
}
