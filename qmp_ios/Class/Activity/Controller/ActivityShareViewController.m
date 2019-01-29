//
//  ActivityShareViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/7/5.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ActivityShareViewController.h"
#import "ShareTo.h"
#import "ActivityModel.h"
#import "QMPActivityCell.h"
#import "QMPActivityCellModel.h"
#import <YYText.h>
#import "NSDate+HY.h"
#import "SLPhotosView.h"

@interface ActivityShareViewController ()


@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) UIView *snapView;

@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *appNameLabel;
@property (nonatomic, strong) UILabel *weekLabel;

@property (nonatomic, strong) UIView *activityView;
@property (nonatomic, strong) UIView *topLogoView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UIImageView *authIcon;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) YYLabel *textLabel;
@property (nonatomic, strong) UIView *relateView;
@property (nonatomic, strong) UIView *photosView;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIImageView *QRCodeView;
@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, strong) UIView *barView;
@property (nonatomic, weak) UIButton *saveButton;

@property (nonatomic, strong) UIImage *shareImage;
@end

@implementation ActivityShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"分享卡片";
    self.view.backgroundColor = HTColorFromRGB(0xF5F5F5);
    
    [self.view addSubview:self.contentView];
    [self.view addSubview:self.barView];
    [self.contentView addSubview:self.snapView];
    self.snapView.backgroundColor = BLUE_BG_COLOR;
    
    [self.snapView addSubview:self.cardView];
    
    [self.snapView addSubview:self.topLogoView];

    [self.cardView addSubview:self.activityView];
    [self.activityView addSubview:self.avatarView];
    [self.activityView addSubview:self.authIcon];
    [self.activityView addSubview:self.nameLabel];
    self.nameLabel.centerY = self.avatarView.centerY;
    [self.activityView addSubview:self.descLabel];
    self.descLabel.right = self.activityView.width-18;
    self.descLabel.centerY = self.avatarView.centerY;
    [self.activityView addSubview:self.textLabel];
    [self.activityView addSubview:self.relateView];
    [self.activityView addSubview:self.photosView];

    
    [self.cardView addSubview:self.bottomView];
    
    
    [self refreshHeight];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self shareButtonClick];
    });
}

- (void)refreshHeight{
    
    self.cardView.height = self.activityView.height+ 55+70;
    self.bottomView.bottom = self.cardView.height;
    
    self.snapView.height = self.cardView.bottom+30;
    self.contentView.contentSize = CGSizeMake(SCREENW, MAX(self.contentView.height, self.cardView.bottom+30));
    
}

