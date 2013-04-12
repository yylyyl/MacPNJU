//
//  FBUPManager.m
//  MacPNJU
//
//  Created by yangyiliang on 12-11-5.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import "FBUPManager.h"

@implementation FBUPManager

static FBUPManager* me;

- (void)checkUpdate
{
    NSProcessInfo *pinfo = [NSProcessInfo processInfo];
    NSArray *myarr = [[pinfo operatingSystemVersionString] componentsSeparatedByString:@" "];
    NSString *version = [myarr objectAtIndex:1];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://macpnju.9away.com/version.php?v=%@&os=%@&uid=%@",
                        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                        version,
                        [[myData getMe] uid]];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    nRequest = [ASIHTTPRequest requestWithURL:url];
    [nRequest setDelegate:self];
    [nRequest startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if ([[[request url] description] rangeOfString:@"version"].location != NSNotFound)
    {
        if ([[[request responseString] substringToIndex:1] isEqualToString:@"V"])
        {
            NSLog(@"Newest version: %@", [request responseString]);
            if (![[request responseString] isEqualToString:[NSString stringWithFormat:@"V%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]])
            {
                [NSApp hide:self];
                NSUserNotification *notification = [[NSUserNotification alloc] init];
                [notification setTitle:[NSString stringWithFormat:@"有新版本！%@", [request responseString]]];
                [notification setInformativeText:@"赶紧去 http://macpnju.9away.com/ 升级吧！😍"];
                NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
                center.delegate = self;
                [center deliverNotification:notification];
            }

        }
    }
    //else if ([[request url] isEqualTo:[NSURL URLWithString:@"http://macpnju.9away.com/feedback.php"]])
    //{
    //
    //}
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"fail: %@", [[request url] description]);
}

- (void)feedback:(NSString *)str
{
    if (!logs)
    {
        logs = [[NSMutableArray alloc] init];
    }
    
    if ([str length] > 100) {
        str = @"TOO LONG!";
    }
    
    NSString *time = [NSDate date];
    str = [NSString stringWithFormat:@"%@ %@", time, str];
    
    [logs addObject:[NSString stringWithString:str]];
}

- (void)postFB
{
    if ([[myData getMe] canFeedBack])
    {
        NSLog(@"%@ %ld", @"Posting feedback info", [logs count]);
        NSProcessInfo *pinfo = [NSProcessInfo processInfo];
        NSArray *myarr = [[pinfo operatingSystemVersionString] componentsSeparatedByString:@" "];
        NSString *version = [myarr objectAtIndex:1];
        
        NSURL *url = [NSURL URLWithString:@"http://macpnju.9away.com/feedback.php"];
        
        for (NSString *log in logs)
        {
            NSString *nlog = [NSString stringWithFormat:@"%@ //%@ %@ %@ %@", log, version, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[myData getMe] username], [[myData getMe] uid]];
            fRequest = [ASIFormDataRequest requestWithURL:url];
            [fRequest setPostValue:nlog forKey:@"log"];
            [fRequest setDelegate:self];
            [fRequest startAsynchronous];
        }
    }
    
    [logs removeAllObjects];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    if ([notification.title isEqualToString:@"有新版本！"])
    {
        NSURL *url = [NSURL URLWithString:@"http://macpnju.9away.com/"];
        [[NSWorkspace sharedWorkspace] openURL:url];
    }
    
    [center removeDeliveredNotification:notification];
}

+ (id)getMe
{
    if (!me)
    {
        me = [[self alloc] init];
    }
    return me;
}
@end
