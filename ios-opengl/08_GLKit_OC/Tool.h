//
//  Tool.h
//  LenzRWControl
//
//  Created by Zero on 2022/4/2.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Tool : NSObject

+(CGContextRef)contextFromData:(NSData *)data width:(size_t)width height:(size_t)height;
+ (UIImage *)imageFromData:(NSData *)data;
+ (UIImage *)imageAddToWindowFromData:(NSData *)data;

@end


@interface NSData (STUnzipArchive)
- (NSData *)zlibDeflate;
@end