- (void)shareButtonClick {
    [self.shareTool shareImgToOtherApp:self.shareImage];
    [QMPEvent event:@"activity_action_click" label:@"动态分享"];
}
- (void)saveButtonClick {
    UIImageWriteToSavedPhotosAlbum(self.shareImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (UIImage *)shareImage {
    if (!_shareImage) {
        _shareImage = [self convertViewToImage:self.snapView];
    }
    return _shareImage;
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = @"保存图片成功";
    if (error != NULL) {
        msg = @"保存图片失败" ;
        self.saveButton.enabled = YES;
    } else {
        self.saveButton.enabled = NO;
    }
    [PublicTool showMsg:msg];
}

- (void)setRelateModel:(ActivityRelateModel *)relateModel {
    _relateModel = relateModel;
}

- (void)setCellModel:(QMPActivityCellModel *)cellModel {
    _cellModel = cellModel;
    
    ActivityModel *activity = cellModel.activity;
    
    NSString *time = [[NSMutableString alloc]initWithString:cellModel.activity.createTime];
    NSArray *timeArr = [time componentsSeparatedByString:@" "];
//    NSArray *dateArr = [timeArr[0] componentsSeparatedByString:@"-"];
    NSArray *hourArr = [timeArr[1] componentsSeparatedByString:@":"];
    NSMutableString *showTime = [NSMutableString string];
    [showTime appendString:timeArr.firstObject];
    [showTime appendString:@"  "];
    [showTime appendString:[NSString stringWithFormat:@"%@:%@",hourArr[0],hourArr[1]]];
    self.timeLabel.text = showTime;
    
//    self.weekLabel.text = [NSDate dayOfWeekWithDate:cellModel.activity.createTime];
    
    if (activity.headerRelate) {
        self.relateModel = activity.headerRelate;
        if ([activity.relates containsObject:self.relateModel]) {
            [activity.relates removeObject:self.relateModel];
        }
    }
    self.authIcon.hidden = YES;
    self.avatarView.layer.cornerRadius = self.avatarView.width / 2.0;
    if (self.relateModel) {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:self.relateModel.image] placeholderImage:[BundleTool imageNamed:@"share_user_holder"]];
        self.nameLabel.text = self.relateModel.name;
        self.descLabel.text = self.relateModel.desc;
        if ([self.relateModel.type isEqualToString:@"product"] || [self.relateModel.type isEqualToString:@"jigou"]) {
            self.avatarView.layer.cornerRadius = 2.0;
        }
        if (!activity.anonymous && self.relateModel.claim_type.integerValue == 2 && [self.relateModel.type isEqualToString:@"person"]) {
            self.authIcon.hidden = NO;
        }
    } else {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:activity.user.avatar] placeholderImage:[BundleTool imageNamed:@"share_user_holder"]];
        self.nameLabel.text = activity.user.name;
        
        if (activity.isAnonymous) {
            self.descLabel.text = @"";
        } else {
            self.descLabel.text = activity.user.desc;
        }
    }
    
    self.timeLabel.hidden = NO;
    if ([PublicTool isNull:self.descLabel.text]) {
        self.timeLabel.hidden = YES;
        self.descLabel.text = self.timeLabel.text;
    }
    
    
    YYTextLayout *layout = [self handleContent:activity];
    self.textLabel.textLayout = layout;
    self.textLabel.height = layout.textBoundingSize.height;

    if (activity.images.count == 1) {
        ActivityImageModel *image = [activity.images firstObject];
        CGSize imagesSize = CGSizeZero;
        CGFloat imageW = SCREENW-30-36;
        if (image.width > image.height) {
            CGFloat a = imageW/ image.width * image.height;
            
            a = MAX((SCREENW-30-36)*0.33, a);
            imagesSize = CGSizeMake((SCREENW * 2 / 3), a);
        } else {
            CGFloat a = imageW / image.width * image.height;
            a = MIN(a, (SCREENW-30-36)*0.8);
            imagesSize = CGSizeMake((SCREENW-30-36)*0.5, a);
        }
        self.photosView.frame = CGRectMake(18, self.textLabel.bottom+10, imagesSize.width, imagesSize.height);
    } else if (activity.images.count > 1) {
        CGSize imagesSize = [self photosViewSizeWithPhotosCount:(int)activity.images.count];
        self.photosView.frame = CGRectMake(18, self.textLabel.bottom+12, imagesSize.width, imagesSize.height);
    } else {
        self.photosView.frame = CGRectZero;
    }
    [self setupPhotosViewWithPhotos:activity.images];

    NSArray *arr = [self handleRelates:activity];
    NSInteger index = 0;
    CGFloat height = 0;
    for (QMPActivityCellRelateView *item in self.relateView.subviews) {
        if (index >= arr.count) {
            item.hidden = YES;
            continue;
        }
        item.hidden = NO;
        ActivityRelateModel *relate = activity.relates[index];
        item.relate = relate;
        NSValue *val = arr[index];
        item.frame = [val CGRectValue];
        height = CGRectGetMaxY(item.frame);
        item.followView.hidden = YES;
        index++;
    }
    if (activity.images.count) {
        self.relateView.frame = CGRectMake(18, self.photosView.bottom + 15, SCREENW-15*2-36, height);
    }else{
        self.relateView.frame = CGRectMake(18, self.textLabel.bottom + 10, SCREENW-15*2-36, height);
    }

    if (activity.images.count > 0) {
        self.activityView.height = self.relateView.bottom;
    } else {
        if (arr.count > 0) {
            self.activityView.height = self.relateView.bottom;
        } else {
            self.activityView.height = self.textLabel.bottom;
        }
    }
    
    [self refreshHeight];

}
- (void)setupPhotosViewWithPhotos:(NSArray *)photos {
    CGFloat margin = 8;
    CGFloat width = (SCREENW-80-16)/3.0;
    for (int i = 0; i< self.photosView.subviews.count; i++) {
        
        UIImageView *photoView = self.photosView.subviews[i];
        
        if (i < photos.count) {
           photoView.hidden = NO;
            if (photos.count == 1) {
                ActivityImageModel *image = [photos firstObject];
                CGFloat imageW = SCREENW-30-36;
                if (image.width > image.height) {
                    CGFloat a = imageW / image.width * image.height;
                    
                    a = MAX((SCREENW-30-36)*0.33, a);
                    photoView.frame = CGRectMake(0, 0, imageW, a);
                } else {
                    CGFloat a = (imageW) / image.width * image.height;
                    a = MIN(a, (SCREENW-30-36)*0.8);
                    photoView.frame = CGRectMake(0, 0, imageW, a);
                }
                
                [photoView sd_setImageWithURL:[NSURL URLWithString:image.smallUrl] completed:nil];
            } else {
                
                int maxColumns = (photos.count == 4) ? 2 : 3;
                int col = i % maxColumns;
                int row = i / maxColumns;
                CGFloat photoX = col * (width + margin);
                CGFloat photoY = row * (width + margin);
                photoView.frame = CGRectMake(photoX, photoY, width, width);
                
                
                ActivityImageModel *image = [photos objectAtIndex:i];
                [photoView sd_setImageWithURL:[NSURL URLWithString:image.smallUrl] completed:nil];
            }
            
            //            photoView.lcck_cornerRadius = 4;
        } else { // 隐藏imageView
            photoView.hidden = YES;
        }
    }
}
#pragma mark - Getter
- (UIScrollView *)contentView {
    if (!_contentView) {
        _contentView = [[UIScrollView alloc] init];
        _contentView.frame = CGRectMake(0, 0, SCREENW, SCREENH - kScreenBottomHeight - kScreenTopHeight);
        _contentView.alwaysBounceVertical = YES;
        _contentView.size = _contentView.bounds.size;
        _contentView.showsVerticalScrollIndicator = NO;
        _contentView.showsHorizontalScrollIndicator = NO;
        _contentView.backgroundColor = BLUE_BG_COLOR;
    }
    return _contentView;
}

