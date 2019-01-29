//
//  DetailMemberSectionCell.m
//  qmp_ios
//
//  Created by QMP on 2018/8/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "DetailMemberSectionCell.h"
#import "DynamicRelateCell.h"
#import "DetailMemberCell.h"
#import "ManagerItem.h"
#import "OrgFaProductModel.h"

@interface DetailMemberSectionCell () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *mainView;
@end
@implementation DetailMemberSectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
+ (DetailMemberSectionCell *)memberSectionCellWithTableView:(UITableView *)tableView{
    DetailMemberSectionCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DetailMemberSectionCellID"];
    if (cell == nil) {
        cell = [[DetailMemberSectionCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DetailMemberSectionCellID"];
        
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.mainView];
    }
    return self;
}
- (void)setMemberArray:(NSArray *)memberArray {
    _memberArray = memberArray;
    [self.mainView reloadData];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return MIN(15, self.memberArray.count);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    DetailMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DetailMemberCellID" forIndexPath:indexPath];
    ManagerItem *manager = self.memberArray[indexPath.row];
    cell.user = manager;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
   
    ManagerItem *member = self.memberArray[indexPath.item];
    PersonModel *person = [[PersonModel alloc]init];
    person.name = member.name;
    person.personId = [PublicTool isNull:member.personId] ? member.person_id:member.personId;
    [PublicTool goPersonDetail:person];
}


- (void)enterFAProduct:(NSIndexPath *)indexPath{
    OrgFaProductModel *faProductM = self.memberArray[indexPath.row];
    if ([PublicTool isNull:faProductM.detail]) {
        return;
    }
    [[AppPageSkipTool shared] appPageSkipToProductDetail:[PublicTool toGetDictFromStr:faProductM.detail]];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.mainView.frame = self.contentView.bounds;
}
#pragma mark - Getter
- (UICollectionView *)mainView {
    if (!_mainView) {
        MyCollectionViewFlowLayout *layout = [[MyCollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(SCREENW-16, 82);
        layout.minimumLineSpacing = 8;
        layout.minimumInteritemSpacing = 0;
        
        CGRect rect = CGRectMake(0, 0, 0, 0);
        _mainView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _mainView.backgroundColor = [UIColor whiteColor];
        _mainView.dataSource = self;
        _mainView.delegate = self;
        _mainView.showsHorizontalScrollIndicator = NO;
        _mainView.contentInset = UIEdgeInsetsMake(0, 16, 5, 16);
        _mainView.decelerationRate = UIScrollViewDecelerationRateFast;
        _mainView.alwaysBounceHorizontal = YES;
        [_mainView registerNib:[UINib nibWithNibName:@"DetailMemberCell" bundle:[BundleTool commonBundle]] forCellWithReuseIdentifier:@"DetailMemberCellID"];
        _mainView.scrollEnabled = NO;
        
    }
    return _mainView;
}
@end
