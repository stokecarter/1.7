//
//  AWSHelper.swift
//  Stoke
//
//  Created by Admin on 24/03/21.
//

import Foundation
import Foundation
import AWSCore
import AWSS3
import UIKit
import AVFoundation
import Foundation




 let S3_BASE_URL = "https://stoke-object.s3.amazonaws.com/"//"https://s3.us-east-1.amazonaws.com/"
 let BUCKET_NAME = "stoke-object"
 let BUCKET_DIRECTORY    = "iOS"
 let poolID = "us-east-1:ca1ee582-ca8c-4d81-a38a-a7647cebf10f"

class AWSController {
    
    
    static func setupAWS(){
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: poolID)
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)!
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        AWSS3TransferUtility.register(with: configuration, forKey: BUCKET_NAME)
    }
    
    
    
    static func uploadImage(_ image:UIImage,
                            compressionRatio : CGFloat = 0.3,
                            success : @escaping (Bool, String) -> Void,
                            progress : @escaping (CGFloat) -> Void,
                            failure : @escaping (Error) -> Void){
        
        //        MARK: Compressing image before making upload request...
        
        let name = "\(Int(Date().timeIntervalSince1970)).png"
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task, prog) in
            progress((CGFloat(prog.totalUnitCount)/CGFloat(prog.fileTotalCount ?? 1)))
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        
        guard let data = image.jpegData(compressionQuality: compressionRatio) else {
            let err = NSError(domain: "Error while compressing the image.", code : 01, userInfo : nil)
            failure(err)
            return
        }
        transferUtility.uploadData(data, bucket: BUCKET_NAME, key: name, contentType: "image/png", expression: expression, completionHandler: { (task, error) in
            if let e = error{
                printDebug(e.localizedDescription)
                failure(e)
            }else{
                let url = S3_BASE_URL
                let imageURL = "\(url)\(name)"
                printDebug(imageURL)
                success(true, imageURL)
            }
        })
    }
}
