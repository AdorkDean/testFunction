//
//  CardListController.m
//  qmp_ios
//
//  Created by QMP on 2018/5/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "CardListController.h"
#import <TZImagePickerController.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
//#imp
#import <TZImageManager.h>
#import <TZLocationManager.h>
#import "CardEditingViewController.h"

#import "GetNowTime.h"
#import "CardItem.h"
#import "TakeImageTool.h" //相机相册
#import "LrdOutputView.h"
#import "DeleteCardController.h"
#import "CardToContactController.h"
#import "CardToContactController.h"
#import "XYCameraViewController.h"
#import "PhotoEditViewController.h"
#import "UIImage+Rotate.h"
#import "CardUploadTool.h"
#import "CardListCell.h"


@interface CardListController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate,UISearchBarDelegate>{
    
    NSInteger _currentPage;
    NSInteger _searchNowPage;
    BOOL _isSearching;
    TakeImageTool *_takeImgageTool;
    
    TakeImageTool *_userPhotoTool;
    
    XYCameraViewController *_cameraVC;
}
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (nonatomic, strong) UIView *addBtn;

@property (strong, nonatomic) UILabel *rightLbl;

@property (strong, nonatomic) CardItem *card;


@property (strong, nonatomic) ManagerHud *hudTool;
@property (strong, nonatomic) GetSizeWithText *sizeTool;
@property (strong, nonatomic) GetNowTime *timeTool;
@property (nonatomic,strong) UIView *searchBgView;
@property (nonatomic,strong) UIButton *cancleBtn;

@property (strong, nonatomic) NSMutableArray *searchData;
@property (nonatomic,strong) UITapGestureRecognizer *tapCancelSearch;
@property (nonatomic,strong)UIProgressView *progressView;

@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic, assign) CGFloat originOffsetY;
@end

@implementation CardListController

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.progressView removeFromSuperview];

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"上传的名片";
    _takeImgageTool = [[TakeImageTool alloc]init];
    _currentPage = 1;
    self.numPerPage = 20;
    _searchNowPage = 1;
    
//    [self buildRightBarButtonItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDelOneCardSuccess:) name:@"DelOneCardSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCardInfoUpdateSuccessNotification:) name:@"CardInfoUpdateSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveAddCardBackNotification:) name:@"AddCardBackSuccess" object:nil];
    
    [self initTableView];
    
    [self showHUD];
    [self requestData];
    
    [[CardUploadTool shared] showUploadView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0001f;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (_isSearching && _searchBar.text.length > 0&& _searchData.count == 0)  {
        [self.tableView removeGestureRecognizer:self.tapCancelSearch];
        
        return 1;
    }
    
    [self.tableView removeGestureRecognizer:self.tapCancelSearch];
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _isSearching ? (self.searchData.count ? self.searchData.count:([PublicTool isNull:_searchBar.text] ? 0 : 1)) : (self.tableData.count ? self.tableData.count:1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_isSearching && _searchBar.text.length > 0&& _searchData.count == 0) {
        
        return SCREENH - kScreenTopHeight;
    }
    
    if (self.tableData.count == 0) {
        return SCREENH - kScreenTopHeight;
    }
    
    
    if (_isSearching) {
        if (self.searchData.count == 0) {
            return 0.1;
        }
    }else{
        if (self.tableData.count == 0) {
            return 0.1;
        }        
    }
    
    return 75;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_isSearching) {
        if (self.searchData.count > 0) {
            CardListCell *uploadCell = [CardListCell cellWithTableView:tableView];
            uploadCell.cardItem = self.searchData[indexPath.row];
            uploadCell.area = CardStyleFromUpload;
            uploadCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return uploadCell;
        }
    }else{
        if (self.tableData.count > 0) {
            CardListCell *uploadCell = [CardListCell cellWithTableView:tableView];
            uploadCell.cardItem = self.tableData[indexPath.row];
            uploadCell.area = CardStyleFromUpload;
            uploadCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return uploadCell;
        }
    }
    
    NSString *title = _isSearching ? REQUEST_SEARCH_NULL : @"暂无名片，点击添加";
    HomeInfoTableViewCell *cell = [self nodataCellWithInfo:title tableView:tableView];
    
    UIButton *uploadBtn = [cell.contentView viewWithTag:1000];
    if (!uploadBtn) {
        uploadBtn = [[UIButton alloc]initWithFrame:CGRectMake((SCREENW-150)/2.0, cell.subInfoLab.bottom+50, 150, 45)];
        uploadBtn.layer.cornerRadius = 4;
        uploadBtn.layer.masksToBounds = YES;
        uploadBtn.backgroundColor = BLUE_BG_COLOR;
        [uploadBtn.titleLabel labelWithFontSize:16 textColor:[UIColor whiteColor]];
        [uploadBtn setImage:[UIImage imageNamed:@"card_cell_upload"] forState:UIControlStateNormal];
        [uploadBtn setTitle:@"上传名片" forState:UIControlStateNormal];
        [uploadBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:6];
        uploadBtn.tag = 1000;
        [cell.contentView addSubview:uploadBtn];
        uploadBtn.userInteractionEnabled = NO;
    }
    return cell;
}