- (UIView *)snapView {
    if (!_snapView) {
        _snapView = [[UIView alloc] init];
        _snapView.frame = CGRectMake(0, 0, SCREENW, 0);
    }
    return _snapView;
}
- (UIView *)activityView {
    if (!_activityView) {
        _activityView = [[UIView alloc] init];
        _activityView.frame = CGRectMake(0, 0, SCREENW-30, 0);
    }
    return _activityView;
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.frame = CGRectMake(18, 25, 26, 26);
        _avatarView.layer.cornerRadius = 13;
        _avatarView.layer.borderWidth = 0.5;
        _avatarView.layer.borderColor = [HTColorFromRGB(0xE3E3E3) CGColor];
        _avatarView.clipsToBounds = YES;
    }
    return _avatarView;
}

- (UIImageView *)authIcon {
    if (!_authIcon) {
        _authIcon = [[UIImageView alloc] init];
        CGFloat w = 12;
        _authIcon.frame = CGRectMake(self.avatarView.right-w, self.avatarView.bottom-w, w, w);
        _authIcon.image = [BundleTool imageNamed:@"activity_person_claim"];
    }
    return _authIcon;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(52, 30, 220, 23);
        if (@available(iOS 8.2, *)) {
            _nameLabel.font = [UIFont systemFontOfSize:19 weight:UIFontWeightMedium];
        }else{
            _nameLabel.font = [UIFont systemFontOfSize:19];
        }
        _nameLabel.textColor = HTColorFromRGB(0x005BB3);
    }
    return _nameLabel;
}
- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.frame = CGRectMake(77, 0, 220, 16);
        _descLabel.font = [UIFont systemFontOfSize:12];
        _descLabel.textColor = H999999;
        _descLabel.textAlignment = NSTextAlignmentRight;
    }
    return _descLabel;
}
- (YYLabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[YYLabel alloc] init];
        _textLabel.frame = CGRectMake(18, self.avatarView.bottom+20, SCREENW-30-36, 0);
    }
    return _textLabel;
}


