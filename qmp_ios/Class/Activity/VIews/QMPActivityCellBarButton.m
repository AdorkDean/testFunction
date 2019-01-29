//
//  QMPActivityCellBarButton.m
//  CommonLibrary
//
//  Created by QMP on 2019/1/17.
//  Copyright © 2019 WSS. All rights reserved.
//

#import "QMPActivityCellBarButton.h"

@implementation QMPActivityCellBarButton


- (instancetype)init {
    self = [super init];
    if (self) {
        self.titleLabel.layer.cornerRadius = 5;
        self.titleLabel.clipsToBounds = YES;
        self.titleLabel.alpha = 0.0001;
        [self addSubview:self.label];
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return self;
}
- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    //    [super setTitle:title forState:state];
    
    if (title && title.length > 0) {
        self.label.hidden = NO;
        self.label.text = title;
        [self.label sizeToFit];
        self.label.frame = CGRectMake(self.imageView.right+4, 0, self.width-self.imageView.right - 4, self.height);
    } else {
        self.label.hidden = YES;
    }
}
- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:12];
        _label.textColor = H999999;
        _label.textAlignment = NSTextAlignmentLeft;
        //        _label.layer.cornerRadius = 5;
        //        _label.clipsToBounds = YES;
        //        _label.backgroundColor = HTColorFromRGB(0x999999);
    }
    return _label;
}
@end
