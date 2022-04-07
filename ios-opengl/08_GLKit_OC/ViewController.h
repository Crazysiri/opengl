//
//  ViewController.h
//  08_GLKit_OC
//
//  Created by 陈嘉琳 on 2020/7/24.
//  Copyright © 2020 CJL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface ViewController : GLKViewController


@end


@interface MapBaseDataUpdater : NSObject

@property (nonatomic,assign) NSInteger width;
@property (nonatomic,assign) NSInteger height;

@property (nonatomic,assign) CGFloat positionX;
@property (nonatomic,assign) CGFloat positionY;

@property (nonatomic,assign) CGFloat resolutionX;
@property (nonatomic,assign) CGFloat resolutionY;

@end
