//  Copyright © 2019 The nef Authors.

import SystemConfiguration

class Reachability {
    static var isConnected: Bool {
        var flags = SCNetworkReachabilityFlags(rawValue: 0)
        var address = zeroAddress
        guard let defaultRouteReachability = createNetworkReachability(withAddress: &address),
              SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) else { return false }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return isReachable && !needsConnection
    }
    
    // MARK: helpers
    private static var zeroAddress: sockaddr_in {
        var address = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        address.sin_len = UInt8(MemoryLayout.size(ofValue: address))
        address.sin_family = sa_family_t(AF_INET)
        
        return address
    }
    
    private static func createNetworkReachability(withAddress address: inout sockaddr_in) -> SCNetworkReachability? {
        withUnsafePointer(to: &address) { addressRef in
            addressRef.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, sockAddress)
            }
        }
    }
}
