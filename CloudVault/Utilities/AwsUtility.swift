//
//  AwsUtility.swift
//  CloudVault
//
//  Created by Chris Schofield on 19/02/2021.
//

import Foundation
import CoreData
import SotoCore
import SotoSTS

/**
Utility for interacting with AWS through Soto library
*/
class AwsUtility: NSObject {
  /**
  Method for testing AWS credentials, returning a boolean for now
  */
  static func testProfile(_ schema: AWSProfileSchema) throws -> STS.GetCallerIdentityResponse {
    var response: STS.GetCallerIdentityResponse?

    // Prepare AWS Client and create STS Client
    let client = AWSClient(
      credentialProvider: .static(accessKeyId: schema.accessKey, secretAccessKey: schema.secretKey),
      httpClientProvider: .createNew
    )
    let sts = STS(client: client, region: .euwest1, partition: .aws)

    // Attempt a call to STS get-caller-idnetity to retrieve account details
    response = try sts.getCallerIdentity(STS.GetCallerIdentityRequest()).wait()

    // Shutdown AWS Client gracefuly
    try? client.syncShutdown()

    return response!
  }
}
