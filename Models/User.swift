//
//  User.swift
//  Recipe
//
//  Created by gu xu on 4/29/25.
//

import Foundation

struct User: Codable {
    let userId: Int
    let userName: String
    let email: String
    let userType: Int
    let createTime: String
    let modifyTime: String
}
