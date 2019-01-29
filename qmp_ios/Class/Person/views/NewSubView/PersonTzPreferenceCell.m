//
//  PersonTzPreferenceCell.m
//  qmp_ios
//
//  Created by QMP on 2018/6/30.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PersonTzPreferenceCell.h"

@interface PersonTzPreferenceCell()
@property(nonatomic,copy)NSString *tagsString;
@property(nonatomic,strong)UILabel *titleLab;
@property(nonatomic,strong)DetailTagsCell *tagCell;
@property(nonatomic,strong)UIView *addInfoView;

@property(nonatomic,copy)void (^didClickShrinkTag)(BOOL, TagsFrame *);
@property(nonatomic,copy)void (^didClickTag)(NSString *tag);

@end

@implementation PersonTzPreferenceCell

+ (id)cellWithTableView:(UITableView *)tableView tagString:(NSString *)tagsString clickShrinkTag:(void (^)(BOOL, TagsFrame *))didClickShrinkTag clickTag:(void (^)(NSString *))didClickTag{
    PersonTzPreferenceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonTzPreferenceCellID"];
    if (!cell) {
        cell = [[PersonTzPreferenceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PersonTzPreferenceCellID"];        
    }
    cell.tagsString = tagsString;
    cell.didClickTag = didClickTag;
    cell.didClickShrinkTag = didClickShrinkTag;
    [cell addViews];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)addViews{
    
    if (!self.titleLab) {
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 100, 14)];
        [self.titleLab labelWithFontSize:14 textColor:COLOR737782];
        [self.contentView addSubview:self.titleLab];
    }
    
    if (!self.tagCell) {
        
        self.tagCell = [[DetailTagsCell alloc]initWithTagString:self.tagsString clickShrinkTag:self.didClickShrinkTag clickAddTag:nil clickTag:self.didClickTag];
        self.tagCell.frame = CGRectMake(0, 0, SCREENW, self.height);
        [self.contentView addSubview:self.tagCell];
        
    }else{
        
        self.tagCell.isCompany = NO;
        if (self.didClickTag) {
            self.tagCell.isCompany = YES;
        }
        [self.tagCell refreshTagsString:self.tagsString];
        self.tagCell.didClickShrinkTag = self.didClickShrinkTag;
        self.tagCell.didClickTag = self.didClickTag;
    }
    
//    if (!self.editBtn) {
//        self.editBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW - 90, 0, 63, 40)];
//        self.editBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//        [self.editBtn setTitle:@"编辑" forState:UIControlStateNormal];
//        [self.editBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
//        [self.editBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
//        [self.contentView addSubview:self.editBtn];
//        self.editBtn.hidden = YES;
//    }
//
}

-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    self.tagCell.frame = self.bounds;
}

- (UIView *)addInfoView{
    if (!_addInfoView) {
        _addInfoView = [[UIView alloc]initWithFrame:CGRectMake(0, 30, SCREENW, self.height - 30)];
        UIButton *addBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 116, 34)];
        [_addInfoView addSubview:addBtn];
        addBtn.center = CGPointMake(SCREENW/2.0, self.contentView.height/2.0);
    }
    return _addInfoView;
}
- (void)setTitleStr:(NSString *)titleStr{
    self.titleLab.text = titleStr;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
