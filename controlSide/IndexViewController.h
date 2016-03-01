//
//  ViewController.h
//  controlSide
//
//  Created by obzone on 16/1/3.
//  Copyright © 2016年 obzone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "PeripheralService.h"
#import "CenterService.h"

typedef NS_ENUM(NSInteger, IndexViewRole) {
    IndexViewRoleNone = 0,
    IndexViewRoleCenter,
    IndexViewRolePeripheral
};

@interface IndexViewController : UIViewController <PeripheralServiceDelegate ,CenterServiceDelegate>

@property (nonatomic ,assign) IndexViewRole        role;

@property (nonatomic ,strong) PeripheralService    *   peripheralService;
@property (nonatomic ,strong) CenterService        *   centerService;

@end

