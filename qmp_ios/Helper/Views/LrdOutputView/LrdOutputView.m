//
//  LrdOutputView.m
//  LrdOutputView
//
//  Created by 键盘上的舞者 on 4/14/16.
//  Copyright © 2016 键盘上的舞者. All rights reserved.
//

#import "LrdOutputView.h"
#import "MoreTableViewCell.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define CellLineEdgeInsets UIEdgeInsetsMake(0, 10, 0, 10)
#define LeftToView 10.f
#define TopToView 10.f

@interface LrdOutputView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) LrdOutputViewDirection direction;

@property (strong, nonatomic) NSString *action;
@property (assign, nonatomic) CGPoint tableViewOrigin;
@property (assign, nonatomic) CGFloat screenH;
@property (assign, nonatomic) BOOL hasImg;

@end

@implementation LrdOutputView

- (instancetype)initWithDataArray:(NSArray *)dataArray
                           origin:(CGPoint)origin
                            width:(CGFloat)width
                           height:(CGFloat)height
                        direction:(LrdOutputViewDirection)direction
                           hasImg:(BOOL)hasImg{
    if (self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)]) {
        //背景色为clearColor
        self.backgroundColor = [UIColor clearColor];
        self.hasImg = hasImg;
        self.origin = origin;
        self.height = height;
        self.width = width;
        self.direction = direction;
        self.dataArray = dataArray;
        if (height <= 0) {
            height = 44;
        }
        if (direction == kLrdOutputViewDirectionLeft) {
            self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(origin.x, origin.y, width, height * _dataArray.count) style:UITableViewStylePlain];
        }else {
            self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(origin.x, origin.y, -width, height * _dataArray.count) style:UITableViewStylePlain];
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        _tableView.separatorColor = [UIColor colorWithWhite:0.3 alpha:1];
//        _tableView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
        _tableView.separatorColor = LIST_LINE_COLOR;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.bounces = NO;
        _tableView.layer.cornerRadius = 2;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        //注册cell
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        
        [self addSubview:self.tableView];
        
        //cell线条
        if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [self.tableView setSeparatorInset:CellLineEdgeInsets];
        }
        
        if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [self.tableView setLayoutMargins:CellLineEdgeInsets];
        }
    }
    return self;
}

- (void)setSeparatorColor:(UIColor *)separatorColor{
    _tableView.separatorColor = separatorColor;
}

-(void)setListColor:(UIColor *)listColor{
    _tableView.backgroundColor = listColor;
}

- (instancetype)initWithDataArray:(NSArray *)dataArray
                           origin:(CGPoint)origin
                  viewLeftBottomLocation:(CGPoint)viewLeftBottomLocation
                            width:(CGFloat)width
                           height:(CGFloat)height
                          screenH:(CGFloat)screenH
                        direction:(LrdOutputViewDirection)direction
                         ofAction:(NSString *)action
                           hasImg:(BOOL)hasImg{
    if (self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)]) {
        
        self.action = action;
        self.hasImg = hasImg;
        //背景色为clearColor
        self.backgroundColor = [UIColor clearColor];
        self.origin = origin;
        self.height = height;
        self.width = width;
        self.screenH = screenH;
        self.direction = direction;
        self.dataArray = dataArray;
        if (height <= 0) {
            height = 44;
        }
        
        CGFloat tableViewH = height * _dataArray.count;
        if (self.direction == kLrdOutputViewDirectionLeft) {
            self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(origin.x, origin.y, width, tableViewH) style:UITableViewStylePlain];
        }
        
        if (self.direction == kLrdOutputViewDirectionRight){
            self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(origin.x, origin.y, -width, tableViewH) style:UITableViewStylePlain];
        }
        if (self.direction == kLrdOutputViewDirectionBottomLeft) {
        
            CGFloat tableViewY = screenH - (viewLeftBottomLocation.y + tableViewH);
            self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(viewLeftBottomLocation.x, tableViewY, width, tableViewH) style:UITableViewStylePlain];
            self.tableViewOrigin = CGPointMake(viewLeftBottomLocation.x, tableViewY);
        }
        if (self.direction == kLrdOutputViewDirectionBottomRight) {
            CGFloat tableViewY = screenH - (viewLeftBottomLocation.y + tableViewH);
            self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(viewLeftBottomLocation.x, tableViewY, -width, tableViewH) style:UITableViewStylePlain];
            self.tableViewOrigin = CGPointMake(viewLeftBottomLocation.x, tableViewY);
        }
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

