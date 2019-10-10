
//
//  HZBBookListVC.m
//  HuaZangBook
//
//  Created by BIN on 2019/8/30.
//  Copyright © 2019 Neusoft. All rights reserved.
//

#import "HZBBookListVC.h"
#import "HZBBookListMenuCell.h"
#import "HZBBookListBookCell.h"
#import "CommonUtil.h"
#import "MBProgressHUD.h"
#import "ChineseConvert.h"

@interface HZBBookListVC () <UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate>
@property (nonatomic, strong) UITableView * menuTableView;
@property (nonatomic, strong) UITableView * bookTableView;
@property (nonatomic, strong) UISearchBar * searchBar;

@property (nonatomic, strong) NSArray * menuArray;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) NSArray * menuSubArray;

@property (nonatomic, assign) BOOL isSearch;
@property (nonatomic, strong) NSArray * menuSearchArray;
@property (nonatomic, assign) CGFloat keyBoardHeight;
@end

@implementation HZBBookListVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self actionToRemote];
}

- (void)initSubviews {
    [self.view addSubview:self.menuTableView];
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.bookTableView];
    [self.menuTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(kTopHeight);
        make.bottom.mas_equalTo(-kBottomHeight);
        make.width.mas_equalTo(100);
    }];

    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(100);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(kTopHeight);
        make.height.mas_equalTo(57);
    }];

    [self.bookTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(100);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(kTopHeight+57);
        make.bottom.mas_equalTo(-kBottomHeight);
    }];
    [self initSignal];
}


- (void)initSignal {
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNotification * _Nullable x) {
        NSDictionary *useInfo = [x userInfo];
        NSValue *value = [useInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        self.keyBoardHeight = [value CGRectValue].size.height;
        __weak __typeof(self) weakSelf = self;
        [self.bookTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            make.bottom.mas_equalTo(-kBottomHeight-strongSelf.keyBoardHeight);
        }];
    }];

    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNotification * _Nullable x) {
        [self.bookTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-kBottomHeight);
        }];
    }];
}
#pragma mark - Method
- (void)actionToRemote {
    RemoteUtil * util = [RemoteUtil new];
    NSString * URLString = [NSString stringWithFormat:@"%@ibook_catalog",WapDomain];
    __weak __typeof(self) weakSelf = self;
    [util remoteURL:URLString method:RemoteMehodTypeGet param:nil complete:^(BOOL success, id  _Nonnull info) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (success) {
            [strongSelf initSubviews];
            strongSelf.menuArray = (NSArray *)info;
            NSDictionary * first = strongSelf.menuArray.firstObject;
            strongSelf.title = first[@"name"];
            strongSelf.selectedIndex = 0;
            [strongSelf.menuTableView reloadData];
            [strongSelf actionToRemoteSubList:first[@"aid"]];
        }
    }];
}

- (void)actionToRemoteSubList:(NSString *)aid{
    RemoteUtil * util = [RemoteUtil new];
    NSString * URLString = [NSString stringWithFormat:@"%@ibook_data/%@",WapDomain,aid];
    __weak __typeof(self) weakSelf = self;
    [util remoteURL:URLString method:RemoteMehodTypeGet param:nil complete:^(BOOL success, id  _Nonnull info) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (success) {
            strongSelf.menuSubArray = (NSArray *)info;
            [strongSelf.bookTableView reloadData];
        }
    }];
}

- (void)actionToDownLoad:(NSInteger)index {
    NSDictionary * info = self.menuSubArray[index];
    if (self.isSearch) {
        info = self.menuSearchArray[index];
    }
    NSString *downloadPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"/downloadFiles"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:downloadPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *filePath = [downloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",info[@"fabo_serial"]]];
    if ([self isFileExistAtPath:filePath]) {
        NSMutableArray * localDownLoadArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"localDownLoadInfoArray"] mutableCopy];
        if (!localDownLoadArray.count) {
            localDownLoadArray = @[info].mutableCopy;
        }else {
            BOOL search = NO;
            for (NSDictionary * localInfo in localDownLoadArray) {
                if ([localInfo[@"fabo_serial"] isEqualToString:info[@"fabo_serial"]]) {
                    search = YES;
                }
            }
            if (!search) {
                [localDownLoadArray insertObject:info atIndex:0];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:localDownLoadArray forKey:@"localDownLoadInfoArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }


    if ([info[@"pdf"] boolValue]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
        hud.label.text = @"下載中";
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            // Do something useful in the background and update the HUD periodically.
            AFHTTPSessionManager *manage  = [AFHTTPSessionManager manager];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/fabo/pdf/%@.pdf",WapDownLoad,info[@"fabo_serial"]]]];
            NSURLSessionDownloadTask *downloadTask = [manage downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {//进度
                if (downloadProgress) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        hud.label.text = [NSString stringWithFormat:@"%.2f%%",100.00 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount];
                        hud.progress = ((CGFloat)(downloadProgress.completedUnitCount))/((CGFloat)downloadProgress.totalUnitCount);
                        NSLog(@"%@",[NSString stringWithFormat:@"%.2f%%",100.00 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount]);
                    });
                }
            } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                NSString *downloadPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"/downloadFiles"];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager createDirectoryAtPath:downloadPath withIntermediateDirectories:YES attributes:nil error:nil];
                NSString *filePath = [downloadPath stringByAppendingPathComponent:response.suggestedFilename];
                return [NSURL fileURLWithPath:filePath];
            } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error) {
                NSLog(@"%@,%@,%@",response,filePath,error);
                if (filePath) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [hud hideAnimated:YES];
                        NSMutableArray * localDownLoadArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"localDownLoadInfoArray"] mutableCopy];
                        if (!localDownLoadArray.count) {
                            localDownLoadArray = @[info].mutableCopy;
                        }else {
                            [localDownLoadArray insertObject:info atIndex:0];
                        }
                        [[NSUserDefaults standardUserDefaults] setObject:localDownLoadArray forKey:@"localDownLoadInfoArray"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                }
            }];
            [downloadTask resume];
        });


    }else {
        [CommonUtil showAlertView:@"" withTitle:@"本類圖書暫不支持"];
    }
}

