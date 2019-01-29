//
//  LrdOutputView.h
//  LrdOutputView
//
//  Created by 键盘上的舞者 on 4/14/16.
//  Copyright © 2016 键盘上的舞者. All rights reserved.
//2017-10-20 变成白色底 灰色圆角框线

#import <UIKit/UIKit.h>

@protocol LrdOutputViewDelegate <NSObject>

@optional
- (void)didSelectedAtIndexPath:(NSIndexPath *)indexPath ofAction:(NSString *)action;
- (void)didSelectedAtIndexPath:(NSIndexPath *)indexPath;
@end

typedef void(^dismissWithOperation)(void);

typedef NS_ENUM(NSUInteger, LrdOutputViewDirection) {
    kLrdOutputViewDirectionLeft = 1,
    kLrdOutputViewDirectionRight,
    kLrdOutputViewDirectionBottomLeft,
    kLrdOutputViewDirectionBottomRight
};

@interface LrdOutputView : UIView

@property (nonatomic, weak) id<LrdOutputViewDelegate> delegate;
@property (nonatomic, strong) dismissWithOperation dismissOperation;
@property (nonatomic, strong) UIColor *separatorColor;
@property (nonatomic, strong) UIColor *listColor;


//初始化方法
- (instancetype)initWithDataArray:(NSArray *)dataArray
                           origin:(CGPoint)origin
                            width:(CGFloat)width
                           height:(CGFloat)height
                        direction:(LrdOutputViewDirection)direction
                           hasImg:(BOOL)hasImg;
//传入参数：模型数组，弹出原点，宽度，高度（每个cell的高度）
- (instancetype)initWithDataArray:(NSArray *)dataArray
                           origin:(CGPoint)origin
                            width:(CGFloat)width
                           height:(CGFloat)height
                        direction:(LrdOutputViewDirection)direction
                         ofAction:(NSString *)action
                           hasImg:(BOOL)hasImg;

/**
 *  初始化方法
 *
 *  @param dataArray       模型数组
 *  @param origin          弹出原点
 *  @param tableViewOrigin tableView的左(右)下角/左(右)上角坐标
 *  @param width           宽
 *  @param height          高
 *  @param direction       三角形所在位置
 *  @param action          action 标识,当一个页面有多个弹窗时,根据action确定具体是哪个弹窗
 *
 *  @return 
 */
- (instancetype)initWithDataArray:(NSArray *)dataArray
                           origin:(CGPoint)origin
                  viewLeftBottomLocation:(CGPoint)viewLeftBottomLocation
                            width:(CGFloat)width
                           height:(CGFloat)height
                          screenH:(CGFloat)screenH
                        direction:(LrdOutputViewDirection)direction
                         ofAction:(NSString *)action
                           hasImg:(BOOL)hasImg;

//弹出
- (void)pop;
- (void)popFromBottom;
//消失
- (void)dismiss;

@end


@interface LrdCellModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *imageName;

- (instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName;

@end
