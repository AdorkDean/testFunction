//
//  QMPTagView.m
//  TestPod
//
//  Created by QMP on 2017/8/28.
//  Copyright © 2017年 WSS. All rights reserved.
//

#import "QMPTagView.h"
#import "TagShowCell.h"
#import "TagEditCell.h"
#import <UICollectionViewLeftAlignedLayout.h>


#define TAGHEIGHT  27 //默认tag宽度，编辑时

#define CLEARCOLOR [UIColor clearColor]

#define BLACKCOLOR HTColorFromRGB(0x1e1e1e)
#define BLACK_BORDER_COLOR HTColorFromRGB(0xb3b3b3)

@interface QMPTagView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource>
{
    BOOL _lastShowStyle;
    NSString *_editCellText;
    CGFloat _editTagWidth;
    NSInteger _deleteTagIndex;
    CGFloat _topCollecHeight;
    UICollectionViewLeftAlignedLayout *_flowLayout;
    UICollectionViewLeftAlignedLayout *_bottomLayout;
    TagEditCell *_editCell;
    BOOL _selectTableCell;
}

@property(nonatomic,strong)UICollectionViewFlowLayout *layout;


@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)UICollectionView *bottomCollecView;
@property(nonatomic,strong)UITableView *tableView;


@property(nonatomic,strong)NSMutableArray *cancelSeleteArr;;

@property(nonatomic,strong)UIView *maskView;

//data
@property(nonatomic,strong)NSMutableArray *myTagArr;

@property(nonatomic,strong)NSMutableArray *searchArr;



@end


@implementation QMPTagView


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        _topCollecHeight = 56;
        _deleteTagIndex = -100;
        _editTagWidth = 90;
        _lastShowStyle = NO;
        _actionKeyboard = YES;
        _tagtitleArr = [NSMutableArray array];
        _myTagArr = [NSMutableArray array];
        _cancelSeleteArr = [NSMutableArray array];
        _editCellText = @"";
        
        [self setUI];
    }
    return self;
}

-(void)dealloc{
    @try{
        [_collectionView removeObserver:self forKeyPath:@"contentSize"];
    }
    @catch (NSException *exception) {
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


- (void)setEditArr:(NSMutableArray*)tagtitleArr myTagArr:(NSMutableArray*)myTagArr{
    self.tagtitleArr = tagtitleArr;
    self.myTagArr = myTagArr;
    
    //找出没有在我的标签里存在的可编辑标签，存在cancelSeleteArr里
    for (NSString *title in self.myTagArr) {
        if (![self.tagtitleArr containsObject:title]) {
            [self.cancelSeleteArr addObject:title];
        }
    }
    
    [_collectionView reloadData];
    [_bottomCollecView reloadData];
    
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    [_collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    if (_editCell) {
        [_editCell addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];

    }
    dispatch_after(DISPATCH_TIME_NOW+3, dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];

    });

    
}


- (void)setUI{
    
    _flowLayout  = [[UICollectionViewLeftAlignedLayout alloc]init];
    _flowLayout.minimumLineSpacing = 10;
    _flowLayout.minimumInteritemSpacing = 10;
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _flowLayout.sectionInset = UIEdgeInsetsMake(10, 17, 9, 17);
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, _topCollecHeight) collectionViewLayout:_flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self addSubview:_collectionView];
    _collectionView.bounces = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.contentSize = CGSizeMake(SCREENW, _topCollecHeight);
    _collectionView.scrollEnabled = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;

    
    [_collectionView registerClass:[TagShowCell class] forCellWithReuseIdentifier:@"ShowCell"];
    [_collectionView registerClass:[TagShowCell class] forCellWithReuseIdentifier:@"EditShowCell"];

    [_collectionView registerClass:[TagEditCell class] forCellWithReuseIdentifier:@"TagEditCell"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UICollectionViewHeaderSectionTop"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"UICollectionViewHeaderSectionFooter"];


    
    _bottomLayout  = [[UICollectionViewLeftAlignedLayout alloc]init];
    _bottomLayout.minimumLineSpacing = 10;
    _bottomLayout.minimumInteritemSpacing = 10;
    _bottomLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    _bottomCollecView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, _topCollecHeight, SCREENW, self.height - _topCollecHeight) collectionViewLayout:_bottomLayout];
    _bottomCollecView.contentInset = UIEdgeInsetsMake(10, 17, 10, 17);
    _bottomCollecView.delegate = self;
    _bottomCollecView.dataSource = self;
    [self addSubview:_bottomCollecView];
    _bottomCollecView.bounces = YES;
    _bottomCollecView.alwaysBounceVertical = YES;
    _bottomCollecView.backgroundColor = [UIColor whiteColor];
    _bottomCollecView.showsVerticalScrollIndicator = NO;
    _bottomCollecView.showsHorizontalScrollIndicator = NO;
    _bottomCollecView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCollectionView)];
    [_bottomCollecView addGestureRecognizer:tap];
  
    [_bottomCollecView registerClass:[TagShowCell class] forCellWithReuseIdentifier:@"ShowCell"];

    
    _tableView = [[UITableView alloc]initWithFrame:_bottomCollecView.frame style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SearchCellID"];
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        
        CGFloat height = [change[@"new"] CGSizeValue].height;
        if (_topCollecHeight < height) { //放大
            [UIView animateWithDuration:0.2 animations:^{
                _topCollecHeight = height + 10;
                _collectionView.height = _topCollecHeight;
                _bottomCollecView.top = _topCollecHeight;
                _bottomCollecView.height = self.height - _topCollecHeight;
            }];
            
     
        }else if(height < _topCollecHeight){ //缩小
            if(height > 27){ //大于一行
                _topCollecHeight = height + 10;

            }else{
                _topCollecHeight = 56;
            }
            
            [UIView animateWithDuration:0.2 animations:^{
                _collectionView.height = _topCollecHeight;
                _bottomCollecView.top = _topCollecHeight;
                _bottomCollecView.height = self.height - _topCollecHeight;
                
                _tableView.frame = _bottomCollecView.frame;
            }];
            
        }
    }else if([keyPath isEqualToString:@"frame"]){
        
       CGFloat rightX = _editCell.left + _editCell.width;
        if (rightX >= SCREENW) { //书写超出屏幕
            [_collectionView reloadData];
        }
    }
}


