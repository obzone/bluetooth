//
//  ViewController.h
//  controlSide
//
//  Created by obzone on 16/1/3.
//  Copyright © 2016年 obzone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

extern NSString * const ControlMsgTakePhoto;

extern NSString * const UserHead ;
extern NSString * const P2CPhoto;
extern NSString * const C2PPhoto;

@protocol PeripheralServiceDelegate;

@interface PeripheralService : NSObject

@property (nonatomic ,strong) NSString * peripheralName;

@property (nonatomic ,weak) id<PeripheralServiceDelegate> delegate;

- (void)sendBluetoothControlRequest;                // 开始广播控制请求
- (void)stopSendBluetoothControlRequest;            // 停止广播控制请求
- (void)sendTakePhotoMsg;                           // 发送拍照请求
- (void)sendPhoto2CenterSide:(UIImage *)image;      // 传一张图片到中心端

@end

@protocol PeripheralServiceDelegate <NSObject>

@required
- (void)isSuccessfulConnect2Center:(BOOL)isSuccess;         // 成功连接到中心设备
- (void)didDisconnect2Center;                               // 与中心设备断开连接

- (void)didReceiveImageFromCenterSide:(UIImage *)image;     // 从中心设备接收到一张图片

@end