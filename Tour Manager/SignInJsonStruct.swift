//
//  SignInJsonStruct.swift
//  Tour Manager
//
//  Created by SHREDDING on 29.04.2023.
//


import Foundation


// MARK: - UnprocessableEntity
struct UnprocessableEntity: Codable {
    let detail: [Detail]
}

// MARK: - Detail
struct Detail: Codable {
    let loc: [String]
    let msg, type: String
}

// MARK: - SuccesfulSignIn
struct SuccesfulSignIn: Codable {
    let message: String
}
