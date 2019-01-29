//
//  PostActivityViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/6/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PostActivityViewController.h"
#import "PostHeaderSelectView.h"
#import <ReactiveObjC.h>
#import "PostActivityViewModel.h"
#import <YYText.h>
#import "HMTextView.h"
#import <TZImagePickerController.h>
#import "PickPhotosView.h"
#import "PostSelectRelateViewController.h"
#import "SearchCompanyModel.h"
#import "ActivityModel.h"
#import "SearchJigouModel.h"
#import "NewsWebViewController.h"
#import "OrganizeItem.h"
#import "CompanyDetailModel.h"
#import "PostBarView.h"
#import "PostRelatesView.h"
#import "PostTextView.h"
#import "PostAddLinkView.h"
#import "PostLinkPopView.h"
#import "PersonModel.h"

const NSInteger ShowTZImagePickerTag = 101;
#define kContentHeight (SCREENH-kScreenTopHeight-50)
@interface PostActivityViewController () <TZImagePickerControllerDelegate, PickPhotosViewDelegate, WKNavigationDelegate, UITextViewDelegate>

@property (nonatomic, strong) PostActivityViewModel *viewModel;
@property (nonatomic, strong) PostSelectRelateViewModel *relateViewModel;

@property (nonatomic, strong) PostHeaderSelectView *selectView;
//@property (nonatomic, strong) HMTextView *textView;

//@property (nonatomic, strong) UIView *barView;
@property (nonatomic, weak) UIButton *addImageButton;
@property (nonatomic, weak) UIButton *addLinkButton;

@property (nonatomic, strong) UIView *photosView;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSMutableArray *photoUrls;

@property (nonatomic, strong) UIView *linkShowView;
@property (nonatomic, weak) UILabel *linkTitleLabel;
@property (nonatomic, weak) UIImageView *linkImageView;
@property (nonatomic, strong) NSString *linkImageUrl;


@property (nonatomic, strong) ActivityRelateModel *relate;

@property (nonatomic, weak) UIButton *currentButton;
@property (nonatomic, weak) UIButton *anonymousButton;

@property (nonatomic, strong) PostBarView *barView2;

@property (nonatomic, weak) UIButton *rightButton;
@property (nonatomic, strong) PostRelatesView *relatesView;
@property (nonatomic, strong) PostTextView *textView;
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, strong) UIScrollView *contentView;

@property (nonatomic, strong) PostLinkPopView *linkPopView;


@property (nonatomic, copy) NSString *linklinkurl;
@end

