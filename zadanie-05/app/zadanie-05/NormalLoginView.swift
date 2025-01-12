//
//  NormalLoginView.swift
//  zadanie-05
//
//  Created by Alexander on 09/01/2025.
//

import Foundation
import SwiftUI

struct NormalLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var message = ""
    
    @State private var isLoggedIn = false
    
    var body: some View {
        NavigationStack {
            VStack {
                
                Text("Log In")
                    .font(.largeTitle)
                    .padding()
                
                TextField("Email", text: $email)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Password", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    handleLogin()
                }) {
                    Text("Log In")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                if !message.isEmpty {
                    Text(message)
                        .foregroundColor(.red)
                        .padding()
                }
                
            }
            .padding()
            .onAppear {
                if let _ = UserDefaults.standard.string(forKey: "accessToken") {
                    isLoggedIn = true
                }
            }
            .navigationBarBackButtonHidden(true)
            
            
            .navigationDestination(isPresented: $isLoggedIn) {
                UserView()
                .navigationBarBackButtonHidden(true)
            }
            
        }
    }
    
    func handleLogin() {
        let url = URL(string: "http://localhost:3000/login")!
        
        let requestBody = [
            "email": email,
            "password": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            message = "something went very wrong"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    message = "Login failed 😳"
                    return
                }
                
                guard let data = data else {
                    message = "No data received"
                    return
                }
                

                if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   
                   let success = jsonResponse["success"] as? Bool {

                    if success {
//                        print("test 1")
                        if let token = jsonResponse["token"] as? String {
 
                            UserDefaults.standard.set(token, forKey: "authToken")
                            
                            
//                          REDIRECT AFTER A WHILE -> brakuje tu implementacji w ogole!!!!
                            print("User logged in")

                            DispatchQueue.main.async {
                                isLoggedIn = true
                            }
                            
                            
                            
                            return
                        } else {
                            message = "something went very wrong"
                        }
                    } else {
//                      TODO: HANDLE ERROR
                    }
                } else {
                    message = "Login failed"
                }
            }
        }.resume()
    }


}
