//
//  TestConnection.h
//  BluMarketWebKit
//
//  Created by Thomas Prezioso on 6/20/16.
//  Copyright © 2016 Thomas Prezioso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface TestConnection : NSObject<NSURLConnectionDelegate>

- (instancetype)initWithUrlRequest:(NSURLRequest *)urlRequest forWebView:(UIWebView *)webView;
- (void)testConnection;

@end
