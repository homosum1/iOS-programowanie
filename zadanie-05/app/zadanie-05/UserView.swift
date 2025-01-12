//
//  UserView.swift
//  zadanie-05
//
//  Created by Alexander on 10/01/2025.
//

import SwiftUI
import Foundation

struct UserView: View {
    
    @State private var token = ""
    @State private var userData: String?
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            if token != "" {
               
                
                if let userData = userData {
                    Text("User Data: \(userData)")
                        .padding()
                    
                    
                    Button(action: {
                       logout()
                   }) {
                       Text("Logout")
                           .font(.headline)
                           .padding()
                           .background(Color.red)
                           .foregroundColor(.white)
                           .cornerRadius(10)
                   }
                   .padding(.top, 20)
                }
                else {
                    Text("Loading data ...")
                        .padding()
                }
            } else {
                // no token -> log in
//                ContentView()
            }
        }
        .padding()
        .navigationTitle("User panel")
        .onAppear {
            if let retrievedToken = UserDefaults.standard.string(forKey: "authToken") {
                token = retrievedToken
                fetchUserData(token: token)
            }
        }
        
    }
    
    func fetchUserData(token: String) {
        let url = URL(string: "http://localhost:3000/userPanel")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("something went very wrong 1")
                return
            }
            

            do {
                
                let decodedResponse = try JSONDecoder().decode(UserPanelResponse.self, from: data)
                
                print(decodedResponse)
                
                DispatchQueue.main.async {
                    userData = decodedResponse.message
                }
            
                print("userData retrieved")
            } catch {
                print("something went very wrong 2")
            }
        }
        
        task.resume()
    }
    
    func logout() {
          
           UserDefaults.standard.removeObject(forKey: "authToken")
           
           token = ""
           userData = nil
           
        DispatchQueue.main.async {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct UserPanelResponse: Codable {
    let message: String
}
