//
//  Model.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 16.04.2025.
//

import Foundation

struct Profile: Decodable {
  let username: String?
  let fullName: String?
  let website: String?
  enum CodingKeys: String, CodingKey {
    case username
    case fullName = "full_name"
    case website
  }
}
struct UpdateProfileParams: Encodable {
  let username: String
  let fullName: String
  let website: String
  enum CodingKeys: String, CodingKey {
    case username
    case fullName = "full_name"
    case website
  }
}
