//
//  BSDSocketServer.m
//  BSDSocketServer
//
//  Created by Calvin Cheng on 30/4/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSDSocketServer.h"
#import <sys/types.h>
#import <arpa/inet.h>

@implementation BSDSocketServer : NSObject 

// method for initializing our socket server
-(instancetype)initOnPort:(int)port {
    
    self = [super init];
    if (self) {
        struct sockaddr_in servaddr;
        
        // no error
        self.errorCode = NOERROR;
        
        if ((self.listenfd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
            
            // socket creation error
            self.errorCode = SOCKETERROR;
            
        } else {
            
            memset(&servaddr, 0, sizeof(servaddr));
            servaddr.sin_family = AF_INET;                  // Using IPv4
            
            // htonl and htons converts the byte order of values passed in
            // from host byte order to the network byte order
            servaddr.sin_addr.s_addr = htonl(INADDR_ANY);   // Allow binding to any IP
            servaddr.sin_port = htons(port);                // bind to given port
            
            if (bind(self.listenfd, (struct sockaddr *)&servaddr, sizeof(servaddr)) < 0) {
                
                // bind is successful, check for socket binding error
                self.errorCode = BINDERROR;
                
            } else {
                
                // We set the maximum number of backlog connection
                // attempts to 1024 (LISTENQ)
                if ((listen(self.listenfd, LISTENQ)) < 0) {
                    
                    // socket listening error
                    self.errorCode = LISTENERROR;
                    
                }
                
            }
            
        }
        
    }
    
    return self;
}

// listens for new connections and when one comes in, we will
// start a new thread to handle the connection
-(void)echoServerListenWithDescriptor:(int)lfd {
    
    int connfd;
    socklen_t clilen;
    struct sockaddr_in cliaddr;
    char buf[MAXLINE];
    
    for (;;) {
        clilen = sizeof(cliaddr);
        if ((connfd = accept(lfd, (struct sockaddr *)&cliaddr, &clilen)) < 0) {
            if (errno != EINTR) {
                self.errorCode = ACCEPTINGERROR;
                NSLog(@"Error accepting connection");
            }
        } else {
            self.errorCode = NOERROR;
            NSString *connStr = [NSString stringWithFormat:@"Connection from %s, port %d", inet_ntop(AF_INET, &cliaddr.sin_addr, buf, sizeof(buf)), ntohs(cliaddr.sin_port)];
            NSLog(@"%@", connStr);
            
            // Multi-thread
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self strEchoServer:@(connfd)];
            });
        }
    }
}

// given socket's file descriptor to read from, we have a
// while loop that will loop each time data comes in on the socket
// when data is received, the recv() function will put the incoming bytes
// into the buffer pointed to by buf.
// The recv() function will then return the number of bytes that are read.
// If the number of bytes is zero, the client is disconnected.
// If the number of bytes is less than zero, there is an error.
// For purposes of this implementation, we will close the socket if the number
// of bytes returned is zero or less.
// As soon as data is read from the socket, we will call written:char:size: function
// to write the data back to the client.
-(void)strEchoServer:(NSNumber *) sockfdNum {
    ssize_t n;
    char buf[MAXLINE];
    
    int sockfd = [sockfdNum intValue];
    while ((n=recv(sockfd, buf, MAXLINE -1, 0)) > 0) {
        [self written:sockfd char:buf size:n];
        buf[n] = '\0';
        NSLog(@"%s", buf);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"posttext" object:[NSString stringWithCString:buf encoding:NSUTF8StringEncoding]];
    }
    NSLog(@"Closing Socket");
    close(sockfd);  // closes our file descriptor when number of bytes returned from the recv() function is zero or less
    
}

// This is our echo server's underlying write operation that writes data back
// to the client.

-(ssize_t) written:(int)sockfdNum char:(const void*)vptr size:(size_t)n {
    
    size_t nleft;
    ssize_t nwritten;
    const char *ptr;
    ptr = vptr;
    nleft = n;
    while (nleft > 0) {
        if ((nwritten = write(sockfdNum, ptr, nleft)) <= 0) {
            if (nwritten < 0 && errno == EINTR) {
                nwritten = 0;   // call write() again
            } else {
                return -1;      // error
            }
            
        }
    }
    return (n);
}

@end