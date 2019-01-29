//
//  CommonDocumentController.m
//  CommonLibrary
//
//  Created by QMP on 2018/11/6.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import "CommonDocumentController.h"
#include <mupdf/common.h>

#import <mupdf/MuPageViewNormal.h>
#import <mupdf/MuPageViewReflow.h>
#import <mupdf/MuDocumentController.h>
#import <mupdf/MuTextFieldController.h>
#import <mupdf/MuChoiceFieldController.h>
#import <mupdf/MuPrintPageRenderer.h>
#import "TestNetWorkReached.h"
#import "MainNavViewController.h"
#import "UploadView.h"

#import "IQKeyboardManager.h"
#import "AlertInfo.h"
#import "ShareTo.h"
#import "GetSizeWithText.h"
#import "WXApi.h"
#import "ManagerHud.h"

#define GAP 20
#define INDICATOR_Y -44-24
#define SLIDER_W (width - GAP - 24)
#define SEARCH_W (width - GAP - 170)
#define MIN_SCALE (1.0)
#define MAX_SCALE (5.0)

static NSString *const AlertTitle = @"Save Document?";
// Correct functioning of the app relies on CloseAlertMessage and ShareAlertMessage differing
static NSString *const CloseAlertMessage = @"Changes have been made to the document that will be lost if not saved";
static NSString *const ShareAlertMessage = @"Your changes will not be shared unless the document is first saved";

static void flattenOutline(NSMutableArray *titles, NSMutableArray *pages, fz_outline *outline, int level)
{
    char indent[8*4+1];
    if (level > 8)
        level = 8;
    memset(indent, ' ', level * 4);
    indent[level * 4] = 0;
    while (outline)
    {
        int page = outline->page;
        if (page >= 0 && outline->title)
        {
            NSString *title = @(outline->title);
            [titles addObject: [NSString stringWithFormat: @"%s%@", indent, title]];
            [pages addObject: @(page)];
        }
        flattenOutline(titles, pages, outline->down, level + 1);
        outline = outline->next;
    }
}

static char *tmp_path(const char *path)
{
    int f;
    char *buf = (char*)malloc(strlen(path) + 6 + 1);
    if (!buf)
        return NULL;
    
    strcpy(buf, path);
    strcat(buf, "XXXXXX");
    
    f = mkstemp(buf);
    
    if (f >= 0)
    {
        close(f);
        return buf;
    }
    else
    {
        free(buf);
        return NULL;
    }
}

static void saveDoc(const char *current_path, fz_document *doc)
{
    char *tmp;
    pdf_document *idoc = pdf_specifics(ctx, doc);
    pdf_write_options opts = { 0 };
    
    opts.do_incremental = 1;
    
    if (!idoc)
        return;
    
    tmp = tmp_path(current_path);
    if (tmp)
    {
        int written = 0;
        
        fz_var(written);
        fz_try(ctx)
        {
            FILE *fin = fopen(current_path, "rb");
            FILE *fout = fopen(tmp, "wb");
            char buf[256];
            size_t n;
            int err = 1;
            
            if (fin && fout)
            {
                while ((n = fread(buf, 1, sizeof(buf), fin)) > 0)
                    fwrite(buf, 1, n, fout);
                err = (ferror(fin) || ferror(fout));
            }
            
            if (fin)
                fclose(fin);
            if (fout)
                fclose(fout);
            
            if (!err)
            {
                pdf_save_document(ctx, idoc, tmp, &opts);
                written = 1;
            }
        }
        fz_catch(ctx)
        {
            written = 0;
        }
        
        if (written)
        {
            rename(tmp, current_path);
        }
        
        free(tmp);
    }
}

@interface CommonDocumentController()<UploadViewDelegate>
{
    fz_document *doc;
    MuDocRef *docRef;
    NSString *key;
    NSString *_filePath;
    BOOL reflowMode;
    MuOutlineController *outline;
    UIScrollView *canvas;
    UILabel *indicator;
    UISlider *slider;
    UISearchBar *searchBar;
    UIBarButtonItem *cancelButton;//, *searchButton
    UIBarButtonItem *moreButton;
    UIBarButtonItem *printButton;//*shareButton
    UIBarButtonItem *highlightButton;
    UIBarButtonItem *tickButton;
    UIBarButtonItem *deleteButton;
    UIBarButtonItem *reflowButton;
    UIBarButtonItem *backButton;
    UIBarButtonItem *sliderWrapper;
    UIBarButtonItem *rightBarBtnItem;
    UIBarButtonItem *searchBarBtnItem;
    UIButton *changePageButton, *searchButton, *shareButton, *collectPdfButton, *outlineButton;
    UIView *tabbarView;
    UIView *toolView;
    UIButton *nextButton, *prevButton;
    UIView *searchToolView;
    UILabel *searchResultLbl;
    
    int searchCount;
    int barmode;
    int searchPage;
    int cancelSearch;
    int showLinks;
    int width; // current screen size
    int height;
    int current; // currently visible page
    int scroll_animating; // stop view updates during scrolling animations
    float scale; // scale applied to views (only used in reflow mode)
    BOOL _isRotating;
}
@property (strong, nonatomic) UILabel *titleLbl;

@property (nonatomic,strong) AlertInfo *alertInfoTool;
@property (strong, nonatomic) ShareTo *shareToTool;
@property (strong, nonatomic) GetSizeWithText *getSizeTool;
@property (strong, nonatomic) ManagerHud *hud;
@property (strong, nonatomic) ManagerHud *uploadHudTool;

@property (strong, nonatomic) NSURLSessionDataTask *task;
@property (strong, nonatomic) UploadView *uploadView;
@property (strong, nonatomic) NSString *local_filePath;
@property (strong, nonatomic) NSString *action;

@end

@implementation CommonDocumentController

- (id) initWithFilename: (NSString*)filename path:(NSString *)cstr document: (MuDocRef *)aDoc
{
    self = [super init];
    if (!self)
        return nil;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
        self.automaticallyAdjustsScrollViewInsets = NO;
#endif
    
    //用于文件上传 & 登录通知0905 molly---
    self.local_filePath = cstr;
    self.action = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:NOTIFI_LOGIN object:nil];
    //---0905 molly
    
    key = filename;
    docRef = aDoc;
    doc = docRef->doc;
    _filePath = cstr;

    dispatch_sync(queue, ^{});
    
    fz_outline *root = fz_load_outline(ctx, doc);
    if (root) {
        NSMutableArray *titles = [[NSMutableArray alloc] init];
        NSMutableArray *pages = [[NSMutableArray alloc] init];
        flattenOutline(titles, pages, root, 0);
        if ([titles count]){
            outline = [[MuOutlineController alloc] initWithTarget:self titles: titles pages: pages];
        }
        fz_drop_outline(ctx, root);
    }
    
    //接收从微信拷贝过来pdf的通知,刷新UI
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUI) name:@"openNewPdfFromWX" object:nil];
    return self;
}