@implementation PostActivityViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self hideNavigationBarLine];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self showNavigationBarLine];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.postFrom == 0) {
        self.postFrom = PostFrom_Flash;
    }
    if (self.postFrom != PostFrom_Circle) { //圈子无链接
        [self checkUrl];
    }
    
    [IQKeyboardManager sharedManager].enable = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    switch (self.postFrom) {
        case PostFrom_Flash:
            self.navigationItem.title = @"发布短讯";
            break;
        case PostFrom_Circle:
             self.navigationItem.title = @"发布话题";
            break;
        default:
            self.navigationItem.title = @"发布动态";
            break;
    }
    
    self.viewModel = [[PostActivityViewModel alloc] init];

    [self.view addSubview:self.contentView];
    
    self.contentView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.contentView addSubview:self.textView];
    [self.contentView addSubview:self.relatesView];
    [self.contentView addSubview:self.photosView];
    [self.contentView addSubview:self.linkShowView];
    [self.view addSubview:self.barView2];
    [self.view addSubview:self.linkPopView];
    
    CGFloat aa = 0.6;
    if (!self.navigationItem.leftBarButtonItems) {
        self.navigationItem.leftBarButtonItems = [self createBackButton];
        aa = 0.05;
    }
    [self setupNavPostButton];
    
   
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(aa * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.textView becomeFirstResponder];
    });

    if (self.link_url.length > 0) {
        self.linkShowView.hidden = NO;
        self.linkShowView.top = self.textView.bottom+16;
        self.linkTitleLabel.text = self.link_url;
        
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        webView.navigationDelegate = self;
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.link_url]]];
        [self.view addSubview:webView];
        
        self.rightButton.enabled = YES;
        [self fixBarButton];
    }

    if (self.company) {
        self.model = self.company;
    }
    if (self.orgnize) {
        self.model = self.orgnize;
    }
    if (self.person) {
        self.model = self.person;
    }
    if (self.model) {
        [self.relateViewModel addNewRelateObject:self.model type:@""];
    }
    
    @weakify(self)
    [RACObserve(self, self.relateViewModel.relateObjects) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        CGFloat h = [self.relatesView reloadWithSelectedObjects:self.relateViewModel.relateObjects];
        self.relatesView.height = h;
        
        
        CGRect frame2 = self.relatesView.frame;
        frame2.origin.y = MAX(90, CGRectGetMaxY(self.textView.frame) + 10);
        self.relatesView.frame = frame2;
        
        if (self.relateViewModel.relateObjects.count > 0) {
            self.linkShowView.top = CGRectGetMaxY(self.relatesView.frame) + 30;
            self.photosView.top = CGRectGetMaxY(self.linkShowView.frame) + 30;
        } else {
            self.linkShowView.top = CGRectGetMaxY(self.textView.frame) + 30;
            self.photosView.top = CGRectGetMaxY(self.linkShowView.frame) + 30;
        }
        [self updateContentViewContentSize];
        [self fixBarRelateButton];
    }];
    
    self.relatesView.didDeleteObject = ^(id selectedObject, NSInteger index) {
        @strongify(self);
        [self.relateViewModel removeRelateObject:selectedObject];
        [self fixBarRelateButton];
    };
    
    __weak typeof(self) weakSelf = self;
    [self.textView textValueDidChanged:^(NSString *text, CGFloat textHeight) {
        CGRect frame = weakSelf.textView.frame;
        frame.size.height = textHeight;
        
        weakSelf.textView.frame = frame;
        
        CGRect frame2 = weakSelf.relatesView.frame;
        frame2.origin.y = MAX(90, CGRectGetMaxY(frame) + 10);
        weakSelf.relatesView.frame = frame2;
        
        if (weakSelf.relateViewModel.relateObjects.count > 0) {
            weakSelf.linkShowView.top = CGRectGetMaxY(weakSelf.relatesView.frame) + 30;
            if (weakSelf.linkShowView.hidden) {
                weakSelf.photosView.top = CGRectGetMaxY(weakSelf.relatesView.frame) + 30;
            } else {
                weakSelf.photosView.top = CGRectGetMaxY(weakSelf.linkShowView.frame) + 30;
            }
        } else {
            weakSelf.linkShowView.top = CGRectGetMaxY(weakSelf.textView.frame) + 30;
            if (weakSelf.linkShowView.hidden) {
                weakSelf.photosView.top = CGRectGetMaxY(weakSelf.textView.frame) + 30;
            } else {
                weakSelf.photosView.top = CGRectGetMaxY(weakSelf.linkShowView.frame) + 30;
            }
        }
        
       
        [weakSelf updateContentViewContentSize];
        
        CGFloat a = weakSelf.keyboardHeight + textHeight;
        weakSelf.contentView.contentOffset = CGPointMake(0, MAX(0, a - kContentHeight + 20));
    }];
    
    
    if (![PublicTool isNull:self.linklinkurl] && self.linkShowView.hidden) {
        self.linkPopView.hidden = NO;
     
        self.linkPopView.linkPopLabel.text = self.linklinkurl;

        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.linkPopView.hidden = YES;
        });
    }
}