- (void)cardCellSelectBtnClick:(UIButton*)btn{
    
    NSInteger index = btn.tag - 1000;
    if (_isSearching) {
        CardItem *cardItem = self.searchData[index];
        cardItem.selected = !cardItem.selected;
        
    }else{
        CardItem *cardItem = self.tableData[index];
        cardItem.selected = !cardItem.selected;
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([self noDataIsAllowSelectedTbVw:tableView withIndexPaht:indexPath]){
       
        [self pressAddCardBtn];
        return;
    }
    
    if (_isSearching) {
        if (self.searchData.count > 0) {
            CardItem *cardItem = self.searchData[indexPath.row];
            
            CardEditingViewController *editVC = [[CardEditingViewController alloc]init];
            editVC.isUpload = NO;
            editVC.card = cardItem;
            editVC.cardEditFinish = ^(CardItem *card) { //添加
            };
            [self.navigationController pushViewController:editVC animated:YES];
        }
    }else{
        
        if (self.tableData.count > 0) {
            
            CardItem *cardItem = self.tableData[indexPath.row];
            
            CardEditingViewController *editVC = [[CardEditingViewController alloc]init];
            editVC.isUpload = NO;
            editVC.card = cardItem;
            editVC.cardEditFinish = ^(CardItem *card) { //添加
            };
            
            [self.navigationController pushViewController:editVC animated:YES];
            
        }else{
            
        }
        
    }
    
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIContextualAction *delAction = nil;
    if (_isSearching) {
        if (self.searchData.count > 0) {
            delAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                
                
                CardItem *cardItem = self.searchData[indexPath.row];
                
                [self requestDelOneCardWithId:cardItem.cardId];
            }];
        }
        
    }else{
        if (self.tableData.count > 0) {
            delAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                
                
                CardItem *cardItem = self.tableData[indexPath.row];
                
                [self requestDelOneCardWithId:cardItem.cardId];
            }];
            
        }
        
    }
    if (delAction) {
        delAction.backgroundColor = RED_TEXTCOLOR;
        UISwipeActionsConfiguration *action = [UISwipeActionsConfiguration configurationWithActions:@[delAction]];
        action.performsFirstActionWithFullSwipe = NO;
        return action;
    }
    return nil;
    
}


- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (iOS11_OR_HIGHER) {
        return @[];
        
    }
    if (_isSearching) {
        if (self.searchData.count > 0) {
            UITableViewRowAction *delAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                
                
                CardItem *cardItem = self.searchData[indexPath.row];
                
                [self requestDelOneCardWithId:cardItem.cardId];
            }];
            delAction.backgroundColor = RED_TEXTCOLOR;
            return @[delAction];
        }
    }else{
        if (self.tableData.count > 0) {
            UITableViewRowAction *delAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                
                
                CardItem *cardItem = self.tableData[indexPath.row];
                
                [self requestDelOneCardWithId:cardItem.cardId];
            }];
            delAction.backgroundColor = RED_TEXTCOLOR;
            return @[delAction];
            
        }
        
    }
    
    return @[];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return NO;
    
    if (_isSearching) {
        return  self.searchData.count > 0;
    }
    return (self.tableData.count > 0);
}