- (UIView*)topLogoView{
    if (!_topLogoView) {
        _topLogoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 115)];
        
        UIImageView *logo  = [[UIImageView alloc] init];
        logo.image = [BundleTool imageNamed:@"qmp_logo_white"];
        logo.frame = CGRectMake(0, 38, 200, 30);
        logo.contentMode = UIViewContentModeScaleAspectFit;
        [_topLogoView addSubview:logo];
        logo.centerX = _topLogoView.width/2.0-5;
        
        UILabel *tipLab = [[UILabel alloc]initWithFrame:CGRectMake(0, logo.bottom+15, 100, 13)];
        [tipLab labelWithFontSize:12 textColor:[UIColor whiteColor]];
        tipLab.text = @"消 息 快 人 一 步";
        [_topLogoView addSubview:tipLab];
        tipLab.centerX = _topLogoView.width/2.0;

    }
    return _topLogoView;
}

- (UIView *)cardView {
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        _cardView.frame = CGRectMake(15, self.topLogoView.bottom, SCREENW-30, 0);
        _cardView.backgroundColor = [UIColor whiteColor];
        _cardView.layer.cornerRadius = 6.0;
        _cardView.clipsToBounds = YES;
    }
    return _cardView;
}
- (UIImageView *)topImageView {
    if (!_topImageView) {
        _topImageView = [[UIImageView alloc] init];
        CGFloat h = 155 * (SCREENW - 40) / 335.0;
        
        _topImageView.frame = CGRectMake(0, self.activityView.bottom+20, SCREENW-40, h);
        _topImageView.contentMode = UIViewContentModeScaleAspectFill;
        _topImageView.backgroundColor = HTColorFromRGB(0xAEB7C0);
        _topImageView.clipsToBounds = YES;
    }
    return _topImageView;
}
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.frame = CGRectMake(0, 0, SCREENW-30, 70);
        _bottomView.backgroundColor = F5COLOR;
        
        [_bottomView addSubview:self.infoLabel];
        self.infoLabel.centerY = _bottomView.height/2.0;
        //竖线
        UIView *verticalLine = [[UIView alloc] init];
        verticalLine.frame = CGRectMake(_bottomView.width/2.0, 20, 1, 30);
        verticalLine.backgroundColor = HCCOLOR;
        [_bottomView addSubview:verticalLine];
        
        [_bottomView addSubview:self.QRCodeView];
        self.QRCodeView.frame = CGRectMake(_bottomView.width-14-50, 10,50, 50);
        //tip小字
        UILabel *topLab =  [[UILabel alloc]initWithFrame:CGRectMake(0, 21,100, 12)];
        [topLab labelWithFontSize:12 textColor:H999999];
        topLab.textAlignment = NSTextAlignmentRight;
        topLab.text = @"下载企名片APP";
        [_bottomView addSubview:topLab];
        topLab.right = self.QRCodeView.left - 10;
        
        UILabel *bottomLab =  [[UILabel alloc]initWithFrame:CGRectMake(0, topLab.bottom+5, 84, 12)];
        [bottomLab labelWithFontSize:12 textColor:H999999];
        bottomLab.textAlignment = NSTextAlignmentRight;
        bottomLab.text = @"获取更多信息";
        [_bottomView addSubview:bottomLab];
        bottomLab.right = self.QRCodeView.left - 10;

    }
    return _bottomView;
}
- (UIImageView *)QRCodeView {
    if (!_QRCodeView) {
        _QRCodeView = [[UIImageView alloc] init];
        _QRCodeView.frame = CGRectMake((SCREENW - 14)/2.0, 0, 65, 65);
        _QRCodeView.image = [BundleTool imageNamed:@"app_share_QR"];
    }
    return _QRCodeView;
}
- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.frame = CGRectMake(0, 0, (SCREENW-30)/2.0, 15);
        _infoLabel.textColor = H6COLOR;
        _infoLabel.font = [UIFont systemFontOfSize:16];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.text = @"商业信息服务平台";
    }
    return _infoLabel;
}

