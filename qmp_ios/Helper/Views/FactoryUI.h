

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FactoryUI : NSObject

//工厂指的是大批量生产零件的地方，映射到项目中，就是利用静态方法将常用控件的常用属性做一总结归纳，方便统一修改

//UIView
+(UIView *)createViewWithFrame:(CGRect)frame;

//UILabel
+ (UILabel *)createLabelWithFrame:(CGRect )frame text:(NSString *)text font:(UIFont *)font;
+(UILabel *)createLabelWithFrame:(CGRect )frame text:(NSString *)text font:(UIFont *)font textAlignment:(NSTextAlignment)textAlignment;
+ (UILabel *)createLabelWithTextColor:(UIColor *)color fontNum:(CGFloat )fontNum textAlignment:(NSTextAlignment)textAlignment;
+ (UILabel *)createLabelWithFrame:(CGRect )frame textColor:(UIColor *)color fontNum:(CGFloat )fontNum textAlignment:(NSTextAlignment)textAlignment;
+ (UILabel *)createLabelWithFrame:(CGRect )frame textColor:(UIColor *)color font:(UIFont *)font textAlignment:(NSTextAlignment)textAlignment;
+ (UILabel *)createLabelWithFrame:(CGRect )frame text:(NSString *)text textColor:(UIColor *)color fontNum:(CGFloat )fontNum textAlignment:(NSTextAlignment)textAlignment;
+ (UILabel *)createLabelWithFrame:(CGRect )frame text:(NSString *)text textColor:(UIColor *)color font:(UIFont *)font textAlignment:(NSTextAlignment)textAlignment;
//UIButton
+ (UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title titleColor:(UIColor *)titleColor fontNum:(CGFloat )fontNum textAlignment:(NSInteger)textAlignment;

+(UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title titleColor:(UIColor *)titleColor imageName:(NSString *)imageName backgroundImageName:(NSString *)backgroundImageName target:(id)target selector:(SEL)selector;
//UIImageView
+(UIImageView *)createImageViewWithFrame:(CGRect)frame imageName:(NSString *)imageName;
//UITextField
+(UITextField *)createTextFieldWithFrame:(CGRect)frame text:(NSString *)text placeholder:(NSString *)placeholder;


@end
