//
//  ELNearbyViewController.m
//  Geo Contents
//
//  Created by spider on 09.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import "ELContentViewController.h"
#import "IMPhotoAlbumLayout.h"
#import "IMAlbumPhotoCell.h"

#import "ELFeature.h"


#import "ELFeatureViewController.h"
#import "ELBridgingApp.h"

#import "ELConstants.h"
#import "ELRESTful.h"

#import "JMImageCache.h"

/** Degrees to Radian **/
#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )

/** Radians to Degrees **/
#define radiansToDegrees( radians ) ( ( radians ) * ( 180.0 / M_PI ) )



static NSString * const PhotoCellIdentifier = @"PhotoCell";




@interface ELContentViewController ()
{
    CLLocation *previousLocation;
    CLLocation *newLocation;
    NSMutableArray  *features;
    UILabel *distanceCoveredLabel;

}
@property (nonatomic, weak) IBOutlet IMPhotoAlbumLayout *photoAlbumLayout;
@property (nonatomic, strong) ELFeatureViewController *secondView;    

@end





@implementation ELContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"ELContentViewController" bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Start location services
    [ self startLocationServices];
        
    // initialze
    features = [@[] mutableCopy];
    
    
    /*  Location service
     Stop CLLOcationManager when you receive notification that your app is resigning active,
     Subscribe to the notifications and provide a method to stop and start location services.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActiveNotif:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActiveNotif:) name:UIApplicationWillResignActiveNotification object:nil];
    
    // prepare collectionview to load features
    [self prepareCollectionView];
    
    //for test purpose only display distance covered in 10 sec by a user
    distanceCoveredLabel = [[UILabel alloc]initWithFrame:CGRectMake(150, 300, 60, 20)];

    // Download Features in the BoundingBox Set by Mappa in NSUserdefaults dictionary
    [self getAndShowFeaturesInBoundingBox];
}



- (void)prepareCollectionView
{
    [self.collectionView registerClass:[IMAlbumPhotoCell class] forCellWithReuseIdentifier:PhotoCellIdentifier];
    
    // Add background image to collection view
    self.collectionView.backgroundView =[[UIView alloc]initWithFrame:self.collectionView.bounds];
    UIImageView *background_image=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mosaic_bg3x107"]];
    [self.collectionView.backgroundView addSubview:background_image];
    
    //self.collectionView.backgroundColor = [UIColor colorWithWhite:0.25f alpha:1.0f];
    self.collectionView.backgroundColor = [UIColor whiteColor];
}



-(void)viewDidAppear:(BOOL)animated
{

}




-(void)getAndShowFeaturesInBoundingBox
{
    
    // dafualt boounding box in case GPS does not work
    NSDictionary *defaultBBox = [[NSDictionary alloc] initWithObjectsAndKeys:
                           @"59.927999267f",@"lat1",
                           @"10.759999771f",@"lng1",
                           @"59.928999267f",@"lat2",
                           @"10.761999771f",@"lng2",
                           nil];
    // fetch the bounding box dictionary from the NSUserDefaults being sent by Mappa
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *bbox = [defaults objectForKey:@"bbox"];
    
    //if bbox found then refresh the view by loading the feautres in it
    if (bbox != nil) {
        [self loadFeaturesInBoundingBox:bbox];
        [self.collectionView reloadData];
    }
    
    //if bbox was not found then refresh the view by using default BBox
    else if (bbox == nil)
    {
        [self loadFeaturesInBoundingBox:defaultBBox];
        [self.collectionView reloadData];
    }

}



-(void) viewDidDisappear:(BOOL)animated
{
    //
    //[self stopUpdatingContentViewtoMylocation];
}








-(void) loadFeaturesInBoundingBox:(NSDictionary*)bbox
{
    //Randomize instagram and overlay pois
    NSArray *results = [ELRESTful fetchPOIsInBoundingBox:bbox];
    
    
    for (ELFeature *feature in results) {
        
        feature.distance = [self distanceBetweenPoint1:newLocation Point2:feature.fLocation];
        [features addObject:feature];
    }

    features = [[self shuffleArray:results] mutableCopy];
    //cach images here?
}


-(NSNumber*)distanceBetweenPoint1:(CLLocation *)point1 Point2:(CLLocation *)point2
{
    
    double meters1 = [point1 distanceFromLocation:point2];
    
    double meters2 = [point2 distanceFromLocation:point1];
    
    double meters = (meters1 + meters2)/2;
    
    NSNumber *distance = [NSNumber numberWithDouble:meters];
    
    return distance;
}


- (NSArray*)shuffleArray:(NSArray*)array {
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:array];
    
    for(NSUInteger i = [array count]; i > 1; i--) {
        NSUInteger j = arc4random_uniform(i);
        [temp exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
    
    return [NSArray arrayWithArray:temp];
}


-(void)openMapview
{
    [ELBridgingApp openMapView];
    
    NSLog(@"goto map view");
}


-(void)viewWillDisappear:(BOOL)animated
{
    //app.features = [features mutableCopy];
    
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}







#pragma mark - UICollectionViewDataSource



- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    
    return features.count;
}






- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return 1;
}




- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IMAlbumPhotoCell *photoCell =
    [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellIdentifier
                                              forIndexPath:indexPath];
    
    ELFeature *feature = [features objectAtIndex:indexPath.section];
    
    //load images using JMImageCache liberary. Awesome :)
    [photoCell.imageView setImageWithURL:feature.images.thumbnail placeholder:[UIImage imageNamed:@"placeholder"]];
    
    // differentiate external POIs with 60% alpha
    if ([feature.source_type isEqualToString:FEATURE_TYPE_MAPPA] || [feature.source_type isEqualToString:FEATURE_TYPE_MAPPED_INSTAGRAM])
    {
        photoCell.imageView.alpha = 1.0;
    }
    else
        photoCell.imageView.alpha = 0.6;
    return photoCell;
    
}






- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.secondView = [[ELFeatureViewController alloc] initWithNibName:@"ELFeatureViewController" bundle:nil];
    ELFeature *feature = [features objectAtIndex:indexPath.section];
    feature.distance = [self distanceBetweenPoint1:newLocation Point2:feature.fLocation];
    self.secondView.feature = feature;
        
	[self.navigationController pushViewController:self.secondView animated:YES];
}







#pragma mark - Location Services


-(void)appDidBecomeActiveNotif:(NSNotification*)notif
{
    [self startLocationServices];
}

-(void)appWillResignActiveNotif:(NSNotification*)notif
{
    [self stopLocationServices];
}




/*
 kCLLocationAccuracyBestForNavigation
 kCLLocationAccuracyBest
 kCLLocationAccuracyNearestTenMeters
 kCLLocationAccuracyHundredMeters
 kCLLocationAccuracyKilometer
 kCLLocationAccuracyThreeKilometers
 */
