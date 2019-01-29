//
//  DetailFeedBackOptionItemCell.m
//  qmp_ios
//
//  Created by QMP on 2018/7/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "DetailFeedBackOptionItemCell.h"

@interface DetailFeedBackOptionItemCell()
@property (nonatomic, strong) UICollectionView * collectionVw;
@property (nonatomic, strong) NSMutableArray * subBtnMArr;
@property (nonatomic, copy) CallTagTitleBlock callTagsBack;
@end

@implementation DetailFeedBackOptionItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
+ (instancetype)initCellWithTableView:(UITableView *)tableview didSelectItem:(CallTagTitleBlock)callBackBlock{
    DetailFeedBackOptionItemCell * itemCell = [tableview dequeueReusableCellWithIdentifier:@"DetailFeedBackOptionItemCellID"];
    if (itemCell == nil) {
        itemCell = [[DetailFeedBackOptionItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DetailFeedBackOptionItemCellID"];
        itemCell.selectTagArr = [NSMutableArray array];
        itemCell.callTagsBack = callBackBlock;
    }
    return itemCell;
}
- (void)addItemBtnOnContentView{
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.subBtnMArr removeAllObjects];
    CGFloat btnW = (SCREENW - (17 * 2 + 17)) / 2;
    CGFloat btnH = 30;
    for (int i = 0; i < self.itemBtnTitleArr.count / 2 + self.itemBtnTitleArr.count % 2; i++) {
        if (i == self.itemBtnTitleArr.count / 2) {
            UIButton * btn = [self customBtn];
            btn.frame = CGRectMake(17, i * (btnH + 5) + 5, btnW, btnH);
            [self.subBtnMArr addObject:btn];
            [self.contentView addSubview:btn];
        }else{
            UIButton * btn = [self customBtn];
            btn.frame = CGRectMake(17, 5 + i * (btnH +5) , btnW, btnH);
            [self.contentView addSubview:btn];
            [self.subBtnMArr addObject:btn];
            UIButton * nextBtn = [self customBtn];
            nextBtn.frame = CGRectMake(17 + btnW + 17, 5 + i * (btnH + 5), btnW, btnH);
            [self.subBtnMArr addObject:nextBtn];
            [self.contentView addSubview:nextBtn];
        }
    }
    for (int i = 0 ; i < self.itemBtnTitleArr.count; i++) {
        UIButton *btn = self.subBtnMArr[i];
        [btn setTitle:self.itemBtnTitleArr[i] forState:UIControlStateNormal];
    }
    UIButton * lastBtn = [self.subBtnMArr lastObject];
    self.cellHeight = CGRectGetMaxY(lastBtn.frame);
}
- (CGFloat)getCellHeight{
    return self.cellHeight;
}

- (void)setSelectTagArr:(NSMutableArray *)selectTagArr{

    _selectTagArr = selectTagArr;
    
    //只允许选中一个
    [self.subBtnMArr enumerateObjectsUsingBlock:^(UIButton * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([selectTagArr containsObject:obj.currentTitle]) {
            obj.selected = YES;
        }else{
            obj.selected = NO;
        }
    }];
    
}

- (void)setItemBtnTitleArr:(NSArray *)itemBtnTitleArr{
    _itemBtnTitleArr = itemBtnTitleArr;
    [self addItemBtnOnContentView];
}
- (void)clickItemTarget:(UIButton *)btn{
//    //允许多选
//    btn.selected = !btn.isSelected;
//    if (btn.isSelected) {
//        [self.selectTagArr addObject:btn.currentTitle];
//    }else{
//        [self.selectTagArr removeObject:btn.currentTitle];
//    }

    //只允许选中一个
    [self.subBtnMArr enumerateObjectsUsingBlock:^(UIButton * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.currentTitle != btn.currentTitle) {
            obj.selected = NO;
        }
    }];
    btn.selected = !btn.isSelected;
    if (btn.isSelected) {
        if (self.selectTagArr.count == 1) {
            [self.selectTagArr replaceObjectAtIndex:0 withObject:btn.currentTitle];
        }else{
            [self.selectTagArr addObject:btn.currentTitle];
        }
    }else{
        [self.selectTagArr removeObject:btn.currentTitle];
    }
    
    if (self.callTagsBack) {
        self.callTagsBack(btn.isSelected, btn.currentTitle, self.selectTagArr);
    }
}
- (UIButton *)customBtn{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"detail_feedback_normal"] forState:UIControlStateNormal];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:6];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setImage:[UIImage imageNamed:@"detail_feedback_selected"] forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickItemTarget:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
- (NSMutableArray *)subBtnMArr{
    if (_subBtnMArr == nil) {
        _subBtnMArr = [NSMutableArray array];
    }
    return _subBtnMArr;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the view for the selected state
}

@end
