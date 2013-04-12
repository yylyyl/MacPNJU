//
//  AboutWindowController.h
//  pNJU
//
//  Created by yangyiliang on 12-9-2.
//  Copyright (c) 2012年 yangyiliang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AboutWindowController : NSWindowController

@property (weak) IBOutlet NSTextField *myURL;
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSTextField *versionField;

@end
