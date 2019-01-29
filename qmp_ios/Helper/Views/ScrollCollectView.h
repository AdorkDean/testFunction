//
//  ScrollCollectView.h
//  qmp_ios
//
//  Created by QMP on 2018/6/11.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollCollectView : UIView
@property(nonatomic,strong)UICollectionView *collectionV;

@property(nonatomic,strong) UIColor *selectTitleColor;
@property(nonatomic,strong) UIColor *unSelectTitleColor;

@property(nonatomic,strong)NSArray *dataArr;
@property(nonatomic,strong)NSArray *imageArr;


- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray*)titles  images:(NSArray*)images didSelectedItem:(void(^)(NSString *title))didSelectItem;

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray*)titles  images:(NSArray*)images selectedImages:(NSArray*)selectedImages didSelectedItem:(void(^)(NSString *title))didSelectItem;

- (void)setSelectedMenu:(NSString*)menuTitle;

@end