-(BOOL)isFileExistAtPath:(NSString*)fileFullPath {
    BOOL isExist = NO;
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileFullPath];
    return isExist;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.menuTableView) {
        NSDictionary * info = self.menuArray[indexPath.row];
        self.selectedIndex = indexPath.row;
        self.title = info[@"name"];
        self.menuSubArray = nil;
        [self.bookTableView reloadData];
        [self actionToRemoteSubList:info[@"aid"]];
    }else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"確認下載選中圖書嗎？" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        [action1 setValue:UIColor.textGrayColor forKey:@"titleTextColor"];
        [alertController addAction:action1];
        __weak __typeof(self) weakSelf = self;
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"確認" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf actionToDownLoad:indexPath.row];
        }];
        [action2 setValue:UIColor.textBlueColor forKey:@"titleTextColor"];
        [alertController addAction:action2];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.menuTableView) {
        return self.menuArray.count;
    }
    if (self.isSearch) {
        return self.menuSearchArray.count;
    }
    return self.menuSubArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self configCell:tableView atIndexPath:indexPath];
}

- (HZBaseTableViewCell *)configCell:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.menuTableView) {
        NSDictionary * info = self.menuArray[indexPath.row];
        HZBBookListMenuCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[HZBBookListMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            RAC(cell, selectedIndex) = RACObserve(self, selectedIndex);
        }
        cell.title = info[@"name"];
        cell.tag = indexPath.row;
        return cell;
    }
    NSDictionary * info = self.menuSubArray[indexPath.row];
    if (self.isSearch) {
        info = self.menuSearchArray[indexPath.row];
    }
    HZBBookListBookCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[HZBBookListBookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.title = info[@"fabo_title"];
    cell.desc = info[@"fabo_content"];
    cell.imageURLString = info[@"img_s"];
    return cell;

    return [HZBaseTableViewCell new];
}

#pragma mark - UISearchBar Delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:YES];
    self.menuSearchArray = @[];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:NO];
    self.isSearch = NO;
    [self.bookTableView reloadData];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar endEditing:YES];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.isSearch = YES;
    NSMutableArray * tempArray = @[].mutableCopy;
    for (NSDictionary * info in self.menuSubArray) {
        NSString * title =  info[@"fabo_title"];
        if ([title containsString:searchBar.text] ) {
            [tempArray addObject:info];
        }else if([title containsString:[ChineseConvert convertSimplifiedToTraditional:searchBar.text]]) {
            [tempArray addObject:info];
        }else if([title containsString:[ChineseConvert convertTraditionalToSimplified:searchBar.text]]) {
            [tempArray addObject:info];
        }
    }
    self.menuSearchArray = tempArray;
    [self.bookTableView reloadData];
}


#pragma mark - Getter
- (UITableView *)menuTableView {
    if (_menuTableView) {
        return _menuTableView;
    }
    _menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTopHeight, kScreenWidth, kScreenHeight-kTopHeight-kBottomHeight) style:UITableViewStyleGrouped];
    _menuTableView.delegate = self;
    _menuTableView.dataSource = self;
    _menuTableView.sectionHeaderHeight = 0.f;
    _menuTableView.sectionFooterHeight = 0.f;
    _menuTableView.rowHeight = 50.f;
    _menuTableView.backgroundColor = UIColor.whiteColor;
    _menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _menuTableView.estimatedRowHeight = 50.f;
    _menuTableView.showsVerticalScrollIndicator = NO;
    return _menuTableView;
}

- (UITableView *)bookTableView {
    if (_bookTableView) {
        return _bookTableView;
    }
    _bookTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTopHeight, kScreenWidth, kScreenHeight-kTopHeight-kBottomHeight) style:UITableViewStyleGrouped];
    _bookTableView.delegate = self;
    _bookTableView.dataSource = self;
    _bookTableView.sectionHeaderHeight = 0.f;
    _bookTableView.sectionFooterHeight = 0.f;
    _bookTableView.backgroundColor = UIColor.whiteColor;
    _bookTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _bookTableView.estimatedRowHeight = 75.f;
    _bookTableView.showsVerticalScrollIndicator = NO;
    return _bookTableView;
}

- (UISearchBar *)searchBar {
    if (_searchBar) {
        return _searchBar;
    }
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.barTintColor = UIColor.whiteColor;
    _searchBar.delegate = self;
    return _searchBar;
}
@end