- (UIBarButtonItem *)newResourceBasedButton:(NSString *)resource withAction:(SEL)selector
{
    //    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //不显示
    //    {
    //        return [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:resource ofType:@"png"]] style:UIBarButtonItemStylePlain target:self action:selector];
    //    }
    //    else
    {
        UIButton *button = [[UIButton alloc]initWithFrame:LEFTBUTTONFRAME];
        [button setImage:[BundleTool imageNamed:resource] forState:UIControlStateNormal];
        [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        
        if (iOS11_OR_HIGHER) {
            button.width = 30;
            button.contentEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 0);
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
            
            return leftButtonItem;
        }else{
            return [[UIBarButtonItem alloc] initWithCustomView:button];
            
        }
    }
}

- (UIBarButtonItem *)newResourceBasedButton:(NSString *)resource withAction:(SEL)selector ofWidth:(CGFloat)width atIndex:(NSInteger)index{
    
    UIButton  *button = [[UIButton alloc] initWithFrame:CGRectMake(0, index * 36 + 8, 36, 36)];
    [button setBackgroundImage:[BundleTool imageNamed:resource] forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}
- (UIButton *)newResourceBasedButton:(NSString *)resource withAction:(SEL)selector atIndex:(NSInteger)index ofMargin:(CGFloat)margin{
    
    UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(margin + (margin + 36) * index,4, 36, 36)];
    [button setBackgroundImage:[BundleTool imageNamed:resource] forState:UIControlStateNormal];
    //    [button setImage:[BundleTool imageNamed:resource] forState:UIControlStateNormal];
    
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)newResourceBasedButton:(NSString *)resource withAction:(SEL)selector atIndex:(NSInteger)index ofMargin:(CGFloat)margin aY:(CGFloat)y aWidth:(CGFloat)aWidth aHeight:(CGFloat)aHeight aTitle:(NSString *)title{
    
    UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(margin + (margin + aWidth) * index, y, aWidth, aHeight)];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:17.f];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)newResourceBasedButton:(NSString *)resource selectedResource:(NSString *)selectedResource withAction:(SEL)selector atIndex:(NSInteger)index ofMargin:(CGFloat)margin{
    UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(margin + (margin + 36) * index, 4, 36, 36)];
    [button setBackgroundImage:[BundleTool imageNamed:resource] forState:UIControlStateNormal];
    [button setBackgroundImage:[BundleTool imageNamed:selectedResource] forState:UIControlStateSelected];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void) addMainMenuButtons
{
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = LEFTNVSPACE;
    
    if (iOS11_OR_HIGHER) {
        self.navigationItem.leftBarButtonItems = @[backButton];
        
    }else{
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = LEFTNVSPACE;
        self.navigationItem.leftBarButtonItems = @[negativeSpacer,backButton];
    }
    
    self.navigationItem.rightBarButtonItem = rightBarBtnItem;
}

- (void) loadView
{
    [[NSUserDefaults standardUserDefaults] setValue: key forKey: @"OpenDocumentKey"];
    
    current = (int)[[NSUserDefaults standardUserDefaults] integerForKey: key];
    if (current < 0 || current >= fz_count_pages(ctx, doc))
        current = 0;
    
    UIView *view = [[UIView alloc] initWithFrame: CGRectZero];
    [view setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [view setAutoresizesSubviews: YES];
    view.backgroundColor = [UIColor grayColor];
    
    //设置最外面画布
    canvas = [[UIScrollView alloc] initWithFrame: CGRectMake(0,0,GAP,0)];
    [canvas setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [canvas setPagingEnabled: YES];
    canvas.scrollEnabled = YES;
    [canvas setShowsHorizontalScrollIndicator: NO];
    [canvas setShowsVerticalScrollIndicator: NO];
    [canvas setDelegate: self];
    
    //点击换页
    UITapGestureRecognizer *tapRecog = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(onTap:)];
    tapRecog.delegate = self;
    [canvas addGestureRecognizer: tapRecog];
    
    // the scale changes to the subviews.
    //捏合手势
    UIPinchGestureRecognizer *pinchRecog = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)];
    pinchRecog.delegate = self;
    [canvas addGestureRecognizer:pinchRecog];
    
    scale = 1.0;
    
    scroll_animating = NO;
    
    //标明页码的label
    indicator = [[UILabel alloc] initWithFrame: CGRectZero];
    [indicator setAutoresizingMask: UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
    [indicator setText: @"0000/9999"];
    [indicator sizeToFit];
    [indicator setCenter: CGPointMake(0, INDICATOR_Y)];
    [indicator setTextAlignment: NSTextAlignmentCenter];
    [indicator setBackgroundColor: [[UIColor blackColor] colorWithAlphaComponent: 0.5]];
    [indicator setTextColor: [UIColor whiteColor]];
    
    [view addSubview: canvas];
    [view addSubview: indicator];
    
    
    // Set up the buttons on the navigation and search bar
    //导航栏和底部按钮
    UIButton *canBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 44)];
    [canBtn setTitleColor:NV_OTHERTITLE_COLOR forState:UIControlStateNormal];
    [canBtn setTitle:@"取消" forState:UIControlStateNormal];
    [canBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
    [canBtn addTarget:self action:@selector(onCancel) forControlEvents:UIControlEventTouchUpInside];
    canBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    cancelButton = [[UIBarButtonItem alloc] initWithCustomView:canBtn];
    reflowButton = [self newResourceBasedButton:@"ic_reflow" withAction:@selector(onToggleReflow:)];
    
    CGFloat margin = (SCREENW - 4 * 36 ) / 5;
    //    changePageButton = [self newResourceBasedButton:@"change-page" withAction:@selector(onChangePage:) atIndex:0 ofMargin:margin];
    outlineButton = [self newResourceBasedButton:@"list" withAction:@selector(onShowOutline:) atIndex:0 ofMargin:margin];
    [outlineButton setBackgroundImage:[BundleTool imageNamed:@"list-disable"] forState:UIControlStateDisabled];
    
    
    if (outline) {
        outlineButton.enabled = YES;
    }
    else{
        outlineButton.enabled = NO;
    }
    outlineButton.enabled = NO;  //手动设置不可点击
    
    shareButton = [self newResourceBasedButton:@"share-other" withAction:@selector(onShare:) atIndex:1 ofMargin:margin];
    searchButton = [self newResourceBasedButton:@"search-pdf" withAction:@selector(onShowSearch:) atIndex:2 ofMargin:margin];
    collectPdfButton = [self newResourceBasedButton:@"collect-pdf" selectedResource:@"collect-selected" withAction:@selector(onCollect:) atIndex:3 ofMargin:margin];
    //    [collectPdfButton setImage:[BundleTool imageNamed:@"collect-disable"] forState:UIControlStateDisabled];
    collectPdfButton.selected = self.pdfModel.collectFlag.integerValue;
    tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW,44)];
    [tabbarView addSubview:outlineButton];
    [tabbarView addSubview:searchButton];
    [tabbarView addSubview:shareButton];
    [tabbarView addSubview:collectPdfButton];
    
    if (self.pdfModel.collectFlag) {
        collectPdfButton.enabled = YES;
        if ([self.pdfModel.collectFlag isEqualToString:@"1"]) {
            [collectPdfButton setSelected:YES];
        }
    }else{
        
        collectPdfButton.enabled = NO;
    }
    if ([self.pdfModel.collectFlag isEqualToString:@"禁止收藏"]) { //收到的BP禁止
        collectPdfButton.enabled = NO;
    }
    [self.navigationController.toolbar setBackgroundImage:[UIImage imageFromColor:[UIColor whiteColor] andSize:tabbarView.size] forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsDefault];
    
    toolView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENH - self.navigationController.toolbar.height-40, SCREENW, 36.f)];
    toolView.backgroundColor = [UIColor clearColor];
    [view addSubview:toolView];
    
    //滑块,滑动可切换页面
    slider = [[UISlider alloc] initWithFrame: CGRectZero];
    [slider setMinimumValue: 0];
    [slider setMaximumValue: fz_count_pages(ctx, doc) - 1];
    [slider addTarget: self action: @selector(onSlide:) forControlEvents: UIControlEventValueChanged];
    [slider setTintColor:RGBa(255, 184, 64, 1)];
    [toolView addSubview:slider];
    
    
    backButton = [self newResourceBasedButton:@"left-arrow" withAction:@selector(onBack:)];
    
    UIButton *shareUrlBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [shareUrlBtn setImage:[BundleTool imageNamed:@"card_share"] forState:UIControlStateNormal];
    [shareUrlBtn addTarget:self action:@selector(presssShareUrl:) forControlEvents:UIControlEventTouchUpInside];
    rightBarBtnItem = [[UIBarButtonItem alloc] initWithCustomView:shareUrlBtn];
    
    CGFloat pageControlWidth = SCREENW / 2;
    prevButton = [self newResourceBasedButton:@"prev-pdf" withAction:@selector(onSearchPrev:) atIndex:0 ofMargin:0 aY:0 aWidth:pageControlWidth aHeight:44 aTitle:@"上一个"];
    nextButton = [self newResourceBasedButton:@"next-pdf" withAction:@selector(onSearchNext:) atIndex:1 ofMargin:0 aY:0 aWidth:pageControlWidth aHeight:44 aTitle:@"下一个"];
    [prevButton setTitleColor:NV_OTHERTITLE_COLOR forState:UIControlStateNormal];
    [nextButton setTitleColor:NV_OTHERTITLE_COLOR forState:UIControlStateNormal];
    
    [prevButton setEnabled: NO];
    [nextButton setEnabled: NO];
    searchToolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 44)];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(SCREENW/2 + 0.5, 0, 1, 44)];
    [lineView setBackgroundColor:[UIColor whiteColor]];
    [searchToolView addSubview:lineView];
    [searchToolView addSubview:prevButton];
    [searchToolView addSubview:nextButton];
    
    searchCount = 0;
    
    //    CGFloat searchW = SCREENW - ( (SCREENW == 414 )? 20.f:16.f ) * 3 - 35.f;
    CGFloat searchW = SCREENW - 65;
    
    searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(0,0,searchW,32)];
    [searchBar setPlaceholder: @"搜索关键字"];
    [searchBar setDelegate: self];
    [searchBar setSearchFieldBackgroundImage:[BundleTool imageNamed:@"searchBarBg"] forState:UIControlStateNormal];
    [searchBar setSearchTextPositionAdjustment:UIOffsetMake(10, 0)];
    
    UITextField *tf = [searchBar valueForKey:@"_searchField"];
    tf.font = [UIFont systemFontOfSize:14];
    NSString *str = @"搜索关键字";
    tf.attributedPlaceholder = [[NSAttributedString alloc]initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    searchBarBtnItem = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
    searchResultLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 0, 20)];
    searchResultLbl.font = [UIFont systemFontOfSize:12];
    searchResultLbl.textColor = [UIColor grayColor];
    [searchBar addSubview:searchResultLbl];
    
    //设置最初状态的nav按钮
    [self addMainMenuButtons];
    
    // TODO: add activityindicator to search bar
    
    [self setView: view];
}

