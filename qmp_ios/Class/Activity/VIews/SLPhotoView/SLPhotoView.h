//
//  SLPhotoView.h
//  SLWeibo
//
//  Created by Sleen Xiu on 16/1/11.
//  Copyright © 2016年 cn.Xsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ICTweetImage;
@interface SLPhotoView : UIImageView
//@property (nonatomic, strong) ICTweetImage *photo;
@property (nonatomic, assign) BOOL is_onlyOne;
@property (nonatomic, assign) BOOL is_article;
@property (nonatomic, copy) NSString *photo;
@end