#pragma mark ---Event---
- (void)addTag:(NSString*)tagTitle  object:(QMPTagView*)tagView{
    
    //去重
    if ([tagView.tagtitleArr containsObject:tagTitle]) {
        
        NSInteger index = [tagView.tagtitleArr indexOfObject:tagTitle];
        [self.tagtitleArr removeObjectAtIndex:index];
        [self.tagtitleArr addObject:tagTitle];
        [tagView.collectionView performBatchUpdates:^{
            [self.collectionView moveItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] toIndexPath:[NSIndexPath indexPathForItem:self.tagtitleArr.count-1 inSection:0]];
        } completion:nil];
        
        
        
    }else{
        
        if ([self.myTagArr containsObject:tagTitle]) {
            [self.cancelSeleteArr removeObject:tagTitle];
        }
        [tagView.tagtitleArr addObject:tagTitle];
        [tagView.collectionView performBatchUpdates:^{
            [tagView.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.tagtitleArr.count-1 inSection:0]]];
        } completion:nil];
    }
    [tagView.collectionView reloadData];
    [tagView.bottomCollecView reloadData];
}


- (void)tapCell:(UITapGestureRecognizer*)tap{
    
    _actionKeyboard = NO;
    [self endEditing:YES];
    
    NSInteger index = 0;
    TagShowCell *cell = (TagShowCell*)tap.view;
    if (cell.tag < 2000) { //编辑标签
        
        index = cell.tag - 1000;
        
        if (_deleteTagIndex != -100 && _deleteTagIndex==index) { //取消选中
            [self cancelDeleteEditintTag]; //
            
            
        }else{
            [self cancelDeleteEditintTag]; //先取消之前选中的
            NSString *selectStr = [(UILabel*)cell.contentView.subviews[0] text];
            NSInteger strIndex = [self.tagtitleArr indexOfObject:selectStr];
            
            _deleteTagIndex = strIndex;
            
            [cell showDeleteBtn];
        }
        
        [self.collectionView reloadData];
    
    }else{
        [self cancelDeleteEditintTag];
        
        index = cell.tag - 2000;
        _lastShowStyle = NO;
        
        NSString *tapTitle = self.myTagArr[index];
        if ([self.tagtitleArr containsObject:tapTitle]) { //从我的标签里取消
            [self.cancelSeleteArr addObject:tapTitle];
            NSInteger indexs = [self.tagtitleArr indexOfObject:tapTitle];
            [self.tagtitleArr removeObject:tapTitle];
            [self.collectionView performBatchUpdates:^{
                [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:indexs inSection:0]]];
            } completion:nil];
            
        }else{
            
            [self.cancelSeleteArr removeObject:tapTitle];
            [self.tagtitleArr addObject:tapTitle];
            
            [self.collectionView performBatchUpdates:^{
                [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.tagtitleArr.count-1 inSection:0]]];
            } completion:nil];
            
        }
        
        //        [_collectionView reloadData];
        [self.bottomCollecView reloadData];
    }
    
}

