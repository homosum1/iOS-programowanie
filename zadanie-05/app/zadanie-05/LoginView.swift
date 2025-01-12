//
//  LoginView.swift
//  zadanie-05
//
//  Created by Alexander on 09/01/2025.
//

import Foundation

import SwiftUI
import OAuthSwift


//struct Config {
//    static func getValue(forKey key: String) -> String? {
//        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
//              let dictionary = NSDictionary(contentsOfFile: path) else {
//            return nil
//        }
//        return dictionary[key] as? String
//    }
//}


struct LoginView: View {
    
    @State private var isLoggedIn = false
    
    private let googleOAuth = OAuth2Swift(
        consumerKey:    "CONSUMER-KEY",
        consumerSecret: "CONSUMER-SECRET",
        authorizeUrl:   "https://accounts.google.com/o/oauth2/auth",
        accessTokenUrl: "https://accounts.google.com/o/oauth2/token",
        responseType:   "code"
    )
    
    private let githubOAuth = OAuth2Swift(
        consumerKey:    "github_consumer",
        consumerSecret: "github_secret",
        authorizeUrl:   "https://github.com/login/oauth/authorize",
        accessTokenUrl: "https://github.com/login/oauth/access_token",
        responseType:   "code"
    )
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Select login type")
                    .font(.headline)
                    .padding()
                
                // Google Login Button
                Button(action: {
                    startOAuthFlow(oauth: googleOAuth, callback: "http://localhost:3000/callback", scope: "email")
                }) {
                    Text("Log in with Google")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)
                
                // GitHub Login Button
                Button(action: {
                    startOAuthFlow(oauth: githubOAuth, callback: "http://localhost:3000/github-callback", scope: "user")
                }) {
                    Text("Log in with GitHub")
                        .font(.headline)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)
                
                NavigationLink(destination: NormalLoginView()) {
                    Text("Log in with email")
                        .font(.headline)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .onAppear {
                if let _ = UserDefaults.standard.string(forKey: "accessToken") {
                    isLoggedIn = true
                }
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                UserView()
            }
        }
    }
    
    func startOAuthFlow(oauth: OAuth2Swift, callback: String, scope: String) {
        let _ = oauth.authorize(
            withCallbackURL: callback,
            scope: scope,
            state: "OAUTH2",
            completionHandler: { result in
                switch result {
                case .success(let (credential, _, _)):
                    UserDefaults.standard.set(credential.oauthToken, forKey: "accessToken")
                    
                    print("User logged in with token: \(credential.oauthToken)")
                    
                    DispatchQueue.main.async {
                        isLoggedIn = true
                    }
                case .failure(let error):
                    print("OAuth error 🙈: \(error.localizedDescription)")
                }
            }
        )
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "accessToken")
    }
}