- (YYTextLayout *)handleContent:(ActivityModel *)activity {

    NSString *text = activity.content;
    NSMutableAttributedString *attrText = [self fixContentAttributed:text];
    
    if (![PublicTool isNull:activity.linkInfo.linkUrl]) {
        NSString *linkTitle = activity.linkInfo.linkTitle;
        NSMutableAttributedString *linkAttrTitle = [self fixContentAttributed:linkTitle];
        [linkAttrTitle insertAttributedString:[self linkAttrImage] atIndex:0];
        linkAttrTitle.yy_color = BLUE_TITLE_COLOR;
        
        [attrText appendAttributedString:linkAttrTitle];
        
        //        _linkHighlightRange = NSMakeRange(text.length, linkAttrTitle.length);
    }
    
    CGFloat maxW = SCREENW - 30-38;
    
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(maxW, MAXFLOAT)];
    YYTextLayout *textLayout = [YYTextLayout layoutWithContainer:container text:attrText];
    
    return textLayout;
}

- (NSMutableAttributedString *)linkAttrImage {
    UIImage *image = [BundleTool imageNamed:@"activity_cell_textlink"];
    NSMutableAttributedString *attr = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:image.size alignToFont:[UIFont systemFontOfSize:18] alignment:YYTextVerticalAlignmentCenter];
    return attr;
}
- (NSMutableAttributedString *)fixContentAttributed:(NSString *)text {
    UIFont *font = [UIFont systemFontOfSize:18];
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
    attrText.yy_font = font;
    attrText.yy_alignment = NSTextAlignmentJustified;
    attrText.yy_lineBreakMode = NSLineBreakByCharWrapping;
    attrText.yy_color = HTColorFromRGB(0x222222);
    attrText.yy_lineSpacing = 12 - (font.lineHeight - font.pointSize);
    return attrText;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.frame = CGRectMake(18, self.topImageView.height-15-14, SCREENW-80, 15);
        _timeLabel.font = [UIFont systemFontOfSize:15];
        _timeLabel.textColor = [UIColor whiteColor];
    }
    return _timeLabel;
}
- (UILabel *)appNameLabel {
    if (!_appNameLabel) {
        _appNameLabel = [[UILabel alloc] init];
        _appNameLabel.frame = CGRectMake(18, 16, SCREENW - 76, 20);
        _appNameLabel.font = [UIFont systemFontOfSize:18];
        _appNameLabel.textColor = [UIColor whiteColor];
        _appNameLabel.text = @"来自企名片App";
        
    }
    return _appNameLabel;
}
- (UILabel *)weekLabel {
    if (!_weekLabel) {
        _weekLabel = [[UILabel alloc] init];
        _weekLabel.frame = CGRectMake(18, self.topImageView.height-30-14, 200, 14);
        _weekLabel.font = [UIFont systemFontOfSize:14];
        _weekLabel.textColor = [UIColor whiteColor];
        _weekLabel.text  = @"";
        _weekLabel.hidden = YES;
    }
    return _weekLabel;
}
- (UIView *)barView {
    if (!_barView) {
        _barView = [[UIView alloc] init];
        _barView.frame = CGRectMake(0, SCREENH - kScreenBottomHeight-kScreenTopHeight, SCREENW, kScreenBottomHeight);
        _barView.backgroundColor = [UIColor whiteColor];
        
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        shareButton.frame = CGRectMake(SCREENW/2.0, 0, SCREENW/2.0, kShortBottomHeight);
        shareButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [shareButton setTitle:@"分享" forState:UIControlStateNormal];
        [shareButton setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [shareButton setImage:[BundleTool imageNamed:@"activity_card_share"] forState:UIControlStateNormal];
        [shareButton addTarget:self action:@selector(shareButtonClick) forControlEvents:UIControlEventTouchUpInside];
        shareButton.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2);
        shareButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, -2);
        [_barView addSubview:shareButton];
        
        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        saveButton.frame = CGRectMake(0, 0, SCREENW/2.0, kShortBottomHeight);
        saveButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [saveButton setTitle:@"保存" forState:UIControlStateNormal];
        [saveButton setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [saveButton setTitleColor:HTColorFromRGB(0xB4D0F7) forState:UIControlStateDisabled];
        [saveButton setImage:[BundleTool imageNamed:@"activity_card_save"] forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(saveButtonClick) forControlEvents:UIControlEventTouchUpInside];
        saveButton.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2);
        saveButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, -2);
        [_barView addSubview:saveButton];
        self.saveButton = saveButton;
        
        UIImageView *line = [[UIImageView alloc] init];
        line.frame = CGRectMake(0, 0, SCREENW, 1);
        line.backgroundColor = HTColorFromRGB(0xE3E3E3);
        [_barView addSubview:line];
    }
    return _barView;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}
