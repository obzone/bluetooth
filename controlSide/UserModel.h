//
//  UserModel.h
//  controlSide
//
//  Created by yecheng.shao on 16/1/20.
//  Copyright © 2016年 obzone. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CBPeripheral;

@interface UserModel : NSObject

@property (nonatomic ,copy)     NSString        * name;
@property (nonatomic ,copy)     NSString        * UUID;
@property (nonatomic ,copy)     NSString        * headImgInDocName;
@property (nonatomic ,strong)   CBPeripheral    * peripheral;

@end
