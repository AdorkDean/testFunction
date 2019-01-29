//
//  CreateFeedBackViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/4/8.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "CreateFeedBackViewController.h"
#import "HMTextView.h"
#import "PickPhotosView.h"
#import <TZImagePickerController.h>

#define kTopHeight
@interface CreateFeedBackViewController () <TZImagePickerControllerDelegate, PickPhotosViewDelegate, UITextViewDelegate> {
    CGFloat _topHeight;
    CGFloat _textViewHeight;
    NSInteger _pickPhotoViewTag;
}
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) HMTextView *textView;
@property (nonatomic, strong) UIView *photosView;

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *assets;

@property (nonatomic, strong) NSMutableArray *photoUrls;
@end

@implementation CreateFeedBackViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        _topHeight = SCREENW >= 375 ? 231 : 200;
        _textViewHeight = 112;
        _pickPhotoViewTag = 1203;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我要反馈";
    self.view.backgroundColor = TABLEVIEW_COLOR;
    [self setupNavBar];
    
    [self.view addSubview:self.topView];
    [self.topView addSubview:self.textView];
    [self.topView addSubview:self.photosView];

}

- (void)setupNavBar {
    UIButton *navRightButton = [[UIButton alloc] initWithFrame:RIGHTBARBTNFRAME];
    [navRightButton setTitle:@"提交" forState:UIControlStateNormal];
    [navRightButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [navRightButton setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    navRightButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:navRightButton];
    [navRightButton addTarget:self action:@selector(postFeedBack) forControlEvents:UIControlEventTouchUpInside];
}

- (void)postFeedBack {
    if (self.photoUrls.count <= 0 && self.textView.text.length <= 0) {
        [PublicTool showMsg:@"请输入反馈内容"];
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:[WechatUserInfo shared].unionid forKey:@"unionid"];
    [param setValue:[@"iosapp:" stringByAppendingString:VERSION] forKey:@"system"];
    [param setValue:self.textView.text forKey:@"desc"];
    [param setValue:self.photoUrls forKey:@"images"];
    
    if (_source == 2) {
        [param setValue:@"全局反馈" forKey:@"type"];
    } else {
        [param setValue:@"贡献反馈" forKey:@"type"];
    }
    
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/userAddFeedback" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData) {
            [PublicTool showMsg:@"感谢您的反馈"];
            if (self.block) {
                self.block([NSDictionary dictionary]);
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [PublicTool showMsg:REQUEST_ERROR_TITLE];
        }
    }];
    
}
#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 500) {
        textView.text = [textView.text substringToIndex:500];
        [PublicTool showMsg:@"最多输入500字"];
    }
}

#pragma mark - TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    self.photos = [NSMutableArray arrayWithArray:photos];
    self.assets = [NSMutableArray arrayWithArray:assets];
    
    [self updatePhotosShowWithPhotos:self.photos];
    
    
    NSMutableArray *urls = [NSMutableArray array];
    [PublicTool showHudWithView:KEYWindow];
    __block int i = 0;
    for (UIImage *image in self.photos) {
        [[NetworkManager sharedMgr] uploadUrl:QMPImageUpLoadURL image:image progress:nil uploadFinished:^(NSURLSessionDataTask *dataTask, NSString *fileUrl) {
            if ([fileUrl containsString:@"http"]) {
                NSLog(@"%@", fileUrl);
                [urls addObject:fileUrl];
                //                [ims removeObject:image];
                
                if (i == self.photos.count-1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [PublicTool dismissHud:KEYWindow];
                        self.photoUrls = urls;
                        NSLog(@"urls:%@", self.photoUrls);
                    });
                }
                
                i++;
            }
        }];
    }
}
#pragma mark - PickPhotosViewDelegate
- (void)pickPhotosView:(PickPhotosView *)view photoViewClick:(NSInteger)index {
   
    NSInteger maxCount = 9;
    NSInteger columnNumber = 4;
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:maxCount columnNumber:columnNumber delegate:self pushPhotoPickerVc:YES];
    // imagePickerVc.navigationBar.translucent = NO;
    
    if (self.assets) {
        imagePickerVc.selectedAssets = self.assets;
    }
    if (view.tag != _pickPhotoViewTag) {
        imagePickerVc = [[TZImagePickerController alloc] initWithSelectedAssets:self.assets selectedPhotos:self.photos index:view.tag];
        
    }
    
