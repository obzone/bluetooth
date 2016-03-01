//
//  ViewController.m
//  controlSide
//
//  Created by obzone on 16/1/3.
//  Copyright © 2016年 obzone. All rights reserved.
//

#import "IndexViewController.h"
#import "ImagePreviewViewController.h"
#import "TransformHistoryModel.h"

@interface IndexViewController ()<UIImagePickerControllerDelegate ,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView        *   mySelfImageView;
@property (weak, nonatomic) IBOutlet UIButton           *   othersIconButton;
@property (weak, nonatomic) IBOutlet UITableView        *   historyTableView;
@property (weak, nonatomic) IBOutlet UIButton           *   sharePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton           *   takePhotoButton;
@property (weak, nonatomic) IBOutlet UILabel            *   userConnectStatusBar;
@property (weak, nonatomic) IBOutlet UIButton           *   disConnectUser;

@property (nonatomic ,strong) UIImagePickerController   *   mainImagePickerController;
@property (strong, nonatomic) CAGradientLayer           *   gradientLayer;
@property (nonatomic ,strong) ImagePreviewViewController*   imagePreviewViewController;

@property (nonatomic ,strong) NSMutableArray            *   historyArray;

@end

@implementation IndexViewController
- (IBAction)ButtonClicked:(id)sender {
    
    switch ([(UIButton *)sender tag]) {
        case 1999: // 发送照片
            
            NSDebug(@"send photo");
            
            break;
        case 2000: // 拍照
            
            if (_role == IndexViewRoleCenter) {
                
                _role = IndexViewRoleNone;
                [_centerService disConnect2Peripheral];
                [_peripheralService sendBluetoothControlRequest];
                
            }else if(_role == IndexViewRolePeripheral){
            
                [_peripheralService sendTakePhotoMsg];
            
            }
            
            break;
        case 2001: // 断开连接
            
            _disConnectUser.hidden = YES;
            [_peripheralService sendBluetoothControlRequest];
            
            break;
        default:
            break;
    }
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqualToString:@"goUserListPage"]) {
        
        [segue.destinationViewController performSelector:@selector(setIndexViewController:) withObject:self];
        
    }

}

- (void)initControllerAboutImage{
    
    _mainImagePickerController                      = [UIImagePickerController new];
    _mainImagePickerController.delegate             = self;
    _mainImagePickerController.sourceType           = UIImagePickerControllerSourceTypeCamera;
    _mainImagePickerController.cameraCaptureMode    = UIImagePickerControllerCameraCaptureModePhoto;
    _mainImagePickerController.cameraDevice         = UIImagePickerControllerCameraDeviceFront;
    _mainImagePickerController.cameraFlashMode      = UIImagePickerControllerCameraFlashModeOff;
    
    _imagePreviewViewController                     = [ImagePreviewViewController new];
    
}

#pragma mark - viewcontroller - delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"首页";
    
    _sharePhotoButton.layer.cornerRadius    = CGRectGetHeight(_sharePhotoButton.frame)  / 2.0f;
    _takePhotoButton.layer.cornerRadius     = CGRectGetHeight(_takePhotoButton.frame)   / 2.0f;
    _mySelfImageView.layer.cornerRadius     = CGRectGetHeight(_mySelfImageView.frame)   / 2.0f;
    _othersIconButton.layer.cornerRadius    = CGRectGetHeight(_othersIconButton.frame)  / 2.0f;
    _disConnectUser.layer.cornerRadius      = CGRectGetHeight(_disConnectUser.frame)    / 2.0f;
    
    [self initControllerAboutImage];
    
    _peripheralService  = [PeripheralService new];
    _peripheralService.delegate = self;
    
    _centerService      = [CenterService new];
    _centerService.delegate = self;
    
//    [self initConnectStatusBar];
//    [self userConnectBarAnimation:0];
    
    _historyArray = [NSMutableArray new];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    
    if (_role == IndexViewRoleNone) [_peripheralService sendBluetoothControlRequest];
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initConnectStatusBar{

    _gradientLayer = [CAGradientLayer new];
    _gradientLayer.startPoint = CGPointMake(0.0, 0.5);
    _gradientLayer.endPoint = CGPointMake(1.0, 0.5);
    _gradientLayer.colors = @[ (__bridge id)[UIColor lightGrayColor].CGColor
                              ,(__bridge id)[UIColor darkGrayColor].CGColor
                              ,(__bridge id)[UIColor lightGrayColor].CGColor ];
    _gradientLayer.locations = @[@0.0,@0.2,@0.4];
    _gradientLayer.frame = CGRectMake(CGRectGetMinX(_userConnectStatusBar.frame), CGRectGetMaxY(_userConnectStatusBar.frame), CGRectGetWidth(_userConnectStatusBar.frame), 3);
    
    [self.view.layer addSublayer:_gradientLayer];

}
- (void)userConnectBarAnimation:(NSInteger)operate{

    CABasicAnimation * baseAnimation0 = [CABasicAnimation animation];
    baseAnimation0.keyPath      = @"locations";
    baseAnimation0.fromValue    = @[@0.0,@0.2,@0.4];
    baseAnimation0.toValue      = @[@0.6,@0.8,@1.0];
    baseAnimation0.repeatCount  = HUGE_VALF;
    baseAnimation0.duration     = 1.5f;
    
    [_gradientLayer addAnimation:baseAnimation0 forKey:@"locationsAnimation"];

}

#pragma mark - UIImagePickerController - Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage * image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        [_centerService sendPhoto2Peripheral:image];

    });
    
    [_mainImagePickerController dismissViewControllerAnimated:YES completion:^{
        
        _mainImagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        [UIApplication sharedApplication].statusBarHidden = NO;
        
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [_mainImagePickerController dismissViewControllerAnimated:YES completion:^{
        
        _mainImagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        [UIApplication sharedApplication].statusBarHidden = NO;
        
    }];
    
}

#pragma mark - PeripheralService - Delegate
- (void)isSuccessfulConnect2Center:(BOOL)isSuccess{

    if (isSuccess) {
        
        _disConnectUser.hidden = NO;
        _role = IndexViewRolePeripheral;
        
    }

}
- (void)didReceiveImageFromCenterSide:(UIImage *)image{

    TransformHistoryModel * transformHistoryModel = [TransformHistoryModel new];
    transformHistoryModel.image = image;
    
    [_historyArray addObject:transformHistoryModel];
    
    _userConnectStatusBar.text = [NSString stringWithFormat:@"ok%@",image];
    
    _imagePreviewViewController.image = image;
    
    _mySelfImageView.image = image;
//    [self presentViewController:_imagePreviewViewController animated:YES completion:nil];

}
-(void)didDisconnect2Center{

    

}

#pragma mark - CenterService - Delegate
- (void)OpenCameraOrTakePhoto{

    if (_mainImagePickerController.cameraFlashMode == UIImagePickerControllerCameraFlashModeOff) {
        
        [self presentViewController:_mainImagePickerController animated:YES completion:^{
            
            _mainImagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
            
        }];
        
    }else{
    
        [_mainImagePickerController takePicture];
        
    }
    
}
- (void)didReceiveImageFromPerpheralSide:(UIImage *)image{
    
    NSLog(@"%@",image);
    
}


@end
