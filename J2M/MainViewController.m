//
//  MainViewController.m
//  J2MPlugin
//
//  Created by 天池邵 on 15/3/27.
//  Copyright (c) 2015年 rainbow. All rights reserved.
//

#import "MainViewController.h"
#import "ChangeViewController.h"

@interface MainViewController ()
@property (weak) IBOutlet NSTextField *modelNameTxt;
@property (weak) IBOutlet NSTextField *jsonTxt;
@property (weak) IBOutlet NSButton *checkInit;
@property (weak) IBOutlet NSButton *checkConvert;
@property (weak) IBOutlet NSButton *checkNSCopy;
@property (copy) NSDictionary *changes;

@property (nonatomic, strong) NSMutableDictionary *keysDic;
@end

@implementation MainViewController

- (instancetype)init {
    self = [super initWithNibName:@"MainViewController" bundle:[NSBundle bundleForClass:[self class]]];
    return self;
}

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _keysDic = [[NSMutableDictionary alloc] init];
}

- (IBAction)startConvertAction:(id)sender {
    NSString *jsonStr = _jsonTxt.stringValue;
//    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    NSLog(@"%@", dic);
    [self buildKeysDicWithJsonDic:dic];
    [self buildHFileWithDic:_keysDic];
    [self buildMFileWithDic:_keysDic];
}


- (void)buildKeysDicWithJsonDic:(NSDictionary *)dic{
    [_keysDic removeAllObjects];
    for (NSString *key in dic.allKeys) {
        id value = dic[key];
        NSString *valueType;
        if ([value isKindOfClass:[NSString class]]) {
            valueType = @"NSString";
        } else if ([value isKindOfClass:[NSNumber class]]) {
            valueType = @"NSNumber";
        } else if ([value isKindOfClass:[NSArray class]]) {
            valueType = @"NSArray";
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            valueType = @"NSDictionary";
        } else {
            valueType = @"id";
        }
        [_keysDic setObject:valueType forKey:key];
    }
}

