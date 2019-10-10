//
//  HZBHomeCollectionCell.m
//  HuaZangBook
//
//  Created by BIN on 2019/8/30.
//  Copyright © 2019 Neusoft. All rights reserved.
//

#import "HZBHomeCollectionCell.h"
#import "CBAutoScrollLabel.h"
#import "UIImageView+WebCache.h"
@interface HZBHomeCollectionCell()
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIImageView * bookImageView;
@end

@implementation HZBHomeCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
        [self initSignal];
        [self initPropertyObserver];
    }
    return self;
}

- (void)initSignal {
    RAC(self,titleLabel.text) = RACObserve(self,title);
}

- (void)initPropertyObserver{
    __weak __typeof(self) weakSelf = self;
    [RACObserve(self, isEmpty) subscribeNext:^(NSNumber * number) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.titleLabel.hidden = number.boolValue;
        strongSelf.bookImageView.hidden = number.boolValue;
        if (number.boolValue) {
            strongSelf.contentView.backgroundColor = UIColor.whiteColor;
            strongSelf.contentView.layer.borderColor = UIColor.whiteColor.CGColor;
            strongSelf.layer.shadowColor = UIColor.whiteColor.CGColor;
        }else {
            strongSelf.contentView.backgroundColor = UIColor.bgLightGrayColor;
            strongSelf.contentView.layer.borderColor = UIColor.lineLightGrayColor.CGColor;
            strongSelf.layer.shadowColor = [UIColor colorWithRed:69/255.0 green:69/255.0 blue:83/255.0 alpha:0.05].CGColor;
            [strongSelf.bookImageView sd_setImageWithURL:[NSURL URLWithString:strongSelf.imageURLString]];
        }
    }];
}

- (void)initSubviews {
    self.contentView.backgroundColor = UIColor.bgLightGrayColor;
    self.contentView.layer.cornerRadius = 4.f;
    self.contentView.layer.borderWidth = 1.f;
    self.contentView.layer.borderColor = UIColor.lineLightGrayColor.CGColor;
    self.contentView.layer.masksToBounds = YES;

    self.layer.shadowColor = [UIColor colorWithRed:69/255.0 green:69/255.0 blue:83/255.0 alpha:0.05].CGColor;
    self.layer.shadowOffset = CGSizeMake(-2.5,-2.5);
    self.layer.shadowOpacity = 1;
    self.layer.shadowRadius = 10;

    [self.contentView addSubview:self.bookImageView];
    [self.contentView addSubview:self.titleLabel];

    [self.bookImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.size.mas_equalTo([UIImage imageNamed:@"CH15-06-01_b"].size);
        make.bottom.mas_lessThanOrEqualTo(0);
    }];


    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo([UIImage imageNamed:@"CH15-06-01_b"].size.height);
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(45);
    }];
}


- (UILabel *)titleLabel {
    if (_titleLabel) {
        return _titleLabel;
    }
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = UIColor.textBlackColor;
    _titleLabel.numberOfLines = 2;
    _titleLabel.text = @"标题";
    return _titleLabel;
}

- (UIImageView *)bookImageView {
    if (_bookImageView) {
        return _bookImageView;
    }
    _bookImageView = [[UIImageView alloc] init];
    return _bookImageView;
}

@end
