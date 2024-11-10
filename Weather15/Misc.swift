//
//  Misc.swift
//  Weather15
//
//  Created by Quân Đinh on 10.11.24.
//

import SystemConfiguration

func isConnectedToNetwork() -> Bool {
  var zeroAddress = sockaddr_in()
  zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
  zeroAddress.sin_family = sa_family_t(AF_INET)
  
  guard let reachability = withUnsafePointer(to: &zeroAddress, {
    SCNetworkReachabilityCreateWithAddress(nil, UnsafeRawPointer($0).bindMemory(to: sockaddr.self, capacity: 1))
  }) else {
    return false
  }
  
  var flags = SCNetworkReachabilityFlags()
  if !SCNetworkReachabilityGetFlags(reachability, &flags) {
    return false
  }
  
  return flags.contains(.reachable) && !flags.contains(.connectionRequired)
}
