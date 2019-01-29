//
//  MyImgViewController.m
//  qmp_ios
//
//  Created by molly on 2017/3/21.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "MyImgViewController.h"
#import <UIImageView+WebCache.h>

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ShareTo.h"
#import "TakeImageTool.h"

@interface MyImgViewController ()<UIScrollViewDelegate>
{
    TakeImageTool *_userPhotoTool;
}
@property (weak, nonatomic) UIScrollView *imgScrollView;
@property (weak, nonatomic) UIImageView *imgView;
@property (nonatomic) BOOL zoom;

@property (strong, nonatomic) ManagerHud* hudTool;
@property (strong, nonatomic) ShareTo *shareTool;

@end

@implementation MyImgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSString *title = @"";
    if ([_key isEqualToString:@"headimgurl"]) {
        title = @"我的头像";
    }
    else if ([_key isEqualToString:@"card"]){
        title = @"名片正面";
    }else if([_key isEqualToString:@"cardback"]){
    
        title = @"名片反面";
    }
    self.title = title;
    
    [self buildRightBarButtonItem];
    
    [self initImgView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pressEditImg{
    
    //判断网络连接状态
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }else{

        __weak typeof(self) weakSelf = self;
        _userPhotoTool = [[TakeImageTool alloc]init];
        [_userPhotoTool alertPhotoAction:^(UIImage *image, NSData *imgData) {

            _imgView.image = image;
            [weakSelf uploadingImg:image imageData:imgData];
        }];
    }

}

#pragma mark - 上传图片
- (void)uploadingImg:(UIImage *)img imageData:(NSData *)data{
    
    //判断网络连接状态
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }else{
        [PublicTool showHudWithView:KEYWindow];
        NSArray *fileDataArr = @[UIImageJPEGRepresentation(img, 1.0)];
        [[NetworkManager sharedMgr] uploadUrl:@"h/uploadusericoncard" fileDataArr:fileDataArr parameters:@{@"field":_key} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [PublicTool dismissHud:KEYWindow];
            //        [message isEqualToString:@"img upload error"]
            if (resultData && [resultData isKindOfClass:[NSString class]]) {
                //修改成功了
                if ([self.delegate respondsToSelector:@selector(updateInfoSuccess:withKey:)]) {
                    [self.delegate updateInfoSuccess:resultData withKey:_key];
                }
                //pop 过去,同时弹窗
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [ShowInfo showInfoOnView:self.view withInfo:@"图片上传失败"];
            }
        }];
    }
}

- (void)buildRightBarButtonItem{
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47.f, 20.f)];
    [rightBtn setTitle:@"上传" forState:UIControlStateNormal];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [rightBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(pressEditImg) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    if ([self.key isEqualToString:@"headimgurl"]) {
        self.navigationItem.rightBarButtonItem = item;

    }
    else if([self.key isEqualToString:@"card"]||[self.key isEqualToString:@"cardback"]){
        
        UIButton *shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47.f, 20.f)];
        [shareBtn setTitle:@"分享" forState:UIControlStateNormal];
        shareBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        shareBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
        [shareBtn setTitleColor:NV_OTHERTITLE_COLOR forState:UIControlStateNormal];
        [shareBtn addTarget:self action:@selector(shareMyCard) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];

        self.navigationItem.rightBarButtonItems = @[item,shareItem];
    }
}
/**
 分享我的名片
 */
- (void)shareMyCard{

    [self.shareTool shareOrginImgToApp:self.value];
}
- (void)initImgView{
    
    CGFloat scrollWH = SCREENW;
//    if ([_key isEqualToString:@"card"]) {
//        scrollWH = SCREENW/16*9;
//    }
    UIScrollView *imgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight)];
    imgScrollView.delegate = self;
    [self.view addSubview:imgScrollView];
    _imgScrollView = imgScrollView;
    
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, scrollWH)];
    imgV.layer.borderWidth = 1.f;
    imgV.layer.borderColor = RGBa(244, 244, 244, 1).CGColor;
    imgV.contentMode = UIViewContentModeScaleAspectFit;
    [imgScrollView addSubview:imgV];
    _imgView = imgV;
    
    [imgV sd_setImageWithURL:[NSURL URLWithString:_value]  placeholderImage:[UIImage imageNamed:@"headimg"]];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapImg:)];
    doubleTap.numberOfTapsRequired = 2;
    imgV.userInteractionEnabled = YES;
    [imgV addGestureRecognizer:doubleTap];
    
    imgScrollView.contentSize = imgV.frame.size;
    imgScrollView.maximumZoomScale = 3.0;
    imgScrollView.minimumZoomScale = 0.5;
    
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    return _imgView;
}

- (void)doubleTapImg:(UIGestureRecognizer *)gesture{
    
    _zoom = !_zoom;
    
    CGFloat scale = .0f;
    if (_zoom) {
        scale = 3.f;
    }
    else{
        
        scale = 1.f;
    }
    
    //    CGRect zoomRect = [self zoomRectForScale:scale withCenter:[gesture locationInView:gesture.view]];
    CGRect zoomRect = [self zoomRectForScale:scale withCenter:CGPointMake(SCREENW, SCREENW * 9 / 16)];
    
    [_imgScrollView zoomToRect:zoomRect animated:YES];
    
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center{
    
    CGRect zoomRect;
    
    zoomRect.size.height = [_imgScrollView frame].size.height / scale + 200;
    zoomRect.size.width  = [_imgScrollView frame].size.width  / scale;
    
    zoomRect.origin.x  = center.x - (zoomRect.size.width  / 2.0);
    
    zoomRect.origin.y  = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}
#pragma mark - 懒加载
- (ManagerHud *)hudTool{
    
    if (!_hudTool) {
        _hudTool = [[ManagerHud alloc] init];
    }
    return _hudTool;
}

- (ShareTo *)shareTool{

    if (!_shareTool) {
        _shareTool =  [[ShareTo alloc] init];
   }
    return _shareTool;
}
@end