#pragma mark - 五类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = YES;
    
    imagePickerVc.allowTakePicture = YES; // 在内部显示拍照按钮
    
    
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    // imagePickerVc.navigationBar.translucent = NO;
    
    // 3. Set allow picking video & photo & originalPhoto or not
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowPickingMultipleVideo = NO; // 是否可以多选视频
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
    
    
    
    /// 5. Single selection mode, valid when maxImagesCount = 1
    /// 5. 单选模式,maxImagesCount为1时才生效
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowCrop = NO;
    imagePickerVc.needCircleCrop = NO;
    
    imagePickerVc.isStatusBarDefault = NO;
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}
- (void)pickPhotosView:(PickPhotosView *)view deleteButtonClick:(NSInteger)index {
    [self.assets removeObjectAtIndex:index];
    [self.photos removeObjectAtIndex:index];
    [self.photoUrls removeObjectAtIndex:index];
    [self updatePhotosShowWithPhotos:self.photos];
}
#pragma mark - msg
- (void)updatePhotosShowWithPhotos:(NSArray *)arr {
    int i = 0;
    CGFloat height = 0;
    for (PickPhotosView *imageView in self.photosView.subviews) {
        imageView.tag = i;
        UIButton *btn = imageView.deleteButton;
        if (i > arr.count) {
            btn.hidden = YES;
            imageView.hidden = YES;
        } else if (i == arr.count && i < 9) {
            imageView.hidden = NO;
            btn.hidden = YES;
            imageView.tag = _pickPhotoViewTag;
            [imageView.photoView setImage:[UIImage imageNamed:@"pick_photos"]];
            height = imageView.bottom;
        } else {
            imageView.hidden = NO;
            btn.hidden = NO;
            UIImage *image = [arr objectAtIndex:i];
            [imageView.photoView setImage:[self clipImageForShow:image]];
            height = imageView.bottom;
        }
        i++;
    }
    self.photosView.height = height;
    self.topView.height = self.photosView.bottom + 11;
    NSLog(@"%f", self.topView.height);
}
#pragma mark - Getter
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.frame = CGRectMake(0, 0, SCREENW, _topHeight);
        _topView.backgroundColor = [UIColor whiteColor];
    }
    return _topView;
}
- (HMTextView *)textView {
    if (!_textView) {
        _textView = [[HMTextView alloc] initWithFrame:CGRectMake(13, 15, SCREENW-26, _textViewHeight)];
        _textView.placehoderColor = HTColorFromRGB(0xa9a9a9);
        _textView.placehoder = @"请在此填写线索，问题或者意见...";
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.delegate = self;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineSpacing = 6;// 字体的行间距
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:15],
                                     NSParagraphStyleAttributeName:paragraphStyle
                                     };
        _textView.typingAttributes = attributes;
    }
    return _textView;
}
- (UIView *)photosView {
    if (!_photosView) {
        _photosView = [[UIView alloc] init];
        _photosView.frame = CGRectMake(15, _textViewHeight+20, SCREENW-30, 100);
        
        CGFloat margin = 10;
        CGFloat photoWH = ((SCREENW-30)-3*margin)/4.0;
        for (int i = 0; i < 9; i++) {
            PickPhotosView *imageView = [[PickPhotosView alloc] init];
            imageView.delegate = self;
            CGFloat left = (i % 4) * (photoWH + margin);
            CGFloat top = (i / 4) * (photoWH + margin);
            imageView.frame = CGRectMake(left, top, photoWH, photoWH);
            [_photosView addSubview:imageView];

            imageView.tag = i;
            imageView.hidden = YES;
            if (i == 0) {
                imageView.hidden = NO;
                imageView.tag = _pickPhotoViewTag;
                [imageView.photoView setImage:[UIImage imageNamed:@"pick_photos"]];
            }
        }
    }
    return _photosView;
}
- (UIImage *)clipImageForShow:(UIImage *)image {
    CGSize size = image.size;
    CGFloat wh = MIN(size.width, size.height);
    
    CGRect myRect = CGRectMake((size.width-wh)/4, (size.height-wh)/4, wh, wh);
    CGImageRef  imageRef = CGImageCreateWithImageInRect(image.CGImage, myRect);
    UIGraphicsBeginImageContext(myRect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myRect, imageRef);
    UIImage * clipImage = [UIImage imageWithCGImage:imageRef];
    UIGraphicsEndImageContext();
    return clipImage;
}
@end
