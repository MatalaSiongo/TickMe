//12/02 at 01:30
//ContentView
import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject private var authManager: FirebaseAuthManager
    @EnvironmentObject private var taskStore: TaskStore

    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            // ✅ FIX: HomeView expects EnvironmentObject<TaskStore>, so pass _taskStore
            HomeView(store: _taskStore)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            NavigationStack {
                AccountView()
                    .environmentObject(authManager)
            }
            .tabItem { Label("Account", systemImage: "person.fill") }
            .tag(1)

            CalendarView(store: taskStore)
                .tabItem { Label("Calendar", systemImage: "calendar") }
                .tag(2)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(3)
        }
        .onAppear {
            taskStore.setCurrentUser(uid: Auth.auth().currentUser?.uid)
        }
    }
}
