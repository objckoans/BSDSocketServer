//
//  main.m
//  BSDSocketServer
//
//  Created by Calvin Cheng on 30/4/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSDSocketServer.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        BSDSocketServer *bsdServ = [[BSDSocketServer alloc] initOnPort:8888];
        if (bsdServ.errorCode == NOERROR) {
            [bsdServ echoServerListenWithDescriptor:bsdServ.listenfd];
        } else {
            NSLog(@"%@", [NSString stringWithFormat:@"Error code %d received. Server was not started", bsdServ.errorCode]);
        }

    }
    return 0;
}
