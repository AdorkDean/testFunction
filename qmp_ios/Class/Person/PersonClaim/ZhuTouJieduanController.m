//
//  ZhuTouJieduanController.m
//  qmp_ios
//
//  Created by QMP on 2018/3/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ZhuTouJieduanController.h"
#import "AreaCollCell.h"
#import "SearchComController.h"

@interface ZhuTouJieduanController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    BOOL update;
}
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *selArr;
@property(nonatomic,strong)NSMutableArray *noSelArr;


@end

@implementation ZhuTouJieduanController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![PublicTool isNull:self.originalJieduan] && self.originalJieduan.length>0) {
        NSArray *arr = [self.originalJieduan componentsSeparatedByString:@"|"];
        if (arr.count) {
            self.selArr = [NSMutableArray arrayWithArray:arr];
        }
    }else{
        self.selArr = [NSMutableArray array];
    }
    
    NSMutableArray *total = [NSMutableArray arrayWithObjects:@"种子轮",@"天使轮",@"Pre-A轮",@"A轮",@"A+轮",@"Pre-B轮",@"B轮",@"B+轮",@"C轮",@"C+轮",@"D轮～Pre-IPO",nil];
    [total removeObjectsInArray:self.selArr];
    self.noSelArr = total;
    
    [self addView];
    NSString *text = ![PublicTool isNull:self.companyM.product] ? @"投资轮次":@"主投阶段";

    self.title = text;

}

