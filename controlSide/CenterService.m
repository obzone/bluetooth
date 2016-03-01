//
//  MainViewController.m
//  bluetooth
//
//  Created by obzone on 16/1/2.
//  Copyright © 2016年 obzone. All rights reserved.
//
#import "CenterService.h"

#define NOTIFY_MTU      20

@interface CenterService () <CBCentralManagerDelegate ,CBPeripheralDelegate ,UINavigationControllerDelegate>

@property (nonatomic ,strong) CBCentralManager           * mainCenterManager;
@property (nonatomic ,strong) CBPeripheral               * connectedPeripheral;             // 当前连接的周边设备

@property (nonatomic ,strong) CBCharacteristic           * photoWriteablechatacteristic;    // 用来回传图片

@end

@implementation CenterService

- (instancetype)initWithDelegate:(id<CenterServiceDelegate>)delegate{
    self = [super init];
    
    if (self) {
        
        self.delegate = delegate;
        
    }
    
    return self;
    
}

#pragma mark - custom - functions
- (void)getUserInfoListOfBluetoothControlRequest{

    _mainCenterManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) options:@{CBCentralManagerOptionShowPowerAlertKey:@YES}];
    
}
- (void)connect2UserOfBluetoothPeripheral:(UserModel *)user{
    
    [_mainCenterManager connectPeripheral:user.peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES}];
    
    [_mainCenterManager stopScan];
    
}
- (void)sendPhoto2Peripheral:(UIImage *)image{

    [self writeData:UIImageJPEGRepresentation(image, .1f) toCharacteristic:_photoWriteablechatacteristic ofPerpheral:_connectedPeripheral];
//    [self writeData:[@"hello" dataUsingEncoding:NSUTF8StringEncoding] toCharacteristic:_photoWriteablechatacteristic ofPerpheral:_connectedPeripheral];

}
- (void)disConnect2Peripheral{

    [_mainCenterManager cancelPeripheralConnection:_connectedPeripheral];

}
- (void)reScanUsers{
    
    [_mainCenterManager stopScan];
    [_mainCenterManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:MAIN_PERIPHERAL_SERVICE]] options:nil];

}
/** Sends the next amount of data to the connected central
 */
- (void)writeData:(NSData *)data toCharacteristic:(CBCharacteristic *)characteristic ofPerpheral:(CBPeripheral *)peripheral{
    
    NSInteger sendDataIndex = 0;
    
    // There's data left, so send until the callback fails, or we're done. WSD - will send data

    [peripheral writeValue:[@"WSD" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
    
    while (YES) {
        
        
        // Work out how big it should be
        NSInteger amountToSend = data.length - sendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:data.bytes+sendDataIndex length:amountToSend];
        
        // Send it
        [peripheral writeValue:chunk forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
        
        // It did send, so update our index
        sendDataIndex += amountToSend;
        
        // Was it the last one?
        if (sendDataIndex >= data.length) {
            
            // It was - send an EOM
            
            // Send it
            [peripheral writeValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
            
            return;
        }
    }
}

#pragma markk - CBCentralManager - Delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            
            [self reScanUsers];
            
            break;
        default:
            break;
    }

}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSDebug(@"%@",peripheral);
    
    UserModel * model = [UserModel new];
    model.peripheral = peripheral;
    
    [self.connectDelegate receivedUserInfoByBluetoothControlRequest:model];
    

}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{

    NSDebug(@"%@",peripheral);
    
    self.connectedPeripheral = peripheral;
    
    peripheral.delegate = self;
    [peripheral discoverServices:nil];

}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{

    if (error) {
        
        NSDebug(@"%@",error);
        [self.connectDelegate isSuccessedConnect2UserOfBluetoothControlRequestStatue:NO];
        
    }
    
    [self reScanUsers];

}

#pragma mark - CBPeripheral - Delegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error{

    NSDebug(@"%@",peripheral.services);
    
    for (CBService * servie in peripheral.services) {
        
        if ([servie.UUID isEqual:[CBUUID UUIDWithString:MAIN_PERIPHERAL_SERVICE]]) {
            
            [peripheral discoverCharacteristics:nil forService:servie];
            
        }
        
    }

}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error{

    NSDebug(@"%@",service.characteristics);
    
    for (CBCharacteristic * character in service.characteristics) {
        
        if ([character.UUID isEqual:[CBUUID UUIDWithString:TAKEPICTURE_CHARACTERISTIC]]) { // 拍照控制 Characteristic
            
            [peripheral setNotifyValue:YES forCharacteristic:character];
            
        }else
        if ([character.UUID isEqual:[CBUUID UUIDWithString:PHOTO_WRITERABLE_CHARACTERISTIC]]) { // 用来回传照片的 Characteristic
            
            self.photoWriteablechatacteristic = character;
            
        }
        
    }

}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{

    NSDebug(@"%@",[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
    
    [self.delegate OpenCameraOrTakePhoto];
    
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{

    if (error) {

        NSDebug(@"%@",error);
        [self.connectDelegate isSuccessedConnect2UserOfBluetoothControlRequestStatue:NO];
        
    }else{
    
        [self.connectDelegate isSuccessedConnect2UserOfBluetoothControlRequestStatue:YES];
    
    }

}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{

    NSDebug(@"%@",error);

}

@end