#pragma mark --UISearchBarDelegate---
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    _isSearching = YES;
    self.addBtn.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.searchBar.frame;
        frame.size.width = SCREENW - 58;
        self.searchBar.frame = frame;
        self.cancleBtn.hidden = NO;
        
    } completion:nil];
    
    if (!_searchBar.text || _searchBar.text.length == 0) {
        [_searchData removeAllObjects];
        [self.tableView reloadData];
        [self.tableView addGestureRecognizer:self.tapCancelSearch];
    }
    self.tableView.backgroundColor = [UIColor whiteColor];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    if (!_searchBar.text || _searchBar.text.length == 0) {
        [_searchData removeAllObjects];
        self.tableView.backgroundColor = [UIColor whiteColor];
        [self.tableView reloadData];
        //        [self setMj_footer];
        [self.tableView addGestureRecognizer:self.tapCancelSearch];
    }
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    _searchNowPage = 1;
    [self requestData];
    
    [self.searchBar resignFirstResponder];
    
}


- (void)searchResignFirseResponder{
    _isSearching = NO;
    self.addBtn.hidden = NO;
    _searchBar.text = @"";
    [self.tableView.mj_header endRefreshing];
    [UIView animateWithDuration:0.3 animations:^{
        [self.searchBar resignFirstResponder];
        CGRect frame = self.searchBar.frame;
        frame.size.width = SCREENW-14;
        self.searchBar.frame = frame;
        self.cancleBtn.hidden = YES;
        
    } completion:^(BOOL finished) {
    }];
    self.tableView.mj_footer.state = MJRefreshStateIdle;
    [self.tableView reloadData];
    
}

- (void)cancleBtnTouched
{
    [self searchResignFirseResponder];
}

- (void)tabelViewTapGesture{
    
    if (_isSearching && self.searchData.count == 0) {
        [self searchResignFirseResponder];
        
    }
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (_isSearching && (_searchBar.text.length == 0 || !_searchBar.text)) {
        [self searchResignFirseResponder];
        
    }else if(_isSearching && _searchBar.text.length >0 && self.searchData.count){
        [self.searchBar resignFirstResponder];
    }
    if (self.tableView == scrollView) {
        self.originOffsetY = scrollView.contentOffset.y;
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.tableView == scrollView) {
        CGFloat VH = SCREENH - kScreenTopHeight;
        if (self.originOffsetY >= 0) {
            if (self.originOffsetY > scrollView.contentOffset.y) {//手指往下滑，显示 +
//                if (self.bottomView.frame.origin.y == VH - kScreenBottomHeight) {
//                    return;
//                }
                [UIView animateWithDuration:0.25 animations:^{
                    self.bottomView.frame = CGRectMake(0, VH - kScreenBottomHeight, SCREENW, kScreenBottomHeight);
                }];
             
            }else{//手指往上滑，隐藏 -
                if (self.bottomView.top == VH) {
                    return;
                }
                [UIView animateWithDuration:0.25 animations:^{
                    self.bottomView.frame = CGRectMake(0, VH, SCREENW, kScreenBottomHeight);
                }];
            }
        }else{
        }
    }
}

#pragma mark - 请求删除单个card
- (void)requestDelOneCardWithId:(NSString *)cardId{
    [PublicTool showHudWithView:self.view];
    if ([TestNetWorkReached networkIsReachedNoAlert]) {
        //待验证
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"l/delComImg" HTTPBody:@{@"id":cardId} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [PublicTool dismissHud:self.view];
            if (resultData && error == nil) {
                [PublicTool showMsg:@"删除成功"];
                CardItem *delCard = [[CardItem alloc] init];
                delCard.cardId = cardId;
                [self delCard:delCard];
            }else{
                [PublicTool showMsg:@"删除失败"];
            }
        }];
    
    }
}

