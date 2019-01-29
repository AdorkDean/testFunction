//
//  CommonIntroduceCell.m
//  qmp_ios
//
//  Created by QMP on 2018/6/29.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "CommonIntroduceCell.h"
#import <YYText.h>

@interface CommonIntroduceCell()

@property(nonatomic,strong)YYLabel *contentLabel;
@property(nonatomic,copy)void(^didTapShowAll)(void);

@end
@implementation CommonIntroduceCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addViews];
    }
    return self;
}
+ (instancetype)cellWithTableView:(UITableView*)tableView didTapShowAll:(void(^)(void))didTapShowAll{
    CommonIntroduceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommonIntroduceCellID"];
    if (!cell) {
        cell = [[CommonIntroduceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CommonIntroduceCellID"];
        cell.didTapShowAll = didTapShowAll;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)addViews{
    
    _contentLabel = [[YYLabel alloc] init];
    _contentLabel.font = [UIFont systemFontOfSize:14];
    _contentLabel.textColor = H4COLOR;
    _contentLabel.frame = CGRectMake(75, 45, SCREENW-72-14, 0);
    _contentLabel.numberOfLines = 0;
    _contentLabel.userInteractionEnabled = YES;
    [self.contentView addSubview:self.contentLabel];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.top.equalTo(self).offset(11);
        make.right.equalTo(self).offset(-15);
        make.bottom.equalTo(self).offset(-3);
    }];
    
    [_contentLabel addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(copyContent)]];
    
}

- (void)setLayout:(IntroduceCellLayout *)layout{
    
    _layout = layout;
    
    self.contentLabel.height = layout.textLayout.textBoundingSize.height;
    
    if (!layout.isNeedExplored) {
        
        self.contentLabel.textLayout = layout.textLayout;
        
    } else {
        
        __weak typeof(self) weakSelf = self;
        
        NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc] initWithAttributedString:layout.textLayout.text];
        
       
        NSRange titleRange = [layout.introduceInfoDic[@"spread"] boolValue] ? NSMakeRange(mStr.length-2, 2):NSMakeRange(mStr.length-4, 4);
        [mStr yy_setTextHighlightRange:titleRange color:BLUE_TITLE_COLOR backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            if (weakSelf.didTapShowAll) {
                weakSelf.didTapShowAll();
            }
        }];
        self.contentLabel.textLayout = layout.textLayout;
        self.contentLabel.attributedText = mStr;
    }
}

- (void)copyContent{
    
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    NSString *copyStr = _layout.textLayout.text.string;
    if (![PublicTool isNull:self.shortUrl]) {
        copyStr = [copyStr stringByAppendingString:[NSString stringWithFormat:@" 来自企名片%@",self.shortUrl]];
    }
    board.string = copyStr;
    
    [ShowInfo showInfoOnView:KEYWindow withInfo:@"复制成功"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
