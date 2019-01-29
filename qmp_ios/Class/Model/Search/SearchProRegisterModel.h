//
//  SearchProRegisterModel.h
//  qmp_ios
//
//  Created by QMP on 2017/11/14.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface SearchProRegisterModel : JSONModel
/*    company = "\U5b89\U5fbd\U7701\U7eba\U7ec7\U5385";
 "company_faren" = "";
 "company_status" = "";
 curlunci = "";
 detail = "http://qimingpian.com/page/detailcom.html?src=magic&ticket=%E5%AE%89%E5%BE%BD%E7%9C%81%E7%BA%BA%E7%BB%87%E5%8E%85&id=e1f8d49c6b5582f0913cd85b0306850e";
 hangye1 = "";
 hangye2 = "";
 icon = "http://ios1.api.qimingpian.com/Public/images/product_default.png";
 product = "";
 province = "";
 "qy_time" = "1970-01-01";
 "qy_ziben" = "-";
 yewu = "";
 }
 */
@property (copy, nonatomic)NSString <Optional>*company;
@property (copy, nonatomic)NSString <Optional>*detail;
@property (copy, nonatomic)NSString <Optional>*faren;
@property (copy, nonatomic)NSString <Optional>*open_time;
@property (copy, nonatomic)NSString <Optional>*regCapital;
@property (copy, nonatomic)NSString <Optional>*qy_ziben;


@end
