//
//  MainViewController.m
//  bluetooth
//
//  Created by obzone on 16/1/2.
//  Copyright © 2016年 obzone. All rights reserved.
//

#import "UsersTableViewController.h"
#import "UserModel.h"

#define NOTIFY_MTU      20

@interface UsersTableViewController () <UITableViewDataSource ,UITableViewDelegate>

@property (nonatomic ,strong) NSMutableArray * userArray;

@end

@implementation UsersTableViewController

- (IBAction)reFreshTable:(id)sender {
    
    [self.tableView reloadData];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate     = self;
    self.tableView.dataSource   = self;
    
    _indexViewController.centerService.connectDelegate = self;
    
    _userArray = [NSMutableArray new];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [_indexViewController.centerService getUserInfoListOfBluetoothControlRequest];
        
    });

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - custom - functions

#pragma mark - UITableView - DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _userArray.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * reusedId = @"reusedId";
    
    CBPeripheral * peripheral = [(UserModel *)[_userArray objectAtIndex:indexPath.row] peripheral];
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reusedId];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reusedId];
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        cell.textLabel.text = peripheral.name;
        cell.detailTextLabel.text = peripheral.RSSI.stringValue;
        cell.imageView.image = [UIImage imageNamed:@"user"];
        
    }
    
    return cell;
    
}

#pragma mark - UITableView - Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [_indexViewController.centerService connect2UserOfBluetoothPeripheral:[_userArray objectAtIndex:indexPath.row]];
        
    });
    
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
    // TODO 跳转用户详情列表
    
}

#pragma mark - CenterServiceConnect - Delegate
- (void)receivedUserInfoByBluetoothControlRequest:(UserModel *)user{

    [_userArray addObject:user];

}
- (void)isSuccessedConnect2UserOfBluetoothControlRequestStatue:(BOOL)isSuccess{    

    if (isSuccess) {
        
        _indexViewController.role = IndexViewRoleCenter;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.navigationController popViewControllerAnimated:NO];
            
        });
        
    }else {
    
        _indexViewController.role = IndexViewRoleNone;
    
    }

}

@end
