//
//  Object.m
//  08_GLKit_OC
//
//  Created by Zero on 2022/3/31.
//  Copyright © 2022 CJL. All rights reserved.
//

#import "Object.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <UIKit/UIKit.h>
#import "Shader.hpp"

@interface Object()
{
    Shader *_shader;
}
@end

@implementation Object



- (id)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        self.name = name;
        _shader = [self createShader:@"map_shader"];
    }
    return self;
}

- (void)draw {
    
}

- (Shader *)createShader:(NSString *)name {
    NSString *vsPath = [NSBundle.mainBundle pathForResource:name ofType:@"vs"];
    NSString *fsPath = [NSBundle.mainBundle pathForResource:name ofType:@"fs"];

    Shader *s = new Shader([vsPath cStringUsingEncoding:NSUTF8StringEncoding],[fsPath cStringUsingEncoding:NSUTF8StringEncoding]);
    return s;
}

- (GLuint)setupTexture: (NSString *)fileName {
    
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"get Image failed");
        exit(1);
    }
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte *spriteData = (GLubyte *)calloc(width*height*4, sizeof(GLubyte));

    CGContextRef context = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextDrawImage(context, rect, spriteImage);
    
    CGContextRelease(context);
    unsigned int texture;
    glGenTextures(1,&texture);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
    
    return texture;
}

@end
