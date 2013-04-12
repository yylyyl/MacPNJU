//
//  myData.m
//  pNJU
//
//  Created by yangyiliang on 12-9-2.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import "myData.h"

@implementation myData

static myData *globalSelf;

+ (id)getMe
{
    if (!globalSelf)
    {
        globalSelf = [[self alloc] init];
    }
    return globalSelf;
}

- (id)init
{
    self = [super init];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    username = [ud stringForKey:@"username"];
    password = [ud stringForKey:@"password"];
    autoInputCode = [ud boolForKey:@"autoInputCode"];
    feedBack = [ud boolForKey:@"feedBack"];
    uid = [ud stringForKey:@"uid"];
    
    if (uid == nil)
    {
        int r1 = arc4random() % 10000;
        int r2 = arc4random() % 10000;
        int r3 = arc4random() % 10000;
        int r4 = arc4random() % 10000;
        uid = [NSString stringWithFormat:@"%d%d%d%d", r1, r2, r3, r4];
        NSLog(@"uid: %@", uid);
        [ud setObject:uid forKey:@"uid"];
    }
    
    return self;
}

- (void)saveUsername:(NSString *)newUsername Password:(NSString *)newpassword AutoInputCode:(BOOL)newAutoInputCode FeedBackCheck:(BOOL)newFeedBack
{
    username = newUsername;
    password = newpassword;
    autoInputCode = newAutoInputCode;
    feedBack = newFeedBack;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:username forKey:@"username"];
    [ud setObject:password forKey:@"password"];
    [ud setBool:autoInputCode forKey:@"autoInputCode"];
    [ud setBool:feedBack forKey:@"feedBack"];
}

- (NSString *)username
{
    return username;
}

- (NSString *)password
{
    return password;
}

- (BOOL)autoInputCode
{
    return autoInputCode;
}

- (BOOL)canFeedBack
{
    return feedBack;
}

- (NSString *)uid
{
    return uid;
}

- (BOOL)empty
{
    return [username isEqualToString:@""] || [password isEqualToString:@""];
}
@end
