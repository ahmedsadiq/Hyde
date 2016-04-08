//
//  Topics.h
//  HydePark
//
//  Created by Mr on 22/04/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "topicsModel.h"
#import "AsyncImageView.h"

@interface Topics : UIViewController

{
    topicsModel *topics_model;
    NSArray *topicsArray;
    NSArray *imagesArray;
    NSArray *topicNameArray;
    NSArray *beamsArray;
    NSString *topicString;
    NSMutableArray *videoModelContainer;
    NSURL *url;
    NSMutableArray *topicsS;
    IBOutlet UIButton *topic_1;
    IBOutlet UIButton *topic_2;
    IBOutlet UIButton *topic_3;
    IBOutlet UIButton *topic_4;
    IBOutlet UIButton *topic_5;
    
    IBOutlet UIImageView *img_topic1;
    IBOutlet UIImageView *img_topic2;
    IBOutlet UIImageView *img_topic3;
    IBOutlet UIImageView *img_topic4;
    IBOutlet UIImageView *img_topic5;
    
    IBOutlet UILabel *name_lbl1;
    IBOutlet UILabel *name_lbl2;
    IBOutlet UILabel *name_lbl3;
    IBOutlet UILabel *name_lbl4;
    IBOutlet UILabel *name_lbl5;
    
    IBOutlet UILabel *beam_lbl1;
    IBOutlet UILabel *beam_lbl2;
    IBOutlet UILabel *beam_lbl3;
    IBOutlet UILabel *beam_lbl4;
    IBOutlet UILabel *beam_lbl5;
    
}

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIScrollView *topicsScrollview;

- (IBAction)topic1Pressed:(id)sender;
- (IBAction)topic2Pressed:(id)sender;
- (IBAction)topic3Pressed:(id)sender;
- (IBAction)topic4Pressed:(id)sender;
- (IBAction)topic5Pressed:(id)sender;
- (IBAction) ShowDrawer:(id)sender;
- (IBAction)DoneBtn:(id)sender;
- (IBAction)searchHideShow:(id)sender;

@end
