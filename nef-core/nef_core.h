//  Copyright © 2019 The nef Authors.

#import <Foundation/Foundation.h>
#import "nef_coreProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface nef_core : NSObject <nef_coreProtocol>
@end
