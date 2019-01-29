//
//  ProductAppListCell.m
//  qmp_ios
//
//  Created by QMP on 2018/9/19.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ProductAppListCell.h"

@interface ProductAppListCell()
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, weak) UILabel *iconLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UILabel *rankLabel;
@property (nonatomic, strong) UILabel *downloadLabel;
@end


@implementation ProductAppListCell
+ (instancetype)cellWithTableView:(UITableView*)tableView{
    ProductAppListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductAppListCellID"];
    if (!cell) {
        cell = [[ProductAppListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ProductAppListCellID"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {        
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.categoryLabel];
        [self.contentView addSubview:self.rankLabel];
        [self.contentView addSubview:self.downloadLabel];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(self.nameLabel.left, 0, SCREENW - self.nameLabel.left, 1)];
        line.backgroundColor = LIST_LINE_COLOR;
        [self.contentView addSubview:line];
        line.tag = 10001;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.contentView viewWithTag:10001].bottom = self.height;
}

- (void)setAppInfo:(NSDictionary *)appInfo {
    _appInfo = appInfo;
    
    self.iconLabel.hidden = YES;
    if (![PublicTool isNull:appInfo[@"icon"]]) {
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:appInfo[@"icon"]]];
    } else {
        self.iconLabel.hidden = NO;
        self.iconLabel.backgroundColor = RANDOM_COLORARR[arc4random()%5];
        if (![PublicTool isNull:appInfo[@"app_name"]]) {
            NSString *appname = appInfo[@"app_name"];
            if (appname.length > 0) {
                self.iconLabel.text = [appname substringToIndex:1];
            }
        }
    }
    
    if (![PublicTool isNull:appInfo[@"tages"]]) {
        self.categoryLabel.text = [NSString stringWithFormat:@"%@", appInfo[@"tages"]];
        [self.categoryLabel sizeToFit];
        self.categoryLabel.frame = CGRectMake(0, -15, self.categoryLabel.width+16, 15);
    }
    
    if (![PublicTool isNull:appInfo[@"app_name"]]) {
        self.nameLabel.text = appInfo[@"app_name"];
    } else {
        self.nameLabel.text = @"";
    }
    
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectMake(self.iconView.right+12, 18, MIN(self.nameLabel.width, SCREENW-32-28-60-self.categoryLabel.width-6), 19);
    self.categoryLabel.left = self.nameLabel.right + 6;
    self.categoryLabel.centerY = self.nameLabel.centerY;
    
    self.rankLabel.attributedText = [self rankWithAppInfo];
    self.downloadLabel.attributedText = [self downloadWithAppInfo];
}

- (NSAttributedString *)rankWithAppInfo {
    NSMutableString *str = [[NSMutableString alloc] init];
    [str appendString:@"AppStore 领域排名："];
    NSInteger len = str.length;
    if (![PublicTool isNull:self.appInfo[@"rank"]]) {
        [str appendString:self.appInfo[@"rank"]];
    } else {
        [str appendString:@"-"];
    }
    NSMutableAttributedString *rank = [[NSMutableAttributedString alloc] initWithString:str
                                                                             attributes:@{
                                                                                          NSFontAttributeName:self.rankLabel.font,
                                                                                          NSForegroundColorAttributeName: self.rankLabel.textColor
                                                                                          }];
    [rank addAttribute:NSForegroundColorAttributeName value:BLUE_TITLE_COLOR range:NSMakeRange(len, str.length-len)];
    
    return rank;
}
- (NSAttributedString *)downloadWithAppInfo {
    NSMutableString *str = [[NSMutableString alloc] init];
    [str appendString:@"Android 昨日下载量："];
    NSInteger len = str.length;
    if (![PublicTool isNull:self.appInfo[@"downloads"]]) {
        NSInteger downCount = [self.appInfo[@"downloads"] integerValue];
        if (downCount < 1000) {
            [str appendString:[NSString stringWithFormat:@"%zd", downCount]];
        } else {
            [str appendString:[NSString stringWithFormat:@"%.1f万", downCount/10000.0]];
        }
    } else {
        [str appendString:@"-"];
    }
    NSMutableAttributedString *download = [[NSMutableAttributedString alloc] initWithString:str
                                                                                 attributes:@{
                                                                                              NSFontAttributeName:self.downloadLabel.font,
                                                                                              NSForegroundColorAttributeName: self.downloadLabel.textColor
                                                                                              }];
    [download addAttribute:NSForegroundColorAttributeName value:BLUE_TITLE_COLOR range:NSMakeRange(len, str.length-len)];
    
    return download;
}
#pragma mark - Getter
- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.frame = CGRectMake(15, 16, 48, 48);
        _iconView.layer.cornerRadius = 4;
        _iconView.layer.borderColor = [BORDER_LINE_COLOR CGColor];
        _iconView.layer.borderWidth = 0.5;
        _iconView.clipsToBounds = YES;
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = _iconView.bounds;
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [_iconView addSubview:label];
        self.iconLabel = label;
        
    }
    return _iconView;
}
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(self.iconView.right+15, 13, 0, 19);
        if (@available(iOS 8.2, *)) {
            _nameLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        }else{
            _nameLabel.font = [UIFont systemFontOfSize:15];
        }
        _nameLabel.textColor = COLOR2D343A;
    }
    return _nameLabel;
}
- (UILabel *)categoryLabel {
    if (!_categoryLabel) {
        _categoryLabel = [[UILabel alloc] init];
        _categoryLabel.frame = CGRectMake(0, 0, 0, 15);
        _categoryLabel.font = [UIFont systemFontOfSize:10];
        _categoryLabel.textColor = BLUE_TITLE_COLOR;
        _categoryLabel.textAlignment = NSTextAlignmentCenter;
        _categoryLabel.backgroundColor = LABEL_BG_COLOR;
        _categoryLabel.layer.cornerRadius = 2;
        _categoryLabel.clipsToBounds = YES;
    }
    return _categoryLabel;
}
- (UILabel *)rankLabel {
    if (!_rankLabel) {
        _rankLabel = [[UILabel alloc] init];
        _rankLabel.frame = CGRectMake(self.nameLabel.left, self.nameLabel.bottom+10, SCREENW-32-28-60, 14);
        _rankLabel.font = [UIFont systemFontOfSize:13];
        _rankLabel.textColor = COLOR737782;
    }
    return _rankLabel;
}
- (UILabel *)downloadLabel {
    if (!_downloadLabel) {
        _downloadLabel = [[UILabel alloc] init];
        _downloadLabel.frame = CGRectMake(self.nameLabel.left, self.rankLabel.bottom+10, SCREENW-32-28-60, 14);
        _downloadLabel.font = [UIFont systemFontOfSize:13];
        _downloadLabel.textColor = COLOR737782;
    }
    return _downloadLabel;
}


@end