- (void) dealloc
{
    docRef = nil;
    doc = NULL;
    indicator = nil;
    slider = nil;
    backButton = nil;
    searchBar = nil;
    searchButton = nil;
    cancelButton = nil;
    prevButton = nil;
    nextButton = nil;
    shareButton = nil;
    highlightButton = nil;
    deleteButton = nil;
    canvas = nil;
    changePageButton = nil;
    collectPdfButton = nil;
    tabbarView = nil;
    searchToolView = nil;
    
    _filePath = nil;
    
    //登录成功的通知 0905 molly---
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //---0905 molly
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREENW - 100, 20)];
    titleLbl.font = [UIFont systemFontOfSize:16.f];
    titleLbl.textColor = NV_TITLE_COLOR;
    titleLbl.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLbl;
    self.titleLbl = titleLbl;
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:[UIColor whiteColor] andSize:CGSizeMake(SCREENW, 20)]];
    
    imgView.frame = CGRectMake(0, -20, SCREENW, 64.f);
    
    //监听状态栏的改变
    [[ NSNotificationCenter defaultCenter ] addObserver : self selector : @selector (layoutControllerSubViews) name : UIApplicationDidChangeStatusBarFrameNotification object : nil ];
    
    if (![PublicTool isNull:self.pdfModel.reportId]) {
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"report/setReadCount" HTTPBody:@{@"report_id":self.pdfModel.reportId} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
        }];
    }
}

- (void)layoutControllerSubViews{
    toolView.top = self.view.height - self.navigationController.toolbar.height-40;
}

- (void) viewWillAppear: (BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = YES;
    
    NSString *filename = [key lastPathComponent];
    NSString *title = [filename substringWithRange:NSMakeRange(0, filename.length)];
    self.titleLbl.text = title;
    self.navigationItem.titleView = self.titleLbl;
    
    [slider setValue: current];
    
    [indicator setText: [NSString stringWithFormat: @" %d/%d ", current+1, fz_count_pages(ctx, doc)]];
    
    toolView.hidden = NO;
    
    [[self navigationController] setToolbarHidden: NO animated: animated];
    
    /*iOS 11导航
     <__NSArrayM 0x600000a4de00>(
     <_UIBarBackground: 0x7f98a1e8fc00; frame = (0 -20; 375 64); userInteractionEnabled = NO; layer = <CALayer: 0x604000624dc0>>,
     <_UINavigationBarLargeTitleView: 0x7f98a1e41a40; frame = (0 0; 0 0); clipsToBounds = YES; hidden = YES; layer = <CALayer: 0x604000425300>>,
     <_UINavigationBarContentView: 0x7f98a1e417a0; frame = (0 0; 375 44); layer = <CALayer: 0x604000620720>>,
     <_UINavigationBarModernPromptView: 0x7f98a1e423f0; frame = (0 0; 0 0); alpha = 0; hidden = YES; layer = <CALayer: 0x604000434ba0>>,
     <UIImageView: 0x7f98a1f12640; frame = (0 -20; 375 64); opaque = NO; userInteractionEnabled = NO; layer = <CALayer: 0x600000c20700>>
     )*/
    if (@available(iOS 11.0,*)) { //iOS11
        for (UIView *subV in self.navigationController.navigationBar.subviews){
            if ([subV isKindOfClass:[UIImageView class]] && subV.height == 64) {
                [subV removeFromSuperview];
            }
        }
    }
    
    toolView.top = self.view.height - 20;
    //    [self requestGetCollectFlag];  //根据传入的值就能确定
    
}

