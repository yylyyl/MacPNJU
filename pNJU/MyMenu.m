//
//  MyMenu.m
//  pNJU
//
//  Created by yangyiliang on 12-9-2.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import "MyMenu.h"

@implementation MyMenu
@synthesize connectMenuItem;
@synthesize connectTimeItem;

- (void)awakeFromNib
{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    //Used to detect where our files are
    NSBundle *bundle = [NSBundle mainBundle];
    
    //Allocates and loads the images into the application which will be used for our NSStatusItem
    statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"in" ofType:@"png"]];
    statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"in2" ofType:@"png"]];
    
    //Sets the images in our NSStatusItem
    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusHighlightImage];
    
    //Tells the NSStatusItem what menu to load
    [statusItem setMenu:statusMenu];
    //Sets the tooptip for our item
    //[statusItem setToolTip:@"My Custom Menu Item"];
    //Enables highlighting
    [statusItem setHighlightMode:YES];
    
    NSTimer *timer;
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.5
                                             target: self
                                           selector: @selector(updateUI)
                                           userInfo: nil
                                            repeats: YES];
    [self updateUI];
}
- (IBAction)settingPressed:(id)sender {
    if(!settingWC)
        settingWC = [[SettingWindowController alloc] initWithWindowNibName:@"SettingWindowController"];
    //[settingWC showWindow:nil];
    [settingWC.window makeKeyAndOrderFront:self];
    [settingWC.window setOrderedIndex:0];
    [NSApp activateIgnoringOtherApps:YES];
    NSLog(@"%@", @"Show settings");
}

- (IBAction)connectPressed:(id)sender {
    myConnect *connect = [myConnect getMe];
    if (![connect isConnected])
        [connect connect];
    else
        [connect disconnect];
}

- (IBAction)aboutPressed:(id)sender {
    if (!aboutWC)
        aboutWC = [[AboutWindowController alloc] initWithWindowNibName:@"AboutWindowController"];
    [aboutWC showWindow:nil];
    [aboutWC.window makeKeyAndOrderFront:nil];
    [aboutWC.window setOrderedIndex:0];
    [NSApp activateIgnoringOtherApps:YES];
    NSLog(@"%@", @"Show about");
}

- (void)updateUI
{
    myConnect *connect = [myConnect getMe];
    NSBundle *bundle = [NSBundle mainBundle];

    if ([connect isConnected])
    {
        connectMenuItem.title = @"断开连接";
        NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
        [df1 setFormatterBehavior:NSDateFormatterBehavior10_4];
        [df1 setDateFormat:@"MM-dd HH:mm"];
        NSDateFormatter *df2 = [[NSDateFormatter alloc] init];
        [df2 setFormatterBehavior:NSDateFormatterBehavior10_4];
        [df2 setDateFormat:@"HH:mm"];
        NSDate *convertedDate = [df1 dateFromString:[connect when_online]];
        NSString *time = [df2 stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:[[NSDate date] timeIntervalSince1970] - [convertedDate timeIntervalSince1970] - 8*3600]];
        
        connectTimeItem.title = time;
        
        [connectTimeItem setHidden:NO];
        
        statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"on" ofType:@"png"]];
        statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"on2" ofType:@"png"]];
        
    }
    else
    {
        [connectTimeItem setHidden:YES];
        if ([connect isConnecting])
        {
            connectMenuItem.title = @"正在连接...";
            statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"in" ofType:@"png"]];
            statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"in2" ofType:@"png"]];
        }
        else
        {
            statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"off" ofType:@"png"]];
            statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"off2" ofType:@"png"]];
            
            if ([[myData getMe] empty])
            {
                [connectMenuItem setAction:NULL];
                connectMenuItem.title = @"请先设定账号密码";
            }
            else
            {
                [connectMenuItem setAction:@selector(connectPressed:)];
                connectMenuItem.title = @"连接";
            }
        }
    }
    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusHighlightImage];
}

@end
