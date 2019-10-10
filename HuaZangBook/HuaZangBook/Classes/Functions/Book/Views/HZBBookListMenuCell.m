//
//  HZBBookListMenuCell.m
//  HuaZangBook
//
//  Created by BIN on 2019/8/30.
//  Copyright © 2019 Neusoft. All rights reserved.
//

#import "HZBBookListMenuCell.h"
#import "CBAutoScrollLabel.h"
#import "NSString+CalculateSize.h"
@interface HZBBookListMenuCell ()
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIView * lineView;
@property (nonatomic, assign) BOOL state;
@end
@implementation HZBBookListMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.insetLeft(5).insetRight(5);
        self.backgroundColor = UIColor.textGreenColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubviews];
        [self initPropertyObserver];
        [self initSignal];
    }
    return self;
}

- (void)initSignal {
    RAC(self, titleLabel.text) = RACObserve(self, title);
}

- (void)initPropertyObserver{
    __weak __typeof(self) weakSelf = self;
    [[RACObserve(self, selectedIndex) merge:RACObserve(self, tag)] subscribeNext:^(id  _Nullable x) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.state = (strongSelf.selectedIndex == strongSelf.tag);
    }];

    [RACObserve(self, state) subscribeNext:^(id  _Nullable x) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.state) {
            strongSelf.backgroundColor = UIColor.textDarkYellowColor;
        }else {
            strongSelf.backgroundColor = UIColor.textGreenColor;
        }
    }];
}

- (void)initSubviews {
    [self.view addSubview:self.titleLabel];
    [self.contentView addSubview:self.lineView];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-1);
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
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 2;
    return _titleLabel;
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
