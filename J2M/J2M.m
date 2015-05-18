//
//  J2M.m
//  J2M
//
//  Created by 天池邵 on 15/3/27.
//  Copyright (c) 2015年 rainbow. All rights reserved.
//

#import "J2M.h"
static J2M *sharedPlugin;

@interface J2M()
@property (strong) NSWindowController *mainWindowController;
@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation J2M

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        
        // Create menu items, initialize UI, etc.

        // Sample Menu Item:
        NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Product"];
        if (menuItem) {
            [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
            NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Json2Model" action:@selector(doMenuAction) keyEquivalent:@""];
            [actionMenuItem setTarget:self];
            [[menuItem submenu] addItem:actionMenuItem];
        }
    }
    return self;
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    if (!_mainWindowController) {
        NSStoryboard *sb = [NSStoryboard storyboardWithName:@"MainWindowController" bundle:[NSBundle bundleForClass:[self class]]];
        NSWindowController *controller = [sb instantiateControllerWithIdentifier:@"Main"];
        _mainWindowController = controller;
    }
    
    if ([NSApp keyWindow]) {
        [[NSApp keyWindow] beginSheet:[_mainWindowController window] completionHandler:^(NSModalResponse returnCode) {
            NSLog(@"return code: %ld", (long)returnCode);
        }];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
