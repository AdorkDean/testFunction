//
//  FileItem.h
//  qmp_ios
//
//  Created by Molly on 2016/11/4.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileItem : NSObject

@property (strong, nonatomic) NSString *fileId;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *fileUrl;
@property (strong, nonatomic) NSString *fileType;

@end
