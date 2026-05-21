//
//  AppConfigurations.swift
//  Aran
//
//  Created by Iker Casillas on 5/21/26.
//

import Foundation

final class AppConfigurations{
    lazy var drugAPIEndpoint: String = {
        guard let drugAPIEndpoint = Bundle.main.object(forInfoDictionaryKey: "DRUG_API_ENDPOINT") as? String else {
            fatalError("APIKey must not be emtpy")
        }
        return drugAPIEndpoint
    }()
    
    lazy var drugAPIDecoding: String = {
        guard let drugAPIDecoding = Bundle.main.object(forInfoDictionaryKey: "DRUG_API_DECODING") as? String else {
            fatalError("APIKey must not be emtpy")
        }
        return drugAPIDecoding
    }()
    
    lazy var drugAPIEncoding: String = {
        guard let drugAPIEncoding = Bundle.main.object(forInfoDictionaryKey: "DRUG_API_ENCODING") as? String else {
            fatalError("APIKey must not be emtpy")
        }
        return drugAPIEncoding
    }()
    
}
