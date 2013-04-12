//
//  SettingWindowController.m
//  pNJU
//
//  Created by yangyiliang on 12-9-2.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import "SettingWindowController.h"

@interface SettingWindowController ()

@end

@implementation SettingWindowController
@synthesize usernameField;
@synthesize passwordField;
@synthesize autoInputCodeCheck;
@synthesize feedBackCheck;
@synthesize startAtLoginButton;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    data = [myData getMe];
    if ([data username] != nil)
    {
        usernameField.stringValue = [data username];
        passwordField.stringValue = [data password];
        autoInputCodeCheck.state = [data autoInputCode]?NSOnState:NSOffState;
        feedBackCheck.state = [data canFeedBack]?NSOnState:NSOffState;
        startAtLoginButton.state = [self willStartAtLogin];
    }
}

- (void)windowWillClose:(NSNotification *)notification
{
    NSLog(@"%@ %@ %@ %@ %@", usernameField.stringValue, passwordField.stringValue, autoInputCodeCheck.state==NSOnState?@"YES":@"NO", feedBackCheck.state==NSOnState?@"YES":@"NO", startAtLoginButton.state==NSOnState?@"YES":@"NO");
    [data saveUsername:usernameField.stringValue Password:passwordField.stringValue AutoInputCode:autoInputCodeCheck.state==NSOnState FeedBackCheck:feedBackCheck.state==NSOnState];
    [self setStartAtLoginEnabled:startAtLoginButton.state==NSOnState];
}

- (BOOL) willStartAtLogin
{
    NSURL *itemURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    Boolean foundIt=false;
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) {
        UInt32 seed = 0U;
        NSArray *currentLoginItems = (__bridge NSArray *)(LSSharedFileListCopySnapshot(loginItems, &seed));
        for (id itemObject in currentLoginItems) {
            LSSharedFileListItemRef item = (__bridge LSSharedFileListItemRef)itemObject;
            
            UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
            CFURLRef URL = NULL;
            OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, /*outRef*/ NULL);
            if (err == noErr) {
                foundIt = CFEqual(URL, (__bridge CFTypeRef)(itemURL));
                CFRelease(URL);
                
                if (foundIt)
                    break;
            }
        }
        CFRelease(loginItems);
    }
    return (BOOL)foundIt;
}

- (void) setStartAtLoginEnabled:(BOOL)enabled
{
    NSURL *itemURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    //OSStatus status;
    LSSharedFileListItemRef existingItem = NULL;
    
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) {
        UInt32 seed = 0U;
        NSArray *currentLoginItems = (__bridge NSArray *)(LSSharedFileListCopySnapshot(loginItems, &seed));
        for (id itemObject in currentLoginItems) {
            LSSharedFileListItemRef item = (__bridge LSSharedFileListItemRef)itemObject;
            
            UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
            CFURLRef URL = NULL;
            OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, /*outRef*/ NULL);
            if (err == noErr) {
                Boolean foundIt = CFEqual(URL, (__bridge CFTypeRef)(itemURL));
                CFRelease(URL);
                
                if (foundIt) {
                    existingItem = item;
                    break;
                }
            }
        }
        
        if (enabled && (existingItem == NULL)) {
            LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst,
                                          NULL, NULL, (__bridge CFURLRef)itemURL, NULL, NULL);
            
        } else if (!enabled && (existingItem != NULL))
            LSSharedFileListItemRemove(loginItems, existingItem);
        
        CFRelease(loginItems);
    }       
}
@end