-(void) startLocationServices
{
    
    if(_locationManager==nil){
        //Instantiate _locationManager
        _locationManager = [[CLLocationManager alloc] init];
        
        //set the accuracy for the signals
        _locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
        
        //The distanceFilter property defines the minimum distance a device has to move horizontally
        // before an update event is produced.
        _locationManager.distanceFilter = 10;
        
        _locationManager.delegate=self;
    }
    //Start updating location
    [_locationManager startUpdatingLocation];
    
}


-(void) stopLocationServices
{
    if (_locationManager != nil) {
        [_locationManager stopUpdatingLocation];
    }
}


#pragma mark - Location Services : delegate



-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if(error.code == kCLErrorDenied){
        [manager stopUpdatingLocation];
    }
}






- (void)notifictationForNewLocation:(CLLocation *)newLocation
{
    UILocalNotification *locationNotification = [[UILocalNotification alloc]
                                                 init];
    locationNotification.alertBody=[NSString stringWithFormat:@"New Location:%.3f, %.3f", newLocation.coordinate.latitude, newLocation.coordinate.longitude];
    locationNotification.alertAction=@"Ok";
    locationNotification.soundName = UILocalNotificationDefaultSoundName;
    //Increment the applicationIconBadgeNumber
    locationNotification.applicationIconBadgeNumber=[[UIApplication sharedApplication] applicationIconBadgeNumber]+1;
    //[[UIApplication sharedApplication] presentLocalNotificationNow:locationNotification];
    [[UIApplication sharedApplication] scheduleLocalNotification:locationNotification];
}



