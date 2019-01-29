//
//  SimilarFilterCell.m
//  qmp_ios
//
//  Created by shan wen on 2018/2/22.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "SimilarFilterCell.h"
#import "TagsFrame.h"
#import <UICollectionViewLeftAlignedLayout.h>

@interface SimilarFilterCell ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    TagsFrame *_tagFrame;
}
@end

@implementation SimilarFilterCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = TABLEVIEW_COLOR;
        self.contentView.backgroundColor = TABLEVIEW_COLOR;
        [self setUI];
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setTagsArr:(NSArray *)tagsArr{
    if (_tagsArr == tagsArr) {
        return;
    }
    _tagsArr = tagsArr;
    _tagFrame = [[TagsFrame alloc]init];
    _tagFrame.tagsArray = _tagsArr;
    
    [_tagsCollecView reloadData];
}

- (void)setUI{

//    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
//    layout.minimumLineSpacing = 12;
//    layout.minimumInteritemSpacing = 12;
    
    UICollectionViewLeftAlignedLayout*layout = [[UICollectionViewLeftAlignedLayout alloc]init];
    layout.minimumLineSpacing = 12;
    layout.minimumInteritemSpacing = 12;
    
    _tagsCollecView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
    _tagsCollecView.scrollEnabled = NO;
    _tagsCollecView.delegate = self;
    _tagsCollecView.dataSource = self;
    _tagsCollecView.contentInset = UIEdgeInsetsMake(49, 15, 50, 15);
    _tagsCollecView.backgroundColor = TABLEVIEW_COLOR;
    [self addSubview:_tagsCollecView];
    
    [_tagsCollecView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"TagCell"];
    
    //标题
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(16, 16, 120, 15)];
    [titleLab labelWithFontSize:13 textColor:H9COLOR];
    titleLab.text = @"试试其他竞品维度吧";
    [self addSubview:titleLab];
    self.titleLab = titleLab;
    
    //展开按钮
    self.showAllBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, self.frame.size.height-50, self.width, 50)];
    [self.showAllBtn setImage:[BundleTool imageNamed:@"company_arrow_down"] forState:UIControlStateNormal];
    [self.showAllBtn setTitleColor:NV_TITLE_COLOR forState:UIControlStateNormal];
    self.showAllBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.showAllBtn setTitle:@"展开" forState:UIControlStateNormal];
    [self.showAllBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:5];
    [self addSubview:_showAllBtn];
    self.showAllBtn.backgroundColor = TABLEVIEW_COLOR;

}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.tagsCollecView.frame = self.bounds;
    self.showAllBtn.frame = CGRectMake(0, self.frame.size.height-50, self.width, 50);
}


#pragma mark ----UICollectionViewDelegate--

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.tagsArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UICollectionViewCell *tagCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TagCell" forIndexPath:indexPath];
    UILabel *label = [tagCell viewWithTag:1000];
    if (!label) {
        label = [[UILabel alloc]initWithFrame:tagCell.bounds];
        label.tag = 1000;
        label.textAlignment = NSTextAlignmentCenter;
        [tagCell addSubview:label];
        label.font = [UIFont systemFontOfSize:12];
    }
    label.frame = tagCell.bounds;
    tagCell.layer.masksToBounds = YES;
    tagCell.layer.cornerRadius = 2;
    tagCell.layer.borderWidth = 1;
    
    label.text = self.tagsArr[indexPath.row];
    if ([label.text isEqualToString:self.selectedTag]) {
        label.textColor = BLUE_TITLE_COLOR;
        tagCell.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
    }else{
        label.textColor = H5COLOR;
        tagCell.layer.borderColor = H9COLOR.CGColor;
    }
    return tagCell;
    
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UILabel *label = [cell viewWithTag:1000];

    if (self.clickTag) {
        QMPLog(@"选中----%@",label.text);
        self.clickTag(label.text);
        
    }
    
}

#pragma mark --UICollectionViewFlowLayout--
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat tagHeight = 24;
    NSString *tag = self.tagsArr[indexPath.row];
    NSString *frame = _tagFrame.tagsFrames[indexPath.row];

    return CGSizeMake([PublicTool widthOfString:tag height:100 fontSize:12]+20, tagHeight);
    return CGSizeMake(CGRectFromString(frame).size.width, tagHeight);
}

@end