#pragma mark - 请求名片列表
- (BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }
    
    NSInteger page = 0;
    
    if (_isSearching) {
        page = _searchNowPage;
    }else{
        page = _currentPage;
    }
    
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:[WechatUserInfo  shared].unionid,@"unionid",@"qmp_ios",@"ptype",VERSION,@"version",@(page),@"page",@(self.numPerPage),@"num",self.searchBar.text,@"keywords", nil];
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"Card/cardList" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
       
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if (resultData && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            
            NSMutableArray *retMArr = [[NSMutableArray alloc] initWithCapacity:0];
            
            for (NSDictionary *cardsDict in resultData[@"list"]) {
                
                CardItem *item = [[CardItem alloc] init];
                [item setValuesForKeysWithDictionary:cardsDict];
                item.cardId = cardsDict[@"card_id"];
                item.imgUrl = cardsDict[@"web_url"];
                item.backImgUrl = cardsDict[@"back_url"];
                [retMArr addObject:item];
            }
            [self dealData:retMArr];
    
            if (self.tableData.count) {
                [self initBottomView];
                if (!self.tableView.tableHeaderView) {
                    self.tableView.tableHeaderView = self.searchBgView;
                }
                self.tableView.scrollEnabled = YES;
            }else{
                self.tableView.scrollEnabled = NO;
                [self.bottomView removeFromSuperview];
                self.tableView.tableHeaderView = nil;
            }
            [self buildRightBtn];
            [self.tableView reloadData];
        }
        
    }];

    return YES;
}

- (void)dealData:(NSArray*)retMArr{
    
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    
    self.tableView.mj_footer = self.mjFooter;
    
    self.tableView.mj_footer = self.mjFooter;
    
    [self refreshFooter:retMArr];
    
    if (_isSearching) {
        
        if (_searchNowPage == 1) {
            self.searchData = [NSMutableArray arrayWithArray:retMArr];
            
        }else{
            [self.searchData addObjectsFromArray:retMArr];
        }

        
        [self.tableView reloadData];
        
        return;
    }
    
    //非搜索
    if (_currentPage == 1) {
        
        self.tableData = [NSMutableArray arrayWithArray:retMArr];
        
    }else{
        [self.tableData addObjectsFromArray:retMArr];
    }
    
    [self.tableView reloadData];
}


#pragma mark - public

