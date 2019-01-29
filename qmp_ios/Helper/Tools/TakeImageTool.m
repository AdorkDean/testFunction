//
//  TakeImageTool.m
//  qmp_ios
//
//  Created by QMP on 2017/11/1.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "TakeImageTool.h"
#import "PhotoEditViewController.h"
#import "UIImage+Rotate.h"
#import "XYCameraViewController.h"

@interface TakeImageTool()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    XYCameraViewController *_cameraVC;
}
@end

@implementation TakeImageTool
- (instancetype)init{
    if (self = [super init]) {
    }
    
    return self;
}
-(void)alertPhotoAction:(PhotoActionSelectImage)photoActionSelectImage{
    
    self.selectImage = photoActionSelectImage;
    
    [self alertController];
}

//点击 相机相册按钮
- (void)enterCameraWithResult:(PhotoActionSelectImage)photoActionSelectImage{
    self.selectImage = photoActionSelectImage;
    if([PublicTool isCameraAvailable]){
        
        [self enterCamera];
        
        //            [self enterImgController:UIImagePickerControllerSourceTypeCamera];
        
    }else{
        // 没有权限。弹出alertView
        [self showAlert:@"相机权限未开启" message:@"相机权限未开启，请进入系统【设置】>【隐私】>【相机】中打开开关,开启相机功能"];
    }
}

- (void)enterLibraryWithResult:(PhotoActionSelectImage)photoActionSelectImage{
    self.selectImage = photoActionSelectImage;
    if ([PublicTool isAlbumAvailable]) {
        [self enterImgController:UIImagePickerControllerSourceTypePhotoLibrary];
    }else{
        [self showAlert:@"照片权限未开启" message:@"照片权限未开启，请进入系统【设置】>【隐私】>【照片】中打开开关,开启相册功能"];
    }
}



- (void)alertController{
    
    UIAlertController *imgC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatusBar" object:nil];
    }];
    [imgC addAction:cancleAction];
    
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatusBar" object:nil];

        if([PublicTool isCameraAvailable]){
            
            [self enterCamera];
           
//            [self enterImgController:UIImagePickerControllerSourceTypeCamera];
            
        }else{
            // 没有权限。弹出alertView
            [self showAlert:@"相机权限未开启" message:@"相机权限未开启，请进入系统【设置】>【隐私】>【相机】中打开开关,开启相机功能"];
        }
        
    }];
    [imgC addAction:photoAction];
    
    UIAlertAction *selectAction = [UIAlertAction actionWithTitle:@"从相册选择"  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatusBar" object:nil];

        
        if ([PublicTool isAlbumAvailable]) {
            [self enterImgController:UIImagePickerControllerSourceTypePhotoLibrary];
        }else{
            [self showAlert:@"照片权限未开启" message:@"照片权限未开启，请进入系统【设置】>【隐私】>【照片】中打开开关,开启相册功能"];
        }
        
    }];
    [imgC addAction:selectAction];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        UIPopoverPresentationController *popPresenter = [imgC popoverPresentationController];
        popPresenter.sourceView = [[PublicTool topViewController] view];
        popPresenter.sourceRect = CGRectMake(0, SCREENH-150, SCREENW, 150);
        [[PublicTool topViewController].navigationController presentViewController:imgC animated:YES completion:nil];
        
    }else{
        
        [[PublicTool topViewController].navigationController presentViewController:imgC animated:YES completion:nil];
        
    }
}


#pragma mark - image picker delegte
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image;

    
    image = [info objectForKey:UIImagePickerControllerOriginalImage];

    [picker dismissViewControllerAnimated:YES completion:^{
        //压缩到200k
//        UIImage *perssImg = [PublicTool compressImage:image toByte:200*1024];
        [self saveImage:image withName:@"img.png" isCamera:NO];//先保存到沙盒再上传

    }];
    

}

- (void)enterCamera{
    
    //获取了权限，直接调用相机接口
    _cameraVC = [[XYCameraViewController alloc]init];
    __weak typeof(self) weakSelf = self;
    [_cameraVC getImage:^(UIImage *image) {
        [weakSelf saveImage:image withName:@"img.png" isCamera:YES];//先保存到沙盒再上传
    }];
    
    [[PublicTool topViewController].navigationController presentViewController:_cameraVC animated:YES completion:nil];
}

// 保存图片至沙盒
- (void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName isCamera:(BOOL)isCamera
{
    PhotoEditViewController *vc = [[PhotoEditViewController alloc]init];
    vc.isCamera = isCamera;
    vc.img = [currentImage fixOrientation];
    vc.finishCropImage = ^(UIImage *image) {
        if (image) {
            image = [PublicTool compressImage:image toByte:100*1024];
            NSData *imageData = UIImageJPEGRepresentation(image, 1);
            NSString * fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
            QMPLog(@"图片保存path:%@",fullPath);
            [imageData writeToFile:fullPath atomically:NO];
           self.selectImage(image,imageData);
            
        }else{
            
        }
    };
    
    vc.reTakeImg = ^(BOOL isCamera) { //重拍或者重新选择
        if (isCamera) {
            if([PublicTool isCameraAvailable]){
                
                [self enterCamera];
                
            }else{
                // 没有权限。弹出alertView
                [self showAlert:@"相机权限未开启" message:@"相机权限未开启，请进入系统【设置】>【隐私】>【相机】中打开开关,开启相机功能"];
            }
        }else{
            
            if ([PublicTool isAlbumAvailable]) {
                [self enterImgController:UIImagePickerControllerSourceTypePhotoLibrary];
            }else{
                [self showAlert:@"照片权限未开启" message:@"照片权限未开启，请进入系统【设置】>【隐私】>【照片】中打开开关,开启相册功能"];
            }
        }
    };
    
    [[PublicTool topViewController].navigationController presentViewController:vc animated:YES completion:nil];
    
}



//调起系统相机/相册
- (void)enterImgController:(NSInteger)sourceType{
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = sourceType;
    imagePickerController.allowsEditing = NO;

    [[PublicTool topViewController].navigationController presentViewController:imagePickerController animated:YES completion:^{}];
    
}


- (void)showAlert:(NSString *)title message:(NSString *)message{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatusBar" object:nil];
    }];
    
    UIAlertAction * otherAction = [UIAlertAction actionWithTitle:@"立即开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            
            NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
            
            [[UIApplication sharedApplication] openURL:url];
            
        }

        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatusBar" object:nil];

    }];
    
    [alert addAction:cancelAction];
    [alert addAction:otherAction];
    [[PublicTool topViewController].navigationController presentViewController:alert animated:YES completion:nil];
    
}



@end
