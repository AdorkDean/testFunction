//
//  ScrollCollectView.m
//  qmp_ios
//
//  Created by QMP on 2018/6/11.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ScrollCollectView.h"
#import "TableHeadMenuCell.h"

@interface ScrollCollectView()<UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSInteger _selectedItem;
}
@property(nonatomic,copy)void(^didSelectedItem)(NSString *title);
@property(nonatomic,strong)NSArray *selectImageArr;

@end


@implementation ScrollCollectView

-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles images:(NSArray *)images didSelectedItem:(void (^)(NSString *))didSelectItem{
    
    if(self = [super initWithFrame:frame]){
        _selectTitleColor = BLUE_TITLE_COLOR;
        _unSelectTitleColor = COLOR737782;
        _selectedItem = 0;
        self.dataArr = titles;
        self.imageArr = images;
        self.didSelectedItem = didSelectItem;
        [self addView];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray*)titles  images:(NSArray*)images selectedImages:(NSArray*)selectedImages didSelectedItem:(void(^)(NSString *title))didSelectItem{
    
    if(self = [super initWithFrame:frame]){
        _selectTitleColor = BLUE_TITLE_COLOR;
        _unSelectTitleColor = COLOR737782;
        _selectedItem = 0;
        self.dataArr = titles;
        self.imageArr = images;
        self.selectImageArr = selectedImages;
        self.didSelectedItem = didSelectItem;
        [self addView];
    }
    return self;
}

- (void)setDataArr:(NSArray *)dataArr{
    _dataArr = dataArr;
    [self.collectionV reloadData];
}

- (void)setImageArr:(NSArray *)imageArr{
    _imageArr = imageArr;
    [self.collectionV reloadData];
}

-(void)layoutSubviews{
    
    [super layoutSubviews];
    self.collectionV.frame = self.bounds;
    [self.collectionV reloadData];
}

- (void)addView{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
//    layout.minimumInteritemSpacing = SCREENW > 375.0?200:60;
//    layout.minimumLineSpacing = SCREENW > 375.0?100:10;
//    layout.itemSize = CGSizeMake(71, self.height);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    
    self.collectionV = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionV.showsVerticalScrollIndicator = YES;
    _collectionV.delegate = self;
    _collectionV.dataSource = self;
    
    [self addSubview:_collectionV];
    
    _collectionV.backgroundColor = [UIColor whiteColor];
    [_collectionV registerNib:[UINib nibWithNibName:@"TableHeadMenuCell" bundle:nil] forCellWithReuseIdentifier:@"TableHeadMenuCellID"];
    _collectionV.contentInset = UIEdgeInsetsMake(0, 10, 0, 10);
    _collectionV.showsHorizontalScrollIndicator = NO;
    [_collectionV reloadData];
}

- (void)setSelectTitleColor:(UIColor *)selectTitleColor{
    _selectTitleColor = selectTitleColor;
}
- (void)setUnSelectTitleColor:(UIColor *)unSelectTitleColor{
    _unSelectTitleColor = unSelectTitleColor;
}

#pragma mark --UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    TableHeadMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TableHeadMenuCellID" forIndexPath:indexPath];
    NSString *imageName = self.imageArr[indexPath.item];
    
    cell.title.text = self.dataArr[indexPath.item];
    if (self.selectImageArr.count) {
        if(_selectedItem == indexPath.item){
            cell.title.textColor = _selectTitleColor;
            cell.icon.image = [UIImage imageNamed:self.selectImageArr[indexPath.item]];
        }else{
            cell.title.textColor = _unSelectTitleColor;
            cell.icon.image = [UIImage imageNamed:self.imageArr[indexPath.item]];
            
        }
    }else{ //写死的 用于项目页的那个
        
        if(_selectedItem == indexPath.item){
            cell.title.textColor = _selectTitleColor;
            cell.icon.image = [UIImage imageNamed:imageName];
        }else{
            cell.title.textColor = _unSelectTitleColor;
            cell.icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_gray",imageName]];
            
        }
        
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    _selectedItem = indexPath.item;
    
    if(self.didSelectedItem ){
        self.didSelectedItem(self.dataArr[indexPath.item]);
    }
    
    [_collectionV reloadData];

}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.dataArr[indexPath.item];
    if (title.length < 4) {
        return CGSizeMake(60, self.height-15);
    } else {
        return CGSizeMake(70, self.height-15);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
     return 33;
}
#pragma mark --Event--
- (void)setSelectedMenu:(NSString*)menuTitle{
    _selectedItem = [self.dataArr indexOfObject:menuTitle];
    [_collectionV reloadData];
    [_collectionV scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_selectedItem inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}
@end
