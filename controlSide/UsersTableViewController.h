//
//  MainViewController.h
//  bluetooth
//
//  Created by obzone on 16/1/2.
//  Copyright © 2016年 obzone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CenterService.h"
#import "IndexViewController.h"

@interface UsersTableViewController : UITableViewController <CenterServiceUserConnectDelegate>

@property (nonatomic ,weak)   IndexViewController  *   indexViewController;

@end
