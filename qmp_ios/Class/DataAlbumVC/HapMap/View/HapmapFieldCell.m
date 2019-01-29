//
//  HapmapFieldCell.m
//  qmp_ios
//
//  Created by QMP on 2017/11/17.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "HapmapFieldCell.h"
#import "HapMapAreaModel.h"
#import "FieldCollectionCell.h"

@interface HapmapFieldCell()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    NSArray *_dataArr;
    UIView *_topView;
    UICollectionView *_collectionView;
}
@property(nonatomic,strong) NSArray *dataArr;


@end


@implementation HapmapFieldCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier data:(HapMapAreaModel*)areaM{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _dataArr = areaM.list;
        _areaModel = areaM;
        [self setUI];
    }
    return self;
}


- (void)setUI{

    //灰色
    UIView *grayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,SCREENW, 10)];
    grayView.backgroundColor = TABLEVIEW_COLOR;
    [self.contentView addSubview:grayView];
    
    _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, SCREENW, 45)];
    [self.contentView addSubview:_topView];
    
    //红
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(17, 16, 2.5, 13)];
    view.backgroundColor = RED_TEXTCOLOR;
    [_topView addSubview:view];
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(30, 25, SCREENW - 30 - 40, 18)];
    [lab labelWithFontSize:15 textColor:NV_TITLE_COLOR];
    [_topView addSubview:lab];
    lab.centerY = _topView.height/2.0;
    lab.tag = 1000;
    
    //arrow
    UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(_topView.width-35, 0, 18, 18)];
    arrow.image = [UIImage imageNamed:@"cell_arrow"];
    [_topView addSubview:arrow];
    arrow.centerY = lab.centerY;
    
    //线
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 44.5, SCREENW, 0.5)];
    line.backgroundColor = LIST_LINE_COLOR;
    [_topView addSubview:line];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickBigClass:)];
    [_topView addGestureRecognizer:tap];
    
    [_topView removeFromSuperview];
    
    
    CGFloat left = 17;
    CGFloat edge = 13;
    CGFloat rowCount = iPad ? 4:3;
    CGFloat width = (SCREENW - left*2 - (rowCount-1)*edge -1)/rowCount;
    CGFloat height = 63;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(width , height);
    layout.minimumLineSpacing = edge;
    layout.minimumInteritemSpacing = edge;
    
    _collectionView = [[UICollectionView alloc]initWithFrame:self.contentView.bounds collectionViewLayout:layout];

    _collectionView.scrollEnabled = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.contentInset = UIEdgeInsetsMake(0, 17, 0, 17);
    [self.contentView addSubview:_collectionView];
    [_collectionView registerNib:[UINib nibWithNibName:@"FieldCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"FieldCollectionCellID"];
    _collectionView.backgroundColor = [UIColor whiteColor];

    
}

- (void)refreshUI:(HapMapAreaModel*)areaModel{
    
    _areaModel = areaModel;
    _dataArr = areaModel.list;
    
    if ([PublicTool isNull:areaModel.name]) {
        [_topView removeFromSuperview];
        
    }else{
        
        if (!_topView.superview) {
            [self.contentView addSubview:_topView];
        }
        UILabel *lab = (UILabel*)[_topView viewWithTag:1000];
        NSString *title = [NSString stringWithFormat:@"%@",_areaModel.name];
        lab.text = title;
    
//        [_collectionView reloadData];
        
    }
    
    if (![PublicTool isNull:_areaModel.name]) {
        _collectionView.frame = CGRectMake(0, _topView.bottom+20, SCREENW, self.contentView.height - _topView.height);
        
    }else{
        _collectionView.frame = CGRectMake(0, 30, SCREENW, self.contentView.height - 30);
        
    }
    [_collectionView reloadData];

    if (_dataArr.count == 0) { //没有子领域
        _collectionView.hidden = YES;
    }else{
        _collectionView.hidden = NO;
    }
    
}

- (void)clickBigClass:(UITapGestureRecognizer*)tap{
    self.clickBigClass(_areaModel.name);
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    if (![PublicTool isNull:_areaModel.name]) {
        _collectionView.frame = CGRectMake(0, _topView.bottom+20, SCREENW, self.contentView.height - _topView.bottom-20);

    }else{
        _collectionView.frame = CGRectMake(0, 30, SCREENW, self.contentView.height - 30);

    }
}



#pragma mark --UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FieldCollectionCell *collecCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FieldCollectionCellID" forIndexPath:indexPath];
    collecCell.filedModel = _dataArr[indexPath.item];
    return collecCell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    HapMapAreaModel *areaM = _areaModel.list[indexPath.item];
    self.clickSubClass(areaM.name);
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat left = 17;
    CGFloat edge = 13;
    CGFloat rowCount = iPad ? 4:3;
    CGFloat width = (SCREENW - left*2 - (rowCount-1)*edge-1)/rowCount;
    CGFloat height = 63;
    
    return CGSizeMake(width , height);
}


@end
