//
//  loginCodeWindowController.h
//  pNJU
//
//  Created by yangyiliang on 12-9-2.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface loginCodeWindowController : NSWindowController
{
    BOOL ok;
}
@property (weak) IBOutlet NSImageView *imageVIew;
@property (weak) IBOutlet NSTextField *loginCodeField;
@property (weak) IBOutlet NSButton *okButton;

- (IBAction)okPressed:(id)sender;
- (BOOL)isOK;
@end