- (void)addView{
    
    CGFloat top = 0;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 20;
    layout.minimumInteritemSpacing = 15;
    layout.sectionInset = UIEdgeInsetsMake(20, 17, 25, 17);
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, top, SCREENW, SCREENH - kScreenTopHeight-top) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[AreaCollCell class] forCellWithReuseIdentifier:@"AreaCollCellID"];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellID"];
    
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerID"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerID"];
    
    [self.view addSubview:self.collectionView];
    
    UIButton *finishBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 47, 44)];
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [finishBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    finishBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [finishBtn addTarget:self action:@selector(finishBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:finishBtn];
}


- (void)finishBtnClick{
   
    NSString *jieduan = @"";
    if (self.selArr.count) {
        jieduan = [self.selArr componentsJoinedByString:@"|"];
        
        if (self.selectedJieDuan && !self.companyM) {
            if ([[jieduan substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"|"]) {
                jieduan = [jieduan substringFromIndex:1];
            }
            self.selectedJieDuan(jieduan);
            [self.navigationController popViewControllerAnimated:YES];
        
        }else if(self.companyM){ //投资案例 投资轮次
            SearchComController *searchVC = self.navigationController.childViewControllers[self.navigationController.childViewControllers.count-2];
            if (searchVC.didSelected) {
                self.companyM.tzLunci = jieduan;
                searchVC.didSelected (self.companyM);
                [self.navigationController popToViewController:self.navigationController.childViewControllers[self.navigationController.childViewControllers.count-3] animated:YES];
            }
            
        }
    }else{
        if (self.selectedJieDuan && !self.companyM) {
    
            self.selectedJieDuan(@"");
            [self.navigationController popViewControllerAnimated:YES];
            
        }else if(self.companyM){ //投资案例 投资轮次
            SearchComController *searchVC = self.navigationController.childViewControllers[self.navigationController.childViewControllers.count-2];
            if (searchVC.didSelected) {
                self.companyM.tzLunci = @"";
                searchVC.didSelected (self.companyM);
                [self.navigationController popToViewController:self.navigationController.childViewControllers[self.navigationController.childViewControllers.count-3] animated:YES];
            }
            
        }
    }
}


#pragma mark --UICollectionViewDelegate--

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title;
    if (indexPath.section == 0 && self.selArr.count) {
        title = self.selArr[indexPath.item];
    }else if(indexPath.section == 1 && self.noSelArr.count){
        title = self.noSelArr[indexPath.item];
    }
    if (![PublicTool isNull:title]) {
        
        CGFloat w = (SCREENW - 17*2 - 15*3) / 4;
        
        return CGSizeMake(w, 39);
    }else{
        return CGSizeMake(SCREENW-34, 50);
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return  2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (section == 0 && self.selArr.count) {
        return self.selArr.count;
    }else if (section == 1 && self.noSelArr.count){
        return self.noSelArr.count;
    }
    return 1;
}
- (void)haha:(UITapGestureRecognizer *)tap {
    AreaCollCell *cell = (AreaCollCell *)tap.view.superview;
    
    UICollectionView *collectionView =self.collectionView;
    
    NSIndexPath *indexPath = [collectionView indexPathForCell:cell];
    NSString *title = cell.titleLab.currentTitle;
    if ([self.selArr containsObject:title]) {
        indexPath = [NSIndexPath indexPathForRow:[self.selArr indexOfObject:title] inSection:0];
    } else if ([self.noSelArr containsObject:title]) {
        indexPath = [NSIndexPath indexPathForRow:[self.noSelArr indexOfObject:title] inSection:1];
    }
    
    if (indexPath.section == 0 && self.selArr.count) {
        
        if ([self.selArr[indexPath.row] isEqualToString:@"推荐"]) {
            return ;
        }
        update = YES;
        [self.noSelArr insertObject:self.selArr[indexPath.row] atIndex:0];
        [self.selArr removeObjectAtIndex:indexPath.row];
        if (self.noSelArr.count == 1) {
            [collectionView reloadData];
            
        }else{
            if (self.selArr.count == 0) {
                [collectionView reloadData];
            }else{
                [collectionView moveItemAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
                [collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:1]]];
            }
        }
        
    }else if (indexPath.section == 1 && self.noSelArr.count){
        update = YES;
        
        [self.selArr addObject:self.noSelArr[indexPath.row]];
        [self.noSelArr removeObjectAtIndex:indexPath.row];
        if (self.selArr.count == 1) {
            [collectionView reloadData];
            
        }else{
            if (self.noSelArr.count == 0) {
                [collectionView reloadData];
            }else{
                [collectionView moveItemAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForItem:self.selArr.count-1 inSection:0]];
                [collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.selArr.count-1 inSection:0]]];
                
            }
            
        }
        
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && self.selArr.count) {
        AreaCollCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AreaCollCellID" forIndexPath:indexPath];
        [cell showAddIcon:NO text:self.selArr[indexPath.row]];
        
        cell.chaIcon.hidden = NO;
        [cell.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(haha:)]];

        return cell;
        
    }else if (indexPath.section == 1 && self.noSelArr.count){
        
        AreaCollCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AreaCollCellID" forIndexPath:indexPath];
        [cell showAddIcon:YES text:self.noSelArr[indexPath.row]];
        cell.chaIcon.hidden = YES;
        [cell.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(haha:)]];

        
        return cell;
    }
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    UILabel *titleLab = [cell.contentView viewWithTag:200];
    if (!titleLab) {
        titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
        [titleLab labelWithFontSize:14 textColor:H9COLOR];
        titleLab.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:titleLab];
        titleLab.center = CGPointMake(cell.contentView.width/2.0, cell.contentView.height/2.0);
        titleLab.tag = 200;
    }
    NSString *text = self.companyM ? @"未选投资轮次":@"未选主投阶段";
    titleLab.text =  indexPath.section == 0 ? text:@"已全选";
    
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return CGSizeMake(SCREENW, 40);
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *headerV = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerID" forIndexPath:indexPath];
        UIView *line = [headerV viewWithTag:900];
        if (!line) {
            line = [[UIView alloc]initWithFrame:CGRectMake(17, 0, SCREENW - 34, 0.5)];
            line.backgroundColor = LIST_LINE_COLOR;
            [headerV addSubview:line];
            line.tag = 900;
        }
        UILabel *titleLab = [headerV viewWithTag:1000];
        if (!titleLab) {
            titleLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 25, 60, 15)];
            titleLab.textColor = H5COLOR;
            if (@available(iOS 8.2, *)) {
                titleLab.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
            }else{
                titleLab.font = [UIFont systemFontOfSize:15];
            }
            [headerV addSubview:titleLab];
            titleLab.tag = 1000;
        }
        
        UILabel *rightLab = [headerV viewWithTag:1003];
        if (!rightLab) {
            rightLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREENW - 17 - 150, 0, 150, 21)];
            rightLab.textColor = H9COLOR;
            rightLab.textAlignment = NSTextAlignmentRight;
            rightLab.font = [UIFont systemFontOfSize:12];
            [headerV addSubview:rightLab];
            rightLab.tag = 1003;
            rightLab.centerY = titleLab.centerY;
        }
        if (indexPath.section == 0) {
            titleLab.text = @"已选";
            rightLab.hidden = YES;
            line.hidden = YES;
            
        }else if (indexPath.section == 1) {
            line.hidden = NO;
            titleLab.text = @"未选";
            //            btn.hidden = YES;
            rightLab.hidden = NO;
            NSString *text = self.companyM ? @"点击添加投资轮次":@"点击添加主投阶段";

            rightLab.text = text;
        }
        return headerV;
    }
    return nil;
    
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (indexPath.section == 0 && self.selArr.count) {
//
//        if ([self.selArr[indexPath.row] isEqualToString:@"推荐"]) {
//            return ;
//        }
//        update = YES;
//        [self.noSelArr insertObject:self.selArr[indexPath.row] atIndex:0];
//        [self.selArr removeObjectAtIndex:indexPath.row];
//        if (self.noSelArr.count == 1) {
//            [collectionView reloadData];
//
//        }else{
//            if (self.selArr.count == 0) {
//                [collectionView reloadData];
//            }else{
//                [collectionView moveItemAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
//                [collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:1]]];
//            }
//        }
//
//    }else if (indexPath.section == 1 && self.noSelArr.count){
//        update = YES;
//
//        [self.selArr addObject:self.noSelArr[indexPath.row]];
//        [self.noSelArr removeObjectAtIndex:indexPath.row];
//        if (self.selArr.count == 1) {
//            [collectionView reloadData];
//
//        }else{
//            if (self.noSelArr.count == 0) {
//                [collectionView reloadData];
//            }else{
//                [collectionView moveItemAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForItem:self.selArr.count-1 inSection:0]];
//                [collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.selArr.count-1 inSection:0]]];
//
//            }
//
//        }
//
//    }
}

#pragma mark --懒加载

-(NSMutableArray *)selArr{
    if (!_selArr) {
        _selArr = [NSMutableArray array];
    }
    return _selArr;
}

-(NSMutableArray *)noSelArr{
    if (!_noSelArr) {
        _noSelArr = [NSMutableArray array];
    }
    return _noSelArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
