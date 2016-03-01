//
//  TransformHistoryModel.h
//  controlSide
//
//  Created by yecheng.shao on 16/1/25.
//  Copyright © 2016年 obzone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class UserModel;

@interface TransformHistoryModel : NSObject

@property (nonatomic ,strong) UserModel * from;
@property (nonatomic ,strong) UIImage   * image;
@property (nonatomic ,assign) NSInteger * status;

@end
