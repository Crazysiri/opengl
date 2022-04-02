//
//  Object.h
//  08_GLKit_OC
//
//  Created by Zero on 2022/3/31.
//  Copyright © 2022 CJL. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Object : NSObject

@property (nonatomic,assign) unsigned int VAO;
@property (nonatomic,assign) unsigned int VBO;
@property (nonatomic,assign) unsigned int EBO;
@property (nonatomic,assign) unsigned int texture;

@property (nonatomic, strong) NSString *name;

- (id)initWithName:(NSString *)name;

- (void)draw;

@end

NS_ASSUME_NONNULL_END
