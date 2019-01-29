//
//  IntroduceCellLayout.h
//  qmp_ios
//
//  Created by QMP on 2018/6/29.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYTextLayout.h>


@interface IntroduceCellLayout : NSObject

/**传入字典
 content:  spread: 文本和是否展开
 */
- (instancetype)initWithIntroduce:(NSMutableDictionary *)introduceInfoDic;

@property(nonatomic,strong)NSMutableDictionary *introduceInfoDic;
@property(nonatomic,assign)CGFloat cellHeight;
@property(nonatomic,assign)BOOL isNeedExplored;
@property(nonatomic,assign)CGFloat height;
@property(nonatomic,strong)YYTextLayout *textLayout;
- (void)layout;

@end
