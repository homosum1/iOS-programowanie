//
//  ContentView.swift
//  zadanie-05
//
//  Created by Alexander on 09/01/2025.
//

import SwiftUI
import CoreData
import OAuthSwift



import SwiftUI

struct ContentView: View {
    
    @State private var showLoginView = false
    @State private var showSignUpView = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to task-05 💀:")
                    .font(.title)
                    .padding()
                HStack {
                    NavigationLink(destination: LoginView()) {
                        Text("Log in")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    
                    NavigationLink(destination: SignUpView()) {
                        Text("Sign Up")
                            .font(.headline)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                }
                .padding()
            }
            .padding()
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
