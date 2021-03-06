/*
     File: Cell.h

 */

#import <UIKit/UIKit.h>
#import "ELFeature.h"
#import "RCLabel.h"

@interface Cell : UICollectionViewCell<UIActionSheetDelegate, CLLocationManagerDelegate,RTLabelDelegate>
{
    BOOL haveLocation;
}

@property (strong, nonatomic) IBOutlet UIImageView *userprofileImageView;
@property (strong, nonatomic) IBOutlet RCLabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeDistance;
@property (strong, nonatomic) IBOutlet UIImageView *standardResolutionImageview;
@property (retain, nonatomic) IBOutlet RCLabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *sourceTypeImageView;


-(IBAction)showActionSheet:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *actionButton;

@property (strong, nonatomic) IBOutlet ELFeature *feature;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *nLocation;




@end
