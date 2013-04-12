//
//  MyMenu.h
//  pNJU
//
//  Created by yangyiliang on 12-9-2.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingWindowController.h"
#import "myConnect.h"
#import "AboutWindowController.h"

@interface MyMenu : NSObject
{
    IBOutlet NSMenu *statusMenu;
    
    /* The other stuff :P */
    NSStatusItem *statusItem;
    NSImage *statusImage;
    NSImage *statusHighlightImage;
    SettingWindowController *settingWC;
    AboutWindowController *aboutWC;
}

- (IBAction)settingPressed:(id)sender;
- (IBAction)connectPressed:(id)sender;
- (IBAction)aboutPressed:(id)sender;

@property (weak) IBOutlet NSMenuItem *connectMenuItem;
@property (weak) IBOutlet NSMenuItem *connectTimeItem;

@end