//        _tableView.separatorColor = [UIColor colorWithWhite:0.3 alpha:1];
//        _tableView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
        _tableView.separatorColor = LIST_LINE_COLOR;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.bounces = NO;
        _tableView.layer.cornerRadius = 2;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        //注册cell
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        
        [self addSubview:self.tableView];
        
        //cell线条
        if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [self.tableView setSeparatorInset:CellLineEdgeInsets];
        }
        
        if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [self.tableView setLayoutMargins:CellLineEdgeInsets];
        }
        
//
//        CMPopTipView *popView = [[CMPopTipView alloc] initWithCustomView:self.tableView];
//        popView.cornerRadius = 5;
//        popView.backgroundColor = [UIColor blackColor];
//        popView.textColor = [UIColor whiteColor];
//        // 0是Slide  1是pop  2是Fade但是有问题，用前两个就好了
//        popView.animation = arc4random() % 1;
//        // 立体效果，默认是YES
//        popView.has3DStyle = arc4random() % 1;
//
////        [self insertSubview:popView belowSubview:self.tableView];
//        [popView presentPointingAtView:sender inView:KEYWindow animated:YES];

    }
    return self;

    
}

- (instancetype)initWithDataArray:(NSArray *)dataArray
                           origin:(CGPoint)origin
                            width:(CGFloat)width
                           height:(CGFloat)height
                        direction:(LrdOutputViewDirection)direction
                         ofAction:(NSString *)action
                           hasImg:(BOOL)hasImg{
    return [self initWithDataArray:dataArray origin:origin viewLeftBottomLocation:origin width:width height:height  screenH:SCREENH direction:direction ofAction:action hasImg:hasImg];
   }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.hasImg) {
        MoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MoreTableViewCell"];
        
        if (!cell) {
            cell = [[nil loadNibNamed:@"MoreTableViewCell" owner:nil options:nil] lastObject];
        }
        cell.txtLbl.textColor = HTColorFromRGB(0x555555);
        cell.txtLbl.font = [UIFont systemFontOfSize:15];
//        cell.backgroundColor = [UIColor clearColor];
        //取出模型
        LrdCellModel *model = [self.dataArray objectAtIndex:indexPath.row];
        cell.txtLbl.text = model.title;
        cell.imgView.image = [UIImage imageNamed:model.imageName];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = LIST_LINE_COLOR;

        if (indexPath.row == self.dataArray.count-1) {
            cell.bottomLine.hidden = YES;
        }
        return cell;

    }else{
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LrdOutputViewCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LrdOutputViewCell"];
//            cell.backgroundColor = [UIColor clearColor];
            cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
            cell.selectedBackgroundView.backgroundColor = LIST_LINE_COLOR;

        }
        UIView *line = [cell.contentView viewWithTag:1000];
        if (!line) {
            line = [[UIView alloc]initWithFrame:CGRectMake(0, cell.contentView.height-0.5, cell.contentView.frame.size.width, 0.5)];
            line.backgroundColor = LIST_LINE_COLOR;
            line.tag = 1000;
            [cell.contentView addSubview:line];
        }
        LrdCellModel *model = [self.dataArray objectAtIndex:indexPath.row];
        cell.textLabel.text = model.title;
        cell.textLabel.textColor = [UIColor whiteColor];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //通知代理处理点击事件
    if ([self.delegate respondsToSelector:@selector(didSelectedAtIndexPath: ofAction:)]) {
        [self.delegate didSelectedAtIndexPath:indexPath ofAction:self.action];
    }
    if ([self.delegate respondsToSelector:@selector(didSelectedAtIndexPath:)]) {
        [self.delegate didSelectedAtIndexPath:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismiss];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:CellLineEdgeInsets];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:CellLineEdgeInsets];
    }
}

