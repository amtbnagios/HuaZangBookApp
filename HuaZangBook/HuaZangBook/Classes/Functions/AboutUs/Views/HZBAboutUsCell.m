//
//  HZBAboutUsCell.m
//  HuaZangBook
//
//  Created by BIN on 2019/8/29.
//  Copyright © 2019 Neusoft. All rights reserved.
//

#import "HZBAboutUsCell.h"
#import "CBAutoScrollLabel.h"
#import "NSString+CalculateSize.h"

@interface HZBAboutUsCell ()
@property (nonatomic, strong) UIImageView * iconImageView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIButton * URLButton;
@property (nonatomic, strong) UILabel * companyLabel;
@property (nonatomic, strong) UIButton * phoneButton;
@property (nonatomic, strong) UIButton * faxButton;
@property (nonatomic, strong) UIButton * emailButton;
@end
@implementation HZBAboutUsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubviews];
        [self initPropertyObserver];
        [self initSignal];
    }
    return self;
}

- (void)initSignal {
}

- (void)initPropertyObserver{
}

- (void)initSubviews {
    [self.view addSubview:self.iconImageView];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.URLButton];
    [self.view addSubview:self.companyLabel];
    [self.view addSubview:self.phoneButton];
    [self.view addSubview:self.faxButton];
    [self.view addSubview:self.emailButton];

    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(50);
        make.centerX.mas_equalTo(0);
        make.size.mas_equalTo([UIImage imageNamed:@"IMG_AboutTitleImage"].size);
    }];

    __weak __typeof(self) weakSelf = self;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        make.left.right.mas_equalTo(0);
        make.top.equalTo(strongSelf.iconImageView.mas_bottom).with.offset(30);
    }];

    [self.URLButton mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        make.left.mas_equalTo(0);
        make.top.equalTo(strongSelf.titleLabel.mas_bottom).with.offset(10);
    }];

    [self.companyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        make.left.right.mas_equalTo(0);
        make.top.equalTo(strongSelf.URLButton.mas_bottom).with.offset(10);
    }];

    [self.phoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        make.left.mas_equalTo(0);
        make.top.equalTo(strongSelf.companyLabel.mas_bottom);
    }];

    [self.faxButton mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        make.left.equalTo(strongSelf.phoneButton.mas_right).with.offset(2);
        make.centerY.equalTo(strongSelf.phoneButton);
    }];

    [self.emailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        make.left.mas_equalTo(0);
        make.top.equalTo(strongSelf.phoneButton.mas_bottom);
        make.bottom.mas_lessThanOrEqualTo(0);
    }];
}

#pragma mark - Getter

- (UIImageView *)iconImageView {
    if (_iconImageView) {
        return _iconImageView;
    }
    _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IMG_AboutTitleImage"]];
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (_titleLabel) {
        return _titleLabel;
    }
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
    _titleLabel.textColor = UIColor.textBlackColor;
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.numberOfLines = 0;
    _titleLabel.text = @"华藏数位法宝APP，提供儒释道数位法宝电子书下载和阅读，方便净宗莲友利用科技产品深入经藏。";
    return _titleLabel;
}

- (UIButton *)URLButton {
    if (_URLButton) {
        return _URLButton;
    }
    _URLButton = [[UIButton alloc] init];
    NSString * string = @"https://www.hwadzan.tv/";
    NSMutableAttributedString * attString = [[NSMutableAttributedString alloc] initWithString:string];
    [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size: 15] range:NSMakeRange(0, string.length)];
    [attString addAttribute:NSForegroundColorAttributeName value:UIColor.textBlackColor range:NSMakeRange(0, string.length)];
    [attString addAttribute:NSForegroundColorAttributeName value:UIColor.textGreenColor range:NSMakeRange(0, string.length)];
    [attString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, string.length)];
    [attString addAttribute:NSUnderlineColorAttributeName value:UIColor.textGreenColor range:NSMakeRange(0, string.length)];
    [_URLButton setAttributedTitle:attString forState:UIControlStateNormal];
    [_URLButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 1)];
    self.URLSignal = [_URLButton rac_signalForControlEvents:UIControlEventTouchUpInside];
    return _URLButton;
}

