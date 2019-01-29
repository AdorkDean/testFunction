//
//  BecomeOfficialPersonVC.m
//  qmp_ios
//
//  Created by QMP on 2018/6/1.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BecomeOfficialPersonVC.h"
#import "SearchPersonVC.h"

@interface BecomeOfficialPersonVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *inputNameTF;
@property (weak, nonatomic) IBOutlet UIButton *cliclkBtn;

@end

@implementation BecomeOfficialPersonVC

-(instancetype)init{
    BecomeOfficialPersonVC *vc = [[BecomeOfficialPersonVC alloc]initWithNibName:@"BecomeOfficialPersonVC" bundle:[BundleTool commonBundle]];
    return vc;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.inputNameTF becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.cliclkBtn.layer.cornerRadius = 22;
    self.cliclkBtn.clipsToBounds = YES;
    self.inputNameTF.returnKeyType = UIReturnKeyDone;
    self.title = @"认证官方人物";
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)clickBtnTarget:(UIButton *)sender {
    if ([PublicTool isNull:_inputNameTF.text]) {
        [PublicTool showMsg:@"请输入姓名"];
        return;
    }
    [self.view endEditing:YES];
    SearchPersonVC *searchVC  = [[SearchPersonVC alloc]init];
    searchVC.keyword = self.inputNameTF.text;
    searchVC.type = SearchfromTypeMySelf;
    [self.navigationController pushViewController:searchVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
