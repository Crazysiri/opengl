//
//  Tool.m
//  LenzRWControl
//
//  Created by Zero on 2022/4/2.
//

#import "Tool.h"

@implementation Tool

+(CGContextRef)contextFromData:(NSData *)data width:(size_t)width height:(size_t)height {
    UInt8 *bytes = (UInt8 *)data.bytes;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceGray();
    CGContextRef cgContext= CGBitmapContextCreate(bytes, width, height, 8, width, space, kCGImageAlphaNone);
    return cgContext;
}

+ (UIImage *)imageFromData:(NSData *)data {
    CGContextRef cgContext = [self contextFromData:data width:1662 height:1706];
    CGImageRef cgImage = CGBitmapContextCreateImage(cgContext);
    UIImage *image=[UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);
    return image;
}
    
+ (UIImage *)imageAddToWindowFromData:(NSData *)data {
    UIImage *image = [self imageFromData:data];
    UIImageView *view = [[UIImageView alloc] initWithImage:image];
    UIWindow *window = UIApplication.sharedApplication.delegate.window;
    [window addSubview:view];
    view.frame = CGRectMake(100, 100, 1662 / 2, 1704 / 2);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [view removeFromSuperview];
    });
    return image;
}

@end

#import <zlib.h>

@implementation NSData (STUnzipArchive)
- (NSData *)zlibDeflate
{
    if ([self length] == 0) return self;

        NSUInteger full_length = [self length];
        NSUInteger half_length = [self length] / 2;

        NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
        BOOL done = NO;
        int status;

        z_stream strm;
        strm.next_in = (Bytef *)[self bytes];
        strm.avail_in = (unsigned)[self length];
        strm.total_out = 0;
        strm.zalloc = Z_NULL;
        strm.zfree = Z_NULL;

        if (inflateInit (&strm) != Z_OK) return nil;

        while (!done)
        {
            // Make sure we have enough room and reset the lengths.
            if (strm.total_out >= [decompressed length])
                [decompressed increaseLengthBy: half_length];
            strm.next_out = [decompressed mutableBytes] + strm.total_out;
            strm.avail_out = (uint)([decompressed length] - strm.total_out);

            // Inflate another chunk.
            status = inflate (&strm, Z_SYNC_FLUSH);
            if (status == Z_STREAM_END) done = YES;
            else if (status != Z_OK) break;
        }
        if (inflateEnd (&strm) != Z_OK) return nil;
    
        // Set real length.
        if (done)
        {
            [decompressed setLength: strm.total_out];
            return [NSData dataWithData: decompressed];
        }
        else return nil;
}

@end
