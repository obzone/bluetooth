//
//  ImagePreviewViewController.h
//  controlSide
//
//  Created by yecheng.shao on 16/1/20.
//  Copyright © 2016年 obzone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePreviewViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;

@property (nonatomic ,strong) UIImage * image;

@end
