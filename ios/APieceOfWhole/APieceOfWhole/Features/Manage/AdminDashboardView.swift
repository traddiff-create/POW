import SwiftUI

struct AdminDashboardView: View {
    var body: some View {
        List {
            Section("People") {
                NavigationLink(destination: AdminApplicationsView()) {
                    Label("Applications", systemImage: "tray.full")
                }
                NavigationLink(destination: AdminUsersView()) {
                    Label("Users", systemImage: "person.2")
                }
            }
            Section("Program") {
                NavigationLink(destination: AdminCohortsView()) {
                    Label("Cohorts", systemImage: "calendar")
                }
                NavigationLink(destination: AdminContentView()) {
                    Label("Content Library", systemImage: "books.vertical")
                }
            }
            Section("Community") {
                NavigationLink(destination: AdminModerationView()) {
                    Label("Moderation", systemImage: "flag")
                }
                NavigationLink(destination: AdminNotificationsView()) {
                    Label("Send Notification", systemImage: "bell")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.powBackground)
    }
}
