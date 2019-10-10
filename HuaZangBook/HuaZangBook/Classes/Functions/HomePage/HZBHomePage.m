//
//  HZBHomePage.m
//  HuaZangBook
//
//  Created by BIN on 2019/8/29.
//  Copyright © 2019 Neusoft. All rights reserved.
//

#import "HZBHomePage.h"
#import "HZBBookListVC.h"
#import "HZBAboutUsVC.h"
#import "HZBHomeCollectionCell.h"
#import <QuickLook/QuickLook.h>
#import "ReaderViewController.h"

@interface HZBHomePage ()<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,QLPreviewControllerDataSource,QLPreviewControllerDelegate,ReaderViewControllerDelegate>
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSArray * bookArray;
@property (nonatomic, strong) QLPreviewController *previewController;
@property (nonatomic, strong) NSURL *currentFileURL;
@property (nonatomic, strong) NSDictionary *currentFileInfo;

@end
@implementation HZBHomePage
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadLocalBookInfo:nil];
}

- (void)loadLocalBookInfo:(NSArray *)array {
    if (!array.count) {
        array = [[NSUserDefaults standardUserDefaults] objectForKey:@"localDownLoadInfoArray"];
    }
    if (array.count) {
        CGFloat countH = floor((kScreenWidth-10)/[UIImage imageNamed:@"CH15-06-01_b"].size.width);
        NSMutableArray * dataSource = @[].mutableCopy;
        NSInteger count = 0;
        NSMutableArray * arrayH = @[].mutableCopy;
        for (NSDictionary * info in array) {
            if (count < countH) {
                count ++;
                [arrayH addObject:info];
            }else {
                [dataSource addObject:arrayH];
                arrayH = @[info].mutableCopy;
                count = 0;
            }
        }

        if (count == countH) {
            [dataSource addObject:arrayH];
            arrayH = @[].mutableCopy;
            count = 0;
        }

        if (arrayH.count&&(arrayH.count<countH)) {
            for (int i = 0; i<countH-arrayH.count; i++) {
                [arrayH addObject:@{}];
            }
            [dataSource addObject:arrayH];
        }
        self.bookArray = dataSource;
    }
    [self.collectionView reloadData];
    if (!self.bookArray.count) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"尚無法寶，是否添加" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        [action1 setValue:UIColor.textGrayColor forKey:@"titleTextColor"];
        [alertController addAction:action1];
        __weak __typeof(self) weakSelf = self;
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf actionToPushBookList];

        }];
        [action2 setValue:UIColor.textBlueColor forKey:@"titleTextColor"];
        [alertController addAction:action2];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)initSubviews {
    [self initNavigationItems];

    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(kTopHeight+5, 5, kBottomHeight, 5));
    }];
}

- (void)initNavigationItems {
    self.title = @"華藏數位法寶";
    self.navigationView.hidesBackButton = YES;
    __weak __typeof(self) weakSelf = self;
    HZBaseNavigationItem * aboutButton = [[HZBaseNavigationItem alloc] init];
    [aboutButton setTitle:@"關於" forState:HZNavigationItemStateNormal];
    [aboutButton setTitleColor:UIColor.whiteColor forState:HZNavigationItemStateNormal];
    [[aboutButton rac_signalForControlEvents:HZNavigationItemEeventTouchUpInside] subscribeNext:^(HZBaseNavigationItem * navigationItem) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf actionToPushAboutUs];
    }];

    HZBaseNavigationItem * bookButton = [[HZBaseNavigationItem alloc] init];
    [bookButton setTitle:@"目錄" forState:HZNavigationItemStateNormal];
    [bookButton setTitleColor:UIColor.whiteColor forState:HZNavigationItemStateNormal];
    [[bookButton rac_signalForControlEvents:HZNavigationItemEeventTouchUpInside] subscribeNext:^(HZBaseNavigationItem * navigationItem) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf actionToPushBookList];
    }];
    self.navigationView.rightItems = @[aboutButton,bookButton];
}

#pragma mark - Method
-(BOOL)isFileExistAtPath:(NSString*)fileFullPath {
    BOOL isExist = NO;
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileFullPath];
    return isExist;
}