- (void) viewWillLayoutSubviews
{
    CGSize size = [canvas frame].size;
    int max_height = fz_max(height, size.height);
    
    width = size.width;
    height = size.height;
    
    [canvas setContentInset: UIEdgeInsetsZero];
    [canvas setContentSize: CGSizeMake( width, fz_count_pages(ctx, doc) * height)];
    [canvas setContentOffset: CGPointMake( 0, current * height)];
    
    [sliderWrapper setWidth: SLIDER_W];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        CGRect r = [[self navigationController] toolbar].frame;
        r.origin.x = 0;
        r.origin.y = 0;
        [slider setFrame:r];
    }
    
    [[[self navigationController] toolbar] setNeedsLayout]; // force layout!
    
    // use max_width so we don't clamp the content offset too early during animation
    [canvas setContentSize: CGSizeMake( width , fz_count_pages(ctx, doc) * max_height)];
    [canvas setContentOffset: CGPointMake( 0, current * height)];
    
    for (UIView<MuPageView> *view in [canvas subviews]) {
        if ([view number] == current) {
            [view setFrame: CGRectMake( 0,[view number] * height, width-GAP, height)];
            [view willRotate];
        }
    }
    for (UIView<MuPageView> *view in [canvas subviews]) {
        if ([view number] != current) {
            [view setFrame: CGRectMake( 0,[view number] * height, width-GAP, height)];
            [view willRotate];
        }
    }
}

- (void) viewDidAppear: (BOOL)animated
{
    [super viewDidAppear:animated];
    
    //iOS 11 toolbar设置在viewdidappear中起作用
    [self.navigationController.toolbar addSubview:tabbarView];
    
    
    if (@available(iOS 11.0, *)) {
        canvas.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self scrollViewDidScroll: canvas];
    
    
    
}

- (void) viewWillDisappear: (BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"OpenDocumentKey"];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    self.navigationController.navigationBar.translucent = NO;
    
}
- (void) showNavigationBar
{
    if ([[self navigationController] isNavigationBarHidden]) {
        [sliderWrapper setWidth: SLIDER_W];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            CGRect r = [[self navigationController] toolbar].frame;
            r.origin.x = 0;
            r.origin.y = 0;
            [slider setFrame:r];
        }
        [[self navigationController] setNavigationBarHidden: NO];
        [[self navigationController] setToolbarHidden: NO];
        toolView.hidden = NO;
        
        [UIView beginAnimations: @"MuNavBar" context: NULL];
        
        [[[self navigationController] navigationBar] setAlpha: 1];
        [[[self navigationController] toolbar] setAlpha: 1];
        
        [UIView commitAnimations];
    }
}

- (void) hideNavigationBar
{
    if (![[self navigationController] isNavigationBarHidden]) {
        [searchBar resignFirstResponder];
        
        [UIView beginAnimations: @"MuNavBar" context: NULL];
        [UIView setAnimationDelegate: self];
        [UIView setAnimationDidStopSelector: @selector(onHideNavigationBarFinished)];
        
        [[[self navigationController] navigationBar] setAlpha: 0];
        [[[self navigationController] toolbar] setAlpha: 0];
        
        toolView.hidden = YES;
        
        [UIView commitAnimations];
    }
}

- (void) onHideNavigationBarFinished
{
    [[self navigationController] setNavigationBarHidden: YES];
    [[self navigationController] setToolbarHidden: YES];
    //    [indicator setHidden: YES];
    toolView.hidden = YES;
}

- (void) onShowOutline: (id)sender
{
    
    MainNavViewController *nav = [[MainNavViewController alloc] initWithRootViewController:outline];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)pressLeftButtonItem:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void) onToggleLinks: (id)sender
{
    showLinks = !showLinks;
    for (UIView<MuPageView> *view in [canvas subviews])
    {
        if (showLinks)
            [view showLinks];
        else
            [view hideLinks];
    }
}

- (void) onToggleReflow: (id)sender
{
    reflowMode = !reflowMode;
    
    //    [annotButton setEnabled:!reflowMode];
    [searchButton setEnabled:!reflowMode];
    
    [[canvas subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self scrollViewDidScroll:canvas];
}


- (void) shareDocument
{
    
    shareButton.enabled = YES;
    NSString *titleStr = [NSString stringWithFormat:@"%@",self.pdfModel.name];
    
    NSString *detailStr = @"商业信息服务平台";
    
    //判断网络连接状态
    if ([TestNetWorkReached networkIsReached:self]) {
        if (![WXApi isWXAppInstalled]) { //检查微信是否已被用户安装,微信已安装返回YES
            //没安装则提示
            //            [self setupWXAlert:self];//弹出提示框
            
        }else{
            
            NSString *titleSessionStr = titleStr;
            NSString *titleTimelineStr = titleStr;
            NSString *urlStr = self.pdfModel.pdfUrl;
            NSString *copyString = [NSString stringWithFormat:@"%@%@来自@企名片",self.pdfModel.name,urlStr];

            [self.shareToTool shareWithDetailStr:detailStr sessionTitle:titleSessionStr timelineTitle:titleTimelineStr copyString:copyString aIcon:[BundleTool imageNamed:@"share_pdf.jpg"] aOpenUrl:urlStr onViewController:self shareResult:^(BOOL shareSuccess) {
                
            }];
        }
    }
}

#pragma mark - 设置提示语
- (void)setupWXAlert:(UIViewController *)viewController{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请先安装微信客户端" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        alertView.tag = 602;
        [alertView show];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请先安装微信客户端" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [viewController.navigationController popViewControllerAnimated:YES];
        }];
        [alert addAction:actionConfirm];
        [viewController presentViewController:alert animated:YES completion:nil];
    }
}

- (void)presssShareUrl:(UIButton *)sender{
    
    pdf_document *idoc = pdf_specifics(ctx, doc);
    if (idoc && ![PublicTool isNull:self.pdfModel.pdfUrl]) {
        [self shareDocument];
        barmode = BARMODE_SHARE;
    }else{
        [PublicTool showMsg:@"此链接不支持分享"];
    }
    
}

- (void) onShare: (id)sender
{
    NSString *_filePathUtf = _filePath;
    NSURL *localFileUrl = [NSURL fileURLWithPath:_filePathUtf];
    //    NSURL *fileUrl = [NSURL URLWithString:self.pdfModel.pdfUrl];
    //    NSArray *shareItems = @[fileUrl,self.pdfModel.name,[BundleTool imageNamed:@"open-pdf.png"]];
    NSArray *shareItems = @[localFileUrl];
    UIActivityViewController *cont = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    cont.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll];
    cont.popoverPresentationController.barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cont.popoverPresentationController.barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
        [self presentViewController:cont animated:YES completion:nil];
    } else {
        [self presentViewController:cont animated:YES completion:nil];
    }
    [cont setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        if (completed) {
            [PublicTool showMsg:@"完成"];
        }
    }];
}

