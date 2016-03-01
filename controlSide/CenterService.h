//
//  MainViewController.h
//  bluetooth
//
//  Created by obzone on 16/1/2.
//  Copyright © 2016年 obzone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "UserModel.h"

@protocol CenterServiceDelegate;
@protocol CenterServiceUserConnectDelegate;

@interface CenterService : NSObject

@property (nonatomic ,weak) id<CenterServiceDelegate> delegate;
@property (nonatomic ,weak) id<CenterServiceUserConnectDelegate> connectDelegate;

- (void)sendPhoto2Peripheral:(UIImage *)image;                  // 发送一张照片到周边设备
- (void)disConnect2Peripheral;                                  // 断开与周边设备的连接

- (void)getUserInfoListOfBluetoothControlRequest;               // 或许当前发起蓝牙请求的用户信息
- (void)connect2UserOfBluetoothPeripheral:(UserModel *)user;    // 连接到一个指定的用户

@end

@protocol CenterServiceDelegate <NSObject>

@required
- (void)OpenCameraOrTakePhoto;                                  // 打开相机 ／ 拍照
- (void)didReceiveImageFromPerpheralSide:(UIImage *)image;      // 从周边设备接收到一张照片

@end

@protocol CenterServiceUserConnectDelegate <NSObject>

@required
- (void)receivedUserInfoByBluetoothControlRequest:(UserModel *)user;
- (void)isSuccessedConnect2UserOfBluetoothControlRequestStatue:(BOOL)isSuccess;

@end