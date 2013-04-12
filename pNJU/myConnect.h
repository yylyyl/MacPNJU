//
//  myConnect.h
//  pNJU
//
//  Created by yangyiliang on 12-9-2.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "myData.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "TFHpple.h"
#import "loginCodeWindowController.h"
#import "FBUPManager.h"
#import "yylOCR.h"

enum status_type {idle, getting, getting_code, login, disconnect, ok};
enum login_code {invalid_code, get_new_ip, no_user, wrong_password, too_much, too_few_args, disconnected, good, unknown};

@interface myConnect : NSObject <NSWindowDelegate>
{
    bool first_status_got;
    myData *data;
    enum status_type status;
    loginCodeWindowController *loginWC;
    NSString *time;
    ASIHTTPRequest *nRequest;
    ASIFormDataRequest *fRequest;
    bool network_error;
    FBUPManager* fb;
    int fail_code_times;
}
+ (id)getMe;
- (BOOL)isConnected;
- (BOOL)isConnecting;
//- (void)connect_loginCode:(NSString *)code;
- (void)connect;
- (void)disconnect;
- (NSString *)when_online;
@end
