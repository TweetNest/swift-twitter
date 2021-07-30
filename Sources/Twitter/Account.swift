//
//  Account.swift
//  
//
//  Created by Jaehong Kang on 2021/02/24.
//

import Foundation

public struct Account: Decodable, Identifiable {
    public let id: Int64
    public let name: String
    public let username: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case username = "screen_name"
    }
}

extension Account {
    public static func me(session: Session) async throws -> Account {
        try await Task {
            var urlRequest = URLRequest(url: URL(string: "https://api.twitter.com/1.1/account/verify_credentials.json")!)
            urlRequest.httpMethod = "GET"
            await urlRequest.oauthSign(session: session)

            let (data, response) = try await session.urlSession.data(for: urlRequest)
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200..<300).contains(httpResponse.statusCode)
            else {
                throw SessionError.invalidServerResponse
            }

            return try JSONDecoder().decode(Account.self, from: data)
        }.value
    }
}