- (void)pressAddCardBtn{
    
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
            [PublicTool showAlert:@"相机权限未开启" message:@"相机权限未开启，请进入系统【设置】>【隐私】>【相机】中打开开关,开启相机功能"];
        }
        
    }];
    [imgC addAction:photoAction];
    
    UIAlertAction *selectAction = [UIAlertAction actionWithTitle:@"从相册选择"  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatusBar" object:nil];
        
        
        if ([PublicTool isAlbumAvailable]) {
            [self selectPhotos];
        }else{
            [PublicTool showAlert:@"照片权限未开启" message:@"照片权限未开启，请进入系统【设置】>【隐私】>【照片】中打开开关,开启相册功能"];
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
    return;
    
}


- (void)enterCamera{
    
    //获取了权限，直接调用相机接口
    _cameraVC = [[XYCameraViewController alloc]init];
    __weak typeof(self) weakSelf = self;
    
    [_cameraVC getImage:^(UIImage *image) {
        
        PhotoEditViewController *vc = [[PhotoEditViewController alloc]init];
        vc.isCamera = YES;
        vc.img = [image fixOrientation];
        vc.reTakeImg = ^(BOOL isCamera) {
            [weakSelf enterCamera];
        };
        vc.finishCropImage = ^(UIImage *image) {
            if (image) {
                
                CardEditingViewController *cardVC = [[CardEditingViewController alloc]init];
                cardVC.image = image;
                cardVC.isUpload = YES;
                [weakSelf.navigationController pushViewController:cardVC animated:YES];
                
            }
        };
        [self.navigationController presentViewController:vc animated:YES completion:nil];
        
    }];
    
    [self.navigationController presentViewController:_cameraVC animated:YES completion:nil];
}


- (void)selectPhotos{
    
    NSInteger maxCount = 100;
    NSInteger columnNumber = 4;
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:maxCount columnNumber:columnNumber delegate:nil pushPhotoPickerVc:YES];
    // imagePickerVc.navigationBar.translucent = NO;
    
#pragma mark - 五类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = NO;
    
    imagePickerVc.allowTakePicture = YES; // 在内部显示拍照按钮
    
    // imagePickerVc.photoWidth = 1000;
    
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    // imagePickerVc.navigationBar.translucent = NO;
    
    // 3. Set allow picking video & photo & originalPhoto or not
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowPickingMultipleVideo = NO; // 是否可以多选视频
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
    
    // imagePickerVc.minImagesCount = 3;
    // imagePickerVc.alwaysEnableDoneBtn = YES;
    
    // imagePickerVc.minPhotoWidthSelectable = 3000;
    // imagePickerVc.minPhotoHeightSelectable = 2000;
    
    /// 5. Single selection mode, valid when maxImagesCount = 1
    /// 5. 单选模式,maxImagesCount为1时才生效
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowCrop = NO;
    imagePickerVc.needCircleCrop = NO;
    // 设置竖屏下的裁剪尺寸
    //    NSInteger left = 30;
    //    NSInteger widthHeight = self.view.tz_width - 2 * left;
    //    NSInteger top = (self.view.tz_height - widthHeight) / 2;
    //    imagePickerVc.cropRect = CGRectMake(left, top, widthHeight, widthHeight);
    // 设置横屏下的裁剪尺寸
    // imagePickerVc.cropRectLandscape = CGRectMake((self.view.tz_height - widthHeight) / 2, left, widthHeight, widthHeight);
    /*
     [imagePickerVc setCropViewSettingBlock:^(UIView *cropView) {
     cropView.layer.borderColor = [UIColor redColor].CGColor;
     cropView.layer.borderWidth = 2.0;
     }];*/
    
    //imagePickerVc.allowPreview = NO;
    
    imagePickerVc.isStatusBarDefault = NO;
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    __weak typeof(self) weakSelf = self;
    
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        [weakSelf uploadPhotos:photos];
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}


- (void)uploadPhotos:(NSArray*)photos{
    
    if (photos.count == 0) {
        return;
    }
    
    if (photos.count == 1) {
        UIImage *image = photos[0];
        CardEditingViewController *cardVC = [[CardEditingViewController alloc]init];
        cardVC.image = image;
        cardVC.isUpload = YES;
        [self.navigationController pushViewController:cardVC animated:YES];
        
        cardVC.cardEditFinish = ^(CardItem *card) { //添加
            
        };
    }else{
        
        [[CardUploadTool shared] uploadCardsImages:photos finishOneImage:^{
            _currentPage = 1;
            [self requestData];
        }];
       
    }
}


- (void)addBackCardSuccess:(CardItem *)card{
    
    for (int i = 0 ;i < self.tableData.count; i++) {
        
        CardItem *oldCard = self.tableData[i];
        if ([oldCard.cardId isEqualToString:card.cardId]) {
            oldCard.backImgUrl = card.backImgUrl;
            oldCard.back_flag = 1;
            break;
        }
        
    }
    
    for (int i = 0 ;i < self.searchData.count; i++) {
        
        CardItem *oldCard = self.tableData[i];
        if ([oldCard.cardId isEqualToString:card.cardId]) {
            oldCard.backImgUrl = card.backImgUrl;
            oldCard.back_flag = 1;
            break;
        }
        
    }
    
    [self.tableView reloadData];
}


#pragma mark - 底部工具
- (void)initBottomView{
    if ([self.bottomView isDescendantOfView:self.view]) {
        
    }else{
      [self.view addSubview:self.bottomView];
    }
}


