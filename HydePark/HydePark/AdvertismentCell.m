//
//  AdvertismentCell.m
//  HydePark
//
//  Created by Ahmed Sadiq on 24/05/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import "AdvertismentCell.h"

@implementation AdvertismentCell

- (void)awakeFromNib {
    // Initialization code
    
    [_ad1.layer setCornerRadius:15.0f];
    [[_ad1 layer] setBorderWidth:0.5f];
    [[_ad1 layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    _ad1.clipsToBounds = YES;
    
    [_ad2.layer setCornerRadius:15.0f];
    [[_ad2 layer] setBorderWidth:0.5f];
    [[_ad2 layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    _ad2.clipsToBounds = YES;
    
    [_ad3.layer setCornerRadius:15.0f];
    [[_ad3 layer] setBorderWidth:0.5f];
    [[_ad3 layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    _ad3.clipsToBounds = YES;
    
    myTimer = [NSTimer scheduledTimerWithTimeInterval:5.00 target:self selector:@selector(changeImage) userInfo:nil repeats:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)changeImage
{
    if(_ad1.tag == 1) {
        UIImage * toImage = [UIImage imageNamed:@"ads1.png"];
        [UIView transitionWithView:_ad1
                          duration:2.0f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            _ad1.image = toImage;
                        } completion:nil];
        _ad1.tag = 0;
    }else {
        UIImage * toImage = [UIImage imageNamed:@"ads2.png"];
        [UIView transitionWithView:_ad1
                          duration:2.0f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            _ad1.image = toImage;
                        } completion:nil];
        _ad1.tag = 1;
    }
    
    if(_ad2.tag == 1) {
        UIImage * toImage = [UIImage imageNamed:@"ads3.png"];
        [UIView transitionWithView:_ad2
                          duration:2.0f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            _ad2.image = toImage;
                        } completion:nil];
        _ad2.tag = 0;
    }else {
        UIImage * toImage = [UIImage imageNamed:@"ads4.jpg"];
        [UIView transitionWithView:_ad2
                          duration:2.0f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            _ad2.image = toImage;
                        } completion:nil];
        _ad2.tag = 1;
    }
    
    if(_ad3.tag == 1) {
        UIImage * toImage = [UIImage imageNamed:@"ads14.jpeg"];
        [UIView transitionWithView:_ad3
                          duration:2.0f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            _ad3.image = toImage;
                        } completion:nil];
        _ad3.tag = 0;
    }else {
        UIImage * toImage = [UIImage imageNamed:@"ads15.jpeg"];
        [UIView transitionWithView:_ad3
                          duration:2.0f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            _ad3.image = toImage;
                        } completion:nil];
        _ad3.tag = 1;
    }
    
    
    
}

@end