- (void)setupNavPostButton {
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 66, 30)];
    [rightButton setTitle:@"发布" forState:UIControlStateNormal];
    rightButton.layer.cornerRadius = 15.0;
    rightButton.clipsToBounds = YES;
    rightButton.titleLabel.font = [UIFont systemFontOfSize:13.f];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageFromColor:HTColorFromRGB(0x197CD8) andSize:CGSizeMake(66, 30)] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageFromColor:HTColorFromRGB(0xCCCCCC) andSize:CGSizeMake(66, 30)] forState:UIControlStateDisabled];
    [rightButton addTarget:self action:@selector(postActivityClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = item;
    self.rightButton = rightButton;
    rightButton.enabled = NO;
}
- (NSArray*)createBackButton {
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    [leftButton setImage:[UIImage imageNamed:@"postact_close"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = LEFTNVSPACE;
    if (iOS11_OR_HIGHER) {
        leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
        UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        
        return @[leftButtonItem];
    }
    return @[negativeSpacer,leftButtonItem];
}

- (void)popSelf{
    [UIPasteboard generalPasteboard].string = @"";
    [self.view endEditing:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (void)postActivityClick {
    [PublicTool showHudWithView:KEYWindow];
    [self.textView resignFirstResponder];
    [QMPEvent event:@"acvitity_post_sureclick"];
    
    NSString *text = [self.textView.text?:@"" stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    
    if (text.length == 0) {
        if (self.photoUrls.count > 0) {
            text = @"分享图片";
        }
    }
    [paramDict setValue:text forKey:@"content"];
    
    [paramDict setValuesForKeysWithDictionary:[self.relateViewModel paramOfRelateObject]];
    
    if (self.link_url.length > 0) {
        [paramDict setValue:self.link_url?:@"" forKey:@"link_url"];
        [paramDict setValue:self.linkTitleLabel.text?:@"" forKey:@"link_title"];
        [paramDict setValue:self.linkImageUrl?:@"" forKey:@"link_img"];
    }
    
    [paramDict setValue:self.photoUrls forKey:@"images"];
    [paramDict setValue:self.barView2.anonymous2?:@"0" forKey:@"anonymous"];
    [paramDict setValue:self.barView2.degree2?:@"" forKey:@"anonymous_degree"];
    [paramDict setValue:@(1) forKey:@"comment_type"];
    //发布位置  1资讯(动态) 2圈子(社区) 3详情页
    switch (self.postFrom) {
        case PostFrom_Flash:
            [paramDict setValue:@(1) forKey:@"release_position"];
            break;
        case PostFrom_Circle:
            [paramDict setValue:@(2) forKey:@"release_position"];
            break;
        default:
            [paramDict setValue:@(3) forKey:@"release_position"];
            break;
    }

    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/releaseActivity" HTTPBody:paramDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [PublicTool dismissHud:KEYWindow];
        if (resultData) {
            [PublicTool showMsg:@"发布成功"];
            if (self.postSuccessBlock) {
                self.postSuccessBlock();
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UserPostActivitySuccess" object:nil];
            if (self.needGo && (self.postFrom == PostFrom_Flash)) {
                [[AppPageSkipTool shared] appPageSkipToActivityCommunity:@"用户分享" activityID:@""];
            } else {
                if (self.navigationController.childViewControllers.count == 1) {
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        } else {
            [PublicTool showMsg:@"发布失败"];
        }
    }];
}
- (void)linkShowViewTap {
    URLModel *model = [[URLModel alloc] init];
    model.url = self.link_url;
    NewsWebViewController *vc = [[NewsWebViewController alloc] init];
    vc.urlModel = model;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)linkShowViewHide {
    self.linkShowView.hidden = YES;
    self.linkTitleLabel.text = @"";
    self.linkImageUrl = @"";
    self.link_url = @"";
    [self updateRightButton];
    [self fixBarButton];
    if (!self.linkShowView.hidden) {
        self.photosView.top = CGRectGetMaxY(self.linkShowView.frame) + 30;
    } else {
        if (self.relateViewModel.relateObjects.count > 0) {
            self.photosView.top = CGRectGetMaxY(self.relatesView.frame) + 30;
        } else {
            self.photosView.top = CGRectGetMaxY(self.textView.frame) + 30;
        }
    }
}
- (void)dealloc {
    QMPLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}
- (void)selectRelateViewTap {
    if (self.relateViewModel.relateObjects.count >= 5) {
        [PublicTool showMsg:@"关联对象最多为5个"];
        return;
    }
    PostSelectRelateViewController *vc = [[PostSelectRelateViewController alloc] init];
    vc.title = @"请选择关联对象";
    [self.navigationController pushViewController:vc animated:YES];
    
    __weak typeof(self) weakSelf = self;
    vc.didSelectedObject = ^(id selectedObject, NSString *type) {
        [weakSelf.relateViewModel addNewRelateObject:selectedObject type:type];
    };
}
- (void)addRelateButtonClick {
    if (self.relateViewModel.relateObjects.count >= 5) {
        [PublicTool showMsg:@"关联对象最多为5个"];
        return;
    }
    [self.view endEditing:YES];
    
    PostSelectRelateViewController *vc = [[PostSelectRelateViewController alloc] init];
    vc.title = @"请选择关联对象";
    [self.navigationController pushViewController:vc animated:YES];
    
    __weak typeof(self) weakSelf = self;
    vc.didSelectedObject = ^(id selectedObject, NSString *type) {
        [weakSelf.relateViewModel addNewRelateObject:selectedObject type:type];
    };
}
- (void)addImageButtonClick {
    [self showImagePickerWithTag:ShowTZImagePickerTag];
}
- (void)addLinkButtonClick {
//    if (!self.photosView.hidden) {
//        [PublicTool showMsg:@"只能选择链接或图片"];
//        return;
//    }
    
    [self.view endEditing:YES];
    
    PostAddLinkView *view = [[PostAddLinkView alloc] init];
    [view show];
    if (![PublicTool isNull:self.linklinkurl]) {
        view.textField.text = self.linklinkurl;
    }
    
    __weak typeof(self) weakSelf = self;
    view.confirmActionTap = ^(NSString * _Nonnull url) {
        
        if (url.length <= 0) {
            [PublicTool showMsg:@"不是正确的链接"];
            return;
        }
        if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"]) {
            url = [NSString stringWithFormat:@"http://%@", url];
        }
        if (![weakSelf isurl:url]) {
            [PublicTool showMsg:@"不是正确的链接"];
            return;
        }
        
        
        weakSelf.link_url = url;
        weakSelf.linkShowView.hidden = NO;
        if (weakSelf.relateViewModel.relateObjects.count > 0) {
            weakSelf.linkShowView.top = weakSelf.relatesView.bottom+30;
        } else {
            weakSelf.linkShowView.top = weakSelf.textView.bottom+30;
        }
        weakSelf.photosView.top = weakSelf.linkShowView.bottom+30;
        
        weakSelf.linkTitleLabel.text = url;
        
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        webView.navigationDelegate = weakSelf;
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:weakSelf.link_url]]];
        [weakSelf.view addSubview:webView];
        [weakSelf updateRightButton];
        [weakSelf fixBarButton];
    };

}
- (void)activityTypeButtonClick:(UIButton *)button {
    self.currentButton.backgroundColor = [UIColor whiteColor];
    [self.currentButton setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    button.backgroundColor = BLUE_TITLE_COLOR;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.currentButton = button;
}
- (NSString *)anonymousParamWithCurrentButton {
    if ([self.currentButton.currentTitle isEqualToString:@"匿名"]) {
        return @"1";
    } else if ([self.currentButton.currentTitle isEqualToString:@"私人"]) {
        return @"2";
    }
    return @"0";
}
- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 500) {
        [PublicTool showMsg:@"最多500字"];
        textView.text = [textView.text substringToIndex:500];
    }
    [self updateRightButton];
}
- (void)updateRightButton {
    NSString *text = [self.textView.text?:@"" stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.rightButton.enabled = text.length > 0 || self.photos.count > 0 || self.link_url.length > 0;
}
#pragma mark - ChosePhotos
- (void)showImagePickerWithTag:(NSInteger)tag {
//    if (!self.linkShowView.hidden) {
//        [PublicTool showMsg:@"只能选择图片或链接"];
//        return;
//    }
    if (self.photos.count >= 9) {
        [PublicTool showMsg:@"最多选择9张图片"];
        return;
    }
    
    NSInteger maxCount = 9;
    NSInteger columnNumber = 4;
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:maxCount columnNumber:columnNumber delegate:self pushPhotoPickerVc:YES];
    if (self.assets) {
        imagePickerVc.selectedAssets = self.assets;
    }
    if (tag != ShowTZImagePickerTag) {
        imagePickerVc = [[TZImagePickerController alloc] initWithSelectedAssets:self.assets selectedPhotos:self.photos index:tag];
    }
    imagePickerVc.isSelectOriginalPhoto = YES;
    imagePickerVc.allowTakePicture = YES; // 在内部显示拍照按钮
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowPickingMultipleVideo = NO; // 是否可以多选视频
    imagePickerVc.sortAscendingByModificationDate = YES;
    
    [self presentViewController:imagePickerVc animated:YES completion:^{
        
    }];
}

#pragma mark - TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    
    self.photos = [NSMutableArray arrayWithArray:photos];
    self.assets = [NSMutableArray arrayWithArray:assets];
    
    [self updatePhotosShowWithPhotos:photos];
    self.photosView.hidden = photos.count == 0;
    
    NSMutableArray *urls = [NSMutableArray array];
    [PublicTool showHudWithView:KEYWindow];
    __block int i = 0;
    for (UIImage *image in self.photos) {
        [[NetworkManager sharedMgr] uploadUrl:QMPImageUpLoadURL image:image progress:nil uploadFinished:^(NSURLSessionDataTask *dataTask, NSString *fileUrl) {
            [PublicTool dismissHud:KEYWindow];
            if ([fileUrl containsString:@"http"]) {
                QMPLog(@"%@", fileUrl);
                [urls addObject:fileUrl];
                if (i == self.photos.count-1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [PublicTool dismissHud:KEYWindow];
                        self.photoUrls = urls;
                        QMPLog(@"urls:%@", self.photoUrls);
                    });
                }
                
                i++;
            }
        }];
    }
}
- (void)updatePhotosShowWithPhotos:(NSArray *)arr {
    [self updateRightButton];
    [self fixBarPhotoButton];
    int i = 0;
    CGFloat height = 0;
    if (arr.count <= 0) {
        self.photosView.hidden = YES;
        return;
    }
    self.photosView.hidden = NO;
    for (PickPhotosView *imageView in self.photosView.subviews) {
        imageView.tag = i;
        UIButton *btn = imageView.deleteButton;
        if (i > arr.count) {
            btn.hidden = YES;
            imageView.hidden = YES;
        } else if (i == arr.count && i < 9) {
            imageView.hidden = NO;
            btn.hidden = YES;
            imageView.tag = ShowTZImagePickerTag;
            [imageView.photoView setImage:[UIImage imageNamed:@"pick_photos"]];
            height = imageView.bottom;
        } else {
            imageView.hidden = NO;
            btn.hidden = NO;
            UIImage *image = [arr objectAtIndex:i];
            [imageView.photoView setImage:image];//[self clipImageForShow:image]];
            height = imageView.bottom;
        }
        i++;
    }
    self.photosView.height = height;
    
    if (!self.linkShowView.hidden) {
        self.photosView.top = CGRectGetMaxY(self.linkShowView.frame) + 30;
    } else {
        if (self.relateViewModel.relateObjects.count > 0) {
            self.photosView.top = CGRectGetMaxY(self.relatesView.frame) + 30;
        } else {
            self.photosView.top = CGRectGetMaxY(self.textView.frame) + 30;
        }
    }
    
    
    [self updateContentViewContentSize];
}
- (void)updateContentViewContentSize {
    CGFloat h = CGRectGetMaxY(self.textView.frame);
    if (self.relateViewModel.relateObjects.count > 0) {
        h += (self.relatesView.height + 10);
    }
    if (!self.linkShowView.hidden) {
        h += (self.linkShowView.height + 30);
    }
    if (self.photos.count > 0) {
        h += (self.photosView.height + 30);
    }
    h += 20;
    self.contentView.contentSize = CGSizeMake(SCREENW, MAX(kContentHeight, h));
}
#pragma mark - PickPhotosViewDelegate
- (void)pickPhotosView:(PickPhotosView *)view deleteButtonClick:(NSInteger)index {
    [self.assets removeObjectAtIndex:index];
    [self.photos removeObjectAtIndex:index];
    [self.photoUrls removeObjectAtIndex:index];
    [self updatePhotosShowWithPhotos:self.photos];
}
- (void)pickPhotosView:(PickPhotosView *)view photoViewClick:(NSInteger)index {
    [self showImagePickerWithTag:view.tag];
}