//删除名片
- (void)deleteBtnClick{
    
    if (self.tableData.count == 0) {
        return;
    }
    
    DeleteCardController *deleteVC = [[DeleteCardController alloc]init];
    deleteVC.type = 0;
    __weak typeof(self) weakSelf = self;
    deleteVC.deleteCardHandle = ^{
        [weakSelf.tableView.mj_header beginRefreshing];
    };
    [self.navigationController pushViewController:deleteVC animated:YES];
}

//导入到通讯录
- (void)leadBtnClick{
    
    if (self.tableData.count == 0) {
        [PublicTool showMsg:@"没有数据"];
        return;
    }
    [QMPEvent event:@"me_card_leadBtnClick"];
    CardToContactController *contactVC = [[CardToContactController alloc]init];
    contactVC.cardFrom = CardStyleFromUpload;
    [self.navigationController pushViewController:contactVC animated:YES];
    
}


- (void)initTableView{
    CGFloat tableH = SCREENH - kScreenTopHeight;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, tableH) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.mj_header = self.mjHeader;
    self.tableView.tableHeaderView = self.searchBgView;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
   
}

- (void)buildRightBtn{
    if (self.tableData.count == 0) {
        self.navigationItem.rightBarButtonItem = nil;

        return;
    }else{
        if (self.navigationItem.rightBarButtonItem) {
            return;
        }
    }
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"card_add"] forState:UIControlStateNormal];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [btn addTarget:self action:@selector(pressAddCardBtn) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item1;
}

- (void)pullDown{
    
    [self.tableView.mj_footer resetNoMoreData];
    
    if (_isSearching) {
        _searchNowPage = 1;
    }else{
        _currentPage = 1;
    }
    
    [self requestData];
}

- (void)pullUp{
    
    [self.tableView.mj_footer beginRefreshing];
    if (_isSearching) {
        _searchNowPage ++;
    }else{
        _currentPage ++;
        
    }
    
    [self requestData];
}


- (void)receiveAddCardBackNotification:(NSNotification *)notification{
    
    
    CardItem *card = (CardItem *)notification.object;
    [self addBackCardSuccess:card];
    
}

- (void)receiveCardInfoUpdateSuccessNotification:(NSNotification *)notification{
    
    CardItem *updateCard = (CardItem *)notification.object;
    
    NSMutableArray *cardArr = [NSMutableArray arrayWithArray:self.tableData];
    
    for (int i = 0; i < cardArr.count; i ++ ) {
        CardItem *card = cardArr[i];
        if ([card.cardId isEqualToString:updateCard.cardId]) { //更新
            [self.tableData replaceObjectAtIndex:i withObject:updateCard];
            [self.tableView reloadData];
            return;
        }
    }
    
    NSMutableArray *searchCardArr = [NSMutableArray arrayWithArray:self.searchData];
    for (int i = 0; i < searchCardArr.count; i ++ ) {
        
        CardItem *card = self.searchData[i];
        if ([card.cardId isEqualToString:updateCard.cardId]) { //更新
            [self.searchData replaceObjectAtIndex:i withObject:updateCard];
            [self.tableView reloadData];
            
            return;
        }
    }
    
    //新建的 刷新列表
    [self.tableView.mj_header beginRefreshing];
    
}


- (void)receiveDelOneCardSuccess:(NSNotification *)notification{
    CardItem *delCard = (CardItem *)notification.object;
    
    [self delCard:delCard];
}

- (void)delCard:(CardItem *)delCard{
    
    for (int i = 0; i < self.searchData.count; i ++ ) {
        CardItem *oldCard = self.searchData[i];
        if([oldCard.cardId isEqualToString:delCard.cardId]){
            [self.searchData removeObjectAtIndex:i];
            
            [self.tableView reloadData];
            break;
        }
        
    }
    
    for (int i = 0; i < self.tableData.count; i ++ ) {
        CardItem *oldCard = self.tableData[i];
        if([oldCard.cardId isEqualToString:delCard.cardId]){
            [self.tableData removeObjectAtIndex:i];
            
            [self.tableView reloadData];
            break;
            
        }
        
    }
    
}