/**
 *  点击换页,出现slider
 *
 *  @param sender
 */
- (void)onChangePage:(id)sender{
    barmode = BARMODE_SLIDER;
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = RIGHTNVSPACE;
    self.navigationItem.rightBarButtonItems = @[ negativeSpacer,cancelButton];
    
    [tabbarView removeFromSuperview];
    [self.navigationController.toolbar addSubview:slider];
    
}

- (void)onCollect:(id)sender{
    
    if (!self.pdfModel.reportId || [self.pdfModel.reportId isEqualToString:@""]) {
        //从其他应用打开的pdf
        //先上传,上传成功后处理收藏
        collectPdfButton.enabled = NO;
        
        self.action = @"collect";
        [self judgeRequest];
    }
    else{
        //云端收藏
        if (![ToLogin canEnterDeep]) {
            [ToLogin accessEnterDeep];
            return;
        }
        
        BOOL status = !self.pdfModel.collectFlag.integerValue;
        
        [self requestCollectPdf:status];
        
    }
}

/**
 *  请求收藏/取消 从其他应用打开的pdf
 *
 *  @param status
 */
- (void)requestLocalCollectPdf:(BOOL)status{
    //本地收藏
    NSMutableArray *collectMArr = nil;
    NSArray *collectArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"collectArr"];
    if (collectArr) {
        collectMArr = [NSMutableArray arrayWithArray:collectArr];
        
    }else{
        
        collectMArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    NSString *info = @"";
    
    if (status) {
        [collectMArr addObject:self.pdfModel.name];
        info = @"添加本地收藏成功";
    }
    else{
        
        if ([collectMArr containsObject:self.pdfModel.name]) {
            [collectMArr removeObject:self.pdfModel.name];
            info = @"取消本地收藏成功";
        }
    }
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:collectMArr forKey:@"collectArr"];
    [userDefaults synchronize];
    
    [ShowInfo showInfoOnView:self.view withInfo:info];
}

/**
 *  请求收藏或取消收藏pdf
 */
- (void)requestCollectPdf:(BOOL)status{
    
    NSString *collectStr = status ? @"1" : @"0";
    __block NSString *infoStr = status ? @"添加收藏成功" : @"取消收藏成功";
    if (self.pdfModel.isBP.integerValue == 1) {  // BP  删除 添加
        if (status == NO ) {
            
            [self deleteBPfile];
            
        }else{
            [self addBPfile];
        }
        return;
    }
    
    NSString *pdfType = self.pdfModel.pdfType;
    [PublicTool showHudWithView:KEYWindow];
    NSDictionary *param = @{@"fileid":self.pdfModel.reportId,@"filetype":(pdfType ? pdfType : @"selfcloudcollect"),@"collect":collectStr,@"fileext":@"pdf"};
    [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"l/collectpdf" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [PublicTool dismissHud:KEYWindow];
        
        if (resultData && [resultData[@"message"] isEqualToString:@"success"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ShowInfo showInfoOnView:self.view withInfo:infoStr];
                
                collectPdfButton.selected = status;
                collectPdfButton.enabled = YES;
                barmode = BARMODE_COLLECT;
                self.pdfModel.collectFlag = collectStr;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"collectPdfSuccess" object:self.pdfModel];
                
                //更新pdf收藏的状态
                //----------根据name和from更改本地数据库中的pdf的收藏状态
                DBHelper *dbHelper = [DBHelper shared];
                FMDatabase *db = [dbHelper toGetDB];
                NSString *tableName = PDFTABLENAME;
                if ([db open]) {
                    
                    NSString *updateSql = [NSString stringWithFormat:@"update '%@' set collect='%@' where name='%@' and  id='%@'", tableName,self.pdfModel.collectFlag,self.pdfModel.name, self.pdfModel.reportId];
                    BOOL res = [db executeUpdate:updateSql];
                    
                    [db close];
                }
                
            });
        }else{
            
            infoStr = @"收藏失败";
            dispatch_async(dispatch_get_main_queue(), ^{
                [ShowInfo showInfoOnView:self.view withInfo:infoStr];
                collectPdfButton.enabled = YES;
            });
        }
    }];
    
    if (status) {
        [QMPEvent event:@"PDF_collectBtn"];
    }
}

//BP 删除
- (void)deleteBPfile{
    
    [PublicTool showHudWithView:KEYWindow];
    NSString *bpid = self.pdfModel.reportId ? self.pdfModel.reportId:@"";
    [AppNetRequest deleteBPWithParameter:@{@"id":bpid} completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [PublicTool dismissHud:KEYWindow];
        
        if(resultData && [resultData[@"msg"] isEqualToString:@"success"]){
            [PublicTool showMsg:@"取消收藏成功"];
            collectPdfButton.selected = NO;
            collectPdfButton.enabled = YES;
            barmode = BARMODE_COLLECT;
            self.pdfModel.collectFlag = @"0";
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"collectPdfSuccess" object:self.pdfModel];
            
            //更新pdf收藏的状态
            //----------根据name和from更改本地数据库中的pdf的收藏状态
            DBHelper *dbHelper = [DBHelper shared];
            FMDatabase *db = [dbHelper toGetDB];
            NSString *tableName = PDFTABLENAME;
            if ([db open]) {
                
                NSString *updateSql = [NSString stringWithFormat:@"update '%@' set collect='%@' where name='%@' and  id='%@'", tableName,self.pdfModel.collectFlag,self.pdfModel.name, self.pdfModel.reportId];
                BOOL res = [db executeUpdate:updateSql];
                
                [db close];
            }
        }else{
            [PublicTool showMsg:@"取消收藏失败"];
            collectPdfButton.enabled = YES;
        }
        QMPLog(@"删除BP-------%@",resultData);
    }];
}

//BP 添加
- (void)addBPfile{
    
    NSString *reportId = self.pdfModel.reportId;
    [PublicTool showHudWithView:KEYWindow];
    
    [AppNetRequest addBPWithParameter:@{@"id":reportId} completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [PublicTool dismissHud:KEYWindow];
        
        if (resultData && [resultData[@"msg"] isEqualToString:@"success"]) {
            
            collectPdfButton.selected = YES;
            collectPdfButton.enabled = YES;
            barmode = BARMODE_COLLECT;
            self.pdfModel.collectFlag = @"1";
            [PublicTool showMsg:@"收藏成功"];
            //更新pdf收藏的状态
            //----------根据name和from更改本地数据库中的pdf的收藏状态
            DBHelper *dbHelper = [DBHelper shared];
            FMDatabase *db = [dbHelper toGetDB];
            NSString *tableName = PDFTABLENAME;
            if ([db open]) {
                
                NSString *updateSql = [NSString stringWithFormat:@"update '%@' set collect='%@' where name='%@' and  id='%@'", tableName,self.pdfModel.collectFlag,self.pdfModel.name, self.pdfModel.reportId];
                BOOL res = [db executeUpdate:updateSql];
                
                [db close];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"collectPdfSuccess" object:nil];
            
        }else{
            [PublicTool showMsg:@"收藏失败"];
            
        }
        QMPLog(@"添加刚删除的bp----%@",resultData);
    }];
}

