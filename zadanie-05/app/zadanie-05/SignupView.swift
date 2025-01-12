//
//  SignupView.swift
//  zadanie-05
//
//  Created by Alexander on 09/01/2025.
//

import Foundation
import SwiftUI

struct SignUpView: View {
    
    @State private var isLoggedIn = false
    
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    
    @State private var message = ""
    @State private var showMessage = false
    
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Sign Up")
                    .font(.largeTitle)
                    .padding()
                
                TextField("Username", text: $username)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Email", text: $email)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Password", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if showMessage {
                    Text(message)
                        .foregroundColor(message == "Signup completed 👌" ? .green : .red)
                        .padding()
                }
                
                Button(action: {
                    handleSignUp()
                }) {
                    Text("Sign up")
                        .font(.headline)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
            .onAppear {
                if let _ = UserDefaults.standard.string(forKey: "accessToken") {
                    isLoggedIn = true
                }
            }
            
            .navigationDestination(isPresented: $isLoggedIn) {
                UserView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    func handleSignUp() {
           if password != confirmPassword {
               message = "Password and confirm password don't match"
               showMessage = true
               return
           }
        
           let url = URL(string: "http://localhost:3000/signup")!
           
           
           let signupData = ["name": username, "password": password, "email": email]
           
           guard let userData = try? JSONSerialization.data(withJSONObject: signupData) else {
               message = "something went very wrong"
               showMessage = true
               return
           }
           
           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           request.httpBody = userData
           
        
//         ececute request:
          
           let task = URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
                   DispatchQueue.main.async {
                       message = "Error: \(error.localizedDescription)"
                       showMessage = true
                   }
                   return
               }
            
               
               if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                   DispatchQueue.main.async {
                       message = "Signup completed 👌"
                       showMessage = true
                       
                       
                       DispatchQueue.main.async {
                           isLoggedIn = true
                       }
                   }
               } else {
                   guard let data = data else {
                       DispatchQueue.main.async {
                           message = "Missing response"
                           showMessage = true
                       }
                       return
                   }
                   
                   if let serverMessage = String(data: data, encoding: .utf8) {
                       DispatchQueue.main.async {
                           message = "Error: \(serverMessage)"
                           showMessage = true
                       }
                   }
               }
           }
           task.resume()
       }
}
