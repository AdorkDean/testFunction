//
//  DynimacRelateCell.m
//  qmp_ios
//
//  Created by QMP on 2018/6/28.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "DynamicRelateCell.h"
#import "ActivityCollectionCell.h"
#import "ActivityLayout.h"
#import "ActivityModel.h"
#import "ActivityDetailViewController.h"
#import "ActivityListViewController.h"


@interface DynamicRelateCell() <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate> {
    NSInteger _selectedItem;
}
@property (nonatomic, copy) void(^didSelectedItem)(NSInteger selectedIndex);

@property (nonatomic, copy) void(^clickSeeMore)(void);
@end

@implementation DynamicRelateCell
+ (instancetype)cellWithTableView:(UITableView*)tableView clickSeeMore:(void(^)(void))clickSeeMore {
    DynamicRelateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DynamicRelateCellID"];
    if (!cell) {
        cell = [[DynamicRelateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DynamicRelateCellID" didSelectedItem:nil];
        [cell.collectionView registerClass:[ActivityCollectionCell class] forCellWithReuseIdentifier:@"ActivityCollectionCellID"];
    }
    cell.clickSeeMore = clickSeeMore;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier didSelectedItem:(void(^)(NSInteger index))didSelectedItem {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.didSelectedItem = didSelectedItem;
        [self setupViews];
    }
    return self;
}

- (void)setDataArr:(NSArray *)dataArr {
    _dataArr = dataArr;
    [self.collectionView reloadData];
}

- (void)setupViews {
    
    MyCollectionViewFlowLayout *layout = [[MyCollectionViewFlowLayout alloc] init];//WithSectionInset:UIEdgeInsetsMake(10, 16, 5, 16)];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing  = 5;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(SCREENW-32, 108);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(12, 16, 5, 16);
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.decelerationRate = 0.1;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.scrollEnabled = NO;
    [self.collectionView registerNib:[UINib nibWithNibName:@"CommonShowMoreItemCell" bundle:[BundleTool commonBundle]] forCellWithReuseIdentifier:@"CommonShowMoreItemCellID"];
    [self.contentView addSubview:self.collectionView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
    
}


#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ActivityCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ActivityCollectionCellID" forIndexPath:indexPath];
    cell.layout = self.dataArr[indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    cell.clickHeaderEvent = ^{
        [weakSelf enterPerson:weakSelf.dataArr[indexPath.row]];
    };
    
    
    return cell;
}

- (void)enterPerson:(ActivityLayout*)layout {
    
    NSInteger userType = layout.activityModel.user.type.integerValue;
    NSString *personID = layout.activityModel.user.ID;
    NSString *unionid = layout.activityModel.user.uID;
    if(layout.activityModel.isAnonymous){
        return ;
    }
    
    if (userType == 2) {
        [PublicTool enterOfficinalPage:unionid ticket:@""];
    }else{
        if (layout.activityModel.isAnonymous) {
            return;
        }
        PersonModel *person = [[PersonModel alloc]init];
        person.personId = personID;
        person.unionid = unionid;
        [PublicTool goPersonDetail:person];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArr.count == 0) {
        return;
    }
    if (self.dataArr.count > 5 && indexPath.item == 5) {
        self.clickSeeMore();
        return;
    }
    self.clickSeeMore();
//
//    ActivityDetailViewController *vc = [[ActivityDetailViewController alloc] init];
//    ActivityLayout *layout = self.dataArr[indexPath.row];
//    vc.activityID = layout.activityModel.ticketID;
//    vc.activityTicket = layout.activityModel.ticket;
//    [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
   
    ActivityLayout *layout = self.dataArr[indexPath.row];
    return layout.collectionCellSize;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0;
}
@end


@implementation MyCollectionViewFlowLayout
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)offset withScrollingVelocity:(CGPoint)velocity {
    CGRect cvBounds = self.collectionView.bounds;
    CGFloat halfWidth = cvBounds.size.width * 0.5f;
    
    NSArray *attributesArray = [self layoutAttributesForElementsInRect:cvBounds];
    if (velocity.x == 0) { // 按住拖动
        CGFloat proposedContentOffsetCenterX = offset.x + halfWidth;
        
        UICollectionViewLayoutAttributes *candidateAttributes;
        for (UICollectionViewLayoutAttributes *attributes in attributesArray) {
            
            if (attributes.representedElementCategory != UICollectionElementCategoryCell) {
                continue;
            }
            
            if(!candidateAttributes) {
                candidateAttributes = attributes;
                continue;
            }
            
            if (fabs(attributes.center.x - proposedContentOffsetCenterX) < fabs(candidateAttributes.center.x - proposedContentOffsetCenterX)) {
                candidateAttributes = attributes;
            }
        }
        return CGPointMake(candidateAttributes.center.x - halfWidth, offset.y);
    } else {
        
        UICollectionViewLayoutAttributes *candidateAttributes;
        for (UICollectionViewLayoutAttributes *attributes in attributesArray) {
            if (attributes.representedElementCategory != UICollectionElementCategoryCell) {
                continue;
            }
            if ((attributes.center.x == 0) || (attributes.center.x > (self.collectionView.contentOffset.x + halfWidth) && velocity.x < 0)) {
                continue;
            }
            candidateAttributes = attributes;
        }
        
        if (!candidateAttributes) {
            return [super targetContentOffsetForProposedContentOffset:offset];
        }
        
        return CGPointMake(floor(candidateAttributes.center.x - halfWidth), offset.y);
    }
}
@end
