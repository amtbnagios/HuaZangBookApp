//
//  HZBAboutUsVC.m
//  HuaZangBook
//
//  Created by BIN on 2019/8/29.
//  Copyright © 2019 Neusoft. All rights reserved.
//

#import "HZBAboutUsVC.h"
#import "HZBAboutUsCell.h"

#import "HZWebViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "CommonUtil.h"

@interface HZBAboutUsVC ()<UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) UITableView * tableView;

@end
@implementation HZBAboutUsVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubviews];
}

- (void)initSubviews {
    self.title = @"華藏數位法寶";

    [self.view addSubview:self.tableView];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(kTopHeight, 0, kBottomHeight, 0));
    }];
}


#pragma mark - Push

- (void)actionToPushWebView:(NSString *)URLString {
    HZWebViewController * vc = [[HZWebViewController alloc] init];
    vc.URLString = URLString;
    vc.showWebTitle = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionToSendEmail {
    if (![MFMailComposeViewController canSendMail]) {
        [CommonUtil showAlertView:@"設備不支持發送郵件"];
        return;
    }
    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
    mailCompose.mailComposeDelegate = self;
    [mailCompose setSubject:@""];
    [mailCompose setMessageBody:@"" isHTML:NO];
    [self presentViewController:mailCompose animated:YES completion:^{
        if (@available(iOS 11.0, *)) {
            //解决iOS11 系统发邮件页面适配问题.....
            for (id obj in mailCompose.view.subviews) {
                [((UIView *)obj) setFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)-20)];
            }
            mailCompose.view.transform=CGAffineTransformMakeTranslation(0,20);
        }
    }];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    switch (result) {
        case MFMailComposeResultSent:
            [CommonUtil showAlertView:@"發送成功"];
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:^{
    }];
}
#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self configCell:tableView atIndexPath:indexPath];
}

- (HZBaseTableViewCell *)configCell:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    HZBAboutUsCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[HZBAboutUsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        __weak __typeof(self) weakSelf = self;
        [cell.URLSignal subscribeNext:^(id  _Nullable x) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf actionToPushWebView:@"https://www.hwadzan.tv/"];
        }];

        [cell.emailSignal subscribeNext:^(id  _Nullable x) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf actionToSendEmail];
        }];
    }
    return cell;
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (_tableView) {
        return _tableView;
    }
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTopHeight, kScreenWidth, kScreenHeight-kTopHeight-kBottomHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedSectionHeaderHeight = 0.f;
    _tableView.estimatedSectionFooterHeight = 0.f;
    _tableView.backgroundColor = UIColor.whiteColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 55.f;
    return _tableView;
}

@end