- (void) textSelectModeOn
{
    [[self navigationItem] setRightBarButtonItems:[NSArray arrayWithObject:tickButton]];
    for (UIView<MuPageView> *view in [canvas subviews])
    {
        if ([view number] == current)
            [view textSelectModeOn];
    }
}

- (void) textSelectModeOff
{
    for (UIView<MuPageView> *view in [canvas subviews])
    {
        [view textSelectModeOff];
    }
}

- (void) onShowSearch: (id)sender
{
    
    [tabbarView removeFromSuperview];
    
    self.navigationItem.rightBarButtonItem = cancelButton;
    self.navigationItem.titleView = [[UIView alloc]init];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = 0;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,searchBarBtnItem];
    //    self.navigationItem.leftBarButtonItem = searchBarBtnItem;
    
    [IQKeyboardManager sharedManager].enable = NO;
    [searchBar becomeFirstResponder];
    [IQKeyboardManager sharedManager].enable = YES;
    
    if (IOS_VERSION >= 7) {
        [searchBar setTintColor:[UIColor blueColor]];
    }
    
    [self.navigationController.toolbar addSubview:searchToolView];
    
    barmode = BARMODE_SEARCH;
    
    toolView.hidden = YES;
}

- (void) onCancel{
    
    switch (barmode)
    {
        case BARMODE_SEARCH:{
            
            barmode = BARMODE_MAIN;
            cancelSearch = YES;
            searchCount = 0;
            
            [searchToolView removeFromSuperview];
            [self.navigationController.toolbar addSubview:tabbarView];
            toolView.hidden = NO;
            [searchBar resignFirstResponder];
            searchBar.text = @"";
            [self resetSearch];
            [[self navigationItem] setTitleView: self.titleLbl];
            [self addMainMenuButtons];
            [self textSelectModeOff];
            break;
        }
        case BARMODE_SLIDER:{
            barmode = BARMODE_MAIN;
            [slider removeFromSuperview];
            [self.navigationController.toolbar addSubview:tabbarView];
            [self addMainMenuButtons];
            [self textSelectModeOff];
            break;
        }
        case BARMODE_COLLECT:{
            
            break;
        }
        case BARMODE_SHARE:{
            
            break;
        }
    }
}

- (void) onBack: (id)sender
{
    [self refreshUI];
}

- (void)refreshUI{
    pdf_document *idoc = pdf_specifics(ctx, doc);
    
    if (idoc) {
        // 0902 molly---
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pdfDismiss" object:nil];
        //--- 0902 molly
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}
- (void) resetSearch
{
    [self clearSearch];
    searchPage = -1;
    for (UIView<MuPageView> *view in [canvas subviews])
        [view clearSearchResults];
}

- (void) showSearchResults: (int)count forPage: (int)number
{
    printf("%d页有搜索结果\n", number+1);
    searchPage = number;
    [self gotoPage: number animated: NO];
    for (UIView<MuPageView> *view in [canvas subviews])
        if ([view number] == number)
            [view showSearchResults: count];
        else
            [view clearSearchResults];
}

- (void) searchInDirection: (int)dir
{
    UITextField *searchField;
    char *needle;
    int start;

    [searchBar resignFirstResponder];

    if (searchPage == current)
        start = current + dir;
    else
        start = current;

    needle = strdup([[searchBar text] UTF8String]);

    searchField = nil;
    for (id view in [searchBar subviews])
        if ([view isKindOfClass: [UITextField class]])
            searchField = view;

    [prevButton setEnabled: NO];
    [nextButton setEnabled: NO];
    [searchField setEnabled: NO];

    cancelSearch = NO;

    dispatch_async(queue, ^{
        for (int i = start; i >= 0 && i < fz_count_pages(ctx, doc); i += dir) {
            int n = [super search_pages:doc num:i needle:needle cookie:NULL];
            
            if (n) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [prevButton setEnabled: YES];
                    [nextButton setEnabled: YES];
                    [searchField setEnabled: YES];
                    [self showSearchResults: n forPage: i];
                    free(needle);
                });
                return;
            }
            if (cancelSearch) {
                dispatch_async(dispatch_get_main_queue(), ^{

                    [self clearSearch];

                    [prevButton setEnabled: YES];
                    [nextButton setEnabled: YES];
                    [searchField setEnabled: YES];
                    free(needle);
                });
                return;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            printf("no search results found\n");
            [prevButton setEnabled: YES];
            [nextButton setEnabled: YES];
            [searchField setEnabled: YES];

            NSString *info = [NSString stringWithFormat: @"没有更多匹配项:%@",[NSString stringWithUTF8String: needle]];
            [ShowInfo showInfoOnView:self.view withInfo:info];

            free(needle);
        });
    });
}

- (void) onSearchPrev: (id)sender
{
    [self searchInDirection: -1];
}

- (void) onSearchNext: (id)sender
{
    [self searchInDirection: 1];
}

- (void) searchBarSearchButtonClicked: (UISearchBar*)sender
{
    [self onSearchNext: sender];
}

- (void) searchBar: (UISearchBar*)sender textDidChange: (NSString*)searchText
{
    [self resetSearch];
    if ([[searchBar text] length] > 0) {
        [prevButton setEnabled: YES];
        [nextButton setEnabled: YES];
    } else {
        [prevButton setEnabled: NO];
        [nextButton setEnabled: NO];
    }
}


/**
 滑块移动执行的方法
 
 @param sender <#sender description#>
 */
- (void) onSlide: (id)sender
{
    int number = [slider value];
    if ([slider isTracking])
        [indicator setText: [NSString stringWithFormat: @"%d/%d", number + 1, fz_count_pages(ctx, doc)]];
    else
        [self gotoPage: number animated: NO];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // For reflow mode, we load UIWebViews into the canvas. Returning YES
    // here prevents them stealing our tap and pinch events.
    return YES;
}

