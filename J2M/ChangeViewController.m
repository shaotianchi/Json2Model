//
//  ChangeViewController.m
//  J2M
//
//  Created by 天池邵 on 15/4/1.
//  Copyright (c) 2015年 rainbow. All rights reserved.
//

#import "ChangeViewController.h"
#import "ChangeCell.h"
#import "ChangeViewController.h"

@interface ChangeViewController ()<NSTableViewDelegate, NSTableViewDataSource>
@property (weak) IBOutlet NSTableView *tableView;
@end

@implementation ChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _properties.count;
}

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    static NSString *installed = @"ChangeCell";
    id item = [self.properties objectAtIndex:row];
    ChangeCell *view = [tableView makeViewWithIdentifier:installed owner:self];
    [view setupWithOriginName:item];
    return view;
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewController:self];
}

- (IBAction)okAction:(id)sender {
    NSMutableDictionary *changes = [NSMutableDictionary dictionary];
    for (int i = 0; i < _properties.count; i ++ ) {
        ChangeCell *cell = [[self.tableView rowViewAtRow:i makeIfNecessary:NO] subviews][0];
        NSDictionary *change = [cell changeInfo];
        if (change) {
            [changes setObject:change forKey:change[@"origin"]];
        }
    }
    if (changes.count > 0 && _OKHandler) {
        _OKHandler([changes copy]);
    }
    
    [self dismissViewController:self];
}
@end