- (void)actionToDelete:(UILongPressGestureRecognizer *)longGes {
    if (longGes.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *selectPath = [self.collectionView indexPathForItemAtPoint:[longGes locationInView:longGes.view]];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"確認刪除選中的圖書嗎" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        [action1 setValue:UIColor.textGrayColor forKey:@"titleTextColor"];
        [alertController addAction:action1];
        __weak __typeof(self) weakSelf = self;
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"確認" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            NSDictionary * info = strongSelf.bookArray[selectPath.section][selectPath.row];
            NSArray * array = [[NSUserDefaults standardUserDefaults] objectForKey:@"localDownLoadInfoArray"];
            NSMutableArray * tempArray = @[].mutableCopy;
            for (NSDictionary * localInfo in array) {
                if (![localInfo[@"fabo_serial"] isEqualToString:info[@"fabo_serial"]]) {
                    [tempArray addObject:localInfo];
                }
            }
            [[NSUserDefaults standardUserDefaults] setObject:tempArray forKey:@"localDownLoadInfoArray"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            NSString *downloadPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"/downloadFiles"];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager createDirectoryAtPath:downloadPath withIntermediateDirectories:YES attributes:nil error:nil];
            NSString *filePath = [downloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",info[@"fabo_serial"]]];
            NSError * error;
            [fileManager removeItemAtPath:filePath error:&error];
            [strongSelf loadLocalBookInfo:tempArray];

        }];
        [action2 setValue:UIColor.textBlueColor forKey:@"titleTextColor"];
        [alertController addAction:action2];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - Push
- (void)actionToPushBookList {
    HZBBookListVC * vc = [HZBBookListVC new];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)actionToPushAboutUs {
    HZBAboutUsVC * vc = [HZBAboutUsVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - QLPreviewController DataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.currentFileURL;
}

#pragma mark - QLPreviewController Delegate

- (void)previewControllerWillDismiss:(QLPreviewController *)controller {
//    NSMutableDictionary * info = [[[NSUserDefaults standardUserDefaults] objectForKey:@"localDownLoadInfoDictonary"] mutableCopy];
//    if (!info.count) {
//        info = @{}.mutableCopy;
//    }
//    [info setObject:@(controller.currentPreviewItemIndex) forKey:self.currentFileInfo[@"fabo_serial"]];
//    [[NSUserDefaults standardUserDefaults] setObject:info forKey:@"localDownLoadInfoDictonary"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)dismissReaderViewController:(ReaderViewController *)viewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UICollectionView DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.bookArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray * array = self.bookArray[section];
    return array.count;
}

- (HZBHomeCollectionCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary * info = self.bookArray[indexPath.section][indexPath.row];
    HZBHomeCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.imageURLString = info[@"img_b"];
    cell.title = info[@"fabo_title"];
    cell.isEmpty = (info.count==0);
    return cell;
}

#pragma mark - UICollectionView Delegate FlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

#pragma mark - UICollectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary * info = self.bookArray[indexPath.section][indexPath.row];
    if (info.count) {
        NSString *downloadPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"/downloadFiles"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:downloadPath withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *filePath = [downloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",info[@"fabo_serial"]]];
        if ([self isFileExistAtPath:filePath]) {
            ReaderDocument *doc = [[ReaderDocument alloc] initWithFilePath:filePath password:nil];
            ReaderViewController *rederVC = [[ReaderViewController alloc] initWithReaderDocument:doc];
            rederVC.delegate = self;
            rederVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            rederVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self presentViewController:rederVC animated:YES completion:nil];

//            self.previewController  =  [[QLPreviewController alloc]  init];
//            self.previewController.dataSource  = self;
//            self.previewController.delegate  = self;
//            self.previewController.title = info[@"fabo_title"];
//            self.currentFileURL = [NSURL fileURLWithPath:filePath];
//            self.currentFileInfo = info;
////            NSDictionary * localIndexInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"localDownLoadInfoDictonary"];
////            NSInteger currentIndex = [localIndexInfo[info[@"fabo_serial"]] integerValue];
////            self.previewController.currentPreviewItemIndex = currentIndex;
//            [self presentViewController:self.previewController animated:YES completion:nil];
        }
    }
}

#pragma mark - Getter

- (UICollectionView *)collectionView {
    if (_collectionView) {
        return _collectionView;
    }
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
    CGSize imageSize = [UIImage imageNamed:@"CH15-06-01_b"].size;
    flowLayout.estimatedItemSize = CGSizeMake(imageSize.width, imageSize.height+45);
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kTopHeight, kScreenWidth, 0)
                                         collectionViewLayout:flowLayout];
    [_collectionView registerClass:HZBHomeCollectionCell.class forCellWithReuseIdentifier:@"cell"];
    _collectionView.backgroundColor = UIColor.whiteColor;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(actionToDelete:)];
    _collectionView.userInteractionEnabled = YES;
    [_collectionView addGestureRecognizer:longPressGesture];
    return _collectionView;
}
@end
