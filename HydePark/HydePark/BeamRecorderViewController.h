//
//  BeamRecorderViewController.h
//  HydePark
//
//  Created by Ahmed Sadiq on 21/05/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <ImageIO/ImageIO.h>
#import <QuartzCore/QuartzCore.h>


@interface BeamRecorderViewController : UIViewController<AVAudioRecorderDelegate> {
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSURL *outputFileURL;
    UIImagePickerController *cameraUI;
}
@property(nonatomic, retain) IBOutlet UIView *vImagePreview;
@property(nonatomic, retain) IBOutlet UIImageView *vImage;
- (IBAction)captureVideo:(id)sender;
- (IBAction)stopVideo:(id)sender;
@end