#pragma mark - Getter
- (PostTextView *)textView {
    if (!_textView) {
        _textView = [[PostTextView alloc] initWithFrame: CGRectMake(15, 8, SCREENW-30, 72)];
        _textView.placeholder = @"说点什么...";
        _textView.placeholderColor = HTColorFromRGB(0xE2E4E8);
        _textView.placeholderFont = [UIFont systemFontOfSize:17];
        _textView.font = [UIFont systemFontOfSize:17];
        _textView.textColor = NV_TITLE_COLOR;
        _textView.delegate = self;
        _textView.maxNumberOfLines = 9999;
        _textView.textAlignment = NSTextAlignmentJustified;
//        _textView.textContainer.lineFragmentPadding = 0;
//        _textView.textContainerInset = UIEdgeInsetsZero;
        _textView.minHeight = 72;
    }
    return _textView;
}
- (PostHeaderSelectView *)selectView {
    if (!_selectView) {
        _selectView = [[PostHeaderSelectView alloc] init];
        _selectView.frame = CGRectMake(0, 0, SCREENW, PostHeaderSelectViewHeight);
        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectRelateViewTap)];
        [_selectView addGestureRecognizer:tapGest];
    }
    return _selectView;
}
- (PostBarView *)barView2 {
    if (!_barView2) {
        _barView2 = [[PostBarView alloc] init];
        _barView2.backgroundColor = [UIColor whiteColor];
        _barView2.frame = CGRectMake(0, SCREENH-kScreenTopHeight-50, SCREENW, 50);
        
        [_barView2.addLinkButton addTarget:self action:@selector(addLinkButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_barView2.addImageButton addTarget:self action:@selector(addImageButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_barView2.addRelateButton addTarget:self action:@selector(addRelateButtonClick) forControlEvents:UIControlEventTouchUpInside];
        if (self.postFrom == PostFrom_Circle) {
            _barView2.addLinkButton.hidden = YES;
        }else if (self.postFrom == PostFrom_Flash){
            [_barView2 showAuthorIfAnonymous:NO];
        }
    }
    return _barView2;
}



- (UIView *)photosView {
    if (!_photosView) {
        _photosView = [[UIView alloc] init];
        _photosView.frame = CGRectMake(15, self.textView.bottom+16, SCREENW-30, 100);
        _photosView.hidden = YES;
        
        CGFloat margin = 5;
        CGFloat photoWH = ((SCREENW-34)-2*margin)/3.0;
        for (int i = 0; i < 9; i++) {
            PickPhotosView *imageView = [[PickPhotosView alloc] init];
            imageView.delegate = self;
            CGFloat left = (i % 3) * (photoWH + margin);
            CGFloat top = (i / 3) * (photoWH + margin);
            imageView.frame = CGRectMake(left, top, photoWH, photoWH);
            [_photosView addSubview:imageView];
            
            imageView.tag = i;
            imageView.hidden = YES;
            if (i == 0) {
                imageView.hidden = NO;
                imageView.tag = ShowTZImagePickerTag;
                [imageView.photoView setImage:[UIImage imageNamed:@"pick_photos"]];
            }
        }
    }
    return _photosView;
}
- (NSMutableArray *)photoUrls {
    if (!_photoUrls) {
        _photoUrls = [NSMutableArray array];
    }
    return _photoUrls;
}
- (UIView *)linkShowView {
    if (!_linkShowView) {
        _linkShowView = [[UIView alloc] init];
        _linkShowView.frame = CGRectMake(17, 0, SCREENW-34, 70);
        _linkShowView.backgroundColor = HTColorFromRGB(0xF5F6F8);
        _linkShowView.hidden = YES;
        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(linkShowViewTap)];
        [_linkShowView addGestureRecognizer:tapGest];
        
        UIImageView *linkImageView = [[UIImageView alloc] init];
        linkImageView.frame = CGRectMake(8, 8, 54, 54);
        linkImageView.image = [UIImage imageNamed:@"post_link_placeholder"];
        [_linkShowView addSubview:linkImageView];
        self.linkImageView = linkImageView;
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(72, 10, SCREENW-34-72-70, 50);
        label.textColor = HTColorFromRGB(0x666666);
        label.font = [UIFont systemFontOfSize:14];
        label.numberOfLines = 2;
        [_linkShowView addSubview:label];
        self.linkTitleLabel = label;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(SCREENW-34-40, 15, 40, 40);
        [button setImage:[UIImage imageNamed:@"post_link_show_delete"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(linkShowViewHide) forControlEvents:UIControlEventTouchUpInside];
        [_linkShowView addSubview:button];
    }
    return _linkShowView;
}
- (PostSelectRelateViewModel *)relateViewModel {
    if (!_relateViewModel) {
        _relateViewModel = [[PostSelectRelateViewModel alloc] init];
    }
    return _relateViewModel;
}
- (PostRelatesView *)relatesView {
    if (!_relatesView) {
        _relatesView = [[PostRelatesView alloc] init];
        _relatesView.frame = CGRectMake(17, 90, SCREENW-34, 0);
    }
    return _relatesView;
}
- (UIScrollView *)contentView {
    if (!_contentView) {
        _contentView = [[UIScrollView alloc] init];
        _contentView.frame = CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight-50);
        _contentView.showsHorizontalScrollIndicator = NO;
        _contentView.showsVerticalScrollIndicator = NO;
        _contentView.alwaysBounceVertical = YES;
        _contentView.contentSize = CGSizeMake(SCREENW, SCREENH-kScreenTopHeight-50);
    }
    return _contentView;
}
#pragma mark - KeyBoard
- (void)keyboardChange:(NSNotification*)aNotification {
    if (!self.textView.isFirstResponder) {
        return;
    }
    
    NSDictionary *userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardY =  keyboardEndFrame.origin.y;
    [UIView animateWithDuration:animationDuration delay:0.0f options:[self animationOptionsForCurve:animationCurve] animations:^{
        
        CGFloat footerToolBarY = keyboardY- CGRectGetHeight(self.barView2.frame) - ((keyboardY+1 > SCREENH)? (isiPhoneX? 34: 0): 0);
        
        self.barView2.top = footerToolBarY-kScreenTopHeight;
        self.linkPopView.top = footerToolBarY-kScreenTopHeight - self.linkPopView.height + 4;
    } completion:^(BOOL finished) {
    }];
    
    self.keyboardHeight = CGRectGetHeight(keyboardEndFrame);
    if (keyboardY+1 > SCREENH) { // 隐藏
        self.contentView.contentOffset = CGPointMake(0, 0);
    } else {
        CGFloat a = self.keyboardHeight + self.textView.height;
        NSLog(@"%f", a - kContentHeight);
        self.contentView.contentOffset = CGPointMake(0, MAX(0, a - kContentHeight + 20));
    }
}
- (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve {
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
            break;
    }
    return kNilOptions;
}

#pragma mark - Get Url Meta
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.linkTitleLabel.text = self.link_url;
    [webView removeFromSuperview];
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    self.linkTitleLabel.text = self.link_url;
    [webView removeFromSuperview];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSString *titleJS = @"document.title";
    if ([self.link_url containsString:@"mp.weixin.qq.com"]) {
        titleJS = @"document.getElementsByClassName(\"rich_media_title\")[0].innerText";
    }
    [webView evaluateJavaScript:titleJS completionHandler:^(NSString *title, NSError * _Nullable error) {
        self.linkTitleLabel.text = title.length > 0 ? title : webView.URL.host;
    }];
    
    NSString *getImagesJs = @"function getImage(){var objs=document.getElementsByTagName(\"img\");if(objs.length>0){var index=Math.min(2,objs.length);var obj=objs[index];return obj.src}return\"\"}; getImage();";
    [webView evaluateJavaScript:getImagesJs completionHandler:^(NSString *urlResurlt, NSError * _Nullable error) {
        if (urlResurlt.length > 0 && [urlResurlt containsString:@"http"]) {
            self.linkImageUrl = urlResurlt;
            [self.linkImageView sd_setImageWithURL:[NSURL URLWithString:urlResurlt] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            }];
        } else {
            self.linkImageView.image = [UIImage imageNamed:@"post_link_placeholder"];
        }
    }];
}