//画出尖尖
- (void)drawRect:(CGRect)rect {
    //拿到当前视图准备好的画板
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect bubbleRect = self.tableView.frame; //绘制的frame
    CGFloat originX = bubbleRect.origin.x;
    CGFloat originY = bubbleRect.origin.y;
    CGFloat pathWidth = bubbleRect.size.width;
    CGFloat pathHeight = bubbleRect.size.height;

    CGFloat radius = 2.0f;
    
    CGContextSetLineWidth(context, 0.5);
    
    //利用path进行绘制三角形
    CGContextBeginPath(context);//标记
    CGMutablePathRef bubblePath = CGPathCreateMutable();

    if (self.direction == kLrdOutputViewDirectionLeft) {
        CGFloat startX = self.origin.x + 20;
        CGFloat startY = self.origin.y;
    //尖
        CGPathMoveToPoint(bubblePath, NULL, startX, startY);
        CGPathAddLineToPoint(bubblePath,NULL, startX + 5, startY - 5);
        CGPathAddLineToPoint(bubblePath,NULL, startX + 10, startY);
    //边
        CGPathAddArcToPoint(bubblePath, NULL, originX+pathWidth, originY, originX+pathWidth, originY+radius, radius);
        CGPathAddArcToPoint(bubblePath, NULL, originX+pathWidth, originY+pathHeight, originX+pathWidth-radius, originY+pathHeight, radius);
        CGPathAddArcToPoint(bubblePath, NULL, originX, originY+pathHeight, originX, originY+pathHeight-radius, radius);
        CGPathAddArcToPoint(bubblePath, NULL, originX, originY, originX+radius, originY, radius);

        CGPathAddLineToPoint(bubblePath, NULL, startX, startY);

    }
    
    if (self.direction == kLrdOutputViewDirectionRight){
        
        CGFloat startX = self.origin.x - 20;
        CGFloat startY = self.origin.y;
        
        //尖
        CGPathMoveToPoint(bubblePath, NULL, startX, startY);
        CGPathAddLineToPoint(bubblePath,NULL, startX + 5, startY - 5);
        CGPathAddLineToPoint(bubblePath,NULL, startX + 10, startY);
        //边
        CGPathAddArcToPoint(bubblePath, NULL, originX + pathWidth, originY, originX+pathWidth, originY+radius, radius);
        CGPathAddArcToPoint(bubblePath, NULL, originX + pathWidth, originY+pathHeight, originX+pathWidth-radius, originY+pathHeight, radius);
        CGPathAddArcToPoint(bubblePath, NULL, originX, originY+pathHeight, originX, originY+pathHeight-radius, radius);
        CGPathAddArcToPoint(bubblePath, NULL, originX , originY, originX+radius, originY, radius);
        CGPathAddLineToPoint(bubblePath,NULL, startX, startY);


    }
    if (self.direction == kLrdOutputViewDirectionBottomLeft) {
        CGFloat startX = self.origin.x + 20;
        CGFloat startY = self.screenH - self.origin.y;
        
        //尖
        CGPathMoveToPoint(bubblePath, NULL, startX, startY );
        CGPathAddLineToPoint(bubblePath,NULL, startX + 5, startY + 5);
        CGPathAddLineToPoint(bubblePath,NULL, startX + 10, startY);
        //边
        CGPathAddArcToPoint(bubblePath, NULL, originX+pathWidth, originY+pathHeight, originX+pathWidth, originY+pathHeight-radius, radius);
        CGPathAddArcToPoint(bubblePath, NULL, originX+pathWidth, originY, originX+pathWidth-radius, originY, radius);
        CGPathAddArcToPoint(bubblePath, NULL, originX, originY, originX, originY+radius, radius);
        
        CGPathAddArcToPoint(bubblePath, NULL, originX, originY+pathHeight, originX+radius, originY+pathHeight, radius);
        CGPathAddLineToPoint(bubblePath, NULL, startX, startY);

    }
    if (self.direction == kLrdOutputViewDirectionBottomRight) {
        CGFloat startX = self.origin.x - 30;
        CGFloat startY = self.screenH - self.origin.y;
        
        //尖
        CGPathMoveToPoint(bubblePath, NULL, startX, startY );
        CGPathAddLineToPoint(bubblePath,NULL, startX + 5, startY + 5);
        CGPathAddLineToPoint(bubblePath,NULL, startX + 10, startY);
        //边
        CGPathAddArcToPoint(bubblePath, NULL, originX+pathWidth, originY+pathHeight, originX+pathWidth, originY+pathHeight-radius, radius);
        CGPathAddArcToPoint(bubblePath, NULL, originX+pathWidth, originY, originX+pathWidth-radius, originY, radius);
        CGPathAddArcToPoint(bubblePath, NULL, originX, originY, originX, originY+radius, radius);
        
        CGPathAddArcToPoint(bubblePath, NULL, originX, originY+pathHeight, originX+radius, originY+pathHeight, radius);
        CGPathAddLineToPoint(bubblePath, NULL, startX, startY);
    }
    
    CGPathCloseSubpath(bubblePath);
    
//    CGContextAddPath(context, bubblePath);
//    CGContextSetStrokeColorWithColor(context, LINE_COLOR.CGColor);
//    CGContextDrawPath(context, kCGPathStroke);

    CGContextAddPath(context, bubblePath);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextDrawPath(context, kCGPathFill);
    CGContextFillPath(context);

    [self.layer setShadowOffset:CGSizeMake(0, 0)];
    [self.layer setShadowOpacity:0.15];
    [self.layer setShadowPath:bubblePath];
    CGContextSaveGState(context);

//    {  //阴影
//        CGContextSaveGState(context);
//        CGMutablePathRef innerShadowPath = CGPathCreateMutable();
//
//        // add a rect larger than the bounds of bubblePath
//        CGPathAddRect(innerShadowPath, NULL, CGRectInset(CGPathGetPathBoundingBox(bubblePath), -3, -3));
//
//        // add bubblePath to innershadow
//        CGPathAddPath(innerShadowPath, NULL, bubblePath);
//        CGPathCloseSubpath(innerShadowPath);
//
//        // draw top highlight
//        UIColor *highlightColor = [[UIColor blackColor]colorWithAlphaComponent:0.4];;
//        CGContextSetFillColorWithColor(context, highlightColor.CGColor);
//        CGContextSetShadowWithColor(context, CGSizeMake(0.0, 4.0), 4.0, highlightColor.CGColor);
//        CGContextAddPath(context, innerShadowPath);
//        CGContextEOFillPath(context);
//
//        // draw bottom shadow
//        UIColor *shadowColor = [[UIColor blackColor]colorWithAlphaComponent:0.4];
//        CGContextSetFillColorWithColor(context, shadowColor.CGColor);
//        CGContextSetShadowWithColor(context, CGSizeMake(0.0, -4.0), 4.0, shadowColor.CGColor);
//        CGContextAddPath(context, innerShadowPath);
//        CGContextEOFillPath(context);
//
//        CGPathRelease(innerShadowPath);
//        CGContextRestoreGState(context);
//    }
//    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径path
    

}

