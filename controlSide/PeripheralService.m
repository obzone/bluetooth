//
//  ViewController.m
//  controlSide
//
//  Created by obzone on 16/1/3.
//  Copyright © 2016年 obzone. All rights reserved.
//

#import "PeripheralService.h"

NSString * const ControlMsgTakePhoto = @"TAKEPHOTO";

NSString * const UserHead = @"USERHEAD";
NSString * const P2CPhoto = @"P2CPHOTO";
NSString * const C2PPhoto = @"C2PPHOTO";

@interface PeripheralService () <CBPeripheralManagerDelegate>

@property (nonatomic ,strong) CBPeripheralManager       *   mainPeripheralManager;
@property (nonatomic ,strong) CBMutableCharacteristic   *   takePhotoCharacteristic;
@property (nonatomic ,strong) CBMutableService          *   myService;

@property (strong ,nonatomic) NSMutableData             *   tempData;

@end

@implementation PeripheralService

- (instancetype)initWithDelegate:(id<PeripheralServiceDelegate>)delegate{

    self = [super init];
    
    if (self) {
        
        self.delegate = delegate;
        
    }
    
    return self;

}


#pragma mark - cus fuc
- (void)sendBluetoothControlRequest{

    // 初始化周边设备管理类
    _mainPeripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{CBPeripheralManagerOptionShowPowerAlertKey:@YES}];
    
    // 初始化拍照控制 Characteristic
    _takePhotoCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TAKEPICTURE_CHARACTERISTIC] properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    // 初始化图片接收 Characteristic
    CBMutableCharacteristic * photoWriteableCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:PHOTO_WRITERABLE_CHARACTERISTIC] properties:CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsWriteable];
    
    // 初始化周边设备服务
    _myService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:MAIN_PERIPHERAL_SERVICE] primary:YES];
    _myService.characteristics = @[_takePhotoCharacteristic,photoWriteableCharacteristic];
    
}
- (void)stopSendBluetoothControlRequest{

    [_mainPeripheralManager stopAdvertising];

}
- (void)sendTakePhotoMsg{

    [_mainPeripheralManager updateValue:[ControlMsgTakePhoto dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_takePhotoCharacteristic onSubscribedCentrals:nil];

}
- (void)sendPhoto2CenterSide:(UIImage *)image{

    

}

#pragma mark - CBPeripheralManager - Delegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{

    NSDebug(@"%ld",(long)peripheral.state);
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            
            [_mainPeripheralManager addService:_myService];
            
            break;
            
        default:
            break;
    }

}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{

    if (error) {
        
        NSDebug(@"%@",error);
        
    }else{
        
        _peripheralName = _peripheralName == nil ? @"iphone(obzone)" : _peripheralName ;
    
        [_mainPeripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[_myService.UUID] ,CBAdvertisementDataLocalNameKey:_peripheralName}];
    
    }

}
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
 
    if (error) {
        
        NSDebug(@"%@",error);
        
    }
    
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests{
    
    NSString * string = [[NSString alloc] initWithData:requests.firstObject.value encoding:NSUTF8StringEncoding];
    
    if ([string isEqualToString:@"EOM"]) {

        [self.delegate didReceiveImageFromCenterSide:[UIImage imageWithData:_tempData]];

    }else if([string isEqualToString:@"WSD"]){

        _tempData = [NSMutableData new];
    
    }else{
    
        [_tempData appendData:requests.firstObject.value];
    
    }
    

}
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    
    [self.delegate isSuccessfulConnect2Center:YES];
    [_mainPeripheralManager stopAdvertising];
    
}

@end
