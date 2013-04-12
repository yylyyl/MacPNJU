//
//  SettingWindowController.h
//  pNJU
//
//  Created by yangyiliang on 12-9-2.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "myData.h"

@interface SettingWindowController : NSWindowController <NSWindowDelegate>
{
    myData *data;
}
@property (weak) IBOutlet NSTextField *usernameField;
@property (weak) IBOutlet NSSecureTextField *passwordField;
@property (weak) IBOutlet NSButton *autoInputCodeCheck;
@property (weak) IBOutlet NSButton *feedBackCheck;
@property (weak) IBOutlet NSButton *startAtLoginButton;
@end
