//
//  ELUserFeaturesCVController.m
//  Geo Contents
//
//  Created by spider on 07.03.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import "ELUserFeaturesCVController.h"
#import "ELRESTful.h"
#import "Cell.h"
#import "ELTweetGenerator.h"
#import "NSDate+Helper.h"
#import "JMImageCache.h"




@interface ELUserFeaturesCVController ()
{
    NSMutableArray  *nFeatures;
    ELRESTful *restfull;
    UIImage *loadingImage;
    NSString *kCellID; 
}

@end






@implementation ELUserFeaturesCVController
@synthesize userName;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        loadingImage = [UIImage imageNamed:@"loadingImage.png"];
    }
    return self;
}





- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    nFeatures = [@[] mutableCopy];
    kCellID = @"cvCell"; 
    
    UINib *cellNib = [UINib nibWithNibName:@"Cell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:kCellID];
    //[self.collectionView registerClass:[Cell class] forCellWithReuseIdentifier:kCellID];
    
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(320, 450)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    [self.collectionView setCollectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self showFeatureForUser:self.userName];

}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma Collection View implementation

//dont highlight the selected collectionview cell
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
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
    suggestedSize = [componentsDS.plainTextData sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(306, FLT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    return CGSizeMake(320.f, 380.f + suggestedSize.height);
}









- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    ELFeature *feature = [nFeatures objectAtIndex:indexPath.item];
    
    static NSString *cellIdentifier = @"cvCell";
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
    if (feature != nil) {
        
        cell.feature = feature;
        NSURL *profileURL;
        if ([feature.source_type isEqualToString:@"instagram"]) {
            cell.sourceTypeImageView.image = [UIImage imageNamed:@"instagram.png"];
            profileURL = [NSURL URLWithString:feature.user.profile_picture];
        }
        else
        {
            cell.sourceTypeImageView.image = [UIImage imageNamed:@"mappa.png"];
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
            CGSize suggestedSize = [componentsDS.plainTextData sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(306, FLT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
            
            [cell.descriptionLabel setFrame:CGRectMake(6,355,300,suggestedSize.height)];
            
            cell.descriptionLabel.componentsAndPlainText = componentsDS;
            
            cell.descriptionLabel.delegate = self;
            
        }
        
        [cell.standardResolutionImageview setImageWithURL:feature.images.standard_resolution placeholder:[UIImage imageNamed:@"placeholder"]];
    }
    
    return cell;
    
}




- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSString*)url
{
    NSLog(@"%@",url);
    NSURL *urlp = [NSURL URLWithString:url];
    if ([url hasPrefix:@"instagram"]) {
        if ([[UIApplication sharedApplication] canOpenURL:urlp]) {
            [[UIApplication sharedApplication] openURL:urlp];
        }
    }
    if ([url hasPrefix:@"content"]) {
        
        NSLog(@"%@",@"send to content view");
        
    }
    if ([url hasPrefix:@"fb"]) {
        
        NSLog(@"%@",@"facebook");
        if ([[UIApplication sharedApplication] canOpenURL:urlp]) {
            [[UIApplication sharedApplication] openURL:urlp];
        }
        
    }
    
}

- (void)showFeatureForUser:(NSString*)userName {
    [nFeatures removeAllObjects];
    [self.collectionView reloadData];
    // Fetch the content on a worker thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *unsortedArrayWithoutDisctanceProperty = [[ELRESTful fetchPOIsByUserName:userName] mutableCopy];
        // Register the content on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            // Move all features to nFeatures
            [nFeatures removeAllObjects];
            [nFeatures addObjectsFromArray:unsortedArrayWithoutDisctanceProperty];
            // Sort all features by distance
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
            [nFeatures sortUsingDescriptors:[NSArray arrayWithObject:sort]];
            // Ensure the new data is used in the collection view
            [self.collectionView reloadData];
        });
    });
}



@end
