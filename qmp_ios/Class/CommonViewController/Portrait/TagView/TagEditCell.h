//
//  TagEditCell.h
//  TestPod
//
//  Created by QMP on 2017/8/28.
//  Copyright © 2017年 WSS. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TagEditCell : UICollectionViewCell



@property (copy, nonatomic) void(^willDeleteLastCell)(void);
@property (copy, nonatomic) void(^deleteLastCell)(void);
@property (copy, nonatomic) void(^addTag)(NSString *tagTitle);
@property (copy, nonatomic) void(^textChanged)(NSString *text);

@property(nonatomic,assign) BOOL actionForKeyboard;

- (void)becomesFirstResponder;
- (void)clearText;

@end
