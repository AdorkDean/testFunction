//
//  RelateCompanyModel.h
//  qmp_ios
//
//  Created by QMP on 2018/2/9.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <JSONModel/JSONModel.h>
/*beizhu = "";
 detail = "http://qimingpian.com/page/detailcom.html?src=magic&ticket=%E8%A5%BF%E8%97%8F%E8%BE%BE%E5%AD%9C%E7%9C%9F%E6%A0%BC%E5%A4%A9%E7%A5%A5%E6%8A%95%E8%B5%84%E7%AE%A1%E7%90%86%E6%9C%89%E9%99%90%E5%85%AC%E5%8F%B8&id=61a99a0a33ca0351d21cc52344f18750&p=";
 "fund_short" = "";
 "fund_type" = "";
 id = ef1f4d925a67ffc924862f69f6bb120b6340;
 jigouname = "\U771f\U683c\U57fa\U91d1";
 "manager_name" = "";
 "muji_status" = "";
 name = "\U897f\U85cf\U8fbe\U5b5c\U771f\U683c\U5929\U7965\U6295\U8d44\U7ba1\U7406\U6709\U9650\U516c\U53f8";
 "open_time" = "2015-03-16";
 "sort_num" = 0;
 "target_scale" = "";
 type = 1;
 tznum = 5;
*/
@interface RelateCompanyModel : JSONModel
@property (copy, nonatomic) NSString <Optional> *company;
@property (copy, nonatomic) NSString <Optional> *open_time;
@property (copy, nonatomic) NSString <Optional> *tz_count;
@property (copy, nonatomic) NSString <Optional> *detail;


//@property (copy, nonatomic) NSString <Optional> *companyId;
//@property (copy, nonatomic) NSString <Optional> *icon;
//@property (copy, nonatomic) NSString <Optional> *jigouname;
//@property (copy, nonatomic) NSString <Optional> *manager_name;
//@property (copy, nonatomic) NSString <Optional> *muji_status;
//@property (copy, nonatomic) NSString <Optional> *name;
//@property (copy, nonatomic) NSString <Optional> *type;
//@property (copy, nonatomic) NSString <Optional> *tznum;

@end