- (void) onTap: (UITapGestureRecognizer*)sender
{
    
    CGPoint p = [sender locationInView: canvas];
    CGPoint ofs = [canvas contentOffset];
    float x0 = (width - GAP) / 5;
    float x1 = (width - GAP) - x0;
    p.x -= ofs.x;
    p.y -= ofs.y;
    __block BOOL tapHandled = NO;
    for (UIView<MuPageView> *view in [canvas subviews])
    {
        CGPoint pp = [sender locationInView:view];
        if (CGRectContainsPoint(view.bounds, pp))
        {
            MuTapResult *result = [view handleTap:pp];
            __block BOOL hitAnnot = NO;
            [result switchCaseInternal:^(MuTapResultInternalLink *link) {
                [self gotoPage:link.pageNumber animated:NO];
                tapHandled = YES;
            } caseExternal:^(MuTapResultExternalLink *link) {
                // Not currently supported
            } caseRemote:^(MuTapResultRemoteLink *link) {
                // Not currently supported
            } caseWidget:^(MuTapResultWidget *widget) {
                tapHandled = YES;
            } caseAnnotation:^(MuTapResultAnnotation *annot) {
                hitAnnot = YES;
            }];
            
            switch (barmode)
            {
                    
                default:
                    if (hitAnnot)
                    {
                        // Annotation will have been selected, which is wanted
                        // only in annotation-editing mode
                        [view deselectAnnotation];
                    }
                    break;
            }
            
            if (tapHandled)
                break;
        }
    }
    if (tapHandled) {
        // Do nothing further
    }
    /**
     else if (p.x < x0) {
     [self gotoPage: current-1 animated: YES];
     } else if (p.x > x1) {
     [self gotoPage: current+1 animated: YES];
     }
     */
    else {
        
        if (barmode == BARMODE_SEARCH) {
            
            if(searchBar.isFirstResponder){
                
                if ([searchBar.text isEqualToString:@""]) {
                    //没有输入内容时,取消搜索这种状态
                    [self onCancel];
                }
                else{
                    //确认搜索这个关键字
                    [searchBar resignFirstResponder];
                    [self findSearchResults];
                    [self onSearchNext:nil];
                }
            }
            
        }else if ([[self navigationController] isNavigationBarHidden])
            [self showNavigationBar];
        else if (barmode == BARMODE_MAIN)
            [self hideNavigationBar];
    }
}

- (void) onPinch:(UIPinchGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
        sender.scale = scale;
    
    if (sender.scale < MIN_SCALE)
        sender.scale = MIN_SCALE;
    
    if (sender.scale > MAX_SCALE)
        sender.scale = MAX_SCALE;
    
    if (sender.state == UIGestureRecognizerStateEnded)
        scale = sender.scale;
    
    for (UIView<MuPageView> *view in [canvas subviews])
    {
        // Zoom only the visible page until end of gesture
        if (view.number == current || sender.state == UIGestureRecognizerStateEnded)
            [view setScale:sender.scale];
    }
}

- (void) scrollViewWillBeginDragging: (UIScrollView *)scrollView
{
    if (barmode == BARMODE_MAIN)
        [self hideNavigationBar];
}

- (void) scrollViewDidScroll: (UIScrollView*)scrollview
{
    // scrollViewDidScroll seems to get called part way through a screen rotation.
    // (This is possibly a UIScrollView bug - see
    // http://stackoverflow.com/questions/4123991/uiscrollview-disable-scrolling-while-rotating-on-iphone-ipad/8141423#8141423 ).
    // This ends up corrupting the current page number, because the calculation
    // 'current = x / width' is using the new value of 'width' before the
    // pages have been resized/repositioned. To avoid this problem, we filter out
    // calls to scrollViewDidScroll during rotation.
    
    
    if (barmode == BARMODE_SEARCH) {
        [searchBar resignFirstResponder];
    }
    
    if (_isRotating)
        return;
    
    if (width == 0)
        return; // not visible yet
    
    if (scroll_animating)
        return; // don't mess with layout during animations
    
    float y = [canvas contentOffset].y + height * 0.5f;
    current = y / height;
    
    [[NSUserDefaults standardUserDefaults] setInteger: current forKey: key];
    
    [indicator setText: [NSString stringWithFormat: @" %d/%d ", current+1, fz_count_pages(ctx, doc)]];
    [slider setValue: current];
    
    // swap the distant page views out
    
    NSMutableSet *invisiblePages = [[NSMutableSet alloc] init];
    for (UIView<MuPageView> *view in [canvas subviews]) {
        if ([view number] != current)
            [view resetZoomAnimated: YES];
        if ([view number] < current - 2 || [view number] > current + 2)
            [invisiblePages addObject: view];
    }
    for (UIView<MuPageView> *view in invisiblePages)
        [view removeFromSuperview];
    // don't bother recycling them...
    
    [self createPageView: current];
    [self createPageView: current - 1];
    [self createPageView: current + 1];
    
    // reset search results when page has flipped
    if (current != searchPage)
        [self resetSearch];
}

- (void) createPageView: (int)number
{
    if (number < 0 || number >= fz_count_pages(ctx, doc))
        return;
    int found = 0;
    for (UIView<MuPageView> *view in [canvas subviews])
        if ([view number] == number)
            found = 1;
    if (!found) {
        
        UIView<MuPageView> *view
        = reflowMode
        ? [[MuPageViewReflow alloc] initWithFrame:CGRectMake(0, number * height, width-GAP, height) document:docRef page:number]
        : [[MuPageViewNormal alloc] initWithFrame:CGRectMake(0, number * height, width-GAP, height) dialogCreator:self updater:self document:docRef page:number];
        
        [view setScale:scale];
        [canvas addSubview: view];
        if (showLinks)
            [view showLinks];
    }
}

- (void)onCancel:(id)sender{
    
}
/**
 跳转到指定页
 
 @param number   从0开始
 @param animated 是否自动滚动
 */
- (void) gotoPage: (int)number animated: (BOOL)animated
{
    if (number < 0){
        number = 0;
    }
    if (number >= fz_count_pages(ctx, doc)){
        number = fz_count_pages(ctx, doc) - 1;
    }
    if (current == number){
        //如果要跳转的页面就是当前页,不执行任何操作
        return;
    }
    if (animated) {
        // setContentOffset:animated: does not use the normal animation
        // framework. It also doesn't play nice with the tap gesture
        // recognizer. So we do our own page flipping animation here.
        // We must set the scroll_animating flag so that we don't create
        // or remove subviews until after the animation, or they'll
        // swoop in from origo during the animation.
        
        scroll_animating = YES;
        [UIView beginAnimations: @"MuScroll" context: NULL];
        [UIView setAnimationDuration: 0.4];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDelegate: self];
        [UIView setAnimationDidStopSelector: @selector(onGotoPageFinished)];
        
        for (UIView<MuPageView> *view in [canvas subviews])
            [view resetZoomAnimated: NO];
        
        [canvas setContentOffset: CGPointMake(0, number * height)];
        [slider setValue: number];
        [indicator setText: [NSString stringWithFormat: @" %d/%d ", number+1, fz_count_pages(ctx, doc)]];
        
        [UIView commitAnimations];
    } else {
        
        //当不自动滚动时
        for (UIView<MuPageView> *view in [canvas subviews]){
            //重置页面缩放状态
            [view resetZoomAnimated: NO];
        }
        //重置画布尺寸
        [canvas setContentOffset:CGPointMake( 0,number * height)];
    }
    
    //设置当前页
    current = number;
}

- (void) invokeTextDialog:(NSString *)aString okayAction:(void (^)(NSString *))block
{
    MuTextFieldController *tf = [[MuTextFieldController alloc] initWithText:aString okayAction:block];
    tf.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:tf animated:YES completion:nil];
}