//点击搜索结果
- (void)addResultToTag:(UITapGestureRecognizer*)tap{
    
    _selectTableCell = YES;
    _lastShowStyle = NO;
    _actionKeyboard = YES;
    _searchString = @"";
    [self.searchArr removeAllObjects];
    [_tableView removeFromSuperview];
    
    
    UILabel *searchResutLab = (UILabel*)tap.view;
    NSString *tagTitle = searchResutLab.text;
    //去重
    if ([self.tagtitleArr containsObject:tagTitle]) {
        
        NSInteger index = [self.tagtitleArr indexOfObject:tagTitle];
        [self.tagtitleArr removeObjectAtIndex:index];
        [self.tagtitleArr addObject:tagTitle];
        [self.collectionView moveItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] toIndexPath:[NSIndexPath indexPathForItem:self.tagtitleArr.count-1 inSection:0]];

        
    }else{
        
        if ([self.myTagArr containsObject:tagTitle]) {
            [self.cancelSeleteArr removeObject:tagTitle];
        }
        [self.tagtitleArr addObject:tagTitle];
        
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.tagtitleArr.count-1 inSection:0]]];
    }
    
    
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.tagtitleArr.count inSection:0]]];
    [self.bottomCollecView reloadData];


    
}

- (void)searchInputText{
    NSMutableArray *resultArr = [NSMutableArray array];
    for (NSString *title in self.myTagArr) {
        if ([title containsString:_searchString]) {
            [resultArr addObject:title];
        }
    }
    self.searchArr = resultArr;
    if (self.searchArr.count && !_tableView.superview) {
        [self addSubview:_tableView];
    }
    [self.tableView reloadData];
}


//取消正在编辑的标签的删除操作
- (void)cancelDeleteEditintTag{
    
    if (_tableView.superview) {
        [_tableView removeFromSuperview];
    }
    
    _deleteTagIndex = -100;
    
    for (UIView *subV in KEYWindow.subviews) {
        if ([subV isKindOfClass:[UIButton class]]) {
            [subV removeFromSuperview];
        }
    }
    
    for (TagShowCell *showCell in _collectionView.visibleCells) {
        
        if ([showCell isKindOfClass:[TagShowCell class]] && showCell.selectedFlag) {
            showCell.backgroundColor = [UIColor whiteColor];
            showCell.textColor = BLUE_TITLE_COLOR;
        }
    }
}




