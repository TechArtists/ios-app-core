//
//  FirebaseFunctionAttribution.swift
//  TAAppCore
//
//  Created by Robert Tataru on 02.04.2025.
//

import FirebaseCore
import FirebaseFunctions

public struct FirebaseFunctionAttribution {
    
    public static let functions: Functions = {
        let instance = Functions.functions()
        instance.useEmulator(withHost: "localhost", port: 5001)
        return instance
    }()

    public static let payload: [String: Any] = [
        "payload": [
            "installDate": "2025-04-03",
            "campaign": "spring_sale",
            "userId": "12345"
        ],
        "userPseudoID": "54321",
        "folderPrefix": "attribution_data"
    ]
    
    public static func onConversionDataSuccess(_ data: [String: Any]) {
        functions.httpsCallable("savePayload").call(data) { result, error in
            if let error = error as NSError? {
                print("Cloud Function error: \(error.localizedDescription)")
                print("Error details: \(error.userInfo)")
            } else if let resultData = result?.data as? [String: Any] {
                if let success = resultData["success"] as? Bool, success {
                    print("AppsFlyer data uploaded successfully.")
                }
                if let path = resultData["filePath"] as? String {
                    print("File stored at: \(path)")
                }
            }
        }
    }
}
