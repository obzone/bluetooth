//
//  ImagePreviewViewController.m
//  controlSide
//
//  Created by yecheng.shao on 16/1/20.
//  Copyright © 2016年 obzone. All rights reserved.
//

#import "ImagePreviewViewController.h"

@interface ImagePreviewViewController ()

@end

@implementation ImagePreviewViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self = [self initWithNibName:@"ImagePreviewView" bundle:nil];
        
    }
    return self;
}

- (IBAction)buttonOnClick:(UIButton *)sender {
    
    switch (sender.tag) {
        case 2000:// 返回按钮
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            break;
            
        case 2001:// 保存到手机相册
            
            break;
            
        default:
            break;
    }
    
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.mainImageView.image = _image;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
