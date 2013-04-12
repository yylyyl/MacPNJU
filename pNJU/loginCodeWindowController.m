//
//  loginCodeWindowController.m
//  pNJU
//
//  Created by yangyiliang on 12-9-2.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import "loginCodeWindowController.h"

@interface loginCodeWindowController ()

@end

@implementation loginCodeWindowController
@synthesize imageVIew;
@synthesize loginCodeField;
@synthesize okButton;

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
    ok = NO;
}

- (IBAction)okPressed:(id)sender {
    //myConnect *connect = [myConnect getMe];
    if (![loginCodeField.stringValue isEqualToString:@""])
    {
        ok = YES;
        [self.window close];
    }
}

- (BOOL)isOK
{
    return ok;
}
@end
