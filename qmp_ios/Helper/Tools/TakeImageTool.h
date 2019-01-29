//
//  TakeImageTool.h
//  qmp_ios
//
//  Created by QMP on 2017/11/1.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,UserPrivalige){
    UserPrivaligeCamera = 1, //相机
    UserPrivaligeAlbum,  //相册
    UserPrivaligeLocal   //定位
};

typedef void(^PhotoActionSelectImage)(UIImage *image,NSData *imgData);

@interface TakeImageTool : NSObject

@property (copy, nonatomic) PhotoActionSelectImage selectImage;
//底部alert
- (void)alertPhotoAction:(PhotoActionSelectImage)photoActionSelectImage;

//点击 相机相册按钮
- (void)enterCameraWithResult:(PhotoActionSelectImage)photoActionSelectImage;
- (void)enterLibraryWithResult:(PhotoActionSelectImage)photoActionSelectImage;

@end