- (void) invokeChoiceDialog:(NSArray *)anArray okayAction:(void (^)(NSArray *))block
{
    MuChoiceFieldController *cf = [[MuChoiceFieldController alloc] initWithChoices:anArray okayAction:block];
    cf.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:cf animated:YES completion:nil];
}

- (void) onGotoPageFinished
{
    scroll_animating = NO;
    [self scrollViewDidScroll: canvas];
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)o
{
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _isRotating = YES;
}

- (void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation)o
{
    _isRotating = NO;
    
    // We need to set these here, because during the animation we may use a wider
    // size (the maximum of the landscape/portrait widths), to avoid clipping during
    // the rotation.
    [canvas setContentSize: CGSizeMake(width, fz_count_pages(ctx, doc) * height)];
    [canvas setContentOffset: CGPointMake( 0,current * height)];
}

- (void)findSearchResults{
    [self.hud addHud:self.view];

    char *needle;
    needle = strdup([[searchBar text] UTF8String]);
    dispatch_async(queue, ^{
        searchCount = 0;

        for (int i = 0; i >= 0 && i < fz_count_pages(ctx, doc); i += 1) {
            int n = [super search_pages:doc num:i needle:needle cookie:NULL];
            if (n > 0) {

                searchCount += n;
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            searchResultLbl.text = [NSString stringWithFormat:@"共%d个",searchCount];
            CGRect frame = searchResultLbl.frame;
            CGFloat lblW = [self.getSizeTool calculateSize:searchResultLbl.text withFont:[UIFont systemFontOfSize:12.f] withWidth:frame.size.width].width + 20;
            frame.size.width = lblW;
            frame.origin.x = searchBar.frame.size.width - 10 - lblW;

            searchResultLbl.frame = frame;
            [self.hud removeHud];
        });
    });
}

/**
 *  清除搜索相关信息
 */
- (void)clearSearch{
    searchCount = 0;
    searchResultLbl.text = @"";
    CGRect frame = searchResultLbl.frame;
    frame.size.width = 0;
    searchResultLbl.frame = frame;
}

- (void)judgeRequest{
    
    if ([TestNetWorkReached networkIsReachedAlertOnView:[UIApplication sharedApplication].keyWindow]) {
        if (![ToLogin canEnterDeep]) {
            [ToLogin accessEnterDeep];
            return;
        }
        
        [self requestUploadPdf];
        
    }
    
}

/**
 *  登录通知
 */
- (void)loginSuccess{
    
    //    collectPdfButton.enabled = YES;
    [self requestGetCollectFlag];
}


/**sea
 请求获取pdf收藏状态
 */
- (void)requestGetCollectFlag{
    
    [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"t/iscollecthybg" HTTPBody:@{@"fileid":self.pdfModel.reportId} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        if (resultData && [resultData isKindOfClass:[NSString class]]) {
            
            self.pdfModel.collectFlag = [NSString stringWithFormat:@"%@",resultData];
            collectPdfButton.enabled = YES;
            collectPdfButton.selected = [self.pdfModel.collectFlag isEqualToString:@"1"] ? YES : NO;
            
            //----------根据name和from更改本地数据库中的pdf的收藏状态
            NSString *from = (self.pdfModel.from ? self.pdfModel.from : PDFFURL);
            
            DBHelper *dbHelper = [DBHelper shared];
            FMDatabase *db = [dbHelper toGetDB];
            NSString *tableName = PDFTABLENAME;
            if ([db open]) {
                
                NSString *updateSql = [NSString stringWithFormat:@"update '%@' set collect='%@' where name='%@' and from ='%@'", tableName,self.pdfModel.collectFlag,self.pdfModel.name, from];
                BOOL res = [db executeUpdate:updateSql];
                
                [db close];
            }
        }else{
            collectPdfButton.enabled = YES;
        }
    }];
}
#pragma mark - 请求上传当前的pdf文件  目前逻辑没用
- (void)requestUploadPdf{
    
    _uploadView = [UploadView initFrame];
    _uploadView.delegate = self;
    [_uploadView initData];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:_uploadView];
    
    
    [AppNetRequest uploadPDFWithFilePath:self.local_filePath fileName:self.pdfModel.name params:@{@"upload_type":@"cloud"} progress:^(CGFloat progress) {
        
        [_uploadView changeProgressWithProgress:progress];
        
    } completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [_uploadView removeFromSuperview];
        _uploadView = nil;
        
        NSString *uploadStatus =@"";
        ReportModel *pdfModel = [[ReportModel alloc] init];
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *itemDict = [resultData objectForKey:@"item"];
            
            pdfModel.reportId = [NSString stringWithFormat:@"%@",[itemDict objectForKey:@"id"]];
            pdfModel.name = [itemDict objectForKey:@"name"];
            pdfModel.datetime = [itemDict objectForKey:@"datetime"];
            pdfModel.pdfUrl = [itemDict objectForKey:@"url"];
            pdfModel.remark = [itemDict objectForKey:@"remark"];
            pdfModel.openFlag = [itemDict objectForKey:@"open_flag"];
            pdfModel.collectFlag = [NSString stringWithFormat:@"collect_flag"];
            pdfModel.size = [itemDict objectForKey:@"size"];
            pdfModel.isDownload = YES;
            pdfModel.pdfType = @"";
            
            self.pdfModel = pdfModel;
            
            if ([self.action isEqualToString:@"share"]) {
                [self shareDocument];
                barmode = BARMODE_SHARE;
            }
            if ([self.action isEqualToString:@"collect"]) {
                
                BOOL status = !self.pdfModel.collectFlag;
                
                [self requestCollectPdf:status];
            }
            
        }else{
            NSString *info = @"上传失败,请重新操作";
            [ShowInfo showInfoOnView:self.view withInfo:info];
            collectPdfButton.enabled = YES;
        }
        
        self.action = @"";
    }];
}

#pragma mark - UploadViewDelegate
- (void)pressCancleDownLoad{
    [_uploadView removeFromSuperview];
    _uploadView = nil;
    
    collectPdfButton.enabled = YES;
    
    [_task cancel];
    _task = nil;
}

#pragma mark - 懒加载
- (ShareTo *)shareToTool{
    
    if (!_shareToTool) {
        _shareToTool = [[ShareTo alloc] init];
    }
    return _shareToTool;
}

- (AlertInfo *)alertInfoTool{
    
    if (!_alertInfoTool) {
        _alertInfoTool = [[AlertInfo alloc] init];
    }
    return _alertInfoTool;
}

- (GetSizeWithText *)getSizeTool{
    
    if (!_getSizeTool) {
        _getSizeTool = [[GetSizeWithText alloc] init];
    }
    return _getSizeTool;
}



- (ManagerHud *)uploadHudTool{
    
    if (!_uploadHudTool) {
        _uploadHudTool = [[ManagerHud alloc] init];
    }
    return _uploadHudTool;
}

- (ManagerHud *)hud{
    
    if (_hud) {
        _hud = [[ManagerHud alloc] init];
    }
    return _hud;
}

@end
