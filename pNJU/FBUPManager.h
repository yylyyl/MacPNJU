//
//  FBUPManager.h
//  MacPNJU
//
//  Created by yangyiliang on 12-11-5.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "myData.h"
@interface FBUPManager : NSObject <NSUserNotificationCenterDelegate>
{
    ASIHTTPRequest *nRequest;
    ASIFormDataRequest *fRequest;
    NSMutableArray *logs;
}
- (void)checkUpdate;
- (void)feedback:(NSString *)str;
- (void)postFB;
+ (id)getMe;
@end
