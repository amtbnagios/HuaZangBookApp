//
//  HZBBookListBookCell.m
//  HuaZangBook
//
//  Created by BIN on 2019/8/30.
//  Copyright © 2019 Neusoft. All rights reserved.
//

#import "HZBBookListBookCell.h"
#import "UIImageView+WebCache.h"

@interface HZBBookListBookCell ()
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * descLabel;
@property (nonatomic, strong) UIImageView * bookImageView;
@property (nonatomic, strong) UIView * lineView;
@property (nonatomic, assign) BOOL state;
@end
@implementation HZBBookListBookCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.insetLeft(5).insetRight(5).insetBottom(5).insetTop(5);
        self.backgroundColor = UIColor.whiteColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubviews];
        [self initPropertyObserver];
        [self initSignal];
    }
    return self;
}

- (void)initSignal {
    RAC(self, titleLabel.text) = RACObserve(self, title);
    RAC(self, descLabel.text) = RACObserve(self, desc);
}

- (void)initPropertyObserver{
    __weak __typeof(self) weakSelf = self;
    [RACObserve(self, imageURLString) subscribeNext:^(id  _Nullable x) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.bookImageView sd_setImageWithURL:[NSURL URLWithString:strongSelf.imageURLString]];
    }];
}

- (void)initSubviews {
    [self.view addSubview:self.bookImageView];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.descLabel];
    [self.contentView addSubview:self.lineView];

    [self.bookImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.size.mas_equalTo([UIImage imageNamed:@"CH15-06-01_s"].size);
        make.bottom.mas_lessThanOrEqualTo(0);
    }];

    __weak __typeof(self) weakSelf = self;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        make.left.equalTo(strongSelf.bookImageView.mas_right).with.offset(5);
        make.right.top.mas_equalTo(0);
        make.bottom.mas_lessThanOrEqualTo(0);
    }];

    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        make.left.equalTo(strongSelf.bookImageView.mas_right).with.offset(5);
        make.top.equalTo(strongSelf.titleLabel.mas_bottom);
        make.right.mas_equalTo(0);
        make.bottom.mas_lessThanOrEqualTo(0);
    }];

    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];

}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (_titleLabel) {
        return _titleLabel;
    }
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
    _titleLabel.textColor = UIColor.textBlackColor;
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.numberOfLines = 0;
    return _titleLabel;
}

- (UILabel *)descLabel {
    if (_descLabel) {
        return _descLabel;
    }
    _descLabel = [[UILabel alloc] init];
    _descLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
    _descLabel.textColor = UIColor.textGrayColor;
    _descLabel.textAlignment = NSTextAlignmentLeft;
    _descLabel.numberOfLines = 0;
    return _descLabel;
}

- (UIImageView *)bookImageView {
    if (_bookImageView) {
        return _bookImageView;
    }
    _bookImageView = [[UIImageView alloc] init];
    return _bookImageView;
}

- (UIView *)lineView {
    if (_lineView) {
        return _lineView;
    }
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
    _lineView.backgroundColor = UIColor.lineLightGrayColor;
    _lineView.layer.borderColor = UIColor.clearColor.CGColor;
    _lineView.layer.shadowColor = UIColor.clearColor.CGColor;
    _lineView.layer.borderWidth = 0.5;
    return _lineView;
}
@end
