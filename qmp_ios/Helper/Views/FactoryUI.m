

#import "FactoryUI.h"

@implementation FactoryUI

//UIView
+(UIView *)createViewWithFrame:(CGRect)frame
{
    UIView * view = [[UIView alloc]initWithFrame:frame];
    return view;
}

//UILabel
+(UILabel *)createLabelWithFrame:(CGRect )frame text:(NSString *)text font:(UIFont *)font
{
    UILabel * label = [[UILabel alloc]initWithFrame:frame];
    label.text = text;
    label.font = font;
    return label;
}


+ (UILabel *)createLabelWithFrame:(CGRect )frame text:(NSString *)text font:(UIFont *)font textAlignment:(NSTextAlignment)textAlignment{
    UILabel * label = [self createLabelWithFrame:frame text:text font:font];
    label.textAlignment = textAlignment;
    return label;
}

+ (UILabel *)createLabelWithTextColor:(UIColor *)color fontNum:(CGFloat )fontNum textAlignment:(NSTextAlignment)textAlignment
{
    return [FactoryUI createLabelWithFrame:CGRectZero textColor:color font:[UIFont systemFontOfSize:fontNum] textAlignment:textAlignment];
}

+ (UILabel *)createLabelWithFrame:(CGRect )frame text:(NSString *)text textColor:(UIColor *)color fontNum:(CGFloat )fontNum textAlignment:(NSTextAlignment)textAlignment
{
    return [FactoryUI createLabelWithFrame:frame text:text textColor:color font:[UIFont systemFontOfSize:fontNum] textAlignment:textAlignment];
}

+ (UILabel *)createLabelWithFrame:(CGRect )frame textColor:(UIColor *)color fontNum:(CGFloat )fontNum textAlignment:(NSTextAlignment)textAlignment
{
    return [FactoryUI createLabelWithFrame:frame text:@"" textColor:color font:[UIFont systemFontOfSize:fontNum] textAlignment:textAlignment];
}

+ (UILabel *)createLabelWithFrame:(CGRect )frame textColor:(UIColor *)color font:(UIFont *)font textAlignment:(NSTextAlignment)textAlignment
{
    return [FactoryUI createLabelWithFrame:frame text:@"" textColor:color font:font textAlignment:textAlignment];
}

+ (UILabel *)createLabelWithFrame:(CGRect )frame text:(NSString *)text textColor:(UIColor *)color font:(UIFont *)font textAlignment:(NSTextAlignment)textAlignment
{
    UILabel * label = [[UILabel alloc]initWithFrame:frame];
    label.text = text;
    label.textColor = color;
    label.font = font;
    label.textAlignment = textAlignment;
    return label;
}


//UIButton
+ (UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title titleColor:(UIColor *)titleColor fontNum:(CGFloat )fontNum textAlignment:(NSInteger)textAlignment{

    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    
    [button setTitle:title forState:UIControlStateNormal];
    
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    
    button.titleLabel.font = [UIFont systemFontOfSize:fontNum];
    button.contentHorizontalAlignment = textAlignment;
 
    return button;
}
+(UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title titleColor:(UIColor *)titleColor imageName:(NSString *)imageName backgroundImageName:(NSString *)backgroundImageName target:(id)target selector:(SEL)selector
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    //设置标题
    [button setTitle:title forState:UIControlStateNormal];
    //设置标题颜色
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    
    //设置图片
    if (imageName && imageName.length) {
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", imageName]] forState:UIControlStateNormal];

    }
    if (backgroundImageName && backgroundImageName.length) {
        //设置背景图片
        [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", backgroundImageName]] forState:UIControlStateNormal];

    }

    //添加响应方法
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}
//UIImageView
+(UIImageView *)createImageViewWithFrame:(CGRect)frame imageName:(NSString *)imageName
{
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:frame];
    imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", imageName]];
    return imageView;
}
//UITextField
+(UITextField *)createTextFieldWithFrame:(CGRect)frame text:(NSString *)text placeholder:(NSString *)placeholder
{
    UITextField * textField = [[UITextField alloc]initWithFrame:frame];
    textField.text = text;
    textField.placeholder = placeholder;
    return textField;
}

@end
