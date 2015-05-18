//
//  J2M.h
//  J2M
//
//  Created by 天池邵 on 15/3/27.
//  Copyright (c) 2015年 rainbow. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface J2M : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end