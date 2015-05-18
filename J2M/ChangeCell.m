//
//  ChangeCell.m
//  J2M
//
//  Created by 天池邵 on 15/4/1.
//  Copyright (c) 2015年 rainbow. All rights reserved.
//

#import "ChangeCell.h"

@interface ChangeCell ()
@property (weak) IBOutlet NSTextField *originPropertyNameLb;
@property (weak) IBOutlet NSTextField *freshPropertyNameTxt;
@property (weak) IBOutlet NSComboBox *typeComboBox;
@end

@implementation ChangeCell
- (void)setupWithOriginName:(NSString *)originName {
    _originPropertyNameLb.stringValue = originName;
}

- (NSDictionary *)changeInfo {
    if ([_freshPropertyNameTxt.stringValue isEqualToString:@""]) {
        return nil;
    } else {
        return @{@"origin" : _originPropertyNameLb.stringValue,
                 @"fresh"  : _freshPropertyNameTxt.stringValue,
                 @"type"   : [[_typeComboBox selectedCell] stringValue]};
    }
    
}
@end
