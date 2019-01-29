//
//  PostTextView.m
//  qmp_ios
//
//  Created by QMP on 2018/10/17.
//  Copyright © 2018 Molly. All rights reserved.
//

#import "PostTextView.h"

@interface PostTextView ()
@property (nonatomic, weak) UITextView *placeholderView;

@property (nonatomic, assign) NSInteger textH;

@property (nonatomic, assign) NSInteger maxTextH;
@end
@implementation PostTextView
- (void)textValueDidChanged:(postTextHeightChangedBlock)block {
    _textChangedBlock = block;
}



- (void)setMaxNumberOfLines:(NSUInteger)maxNumberOfLines
{
    _maxNumberOfLines = maxNumberOfLines;
    
    /**
     *  根据最大的行数计算textView的最大高度
     *  计算最大高度 = (每行高度 * 总行数 + 文字上下间距)
     */
    _maxTextH = ceil(self.font.lineHeight * maxNumberOfLines + self.textContainerInset.top + self.textContainerInset.bottom);
    
}



- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    
    self.placeholderView.textColor = placeholderColor;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    
    self.placeholderView.text = placeholder;
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont {
    
    _placeholderFont = placeholderFont;
    
    self.placeholderView.font = placeholderFont;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    
    self.scrollEnabled = NO;
    self.scrollsToTop = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.enablesReturnKeyAutomatically = YES;
//    self.layer.borderWidth = 1;
//    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    //实时监听textView值得改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self];
    
    //设置监听，监听对text的赋值操作情况的处理
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(text)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(text))]) {
        // 根据文字内容决定placeholderView是否隐藏
        self.placeholderView.hidden = self.text.length > 0;
        
    }
}
- (void)textDidChange{
    // 根据文字内容决定placeholderView是否隐藏
    self.placeholderView.hidden = self.text.length > 0;
    
    NSInteger height = ceilf([self sizeThatFits:CGSizeMake(self.bounds.size.width, MAXFLOAT)].height);
    
    if (_textH != height && height > self.minHeight) { // 高度不一样，就改变了高度
        
        // 当高度大于最大高度时，需要滚动
        self.scrollEnabled = NO;//height > _maxTextH && _maxTextH > 0;
        
        _textH = height;
        
        //当不可以滚动（即 <= 最大高度）时，传值改变textView高度
        if (_textChangedBlock && self.scrollEnabled == NO) {
            _textChangedBlock(self.text,height);
            
            [self.superview layoutIfNeeded];
            self.placeholderView.frame = self.bounds;
            
        }
    }
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(text))];
}
- (UITextView *)placeholderView {
    if (!_placeholderView ) {
        UITextView *placeholderView = [[UITextView alloc] initWithFrame:self.bounds];
        _placeholderView = placeholderView;
        //防止textView输入时跳动问题
        _placeholderView.scrollEnabled = NO;
        _placeholderView.showsHorizontalScrollIndicator = NO;
        _placeholderView.showsVerticalScrollIndicator = NO;
        _placeholderView.userInteractionEnabled = NO;
        _placeholderView.font =  self.font;
        _placeholderView.textColor = [UIColor lightGrayColor];
        _placeholderView.backgroundColor = [UIColor clearColor];
//        _placeholderView.textContainer.lineFragmentPadding = 0;
//        _placeholderView.textContainerInset = UIEdgeInsetsZero;
        [self addSubview:placeholderView];
    }
    return _placeholderView;
}
@end