- (UILabel *)companyLabel {
    if (_companyLabel) {
        return _companyLabel;
    }
    _companyLabel = [[UILabel alloc] init];
    _companyLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
    _companyLabel.textColor = UIColor.textBlackColor;
    _companyLabel.textAlignment = NSTextAlignmentLeft;
    _companyLabel.numberOfLines = 0;
    _companyLabel.text = @"社团法人中华华藏净宗学会\n台北市大安区信义路四段331-1号2楼\n财团法人华藏净宗弘化基金会\n台北市大安区信义路四段341号5楼";
    return _companyLabel;
}

- (UIButton *)phoneButton {
    if (_phoneButton) {
        return _phoneButton;
    }
    _phoneButton = [[UIButton alloc] init];
    NSString * string = @"TEL:+886-2-27547178";
    NSRange range = [string rangeOfString:@"+886-2-27547178"];
    NSMutableAttributedString * attString = [[NSMutableAttributedString alloc] initWithString:string];
    [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size: 15] range:NSMakeRange(0, string.length)];
    [attString addAttribute:NSForegroundColorAttributeName value:UIColor.textBlackColor range:NSMakeRange(0, string.length)];
    [attString addAttribute:NSForegroundColorAttributeName value:UIColor.textGreenColor range:range];
    [attString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:range];
    [attString addAttribute:NSUnderlineColorAttributeName value:UIColor.textGreenColor range:range];
    [_phoneButton setAttributedTitle:attString forState:UIControlStateNormal];
    [_phoneButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 1)];
    [[_phoneButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL * URL = [NSURL URLWithString:@"tel://+886-2-27547178"];
            [[UIApplication sharedApplication] openURL:URL];
        });
    }];
    return _phoneButton;
}


- (UIButton *)faxButton {
    if (_faxButton) {
        return _faxButton;
    }
    _faxButton = [[UIButton alloc] init];
    NSString * string = @"FAX:+886-2-27547262";
    NSRange range = [string rangeOfString:@"+886-2-27547262"];
    NSMutableAttributedString * attString = [[NSMutableAttributedString alloc] initWithString:string];
    [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size: 15] range:NSMakeRange(0, string.length)];
    [attString addAttribute:NSForegroundColorAttributeName value:UIColor.textBlackColor range:NSMakeRange(0, string.length)];
    [attString addAttribute:NSForegroundColorAttributeName value:UIColor.textGreenColor range:range];
    [attString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:range];
    [attString addAttribute:NSUnderlineColorAttributeName value:UIColor.textGreenColor range:range];
    [_faxButton setAttributedTitle:attString forState:UIControlStateNormal];
    [_faxButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 1)];
    [[_faxButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL * URL = [NSURL URLWithString:@"tel://+886-2-27547262"];
            [[UIApplication sharedApplication] openURL:URL];
        });
    }];
    return _faxButton;
}


- (UIButton *)emailButton {
    if (_emailButton) {
        return _emailButton;
    }
    _emailButton = [[UIButton alloc] init];
    NSString * string = @"E-MAIL:amtb@hwadzan.com";
    NSRange range = [string rangeOfString:@"amtb@hwadzan.com"];
    NSMutableAttributedString * attString = [[NSMutableAttributedString alloc] initWithString:string];
    [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size: 15] range:NSMakeRange(0, string.length)];
    [attString addAttribute:NSForegroundColorAttributeName value:UIColor.textBlackColor range:NSMakeRange(0, string.length)];
    [attString addAttribute:NSForegroundColorAttributeName value:UIColor.textGreenColor range:range];
    [attString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:range];
    [attString addAttribute:NSUnderlineColorAttributeName value:UIColor.textGreenColor range:range];
    [_emailButton setAttributedTitle:attString forState:UIControlStateNormal];
    [_emailButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 1)];
    self.emailSignal = [_emailButton rac_signalForControlEvents:UIControlEventTouchUpInside];
    return _emailButton;
}

@end
