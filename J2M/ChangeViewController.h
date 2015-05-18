//
//  ChangeViewController.h
//  J2M
//
//  Created by 天池邵 on 15/4/1.
//  Copyright (c) 2015年 rainbow. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ChangeViewController : NSViewController
@property (copy) void(^OKHandler)(NSDictionary *changes);
@property (copy) NSArray *properties;
@end
