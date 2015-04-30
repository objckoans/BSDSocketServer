//
//  BSDSocketServer.h
//  BSDSocketServer
//
//  Created by Calvin Cheng on 30/4/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#ifndef BSDSocketServer_BSDSocketServer_h
#define BSDSocketServer_BSDSocketServer_h

#import <Foundation/Foundation.h>

#define LISTENQ 1024
#define MAXLINE 4096

// 5 error conditions
typedef NS_ENUM(NSUInteger, BSDServerErrorCode) {
    NOERROR,        // determines that no errors occurred while performing the socket, bind and listen steps
    SOCKETERROR,    // determines that the error occurred while creating the socket
    BINDERROR,      // determines that the error occurred while binding the sockaddr family of structures with the socket
    LISTENERROR,    // determines that the error occurred while preparing to listen to the socket
    ACCEPTINGERROR  // determines that the error occurred while accepting a connection
};

@interface BSDSocketServer: NSObject

@property (nonatomic) int errorCode, listenfd;

-(id)initOnPort: (int)port;
-(void)echoServerListenWithDescriptor:(int)lfd;

@end

#endif