#pragma mark - 懒加载
- (UIView *)searchBgView
{
    if (!_searchBgView) {
        _searchBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 44)];
        _searchBgView.backgroundColor = [UIColor whiteColor];
        
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(7, 0, SCREENW-14, 44)];
        [_searchBar setBackgroundImage:[UIImage imageFromColor:[UIColor whiteColor] andSize:_searchBar.size]];
        //设置背景色
        [_searchBar setBackgroundColor:[UIColor whiteColor]];
        [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"card_search_bg"] forState:UIControlStateNormal];
        [_searchBar setSearchTextPositionAdjustment:UIOffsetMake(10, 0)];
        UITextField *tf = [_searchBar valueForKey:@"_searchField"];
        tf.font = [UIFont systemFontOfSize:14];
        NSString *str = @"搜索姓名、公司、职务等";
        tf.attributedPlaceholder = [[NSAttributedString alloc]initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],NSForegroundColorAttributeName:H999999}];
        tf.font = [UIFont systemFontOfSize:14];
        
        _searchBar.showsCancelButton = NO;
        _searchBar.delegate = self;
        
        [_searchBgView addSubview:_searchBar];
        
        
        _cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW - 61, 0, 60, _searchBgView.height)];
        _cancleBtn.backgroundColor = [UIColor clearColor];
        _cancleBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancleBtn setTitleColor:HTColorFromRGB(0x555555) forState:UIControlStateNormal];
        [_searchBgView addSubview:_cancleBtn];
        self.cancleBtn.hidden = YES;
        
        [_cancleBtn addTarget:self action:@selector(cancleBtnTouched) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _searchBgView;
}


- (NSMutableArray *)searchData{
    if (!_searchData) {
        _searchData = [NSMutableArray array];
    }
    return _searchData;
}
- (UITapGestureRecognizer *)tapCancelSearch{
    if (!_tapCancelSearch) {
        _tapCancelSearch = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tabelViewTapGesture)];
    }
    return _tapCancelSearch;
}


- (GetSizeWithText *)sizeTool{
    
    if (!_sizeTool) {
        _sizeTool = [[GetSizeWithText alloc] init];
    }
    return _sizeTool;
}



- (GetNowTime *)timeTool{
    
    if (!_timeTool) {
        _timeTool = [[GetNowTime alloc] init];
    }
    return _timeTool;
}
- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (iOS9_OR_HIGHER) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleDefault;
}

-(UIProgressView *)progressView{
    
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
        _progressView.trackTintColor = [UIColor lightGrayColor];
        _progressView.progressTintColor = RED_TEXTCOLOR;
        _progressView.frame = CGRectMake(0, 0, 100, 30);
        _progressView.progress = 0.0;
    }
    return _progressView;
}
- (UIView *)bottomView{
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENH - kScreenTopHeight - kScreenBottomHeight, SCREENW, kScreenBottomHeight)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 0.5)];
        line.backgroundColor = LINE_COLOR;
        [_bottomView addSubview:line];
        
        
        UIButton *delBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREENW/2.0, kShortBottomHeight)];
        [delBtn setTitle:@"删除" forState:UIControlStateNormal];
        [delBtn setImage:[UIImage imageNamed:@"workFlowDel"] forState:UIControlStateNormal];
        [delBtn setTitleColor:H5COLOR forState:UIControlStateNormal];
        delBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [delBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:7];
        [delBtn addTarget:self  action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:delBtn];
        
        
        UIButton *leadBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW/2.0, 0, SCREENW/2.0, kShortBottomHeight)];
        [leadBtn setImage:[UIImage imageNamed:@"leadToAlbumIcon"] forState:UIControlStateNormal];
        [leadBtn setTitle:@"导出至手机通讯录" forState:UIControlStateNormal];
        [leadBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:7];
        [leadBtn setTitleColor:H5COLOR forState:UIControlStateNormal];
        leadBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [leadBtn addTarget:self  action:@selector(leadBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:leadBtn];
    }
    return _bottomView;
}

@end
