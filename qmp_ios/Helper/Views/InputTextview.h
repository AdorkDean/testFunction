//
//  InputTextview.h
//  qmp_ios
//
//  Created by molly on 2017/3/24.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol InputTextviewDelegate<NSObject>
- (void)inputTextViewChange:(NSString *)text;
- (void)inputTextViewBeginEditing;
@end

@interface InputTextview : UIView

@property (strong, nonatomic) UITextView *textView;
@property (weak, nonatomic) id <InputTextviewDelegate> delegate;

@property (copy, nonatomic) NSString *flag;//如果不为nil, 说明为爆料; =1 公司爆料 , =2 机构爆料
@property (copy, nonatomic) NSString *module;//更多反馈的模块

- (void)toSetPlaceholderlblText;
@end
