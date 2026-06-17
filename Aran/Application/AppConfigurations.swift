//
//  AppConfigurations.swift
//  Aran
//
//  Created by Iker Casillas on 5/21/26.
//

import Foundation

final class AppConfigurations {
    let drugAPIEndpoint: String = "https://apis.data.go.kr/1471000/DrbEasyDrugInfoService"
    let drugAPIPrdtEndpoint: String = "https://apis.data.go.kr/1471000/DrugPrdtPrmsnInfoService07"

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
    
    lazy var drugAPIPrdtDecoding: String = {
        guard let drugAPIPrdtDecoding = Bundle.main.object(forInfoDictionaryKey: "DRUG_API_PRDT_DECODING") as? String else {
            fatalError("APIKey must not be emtpy")
        }
        return drugAPIPrdtDecoding
    }()
    
    lazy var drugAPIPrdtEncoding: String = {
        guard let drugAPIPrdtEncoding = Bundle.main.object(forInfoDictionaryKey: "DRUG_API_PRDT_ENCODING") as? String else {
            fatalError("APIKey must not be emtpy")
        }
        return drugAPIPrdtEncoding
    }()
    
    
}
