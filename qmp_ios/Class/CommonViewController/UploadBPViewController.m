//
//  UploadBPViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/4/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "UploadBPViewController.h"

@interface UploadBPViewController ()
@property(nonatomic,strong)UIScrollView *contentView;
@end

@implementation UploadBPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.contentView];
    self.contentView.frame = self.view.bounds;
    
    self.title = @"3步完成手机上传BP";
    
    UIImage *image = [BundleTool imageNamed:@"bp"];
    CGFloat height = image.size.height / [UIScreen mainScreen].scale;
    CGFloat width = image.size.width / [UIScreen mainScreen].scale;

    width = SCREENW;
    height = SCREENW*image.size.height/ SCREENH;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    imageView.image = image;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:imageView];
    self.contentView.contentSize =CGSizeMake(SCREENW, height+50);
    if (@available(iOS 11.0, *)) {
        self.contentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
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

- (UIScrollView *)contentView {
    if (!_contentView) {
        _contentView = [[UIScrollView alloc] init];
    }
    return _contentView;
}
@end