#pragma mark --UICollectionViewDelegate


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
   
    if (collectionView == _collectionView) {
        
        return self.tagtitleArr.count + 1;
        
    }else{
        return self.myTagArr.count;
    }
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{

    if(collectionView == _collectionView){
        if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
            UICollectionReusableView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                    withReuseIdentifier:@"UICollectionViewHeaderSectionTop"
                                                                                           forIndexPath:indexPath];
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(-20,0, SCREENW+20, 10)];
            line.backgroundColor = TABLEVIEW_COLOR;
            [headView addSubview:line];
            
            return headView;
            
        }else{
            
            //UICollectionViewHeaderSectionFooter
            UICollectionReusableView *footView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                    withReuseIdentifier:@"UICollectionViewHeaderSectionFooter"
                                                                                           forIndexPath:indexPath];
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(-20, 0, SCREENW+20, 1)];
            line.backgroundColor = LIST_LINE_COLOR;
            [footView addSubview:line];
            return footView;
        }
        
       
    }
        
    return nil;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self) weakSelf = self;

    if (collectionView == _collectionView) {
        
        if (indexPath.item == self.tagtitleArr.count) {
            TagEditCell *editCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TagEditCell" forIndexPath:indexPath];
            editCell.actionForKeyboard = _actionKeyboard;
            if (_selectTableCell) {
                [editCell clearText];
                _selectTableCell = NO;
            }
            
            editCell.addTag = ^(NSString *tagTitle) {
                _searchString = @"";

                if (_tableView.superview) {
                    [self.searchArr removeAllObjects];
                    [_tableView removeFromSuperview];
                }
                
                _lastShowStyle = NO;
                [weakSelf addTag:tagTitle object:weakSelf];
            };
            
            editCell.willDeleteLastCell = ^{
                if (self.tagtitleArr.count == 0) {
                    return ;
                }
                //最后一个showCell变样式
                _lastShowStyle = YES;
                [weakSelf.collectionView performBatchUpdates:^{
                    [weakSelf.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.tagtitleArr.count-1 inSection:0]]];
                } completion:nil];
                
                
            };
            
            editCell.deleteLastCell  = ^{
                
                if (self.tagtitleArr.count == 0) {
                    return ;
                }
                //删除一个showCell变样式
                _lastShowStyle = NO;
                NSString *title = weakSelf.tagtitleArr.lastObject;
                [self.cancelSeleteArr addObject:title];
                [weakSelf.tagtitleArr removeLastObject];

                [weakSelf.collectionView performBatchUpdates:^{
                    [weakSelf.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:weakSelf.tagtitleArr.count  inSection:0]]];
                } completion:nil];

                
                [weakSelf.bottomCollecView reloadData];

                
            };
            
            
            editCell.textChanged = ^(NSString *text) {
                
                if (_lastShowStyle) {
                    _lastShowStyle = NO;
                    [weakSelf.collectionView performBatchUpdates:^{
                        [weakSelf.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:weakSelf.tagtitleArr.count-1 inSection:0]]];
                    } completion:nil];
                }
                
                if (_deleteTagIndex != -100) {
                    [weakSelf cancelDeleteEditintTag];
                    [weakSelf.collectionView reloadData];
                }
                if (!_tableView.superview && self.searchArr.count && text.length) {
                    [weakSelf addSubview:weakSelf.tableView];
                }else if(_tableView.superview){
                    _searchString = @"";
                    weakSelf.searchArr = [NSMutableArray array];
                    [weakSelf.tableView removeFromSuperview];
                }
                
                if (text.length) {
                    _searchString = text;
                    [weakSelf searchInputText];
                }

            };
            
            [editCell becomesFirstResponder];
            _editCell = editCell;
            return editCell;
            
        }else{
            
            
            TagShowCell *showCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EditShowCell" forIndexPath:indexPath];
            showCell.layer.borderColor = RGBBlueColor.CGColor;

            showCell.title = self.tagtitleArr[indexPath.item];
        
            showCell.deleteCell = ^{
                
                if (_deleteTagIndex >= weakSelf.tagtitleArr.count) {
                    return ;
                }
                NSString *title = weakSelf.tagtitleArr[_deleteTagIndex];
                _deleteTagIndex = -100;

                if ([weakSelf.myTagArr containsObject:title]) {
                    [weakSelf.cancelSeleteArr addObject:title];
                }
                NSInteger index = [weakSelf.tagtitleArr indexOfObject:title];
                [weakSelf.tagtitleArr removeObject:title];
                
//                [weakSelf.collectionView performBatchUpdates:^{
//                    [weakSelf.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index  inSection:0]]];
//                } completion:nil];
                
                [weakSelf.collectionView reloadData];
                [weakSelf.bottomCollecView reloadData];
            };
            
            if ((indexPath.item == self.tagtitleArr.count-1 && _lastShowStyle) || _deleteTagIndex == indexPath.item) {
                
                showCell.backgroundColor = RGBBlueColor;
                showCell.textColor = [UIColor whiteColor];
                showCell.selectedFlag = YES;
                
            }else{
                
                showCell.selectedFlag = NO;

                showCell.backgroundColor = [UIColor whiteColor];
                showCell.textColor = BLUE_TITLE_COLOR;
                
            }
           
            //自己加点击方法
            showCell.tag = 1000 +indexPath.row;
            [showCell addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCell:)]];
            
            return showCell;
        }

    }else{
        
        TagShowCell *myTagCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ShowCell" forIndexPath:indexPath];
        NSString *title = self.myTagArr[indexPath.item];
        myTagCell.title = title;
        
        if ([self.cancelSeleteArr containsObject:title]) { //取消选中，背景变灰
            myTagCell.backgroundColor = [UIColor whiteColor];
            myTagCell.textColor = H5COLOR;
            myTagCell.layer.borderColor = BORDER_LINE_COLOR.CGColor;
            
        }else{
            myTagCell.backgroundColor = [UIColor whiteColor];
            myTagCell.textColor = BLUE_TITLE_COLOR;
            myTagCell.layer.borderColor = RGBBlueColor.CGColor;

        }
        
        //自己加点击方法
        myTagCell.tag = 2000 +indexPath.row;
        [myTagCell addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCell:)]];
    
        return myTagCell;
    }
    
    return nil;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
 
    [self cancelDeleteEditintTag];
    _actionKeyboard = NO;
}