- (void)buildHFileWithDic:(NSDictionary *)dic{
    NSMutableString *h_Content = [NSMutableString stringWithFormat:@"#import <Foundation/Foundation.h>\n\n"
                                  "@interface %@ : NSObject",_modelNameTxt.stringValue];
    if (_checkNSCopy.state == 1) {
        [h_Content appendString:@"<NSCopying>\n"];
    } else {
        [h_Content appendString:@"\n"];
    }
    for (NSString *key in dic.allKeys) {
        NSString *valueType = dic[key];
        NSString *realKey = [key copy];
        if ([_changes.allKeys containsObject:key]) {
            realKey = _changes[key][@"fresh"];
            valueType = _changes[key][@"type"];
        }
        NSString *property = [NSString stringWithFormat:@"@property (strong, nonatomic) %@ *%@;\n",valueType,realKey];
        [h_Content appendString:property];
    }
    if (_checkInit.state == 1) {
        [h_Content appendString:@"- (instancetype)initWithDic:(NSDictionary *)dic;\n"];
        [h_Content appendString:@"+ (NSArray *)setupWithArray:(NSArray *)arr;\n"];
    }
    if (_checkConvert.state == 1) {
        [h_Content appendString:@"- (NSDictionary *)convertToDic;\n"];
    }
    
    [h_Content appendString:@"@end"];
    NSString *path = [NSString stringWithFormat:@"%@/%@.h",NSHomeDirectory(),_modelNameTxt.stringValue];
    [h_Content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)buildMFileWithDic:(NSDictionary *)dic{
    NSMutableString *m_Content = [NSMutableString stringWithFormat:@"#import \"%@.h\"\n\n",_modelNameTxt.stringValue];
    if (_changes && _changes.allKeys > 0) {
        [m_Content appendFormat:@"@interface %@ ()\n", _modelNameTxt.stringValue];
        for (NSString *key in _changes.allKeys) {
            NSString *originValueType = dic[key];
            [m_Content appendFormat:@"@property(strong, nonatomic) %@ *%@;\n",originValueType, key];
        }
        [m_Content appendString:@"@end\n\n"];
        
    }
    
    [m_Content appendFormat:@"@implementation %@\n", _modelNameTxt.stringValue];
    
    if (_checkInit.state == 1) {
        [m_Content appendString:@"- (instancetype)initWithDic:(NSDictionary *)dic{\n"
         "    self = [super init];\n"
         "    if (self) {\n"];
        for (NSString *key in dic.allKeys) {
            NSString *property = [NSString stringWithFormat:@"        _%@ = dic[@\"%@\"];\n",key,key];
            [m_Content appendString:property];
        }
        [m_Content appendString:@"    }\n"
         "    return self;\n"
         "}\n\n"];
        
        [m_Content appendFormat:@"+ (NSArray *)setupWithArray:(NSArray *)arr {\n"
         "   NSMutableArray *resultArr = [NSMutableArray array];\n"
         "   for (NSDictionary *lockDic in arr) {\n"
         "       %@ *lock = [[%@ alloc] initWithDic:lockDic];\n"
         "       [resultArr addObject:lock];\n"
         "   }\n"
         "   return resultArr;\n"
         "}\n\n", _modelNameTxt.stringValue, _modelNameTxt.stringValue];
    }
    if (_checkConvert.state == 1) {
        [m_Content appendString:@"- (NSDictionary *)convertToDic{\n"
         "    NSDictionary *dic = @{\n"];
        for (NSString *key in _keysDic.allKeys) {
            NSString *property;
            if ([_keysDic.allKeys indexOfObject:key] == _keysDic.allKeys.count - 1) {
                property = [NSString stringWithFormat:@"                           @\"%@\" : _%@};\n",key,key];
            } else {
                property = [NSString stringWithFormat:@"                           @\"%@\" : _%@,\n",key,key];
            }
            [m_Content appendString:property];
        }
        [m_Content appendString:@"    return dic;\n"
         "}\n\n"];
        
    }
    if (_checkNSCopy.state == 1) {
        [m_Content appendFormat:@"-(instancetype)copyWithZone:(NSZone *)zone{ \n"
         "    %@ *model = [[[self class] allocWithZone:zone] init];\n", _modelNameTxt.stringValue];
        for (NSString *key in _keysDic.allKeys) {
            NSString *property;
            property = [NSString stringWithFormat:@"    model.%@ = self.%@; \n", key, key];
            [m_Content appendString:property];
        }
        
        [m_Content appendString:@"    return model;\n}\n"];
        
    }
    
    if (_changes && _changes.allKeys > 0) {
        for (NSString *key in _changes.allKeys) {
            [m_Content appendFormat:@"- (%@ *)%@ {\n",_changes[key][@"type"], _changes[key][@"fresh"]];
            [m_Content appendString:@"#error Complete Me\n"];
            [m_Content appendString:@"}\n"];
        }
    }
    [m_Content appendString:@"@end"];
    NSString *path = [NSString stringWithFormat:@"%@/%@.m",NSHomeDirectory(),_modelNameTxt.stringValue];
    [m_Content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (IBAction)closeAction:(id)sender {
    [[[self view] window] close];
    [[NSApp keyWindow] endSheet:[self.view window]];
}

- (IBAction)changeAction:(id)sender {
    NSString *jsonStr = _jsonTxt.stringValue;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:kUnicodeUTF8Format] options:0 error:nil];
    [self buildKeysDicWithJsonDic:dic];
    [self performSegueWithIdentifier:@"ShowChange" sender:self];
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowChange"]) {
        ChangeViewController *changeVC = segue.destinationController;
        [changeVC setOKHandler:^(NSDictionary *changes) {
            _changes = changes;
        }];
        changeVC.properties = [_keysDic.allKeys copy];
    }
}
@end
