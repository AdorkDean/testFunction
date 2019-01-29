//
//  CompanyTagsCell.m
//  qmp_ios
//
//  Created by QMP on 2017/8/30.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "CompanyTagsCell.h"

@interface CompanyTagsCell ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@end
@implementation CompanyTagsCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}

-(void)dealloc{
    
    [_tagsCollecView removeObserver:self forKeyPath:@"contentSize"];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setTagsArr:(NSArray *)tagsArr{
    if (_tagsArr == tagsArr) {
        return;
    }
    _tagsArr = tagsArr;
    [_tagsCollecView reloadData];
}

- (void)setUI{
    
 
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    
    _tagsCollecView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
    _tagsCollecView.scrollEnabled = NO;
    _tagsCollecView.delegate = self;
    _tagsCollecView.dataSource = self;
    _tagsCollecView.contentInset = UIEdgeInsetsMake(10, 15, 10, 15);
    _tagsCollecView.backgroundColor =[ UIColor whiteColor];
    [self addSubview:_tagsCollecView];
    [_tagsCollecView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
    [_tagsCollecView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"TagCell"];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.tagsCollecView.frame = self.bounds;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGFloat height = [change[@"new"] CGSizeValue].height;

//        self.tagsCollecView.frame = self.bounds;

    }
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
        label.font = [UIFont systemFontOfSize:14];
    }
    label.frame = tagCell.bounds;
    tagCell.layer.masksToBounds = YES;
    tagCell.layer.cornerRadius = 5;
    tagCell.layer.borderWidth = 0.5;
    tagCell.layer.borderColor = [UIColor lightGrayColor].CGColor;
    label.text = self.tagsArr[indexPath.row];
    return tagCell;
   
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.clickTag) {
        
        self.clickTag(indexPath.row);
        
    }
    
}

#pragma mark --UICollectionViewFlowLayout--
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat tagHeight = 30;
    CGFloat tagWidth = [PublicTool widthOfString:self.tagsArr[indexPath.row] height:tagHeight fontSize:14];
    return CGSizeMake(tagWidth+20, tagHeight);
}



@end