#pragma mark  --UICollectionViewFlawLayout---

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 15;
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == _collectionView) {
        if (indexPath.item == self.tagtitleArr.count) { //最后一个编辑标签
//            return CGSizeMake(SCREENW, TAGHEIGHT);
 
            CGFloat width = [PublicTool widthOfString:_searchString height:CGFLOAT_MAX fontSize:14];
            width = width>90 ? width+20 : 90;
            return CGSizeMake(width, TAGHEIGHT);
            
//            return CGSizeMake(_editTagWidth, TAGHEIGHT);

            
        }else{
            
            NSString *title = self.tagtitleArr[indexPath.item];
            CGFloat strWidth = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, TAGHEIGHT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size.width;
            return CGSizeMake(strWidth+20, TAGHEIGHT);
            
        }

    }else{
    
        NSString *title = self.myTagArr[indexPath.item];
        CGFloat strWidth = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, TAGHEIGHT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size.width;
        return CGSizeMake(strWidth+20, TAGHEIGHT);
    }
    
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {

    if(collectionView == _collectionView){
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, 10);

    }
        
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if(collectionView == _collectionView){
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, 1);
    }
    
    return CGSizeZero;
}




#pragma mark  --UITabelViewDelegate--
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.searchArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *searchCell = [tableView dequeueReusableCellWithIdentifier:@"SearchCellID" forIndexPath:indexPath];
    searchCell.backgroundColor = [UIColor whiteColor];
    UILabel *titleLab = [searchCell.contentView viewWithTag:333];
    if (!titleLab) {
        titleLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, SCREENW-34, 45)];
        titleLab.font  =[UIFont systemFontOfSize:14];
        titleLab.textColor = [UIColor blackColor];
        titleLab.tag = 333;
        [searchCell.contentView addSubview:titleLab];
        titleLab.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addResultToTag:)];
        [titleLab addGestureRecognizer:tap];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 44.5, SCREENW, 0.5)];
        line.backgroundColor = LIST_LINE_COLOR;
        [searchCell addSubview:line];
    }
    
    NSString *resultStr = self.searchArr[indexPath.row];
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:resultStr];
    NSRange range = [resultStr rangeOfString:_searchString];
    [attText addAttributes:@{NSForegroundColorAttributeName:BLUE_TITLE_COLOR} range:range];
    titleLab.attributedText = attText;
    searchCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return searchCell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    _lastShowStyle = NO;
    NSString *tagTitle = self.searchArr[indexPath.row];
    
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self cancelDeleteEditintTag];

    _actionKeyboard = NO;
    _deleteTagIndex = -100;

}

- (void)keyboardWillShow{
    
    [self cancelDeleteEditintTag];

}

- (void)keyboardWillHide{
    
//    [self cancelDeleteEditintTag];
//    _actionKeyboard = NO;
}
- (void)tapCollectionView{
    
    [self endEditing:YES];
    [self cancelDeleteEditintTag];

}

@end
