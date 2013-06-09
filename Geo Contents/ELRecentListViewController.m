//
//  ELRecentListViewController.m
//  Geo Contents
//
//  Created by spider on 30.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import "ELRecentListViewController.h"
#import "ELRESTful.h"
#import "Cell.h"
#import "ELTweetGenerator.h"
#import "NSDate+Helper.h"
#import "JMImageCache.h"
#import "ELHashedFeatureCVController.h"
#import "ELUserFeaturesCVController.h"
#import "ELConstants.h"



@interface ELRecentListViewController ()
{
    NSMutableArray  *nFeatures;
    ELRESTful *restfull;
    NSString *kCellID;
    UIImage *loadingImage;
    
}
@property (nonatomic, strong) NSOperationQueue *thumbnailQueue;
@property (nonatomic, strong) ELHashedFeatureCVController *hashedFeatureCVController;
@property (nonatomic, strong) ELUserFeaturesCVController *userFeatureCVController;


@end

@implementation ELRecentListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        kCellID = @"cvCell";
        loadingImage = [UIImage imageNamed:@"loadingImage.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    nFeatures = [@[] mutableCopy];
    
    //Start Location Services
    if ([CLLocationManager locationServicesEnabled]){
        CLLocationManager *locationManager = [CLLocationManager new];
        [self showItemsAtLocation:locationManager.location];
    } else {
        /* Location services are not enabled.
         Take appropriate action: for instance, prompt the
         user to enable location services */
        NSLog(@"Location services are not enabled");
    }
    
    
    UINib *cellNib = [UINib nibWithNibName:@"Cell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:kCellID];
    //[self.collectionView registerClass:[Cell class] forCellWithReuseIdentifier:kCellID];
    
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(320, 450)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    [self.collectionView setCollectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];

    
    self.thumbnailQueue = [[NSOperationQueue alloc] init];
    self.thumbnailQueue.maxConcurrentOperationCount = 3;
    
    // Refresh button to update list
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                      target:self
                                      action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    
}

-(void)refresh
{
    if ([CLLocationManager locationServicesEnabled]){
        CLLocationManager *locationManager = [CLLocationManager new];        
        [self showItemsAtLocation:locationManager.location];
    } else {
        /* Location services are not enabled.
         Take appropriate action: for instance, prompt the
         user to enable location services */
        NSLog(@"Location services are not enabled");
    }
    
    NSLog(@"%@",@"refresh pressed");
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    //nFeatures = [NSMutableArray arrayWithArray:app.features];
    //[self.collectionView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //return self.albums.count;
    
    return 1;
}



- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    NSInteger size = nFeatures.count;
    return size;
}



//recalculate the size of the CELL runtime to fit the content in it
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout  *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ELFeature *feature = [nFeatures objectAtIndex:indexPath.item];
    CGSize suggestedSize;
    
    NSString *htmlTweet =[ELTweetGenerator createHTMLTWeet:feature];
    
    RTLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:htmlTweet];
    //find the height of RTLabel
    suggestedSize = [componentsDS.plainTextData sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(304, FLT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    return CGSizeMake(320.f, 380.f + suggestedSize.height);
}




//- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
//{
//    ELFeature *feature = [nFeatures objectAtIndex:indexPath.item];
//    
//    static NSString *cellIdentifier = @"cvCell";
//    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
//        
//    // load photo images in the background
//    __weak ELRecentListViewController *weakSelf = self;
//    __block UIImage *image = nil;
//    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
//        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:feature.images.standard_resolution]];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // then set them via the main queue if the cell is still visible.
//            if ([weakSelf.collectionView.indexPathsForVisibleItems containsObject:indexPath]) {
//                Cell *cell =
//                (Cell *)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
//                
//                
//                if (feature != nil) {
//                    
//                    cell.feature = feature;
//                    NSURL *profileURL;
//                    if ([feature.source_type isEqualToString:FEATURE_TYPE_INSTAGRAM]) {
//                        cell.sourceTypeImageView.image = [UIImage imageNamed:@"instagram.png"];
//                        profileURL = [NSURL URLWithString:feature.user.profile_picture];
//                    }
//                    else
//                    {
//                        cell.sourceTypeImageView.image = [UIImage imageNamed:@"overlay.png"];
//                        profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",@"https://graph.facebook.com/",feature.user.idd,@"/picture"]];
//                    }
//                    cell.userprofileImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:profileURL]];
//
//                    //clickable user label
//                    RTLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:[ELTweetGenerator createHTMLUserString:feature]];
//                    cell.usernameLabel.componentsAndPlainText = componentsDS;
//                    cell.usernameLabel.delegate = self;
//                    
//                    //: formate time using Utitlity category NSDATE+Helper
//                    NSString *timeStamp = feature.time;
//                    NSTimeInterval timeInterval = (double)([feature.time unsignedLongLongValue]);
//                    NSDate *theDate = [[NSDate alloc]initWithTimeIntervalSince1970: timeInterval];
//                    NSString *displayString = [NSDate stringForDisplayFromDate:theDate];
//                    
//                    cell.timeDistance.text = displayString;
//                
//                    if (feature.description !=NULL) {
//                        
//                        NSString *htmlTweet =[ELTweetGenerator createHTMLTWeet:feature];
//                        
//                        RTLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:htmlTweet];
//                        //find the height of RTLabel
//                        CGSize suggestedSize = [componentsDS.plainTextData sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(306, FLT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
//                        
//                        [cell.descriptionLabel setFrame:CGRectMake(6,355,300,suggestedSize.height)];
//                        
//                        cell.descriptionLabel.componentsAndPlainText = componentsDS;
//                        
//                        cell.descriptionLabel.delegate = self;
//                        
//                    }
//
//                    cell.standardResolutionImageview.image = image;
//                }
//                
//                
//            }
//        });
//    }];
//    
//    [self.thumbnailQueue addOperation:operation];
//        
//    
//    return cell;
//    
//}



- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    ELFeature *feature = [nFeatures objectAtIndex:indexPath.item];
    
    static NSString *cellIdentifier = @"cvCell";
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
                
                
                if (feature != nil) {
                    
                    cell.feature = feature;
                    NSURL *profileURL;
                    if ([feature.source_type isEqualToString:FEATURE_TYPE_INSTAGRAM])
                    {
                        cell.sourceTypeImageView.image = [UIImage imageNamed:@"instagram"];
                        profileURL = [NSURL URLWithString:feature.user.profile_picture];
                    }
                    else if ([feature.source_type isEqualToString:FEATURE_TYPE_MAPPED_INSTAGRAM])
                    {
                        cell.sourceTypeImageView.image = [UIImage imageNamed:@"mapped_instagram"];
                        profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",@"https://graph.facebook.com/",feature.user.idd,@"/picture"]];
                    }

                    else
                    {
                        cell.sourceTypeImageView.image = [UIImage imageNamed:@"mappa"];
                        profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",@"https://graph.facebook.com/",feature.user.idd,@"/picture"]];
                    }
                    cell.userprofileImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:profileURL]];
                    
                    //clickable user label
                    RTLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:[ELTweetGenerator createHTMLUserString:feature.user withSourceType:feature.source_type]];
                    cell.usernameLabel.componentsAndPlainText = componentsDS;
                    cell.usernameLabel.delegate = self;
                    
                    //: formate time using Utitlity category NSDATE+Helper
                    NSTimeInterval timeInterval = (double)([feature.time unsignedLongLongValue]);
                    NSDate *theDate = [[NSDate alloc]initWithTimeIntervalSince1970: timeInterval];
                    NSString *displayString = [NSDate stringForDisplayFromDate:theDate];
                    
                    cell.timeDistance.text = displayString;
                    
                    if (feature.description !=NULL) {
                        
                        NSString *htmlTweet =[ELTweetGenerator createHTMLTWeet:feature];
                        
                        RTLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:htmlTweet];
                        //find the height of RTLabel
                        CGSize suggestedSize = [componentsDS.plainTextData sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(306, FLT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
                        
                        [cell.descriptionLabel setFrame:CGRectMake(6,355,304,suggestedSize.height)];
                        
                        cell.descriptionLabel.componentsAndPlainText = componentsDS;
                        
                        cell.descriptionLabel.delegate = self;
                        
                    }
//                    if (feature.images.standard_resolution) {
//                        <#statements#>
//                    }
                    [cell.standardResolutionImageview setImageWithURL:feature.images.standard_resolution placeholder:[UIImage imageNamed:@"listloading304px"]];
                }
    
    return cell;
    
}




- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSString*)url
{
    NSLog(@"%@",url);
    NSURL *urlp = [NSURL URLWithString:url];
    NSDictionary *dict = [ELRESTful parseQueryString:[urlp query]];
    
    if ([url hasPrefix:@"instagram"]) {
        if ([[UIApplication sharedApplication] canOpenURL:urlp]) {
            [[UIApplication sharedApplication] openURL:urlp];
        }
    }
    
    if ([url hasPrefix:@"geocontent"]) {
        
        if ([[urlp host] isEqualToString:@"tag"])
        {
            self.hashedFeatureCVController = [[ELHashedFeatureCVController alloc]initWithNibName:@"ELHashedFeatureCVController" bundle:nil];
            [self.hashedFeatureCVController setTitle:[dict valueForKey:@"name"]];
            self.hashedFeatureCVController.hashTag = [dict valueForKey:@"name"];
            [self.navigationController pushViewController:self.hashedFeatureCVController animated:YES];
        }
        else if ([[urlp host] isEqualToString:@"user"])
        {
            self.userFeatureCVController = [[ELUserFeaturesCVController alloc]initWithNibName:@"ELUserFeaturesCVController" bundle:nil];
            [self.userFeatureCVController setTitle:[dict valueForKey:@"username"]];
            self.userFeatureCVController.userName = [dict valueForKey:@"username"];
            [self.navigationController pushViewController:self.userFeatureCVController animated:YES];
        }
        
    }
    if ([url hasPrefix:@"fb"]) {
        if ([[UIApplication sharedApplication] canOpenURL:urlp]) {
            [[UIApplication sharedApplication] openURL:urlp];
        }
        
    }
    
}





- (void)showItemsAtLocation:(CLLocation*)newLocation {
    [nFeatures removeAllObjects];
    [self.collectionView reloadData];
    
    NSMutableArray *temp = [[NSMutableArray alloc]init];
    
    // Fetch the content on a worker thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [temp addObjectsFromArray: [ELRESTful fetchRecentlyAddedFeatures:newLocation.coordinate]];
        // Register the content on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
            [temp sortUsingDescriptors:[NSArray arrayWithObject:sort]];
            [nFeatures removeAllObjects];
            [nFeatures addObjectsFromArray:temp];
            // Ensure the new data is used in the collection view
            [self.collectionView reloadData];
        });
    });
}



- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    /* Failed to receive user's location */
}




-(NSNumber*)getDistanceBetweenPoint1:(CLLocation *)point1 Point2:(CLLocation *)point2
{
    
    double meters1 = [point1 distanceFromLocation:point2];
    
    double meters2 = [point2 distanceFromLocation:point1];
    
    double meters = (meters1 + meters2)/2;
    
    NSNumber *distance = [NSNumber numberWithDouble:meters];
    
    return distance;
}





@end
