//
//  Note.swift
//  Notes
//
//  Created by Elmar Ibrahimli on 26.05.23.
//

import Foundation

struct Note: Codable {
    let id: Int
    let name: String
    var body: String?
    let createDate: String
}
