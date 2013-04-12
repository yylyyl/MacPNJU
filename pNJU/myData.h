//
//  myData.h
//  pNJU
//
//  Created by yangyiliang on 12-9-2.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface myData : NSObject
{
    NSString *username;
    NSString *password;
    NSString *uid;
    BOOL autoInputCode;
    BOOL feedBack;
}

+ (id)getMe;
- (void)saveUsername:(NSString *)newUsername Password:(NSString *)newpassword AutoInputCode:(BOOL)newAutoInputCode FeedBackCheck:(BOOL)newFeedBack;
- (NSString *)username;
- (NSString *)password;
- (NSString *)uid;
- (BOOL)autoInputCode;
- (BOOL)canFeedBack;
- (BOOL)empty;
@end

