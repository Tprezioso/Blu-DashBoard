//
//  TestConnection.m
//  BluMarketWebKit
//
//  Created by Thomas Prezioso on 6/20/16.
//  Copyright © 2016 Thomas Prezioso. All rights reserved.
//

#import "TestConnection.h"



@interface TestConnection ()

@property (strong, nonatomic) NSURLRequest *urlRequest;
@property (strong, nonatomic) WKWebView *webView;

@end

@implementation TestConnection

- (instancetype)initWithUrlRequest:(NSURLRequest *)urlRequest forWebView:(WKWebView *)webView
{
    self = [super init];
    if (self) {
        _urlRequest = urlRequest;
        _webView = webView;
    }
    
    return self;
}

- (void)testConnection
{
    [[NSURLConnection alloc] initWithRequest:self.urlRequest delegate:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self showAlert:@"Connection error" withMessage:@"Error connecting to page.  Please check your 3G and/or Wifi settings."];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    //Check for server error
    if ([httpResponse statusCode] >= 400) {
        [self showAlert:@"Server error" withMessage:@"Error connecting to page.  If error persists, please contact support."];
    }
    [self.webView loadRequest:self.urlRequest];
}

- (void)showAlert:(NSString *)title withMessage:(NSString *)message
{
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                               }];
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:okAction];
    
    UIViewController *viewC = (UIViewController *)self.webView.UIDelegate;
    
    
    [viewC presentViewController:alertController animated:YES completion:nil];
}


@end