- (PostLinkPopView *)linkPopView {
    if (!_linkPopView) {
        _linkPopView = [[PostLinkPopView alloc] init];
        _linkPopView.frame = CGRectMake(129, SCREENH-kScreenTopHeight-50+4-62, 128, 62);
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(linkPopViewClick)];
        [_linkPopView addGestureRecognizer:tapGest];
        _linkPopView.hidden = YES;
    }
    return _linkPopView;
}
- (void)linkPopViewClick {
    NSString *url = self.linklinkurl;
    self.linkPopView.hidden = YES;
    if (url.length <= 0 || ( ![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"])) {
        [PublicTool showMsg:@"不是正确的链接"];
        return;
    }
    
    self.link_url = url;
    self.linkShowView.hidden = NO;
    if (self.relateViewModel.relateObjects.count > 0) {
        self.linkShowView.top = self.relatesView.bottom+30;
    } else {
        self.linkShowView.top = self.textView.bottom+30;
    }
    self.photosView.top = self.linkShowView.bottom + 30;
    
    self.linkTitleLabel.text = url;
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    webView.navigationDelegate = self;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.link_url]]];
    [self.view addSubview:webView];
    [self updateRightButton];
    [self fixBarButton];
}

- (void)fixBarButton {
    if (!self.linkShowView.hidden) {
        self.barView2.addLinkButton.enabled = NO;
//        [self.barView2.addImageButton setImage:[UIImage imageNamed:@"post_bar_add_photo_n"] forState:UIControlStateNormal];
//        [self.barView2.addImageButton setTitleColor:HTColorFromRGB(0xCCCCCC) forState:UIControlStateNormal];
    } else {
        self.barView2.addLinkButton.enabled = YES;
//        [self.barView2.addImageButton setImage:[UIImage imageNamed:@"post_bar_add_photo"] forState:UIControlStateNormal];
//        [self.barView2.addImageButton setTitleColor:HTColorFromRGB(0x197CD8) forState:UIControlStateNormal];
    }
}
- (void)fixBarRelateButton {
    if (self.relateViewModel.relateObjects.count >= 5) {
        [self.barView2.addRelateButton setImage:[UIImage imageNamed:@"post_bar_add_relate_n"] forState:UIControlStateNormal];
        [self.barView2.addRelateButton setTitleColor:HTColorFromRGB(0xCCCCCC) forState:UIControlStateNormal];
    } else {
        [self.barView2.addRelateButton setImage:[UIImage imageNamed:@"post_bar_add_relate"] forState:UIControlStateNormal];
        [self.barView2.addRelateButton setTitleColor:HTColorFromRGB(0x197CD8) forState:UIControlStateNormal];
    }
}
- (void)fixBarPhotoButton {
    if (self.photos.count >= 9) {
        [self.barView2.addImageButton setImage:[UIImage imageNamed:@"post_bar_add_photo_n"] forState:UIControlStateNormal];
        [self.barView2.addImageButton setTitleColor:HTColorFromRGB(0xCCCCCC) forState:UIControlStateNormal];
    } else {
        [self.barView2.addImageButton setImage:[UIImage imageNamed:@"post_bar_add_photo"] forState:UIControlStateNormal];
        [self.barView2.addImageButton setTitleColor:HTColorFromRGB(0x197CD8) forState:UIControlStateNormal];
    }
//    if (self.photos.count > 0) {
//        [self.barView2.addLinkButton setImage:[UIImage imageNamed:@"post_bar_add_link_n"] forState:UIControlStateNormal];
//        [self.barView2.addLinkButton setTitleColor:HTColorFromRGB(0xCCCCCC) forState:UIControlStateNormal];
//    } else {
//        [self.barView2.addLinkButton setImage:[UIImage imageNamed:@"post_bar_add_link"] forState:UIControlStateNormal];
//        [self.barView2.addLinkButton setTitleColor:HTColorFromRGB(0x197CD8) forState:UIControlStateNormal];
//    }
}

- (void)checkUrl {
    NSString *string = [UIPasteboard generalPasteboard].string;
    if ([PublicTool isNull:string]) {
        return;
    }
    
    NSError *error;
    NSString *regulaStr = @"http[s]{0,1}://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    if (arrayOfAllMatches.count > 0) {
        NSTextCheckingResult *match = [arrayOfAllMatches firstObject];
        NSString *url = [string substringWithRange:match.range];
        self.linklinkurl = url;
    }
}
- (BOOL)isurl:(NSString *)string {
    if ([PublicTool isNull:string]) {
        return NO;
    }
    
    NSError *error;
    NSString *regulaStr = @"http[s]{0,1}://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    return (arrayOfAllMatches.count > 0);
}
@end