- (UIView *)relateView {
    if (!_relateView) {
        _relateView = [[UIView alloc] init];
        _relateView.frame = CGRectMake(18, 0, SCREENW-15*2-36, 0);
        
        for (int i = 0; i < 10; i++) {
            QMPActivityCellRelateView *item = [[QMPActivityCellRelateView alloc] init];
            item.tag = i;
            [_relateView addSubview:item];
        }
        
    }
    return _relateView;
}
- (UIView *)photosView {
    if (!_photosView) {
        _photosView = [[UIView alloc] init];
        _photosView.userInteractionEnabled = NO;
        
        for (int i = 0; i < 9; i++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.hidden = YES;
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [_photosView addSubview:imageView];
        }
    }
    return _photosView;
}
- (CGSize)photosViewSizeWithPhotosCount:(int)count
{
    CGFloat margin = 8;
    CGFloat width = (SCREENW-80-16)/3.0;
    if (count == 1) {
        return CGSizeMake(200, 180);
    }
    
    // 一行最多有3列
    int maxColumns = (count == 4) ? 2 : 3;
    
    //  总行数
    int rows = (count + maxColumns - 1) / maxColumns;
    
    rows = (count > 9) ? 3 : rows;
    
    // 高度
    CGFloat photosH = rows * width + (rows - 1) * margin;
    
    // 总列数
    int cols = (count >= maxColumns) ? maxColumns : count;
    // 宽度
    CGFloat photosW = cols * width + (cols - 1) * margin;
    return CGSizeMake(photosW, photosH);
}
#pragma mark - Utils
- (UIImage *)convertViewToImage:(UIView *)view {
    // 第二个参数表示是否非透明。如果需要显示半透明效果，需传NO，否则YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(view.bounds.size,YES,[UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *resultImage = [PublicTool compressImage:image toByte:200 * 1024];
    
    return resultImage;
}

- (void)drawLineOfDashByCAShapeLayer:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor lineDirection:(BOOL)isHorizonal {
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    [shapeLayer setBounds:lineView.bounds];
    
    if (isHorizonal) {
        
        [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame))];
        
    } else{
        [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame)/2)];
    }
    
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    //  设置虚线宽度
    if (isHorizonal) {
        [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    } else {
        
        [shapeLayer setLineWidth:CGRectGetWidth(lineView.frame)];
    }
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    
    if (isHorizonal) {
        CGPathAddLineToPoint(path, NULL,CGRectGetWidth(lineView.frame), 0);
    } else {
        CGPathAddLineToPoint(path, NULL, 0, CGRectGetHeight(lineView.frame));
    }
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
    //  把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
}


- (NSArray *)handleRelates:(ActivityModel *)activity {
    
    NSMutableArray *relates = [NSMutableArray arrayWithArray:activity.relates];
    
    NSMutableArray *arr = [NSMutableArray array];
    if (relates.count == 0) {
        return arr;
    }
    UIFont *font = [UIFont systemFontOfSize:12];
    CGFloat extral = 18+12;
    CGFloat margin = 6;
    CGFloat padding = 30+36;
    CGFloat maxW = SCREENW - padding;
    CGFloat lastRight = 0;
    CGFloat height = 23;
    CGFloat marginH = 5;
    CGFloat top = 0;
    for (ActivityRelateModel *relate in relates) {
        CGFloat w = [self calculateLabelWidthWithString:relate.name height:ceil(font.lineHeight) font:font];
        w = w + extral;
        CGRect r = CGRectMake(lastRight, top, w, height);
        
        lastRight = lastRight + w + margin;
        if (lastRight > maxW) {
            top += (height + marginH);
            lastRight = 0;
            r = CGRectMake(lastRight, top, w, height);
            lastRight = (w+margin);
        }
        
        [arr addObject:[NSValue valueWithCGRect:r]];
    }
    height += top;
    
    return arr;
}
- (CGFloat)calculateLabelWidthWithString:(NSString *)string height:(CGFloat)height font:(UIFont *)font {
    if (string.length == 0) {
        return 0.f;
    }
    
    CGSize size = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size;
    
    return ceil(size.width);
}

@end
