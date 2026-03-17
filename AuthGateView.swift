//AuthGateView
 //13/02
import SwiftUI

struct AuthGateView: View {
    @EnvironmentObject private var auth: FirebaseAuthManager

    var body: some View {
        Group {
            if auth.user != nil {
                ContentView()
            } else {
                SignInView()
            }
        }
    }
}
