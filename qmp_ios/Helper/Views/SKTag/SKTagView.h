//
//  SKTagView.h
//
//  Created by Shaokang Zhao on 15/1/12.
//  Copyright (c) 2015 Shaokang Zhao. All rights reserved.


//内部加了自己的代码，原库  https://github.com/DeftMKJ/SKTag

#import <UIKit/UIKit.h>
#import "SKTag.h"
#import "SKTagButton.h"

@interface SKTagView : UIView

@property (assign, nonatomic) UIEdgeInsets padding;
@property (assign, nonatomic) CGFloat lineSpacing;
@property (assign, nonatomic) CGFloat interitemSpacing;
@property (assign, nonatomic) CGFloat preferredMaxLayoutWidth;
@property (assign, nonatomic) CGFloat regularWidth; //!< 固定宽度
@property (nonatomic,assign ) CGFloat regularHeight; //!< 固定高度
@property (assign, nonatomic) BOOL singleLine;
@property (copy, nonatomic, nullable) void (^didTapTagAtIndex)(NSUInteger index);

- (void)addTag: (nonnull SKTag *)tag;
- (void)insertTag: (nonnull SKTag *)tag atIndex:(NSUInteger)index;
- (void)removeTag: (nonnull SKTag *)tag;
- (void)removeTagAtIndex: (NSUInteger)index;
- (void)removeAllTags;

//自加代码
- (void)onTag: (SKTagButton *_Nullable)btn;

@end

