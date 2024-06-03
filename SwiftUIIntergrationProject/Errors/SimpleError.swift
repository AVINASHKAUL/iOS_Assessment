//
//  SimpleError.swift
//  SwiftUIIntergrationProject
//
//  Created by Yuchen Nie on 5/22/24.
//

import Foundation

public enum SimpleError: Error, Equatable {
    
    case address
    case dataLoad(String)
    case dataParse(String?)
    
    case invalidUrl
    case requestFailed
    case invalidResponse
    case decodingFailed
}