- (void)pop {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    //动画效果弹出
    self.alpha = 0;
    CGRect frame = self.tableView.frame;
//    self.tableView.frame = CGRectMake(self.origin.x, self.origin.y, 0, 0);
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
//        self.tableView.frame = frame;
    }];
}
- (void)popFromBottom {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    //动画效果弹出
//    self.alpha = 1;
//    CGRect frame = self.tableView.frame;
////    self.tableView.frame = CGRectMake(self.origin.x,SCREENH, 0, 0);
//    [UIView animateWithDuration:0.05 animations:^{
//        self.alpha = 1;
////        self.tableView.frame = frame;
//    }];
}

- (void)dismiss {
    
    [self removeFromSuperview];
    return;
    
    //动画效果淡出
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
        
        CGFloat h = self.origin.y;
        if (self.direction == kLrdOutputViewDirectionBottomRight || self.direction == kLrdOutputViewDirectionBottomLeft) {
            h = SCREENH;
        }
        self.tableView.frame = CGRectMake(self.origin.x,h , 0, 0);
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
            if (self.dismissOperation) {
                self.dismissOperation();
            }
        }  
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (![touch.view isEqual:self.tableView]) {
        [self dismiss];
    }
}

@end


#pragma mark - LrdCellModel

@implementation LrdCellModel

- (instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName {
    LrdCellModel *model = [[LrdCellModel alloc] init];
    model.title = title;
    model.imageName = imageName;
    return model;
}

@end
