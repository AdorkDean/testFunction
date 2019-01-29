//
//  QMPSetupCategoryViewController.m
//  CommonLibrary
//
//  Created by QMP on 2018/12/6.
//  Copyright © 2018 WSS. All rights reserved.
//

#import "QMPSetupCategoryViewController.h"
#import "QMPCategoryItem.h"
@interface QMPSetupCategoryViewController ()
@property (nonatomic, assign) CGPoint startP;
@property (nonatomic, assign) CGPoint buttonP;
@property (nonatomic, strong) NSMutableArray *buttons;

@property (nonatomic, strong) NSMutableArray *myCategorys;
@property (nonatomic, strong) NSMutableArray *lastCategorys;

@property (nonatomic, strong) UIView *myCategoryView;
@property (nonatomic, strong) UIView *myCategoryContentView;
@property (nonatomic, strong) UIView *lastCategoryView;
@property (nonatomic, strong) UIView *lastCategoryContentView;
@end

@implementation QMPSetupCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupViews];
}
- (void)closeButtonClick {
    if (self.cateGrayDidSetup && [self categrayChange]) {
        self.cateGrayDidSetup(self.myCategorys);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)setShowCategorys:(NSMutableArray *)showCategorys {
    _showCategorys = showCategorys;
    self.myCategorys = [NSMutableArray arrayWithArray:showCategorys];
    
    [self reloadMyCategory];
}
- (void)setAllCategorys:(NSMutableArray *)allCategorys {
    _allCategorys = allCategorys;
    
    [self reloadLastCategory];
}
- (void)reloadMyCategory {
    
    [self.myCategoryContentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.buttons = [NSMutableArray array];
//    NSInteger i = 0;
    CGFloat l = 17;
    CGFloat m = 16;
    CGFloat w = (SCREENW - l *2 - m * 2)/3.0;
    CGFloat h = 34;
//    for (NSDictionary *dict in self.myCategorys) {
    for (NSInteger i = 0; i < self.myCategorys.count; i++) {
        NSInteger col = i % 3;
        NSInteger row = i / 3;
//        if (i == 0) {
//            QMPCategoryItem *item1 = [[QMPCategoryItem alloc] init];
//            [item1 setTitle:@"推荐" forState:UIControlStateNormal];
//            item1.frame = CGRectMake(17+w*col+m*col, 10+h*row+m*row, w, h);
//            [item1 setTitleColor:H3COLOR forState:UIControlStateNormal];
//            item1.backgroundColor = HTColorFromRGB(0xF5F5F5);
//            item1.titleLabel.font = [UIFont systemFontOfSize:14];
//            [self.myCategoryContentView addSubview:item1];
//            continue;
//        }
        
        NSDictionary *dict = self.myCategorys[i];
        NSString *ticket = dict[@"ticket"];
        
        QMPCategoryItem *item = [[QMPCategoryItem alloc] init];
        [item setTitle:dict[@"name"] forState:UIControlStateNormal];
        [item setTitleColor:H3COLOR forState:UIControlStateNormal];
        item.titleLabel.font = [UIFont systemFontOfSize:14];
        item.backgroundColor = HTColorFromRGB(0xF5F5F5);
        item.frame = CGRectMake(17+w*col+m*col, 10+h*row+m*row, w, h);
        if (ticket.length == 1) {
            item.deleteView.hidden = YES;
        } else {
            item.deleteView.hidden = NO;
        }
        
        [item addTarget:self action:@selector(myItemClick:) forControlEvents:UIControlEventTouchUpInside];
        item.tag = i;
        UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(itemButtonLongPress:)];
        [item addGestureRecognizer:longPressGest];
        [self.myCategoryContentView addSubview:item];
        [self.buttons addObject:item];
    
    }
    NSInteger rows = (self.myCategorys.count) / 3 + 1;
    if ((self.myCategorys.count) % 3 == 0) {
        rows -= 1;
    }
    self.myCategoryContentView.height = 10 + rows * h+ (rows-1)*m + 20;
    self.myCategoryView.height = self.myCategoryContentView.height + 30;
    self.lastCategoryView.top = self.myCategoryView.bottom + 15;
}

- (void)myItemClick:(QMPCategoryItem *)item {
    if (self.myCategorys.count <= 1) {
        [PublicTool showMsg:@"至少保留一个分类"];
        return;
    }
    NSDictionary *dict = self.myCategorys[item.tag];
    NSString *ticket = dict[@"ticket"];
    if (ticket.length == 1) {
        return;
    }
    
    [self.myCategorys removeObjectAtIndex:item.tag];
    [self reloadMyCategory];
    [self reloadLastCategory];
}
- (void)lastItemClick:(QMPCategoryItem *)item {
    NSDictionary *dict = self.lastCategorys[item.tag];
    [self.myCategorys addObject:dict];
    [self reloadMyCategory];
    [self reloadLastCategory];
}
- (void)reloadLastCategory {
    
    [self.lastCategoryContentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.lastCategorys = nil;
    
    NSInteger i = 0;
    CGFloat l = 17;
    CGFloat m = 16;
    CGFloat w = (SCREENW - l *2 - m * 2)/3.0;
    CGFloat h = 34;
    for (NSDictionary *dict in self.allCategorys) {
        if ([self allContainsCategray:dict]) {
            continue;
        }
        NSInteger col = i % 3;
        NSInteger row = i / 3;
        QMPCategoryItem *item = [[QMPCategoryItem alloc] init];
        [item setTitle:dict[@"name"] forState:UIControlStateNormal];
        [item setTitleColor:H3COLOR forState:UIControlStateNormal];
        item.titleLabel.font = [UIFont systemFontOfSize:14];
        item.backgroundColor = HTColorFromRGB(0xF5F5F5);
        item.frame = CGRectMake(17+w*col+m*col, 10+h*row+m*row, w, h);
        [item addTarget:self action:@selector(lastItemClick:) forControlEvents:UIControlEventTouchUpInside];
        item.tag = i;
        [self.lastCategoryContentView addSubview:item];
        i++;
        [self.lastCategorys addObject:dict];
    }
    NSInteger rows = i / 3 + 1;
    if (i % 3 == 0) {
        rows -= 1;
    }
    self.lastCategoryContentView.height = 10 + rows * h+ (rows-1)*m + 20;
    self.lastCategoryView.height = self.lastCategoryContentView.height + 30;
}
- (BOOL)allContainsCategray:(NSDictionary *)d {
    for (NSDictionary *dict in self.myCategorys) {
        if ([dict[@"name"] isEqualToString:d[@"name"]]) {
            return YES;
        }
    }
    return NO;
}
- (void)setupViews {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(SCREENW-40-9, kScreenTopHeight-40-2, 40, 40);
    [button setImage:[UIImage imageNamed:@"category_close"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"category_close"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    [self.view addSubview:self.myCategoryView];
    [self.myCategoryView addSubview:self.myCategoryContentView];
    [self.view addSubview:self.lastCategoryView];
    [self.lastCategoryView addSubview:self.lastCategoryContentView];
}

- (UIView *)myCategoryView {
    if (!_myCategoryView) {
        _myCategoryView = [[UIView alloc] init];
        _myCategoryView.frame = CGRectMake(0, kScreenTopHeight, SCREENW, 200);
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(17, 8, 90, 20);
        label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        label.textColor = H3COLOR;
        label.text = @"我的分类";
        [_myCategoryView addSubview:label];
        
        UILabel *label2 = [[UILabel alloc] init];
        label2.frame = CGRectMake(91, 11, 100, 17);
        label2.font = [UIFont systemFontOfSize:13];
        label2.textColor = H9COLOR;
        label2.text = @"长按可拖动顺序";
        [_myCategoryView addSubview:label2];
        
    }
    return _myCategoryView;
}
- (UIView *)myCategoryContentView {
    if (!_myCategoryContentView) {
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, 30, SCREENW, 200);
        _myCategoryContentView = view;
    }
    return _myCategoryContentView;
}
- (UIView *)lastCategoryContentView {
    if (!_lastCategoryContentView) {
        _lastCategoryContentView = [[UIView alloc] init];
        _lastCategoryContentView.frame = CGRectMake(0, 30, SCREENW, 200);
    }
    return _lastCategoryContentView;
}
- (UIView *)lastCategoryView {
    if (!_lastCategoryView) {
        _lastCategoryView = [[UIView alloc] init];
        _lastCategoryView.frame = CGRectMake(0, kScreenTopHeight+200, SCREENW, 200);
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(17, 8, 90, 20);
        label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        label.textColor = H3COLOR;
        label.text = @"全部分类";
        [_lastCategoryView addSubview:label];
        
        UILabel *label2 = [[UILabel alloc] init];
        label2.frame = CGRectMake(91, 11, 150, 17);
        label2.font = [UIFont systemFontOfSize:13];
        label2.textColor = H9COLOR;
        label2.text = @"点击添加至我的分类";
        [_lastCategoryView addSubview:label2];
        
    }
    return _lastCategoryView;
}
- (NSMutableArray *)lastCategorys {
    if (!_lastCategorys) {
        _lastCategorys = [NSMutableArray array];
    }
    return _lastCategorys;
}

- (void)itemButtonLongPress:(UILongPressGestureRecognizer *)longPressGest {
    
    QMPCategoryItem *currentButton = (QMPCategoryItem *)longPressGest.view;
    
    
    if (UIGestureRecognizerStateBegan == longPressGest.state) {
        [UIView animateWithDuration:0.2 animations:^{
            currentButton.transform = CGAffineTransformScale(currentButton.transform, 1.2, 1.2);
//            currentButton.deleteView.hidden = YES;
            [self.myCategoryContentView bringSubviewToFront:currentButton];
            _startP = [longPressGest locationInView:currentButton];
            _buttonP = currentButton.center;
        }];
    }
    
    
    if (UIGestureRecognizerStateChanged == longPressGest.state) {
        CGPoint newP = [longPressGest locationInView:currentButton];
        CGFloat movedX = newP.x - _startP.x;
        CGFloat movedY = newP.y - _startP.y;
        currentButton.center = CGPointMake(currentButton.center.x + movedX, currentButton.center.y + movedY);
        
        // 获取当前按钮的索引
        NSInteger fromIndex = currentButton.tag;
        // 获取目标移动索引
        NSInteger toIndex = [self getMovedIndexByCurrentButton:currentButton];
        
        if (toIndex < 0) {
            return;
        } else {
            
            currentButton.tag = toIndex;
            // 按钮向后移动
            if (fromIndex < toIndex) {
                
                for (NSInteger i = fromIndex; i < toIndex; i++) {
                    // 拿到下一个按钮
                    UIButton * nextBtn = self.buttons[i + 1];
                    CGPoint tempP = nextBtn.center;
                    [UIView animateWithDuration:0.5 animations:^{
                        nextBtn.center = _buttonP;
                    }];
                    _buttonP = tempP;
                    nextBtn.tag = i;
                }
                [self sortArray];
            } else if(fromIndex > toIndex) { // 按钮向前移动
                
                for (NSInteger i = fromIndex; i > toIndex; i--) {
                    UIButton * previousBtn = self.buttons[i - 1];
                    CGPoint tempP = previousBtn.center;
                    [UIView animateWithDuration:0.5 animations:^{
                        previousBtn.center = _buttonP;
                    }];
                    _buttonP = tempP;
                    previousBtn.tag = i;
                }
                [self sortArray];
            }
        }
        
    }
    
    if (UIGestureRecognizerStateEnded == longPressGest.state) {
        [UIView animateWithDuration:0.2 animations:^{
            currentButton.transform = CGAffineTransformIdentity;
            currentButton.center = _buttonP;
            [currentButton setNeedsLayout];
//            NSLog(@"%@", dict[@"name"]);
//            if (ticket.length == 1) {
//                NSLog(@"123");
//                currentButton.deleteView.hidden = YES;
//            } else {
//                NSLog(@"456");
//                currentButton.deleteView.hidden = NO;
//            }
        }];
        [self updateTitleData];
    }
    
}
- (void)sortArray {
    // 对已改变按钮的数组进行排序
    [_buttons sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        UIButton *temp1 = (UIButton *)obj1;
        UIButton *temp2 = (UIButton *)obj2;
        return temp1.tag > temp2.tag;    // 将tag值大的按钮向后移
    }];
}
- (NSInteger)getMovedIndexByCurrentButton:(UIButton *)currentButton {
    for (NSInteger i = 0; i<self.buttons.count ; i++) {
        UIButton * button = self.buttons[i];
        if (!currentButton || button != currentButton) {
            if (CGRectContainsPoint(button.frame, currentButton.center)) {
                return i;
            }
        }
    }
    return -1;
}
- (void)updateTitleData {
    
    NSMutableArray *mArr = [NSMutableArray array];
    NSInteger index = 0;
    for (UIButton *button in self.buttons) {
        NSDictionary *dict = [self dictWithTitle:button.currentTitle];
        if (!dict) {
            continue;
        }
        [mArr addObject:dict];
        index++;
    }
    self.myCategorys = mArr;
}
- (NSDictionary *)dictWithTitle:(NSString *)title {
    for (NSDictionary *dict in self.myCategorys) {
        if ([dict[@"name"] isEqualToString:title]) {
            return dict;
        }
    }
    return nil;
}
- (BOOL)categrayChange {
    if (self.myCategorys.count != self.showCategorys.count) {
        return YES;
    }
    for (int i = 0; i < self.myCategorys.count; i++) {
        NSDictionary *dict = self.myCategorys[i];
        NSDictionary *dict2 = self.showCategorys[i];
        if (![dict[@"name"] isEqualToString:dict2[@"name"]]) {
            return YES;
        }
    }
    return NO;
}
@end