/*
 var R = 6371; // km
 var dLat = (lat2-lat1).toRad();
 var dLon = (lon2-lon1).toRad();
 var lat1 = lat1.toRad();
 var lat2 = lat2.toRad();
 
 var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
 Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2);
 var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
 var d = R * c;
 */
+(NSNumber*)getDistanceBetweenPoint1:(CLLocation *)point1 Point2:(CLLocation *)point2
{
    
    double meters1 = [point1 distanceFromLocation:point2];
    
    double meters2 = [point2 distanceFromLocation:point1];
    
    double meters = (meters1 + meters2)/2;
    
    NSNumber *distance = [NSNumber numberWithDouble:meters];
    
    return distance;
}





-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    // refuses events older than 5 seconds:
    if (abs(howRecent) < 15.0)
    {
        //set old loacation to
        if (previousLocation == nil) {
            previousLocation = [locations lastObject];
            
            features=  [ELRESTful fetchPOIsAtLocation:location.coordinate];
            
            [self.collectionView reloadData];
            
        }
        // find the distance covered since last location update
        NSNumber *distanceCovered = [self distanceBetweenPoint1:previousLocation Point2:location];
        
        // find the time passed since last location update
        NSTimeInterval timeElepsed = [previousLocation.timestamp timeIntervalSinceNow];
        
        if ([distanceCovered intValue] >= 10 || abs(timeElepsed) > 20.0)
        {
            NSLog(@"You covered: %@ m", distanceCovered);
            previousLocation = newLocation;
            newLocation = location;
            
            //Refresh view with new Features at this position
            [self refreshView:newLocation];
            
            // Placed label for testing purpose only
            distanceCoveredLabel.text = [distanceCovered stringValue];
            [self.collectionView addSubview:distanceCoveredLabel];
            
            [self refreshView:newLocation];
        }
    }
}



-(void)refreshView:(CLLocation*)newLocation
{
    NSMutableArray *newFeatures = [ELRESTful fetchPOIsAtLocation:newLocation.coordinate];
    
    //Compare the restults are diffirent
    if ([self foundNewEntriesIn:newFeatures withOldResults:features])
    {
            features = newFeatures;
            [self.collectionView reloadData];
    }

}


-(BOOL)foundNewEntriesIn:(NSMutableArray*)newArray withOldResults:(NSMutableArray*)oldArray
{
    
    NSMutableSet *newSet = [NSMutableSet setWithArray: newArray];
    NSSet *oldSet = [NSSet setWithArray: oldArray];
    [newSet minusSet: oldSet];
    if (newSet.count > 0) {
        return YES;
    }
    
    return NO;
}



@end



//- (void)gotoMyLocationButton{    // Method for creating button, with background image and other properties
//    
//    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    playButton.frame = CGRectMake(110.0, 360.0, 100.0, 30.0);
//    [playButton setTitle:@"Play" forState:UIControlStateNormal];
//    playButton.backgroundColor = [UIColor clearColor];
//    [playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
//    UIImage *buttonImageNormal = [UIImage imageNamed:@"blueButton.png"];
//    UIImage *strechableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
//    [playButton setBackgroundImage:strechableButtonImageNormal forState:UIControlStateNormal];
//    UIImage *buttonImagePressed = [UIImage imageNamed:@"whiteButton.png"];
//    UIImage *strechableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];
//    [playButton setBackgroundImage:strechableButtonImagePressed forState:UIControlStateHighlighted];
//    [playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:playButton];
//}
