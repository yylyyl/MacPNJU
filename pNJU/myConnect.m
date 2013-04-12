//
//  myConnect.m
//  pNJU
//
//  Created by yangyiliang on 12-9-2.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import "myConnect.h"

@implementation myConnect

static myConnect *globalSelf;

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
        
    data = [myData getMe];
    fb = [FBUPManager getMe];
    status = idle;
    network_error = NO;
    first_status_got = NO;
    
    NSLog(@"%@",@"Started, getting status...");
    
    NSTimer *timer;
    timer = [NSTimer scheduledTimerWithTimeInterval: 60
                                             target: self
                                           selector: @selector(updateConnectionStatus)
                                           userInfo: nil
                                            repeats: YES];
    [self updateConnectionStatus];
    
    return self;
}

- (BOOL)getConnectedStatus
{
    return status==ok;
}

- (void)updateConnectionStatus
{
    if (status==ok || status==idle)
    {
        status = getting;
        NSLog(@"%@",@"Updating status...");
        NSURL *url = [NSURL URLWithString:@"http://p.nju.edu.cn/portal.do"];
        nRequest = [ASIHTTPRequest requestWithURL:url];
        [nRequest setDelegate:self];
        [nRequest startAsynchronous];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    network_error = NO;
    switch (status)
    {
        case idle:
        case ok:
            //impossile
            break;
            
        case getting:
        {
            NSLog(@"%@", @"Got status");
            TFHpple *doc = [TFHpple hppleWithHTMLData:[request responseData]];
            TFHppleElement *e = [doc peekAtSearchWithXPathQuery:@"/html/body/table[1]/tr[2]/td[2]"];
            TFHppleElement *e2 = [doc peekAtSearchWithXPathQuery:@"/html/body/table[1]/tr[1]/td[1]"];
            if ( ! [[[e2 firstChild] content] isEqualToString:@"用户名"])
            {
                NSLog(@"%@", @"Idle");
                status = idle;
                
                if (!first_status_got)
                {
                    [self notificationWithTitle:@"未连接" andContent:@"为什么不联网冲浪去呢！😉"];
                }
            }
            else
            {
                status = ok;
                time = [NSString stringWithString:[[e firstChild] content]];
                NSLog(@"Connected at: %@", [[e firstChild] content]);
                
                if (!first_status_got)
                {
                    [self notificationWithTitle:@"已经连接" andContent:@"您现在可以去冲浪了！😄"];
                    [fb performSelector:@selector(checkUpdate) withObject:nil afterDelay:1];
                }
            }
            first_status_got = YES;
            break;
        }
            
        case getting_code:
        {
            NSLog(@"%@", @"Received code");
            
            if ([data autoInputCode] && fail_code_times < 3)
            {
                yylOCR *ocr = [[yylOCR alloc] initWithData:[request responseData]];
                NSString *code = [ocr getCode];
                NSLog(@"Code: %@", code);
                [self connect_loginCode:code];
                break;
            }
            
            loginWC = [[loginCodeWindowController alloc] initWithWindowNibName:@"loginCodeWindowController"];
            loginWC.window.delegate = self;
            [loginWC.window makeKeyAndOrderFront:nil];
            [loginWC.window setOrderedIndex:0];
            [NSApp activateIgnoringOtherApps:YES];
            [loginWC.imageVIew setImage:[[NSImage alloc] initWithData:[request responseData]]];
            
            break;
        }
            
        case login:
        {
            if ([[request responseString] rangeOfString:@"alert"].location==NSNotFound
                && [[request responseString] rangeOfString:@"location.href"].location!=NSNotFound
                && [[request responseString] length] < 100)
            {
                //rubbish website needs the browser to reload
                NSURL *url = [NSURL URLWithString:@"http://p.nju.edu.cn/portal.do"];
                nRequest = [ASIHTTPRequest requestWithURL:url];
                [nRequest setDelegate:self];
                [nRequest startAsynchronous];
                break;
            }
            
            switch ([self getReturnCode:request]) {
                case good:
                {
                    NSLog(@"%@", @"Connected!");
                    [self notificationWithTitle:@"连接成功" andContent:@"您现在可以去冲浪了！😄"];
                    status = ok;
                    [fb performSelector:@selector(checkUpdate) withObject:nil afterDelay:1];
                    [fb performSelector:@selector(postFB) withObject:nil afterDelay:5];
                    
                    first_status_got = YES;
                    break;
                }
                case invalid_code:
                {
                    NSLog(@"%@", @"E: Wrong code");
                    
                    if ([data autoInputCode] && fail_code_times < 3)
                    {
                        int t = fail_code_times + 1;
                        [self connect];
                        fail_code_times = t;
                        break;
                    }
                    
                    [self notificationWithTitle:@"连接失败" andContent:@"验证码错误！❌"];
                    status = idle;
                    
                    break;
                }
                    
                case get_new_ip:
                {
                    NSLog(@"%@", @"E: Get new ip");
                    [self notificationWithTitle:@"连接失败" andContent:@"请重新获取IP地址！😧\n可能您不在 p.nju.edu.cn 使用区域"];
                    status = idle;
                    break;
                }
                    
                case no_user:
                case wrong_password:
                {
                    NSLog(@"%@", @"E: Wrong password");
                    [self notificationWithTitle:@"连接失败" andContent:@"账号或密码错误！❌"];
                    status = idle;
                    break;
                }
                    
                case too_much:
                {
                    NSLog(@"%@", @"E: Too many connections from this user");
                    [self notificationWithTitle:@"连接失败" andContent:@"您的登录数已达最大并发登录数！😧\n请强制下线"];
                    status = idle;
                    break;
                }
                default:
                {
                    //kidding ?!
                    NSLog(@"%@", @"E: Unknown error");
                    NSLog(@"%@", [request responseString]);
                    [self notificationWithTitle:@"错误" andContent:@"出现了未知错误！😰⁉"];
                    status = idle;
                    
                    [fb feedback:[request responseString]];
                    
                    break;
                }
            }
            break;
        }
            
        case disconnect:
        {
            switch ([self getReturnCode:request]) {
                case disconnected:
                {
                    NSLog(@"%@", @"Disconnected");
                    [self notificationWithTitle:@"连接已断开" andContent:@"你可以放心地做其他事情了"];
                    status = idle;
                    break;
                }
                default:
                {
                    NSLog(@"%@", @"E: Unknown error");
                    [self notificationWithTitle:@"错误" andContent:@"出现了未知错误！😰⁉"];
                    status = idle;
                    
                    [fb feedback:[request responseString]];
                    
                    break;
                }
            }
            break;
        }
        
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (![request isCancelled])
    {
        status = idle;
        //don't show that again and again
        if (!network_error) {
            [self notificationWithTitle:@"错误" andContent:@"出现了网络错误😰\n请检查您的网络连接"];
            network_error = YES;
        }
        NSLog(@"%@", @"E: Network error");
    }
    
}

- (void)connect_loginCode:(NSString *)code
{
    NSLog(@"%@", @"Posting data...");
    status = login;
    [nRequest cancel];
    [fRequest cancel];
    
    NSURL *url = [NSURL URLWithString:@"http://p.nju.edu.cn/portal.do"];
    fRequest = [ASIFormDataRequest requestWithURL:url];
    [fRequest setPostValue:@"login" forKey:@"action"];
    [fRequest setPostValue:@"p_login" forKey:@"p_login"];
    [fRequest setPostValue:@"http://p.nju.edu.cn" forKey:@"url"];
    [fRequest setPostValue:[data username] forKey:@"username"];
    [fRequest setPostValue:[data password] forKey:@"password"];
    [fRequest setPostValue:code forKey:@"code"];
    [fRequest setDelegate:self];
    [fRequest startAsynchronous];
}

- (BOOL)isConnected
{
    return status==ok;
}

- (BOOL)isConnecting
{
    return status==login || status==getting_code;
}

- (void)connect
{
    NSLog(@"%@", @"Getting login code...");
    fail_code_times = 0;
    [nRequest cancel];
    [fRequest cancel];
    status = getting_code;
    network_error = NO;
    
    NSURL *url = [NSURL URLWithString:@"http://p.nju.edu.cn/portal/img.html"];
    nRequest = [ASIHTTPRequest requestWithURL:url];
    [nRequest setDelegate:self];
    [nRequest startAsynchronous];
}

- (void)windowWillClose:(NSNotification *)notification
{
    if ([loginWC isOK])
    {
        [self connect_loginCode:loginWC.loginCodeField.stringValue];
    }
    else
    {
        status = idle;
    }
}

- (void)disconnect
{
    NSLog(@"%@", @"Sending disconnect");
    status = disconnect;
    [nRequest cancel];
    [fRequest cancel];
    NSURL *url = [NSURL URLWithString:@"http://p.nju.edu.cn/portal.do"];
    fRequest = [ASIFormDataRequest requestWithURL:url];
    [fRequest setPostValue:@"p_logout" forKey:@"p_logout"];
    [fRequest setPostValue:@"logout" forKey:@"action"];
    [fRequest setDelegate:self];
    [fRequest startAsynchronous];
}

- (enum login_code)getReturnCode:(ASIHTTPRequest *)request
{
    //NSLog(@"%@", [request responseString]);
    
    TFHpple *doc = [TFHpple hppleWithHTMLData:[request responseData]];
    TFHppleElement *e = [doc peekAtSearchWithXPathQuery:@"/html/body/table[1]/tr[2]/td[2]"];
    if (e!=nil)
    {
        time = [NSString stringWithString:[[e firstChild] content]];
        return good;
    }
    
    NSArray *types = @[@"验证码错误",
                      @"请重新获取IP地址",
                      @"未发现此用户",
                      @"您输入的密码无效",
                      @"您的登录数已达最大并发登录数",
                      @"缺少参数",
                      @"下线成功"]; //must match enum login_code
    NSUInteger errCode=0;
    for (NSString *errStr in types)
    {
        if ([[request responseString] rangeOfString:errStr].location!=NSNotFound)
            return (enum login_code)errCode;
        else errCode++;
    }
    return unknown;
}

- (NSString *)when_online
{
    return time;
}

- (void)notificationWithTitle:(NSString *)title andContent:(NSString *)content
{
    [NSApp hide:self];
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    [notification setTitle:title];
    [notification setInformativeText:content];
    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    center.delegate = fb;
    [center deliverNotification:notification];
}
@end
