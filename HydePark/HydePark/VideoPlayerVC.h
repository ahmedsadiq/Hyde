//
//  VideoPlayerVC.h
//  HydePark
//
//  Created by Apple on 25/02/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VideoPlayerVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView *VideoPLayerTable;
    IBOutlet UILabel *scrollup;
    IBOutlet UILabel *scrollDown;
    NSMutableDictionary *cache;
}
@property (strong, nonatomic) NSMutableArray *videoObjs;

@end
