#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface yylOCR : NSObject
{
    NSBitmapImageRep *bmp;
}

- (id)initWithFile:(NSString *)file_name;
- (id)initWithData:(NSData *)data;
- (NSString *)getCode;
@end
