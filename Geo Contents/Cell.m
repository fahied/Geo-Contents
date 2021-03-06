/*
     File: Cell.m

 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import "Cell.h"
#import "CustomCellBackground.h"
#import "ELTweetGenerator.h"
#import "ELConstants.h"

@implementation Cell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // change to our custom selected background view
        CustomCellBackground *backgroundView = [[CustomCellBackground alloc] initWithFrame:CGRectZero];
        self.selectedBackgroundView = backgroundView;
        self.highlighted = NO;
        self.actionButton.enabled=YES;
        
        
        self.usernameLabel = [[RCLabel alloc] initWithFrame:CGRectMake(94,12,165,21)];
        [self addSubview:self.usernameLabel];

        
        self.descriptionLabel = [[RCLabel alloc]initWithFrame:CGRectMake(6,355,308,100)];
        //self.descriptionLabel.delegate = self;
        [self addSubview:self.descriptionLabel];
        
    }
    return self;
}



- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSString*)url
{
    //NSLog(@"%@",url);
    
}




-(IBAction)showActionSheet:(id)sender {
    
    
    
    if ([self.feature.source_type isEqualToString:FEATURE_TYPE_INSTAGRAM]) {
        UIActionSheet *sheet = sheet = [[UIActionSheet alloc]initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View in map",@"Direct me here", @"Map this!", nil];
        
        [sheet showFromRect:[self.actionButton frame] inView:[UIApplication sharedApplication].keyWindow animated:YES];
    }
    else
    {
        UIActionSheet *sheet = sheet = [[UIActionSheet alloc]initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View in map", @"Direct me here",@"Edit",@"Delete" ,nil];
        sheet.destructiveButtonIndex = 3;
        [sheet showInView:self];
        //[sheet showFromRect:[self.actionButton frame] inView:self animated:YES];
    }
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:@"Delete"])
        [self deleteClicked];
    else if([buttonTitle isEqualToString:@"Edit"])
        [self editClicked];
    else if([buttonTitle isEqualToString:@"View in map"])
        [self viewInMapClicked];
    else if([buttonTitle isEqualToString:@"Direct me here"])
        [self directMeHereClicked];
    else if([buttonTitle isEqualToString:@"Map this!"])
        [self mapThisClicked];
    
}




-(void)deleteClicked
{
    //NSLog(@"deleteClicked");
    UIApplication *app = [UIApplication sharedApplication];
    
    NSString *urlPath = [NSString stringWithFormat:@"overlay://delete/entry?id=%@",self.feature.idd];
    NSURL *url = [NSURL URLWithString:urlPath];
    
    if ([app canOpenURL:url]) {
        [app openURL:url];
    }
    else {
        //Display error
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Receiver Not Found" message:@"The Receiver App is not installed. It must be installed to send text." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
    
}





-(void)editClicked
{
    //NSLog(@"editClicked");
    UIApplication *app = [UIApplication sharedApplication];
    
    NSString *urlPath = [NSString stringWithFormat:@"overlay://edit/entry?id=%@",self.feature.idd];
    NSURL *url = [NSURL URLWithString:urlPath];
    
    if ([app canOpenURL:url]) {
        [app openURL:url];
    }
    else {
        //Display error
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Receiver Not Found" message:@"The Receiver App is not installed. It must be installed to send text." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
}




-(void)viewInMapClicked
{
    //NSLog(@"viewInMapClicked");
    
    UIApplication *app = [UIApplication sharedApplication];
    
    NSString *lat = [NSString stringWithFormat:@"%f",self.feature.fLocation.coordinate.latitude];
    NSString *lng = [NSString stringWithFormat:@"%f",self.feature.fLocation.coordinate.longitude];
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"overlay://browse/mapview?lat=%@&lng=%@",lat,lng]];
    
    if ([app canOpenURL:url]) {
        [app openURL:url];
    }
    else {
        //Display error
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Receiver Not Found" message:@"The Receiver App is not installed. It must be installed to send text." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        //Test
    }
    
}




-(void)directMeHereClicked
{
    //NSLog(@"directMeHereClicked");
    
    UIApplication *app = [UIApplication sharedApplication];
    
    NSString *lat = [NSString stringWithFormat:@"%f",self.feature.fLocation.coordinate.latitude];
    NSString *lng = [NSString stringWithFormat:@"%f",self.feature.fLocation.coordinate.longitude];
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"overlay://browse/directMe?lat=%@&lng=%@",lat,lng]];
    
    if ([app canOpenURL:url]) {
        [app openURL:url];
    }
    else {
        //Display error
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Receiver Not Found" message:@"The Receiver App is not installed. It must be installed to send text." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        //Test
    }
}




-(void)mapThisClicked
{

    UIApplication *app = [UIApplication sharedApplication];
    
    NSString *feature_id = self.feature.idd;
    NSString *source_type = self.feature.source_type;
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"overlay://mapthis/entry?feauture_id=%@&source_type=%@",feature_id,source_type]];
    
    if ([app canOpenURL:url]) {
        [app openURL:url];
    }
    else {
        //Display error
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Receiver Not Found" message:@"The Receiver App is not installed. It must be installed to send text." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];

        //Test
    }
    
}



@end
