//
//  PhotoEditViewController.m
//  qmp_ios
//
//  Created by QMP on 2017/12/13.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "PhotoEditViewController.h"
#import "TKImageView.h"
#import "UIImage+Rotate.h"

@interface PhotoEditViewController ()
{
    
    __weak IBOutlet NSLayoutConstraint *_topHeight;
    __weak IBOutlet TKImageView *_tkImageView;
}

@property (weak, nonatomic) IBOutlet UIButton *retakeBtn;

@end

@implementation PhotoEditViewController
-(instancetype)init{
    PhotoEditViewController *vc = [[PhotoEditViewController alloc]initWithNibName:@"PhotoEditViewController" bundle:[BundleTool commonBundle]];
    return vc;
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    _topHeight.constant = kStatusBarHeight+20;
    [self.retakeBtn setTitle:self.isCamera ? @"重拍":@"重新选择" forState:UIControlStateNormal];
    [self setUpTKImageView];
}


- (void)setUpTKImageView {
    
    _tkImageView.toCropImage = self.img;
    _tkImageView.cropAspectRatio = self.img.size.width/self.img.size.height;
    _tkImageView.showMidLines = YES;
    _tkImageView.needScaleCrop = YES;
    _tkImageView.showCrossLines = NO; //不显示内部分割线
    _tkImageView.cornerBorderInImage = NO;
    _tkImageView.cropAreaCornerWidth = 25;
    _tkImageView.cropAreaCornerHeight = 25;
    _tkImageView.minSpace = 30;
    _tkImageView.cropAreaCornerLineColor = [UIColor whiteColor];
    _tkImageView.cropAreaCornerLineWidth = 3;

    _tkImageView.cropAreaBorderLineColor = [UIColor whiteColor];
    _tkImageView.cropAreaBorderLineWidth = 1;
    
    _tkImageView.cropAreaMidLineWidth = 30;
    _tkImageView.cropAreaMidLineHeight = 3;
    _tkImageView.cropAreaMidLineColor = [UIColor whiteColor];
    
    _tkImageView.cropAreaCrossLineColor = [UIColor whiteColor];
    _tkImageView.cropAreaCrossLineWidth = 2;
    _tkImageView.initialScaleFactor = 1;
    _tkImageView.cropAspectRatio = 0;
    _tkImageView.backgroundColor = [UIColor blackColor];
    
}



- (IBAction)cancleBtnClick:(id)sender {
    

    [self dismissViewControllerAnimated:YES completion:^{
        if(self.isCamera){
            self.reTakeImg(YES);
        }else{
            self.reTakeImg(NO);
        }
    }];

}

/* UIImageOrientationUp,            // default orientation
 UIImageOrientationDown,          // 180 deg rotation
 UIImageOrientationLeft,          // 90 deg CCW
 UIImageOrientationRight, */

- (IBAction)rotateBtnClick:(id)sender {
    
    switch (self.img.imageOrientation) {
        case UIImageOrientationUp:
            
            _tkImageView.toCropImage = [_tkImageView.toCropImage rotate:UIImageOrientationRight];
            break;
            
        case UIImageOrientationUpMirrored:
            _tkImageView.toCropImage = [_tkImageView.toCropImage rotate:UIImageOrientationRightMirrored];
            break;
            
        case UIImageOrientationDown:
            _tkImageView.toCropImage = [_tkImageView.toCropImage rotate:UIImageOrientationLeft];

            break;
            
        case UIImageOrientationDownMirrored:
            _tkImageView.toCropImage = [_tkImageView.toCropImage rotate:UIImageOrientationLeftMirrored];
            
            break;
            
        case UIImageOrientationLeft:
            _tkImageView.toCropImage = [_tkImageView.toCropImage rotate:UIImageOrientationUp];

            break;
            
        case UIImageOrientationLeftMirrored:
            _tkImageView.toCropImage = [_tkImageView.toCropImage rotate:UIImageOrientationUpMirrored];

            break;
            
        case UIImageOrientationRight:
            _tkImageView.toCropImage = [_tkImageView.toCropImage rotate:UIImageOrientationDown];
           
            break;
            
        case UIImageOrientationRightMirrored:
            _tkImageView.toCropImage = [_tkImageView.toCropImage rotate:UIImageOrientationDownMirrored];
            break;
    }
    
}

- (IBAction)sureBtnClick:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        self.finishCropImage(_tkImageView.currentCroppedImage);

    }];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
