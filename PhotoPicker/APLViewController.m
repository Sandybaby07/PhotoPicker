/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Main view controller for the application.
 */

#import "APLViewController.h"

@interface APLViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

//@property (nonatomic, weak) IBOutlet UIImageView*imageView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
@property (nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *takePictureButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *startStopButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic) UIImagePickerController *imagePickerController;

//@property (nonatomic, weak) NSTimer *cameraTimer;
@property (nonatomic) NSMutableArray *capturedImages;

@end


#pragma mark -

@implementation APLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.faceResults.hidden = true;
    self.labelResults.hidden = true;
    self.spinner.hidesWhenStopped = true;

    self.capturedImages = [[NSMutableArray alloc] init];

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // There is not a camera on this device, so don't show the camera button.
        NSMutableArray *toolbarItems = [self.toolBar.items mutableCopy];
        [toolbarItems removeObjectAtIndex:2];
        [self.toolBar setItems:toolbarItems animated:NO];
    }
}

- (IBAction)showImagePickerForCamera:(id)sender
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera fromButton:sender];
}

- (IBAction)showImagePickerForPhotoPicker:(id)sender
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary fromButton:sender];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType fromButton:(UIBarButtonItem *)button
{
    if (self.imageView.isAnimating)
    {
        [self.imageView stopAnimating];
    }

    if (self.capturedImages.count > 0)
    {
        [self.capturedImages removeAllObjects];
    }

    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    imagePickerController.modalPresentationStyle =
        (sourceType == UIImagePickerControllerSourceTypeCamera) ? UIModalPresentationFullScreen : UIModalPresentationPopover;
    
    UIPopoverPresentationController *presentationController = imagePickerController.popoverPresentationController;
    presentationController.barButtonItem = button;  // display popover from the UIBarButtonItem as an anchor
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        // The user wants to use the camera interface. Set up our custom overlay view for the camera.
        imagePickerController.showsCameraControls = NO;

        /*
         Load the overlay view from the OverlayView nib file. Self is the File's Owner for the nib file, so the overlayView outlet is set to the main view in the nib. Pass that view to the image picker controller to use as its overlay view, and set self's reference to the view to nil.
         */
        [[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil];
        self.overlayView.frame = imagePickerController.cameraOverlayView.frame;
        imagePickerController.cameraOverlayView = self.overlayView;
        self.overlayView = nil;
    }

    _imagePickerController = imagePickerController; // we need this for later

    [self presentViewController:self.imagePickerController animated:YES completion:^{
        //.. done presenting
    }];
}


#pragma mark - Toolbar actions

//- (IBAction)done:(id)sender
//{
//    // Dismiss the camera.
//    if ([self.cameraTimer isValid])
//    {
//        [self.cameraTimer invalidate];
//    }
//    [self finishAndUpdate];
//}

- (IBAction)takePhoto:(id)sender
{
    [self.imagePickerController takePicture];
}


- (IBAction)startTakingPicturesAtIntervals:(id)sender
{
    /*
     Start the timer to take a photo every 1.5 seconds.
     
     CAUTION: for the purpose of this sample, we will continue to take pictures indefinitely.
     Be aware we will run out of memory quickly.  You must decide the proper threshold number of photos allowed to take from the camera.
     One solution to avoid memory constraints is to save each taken photo to disk rather than keeping all of them in memory.
     In low memory situations sometimes our "didReceiveMemoryWarning" method will be called in which case we can recover some memory and keep the app running.
     */
    //self.startStopButton.title = NSLocalizedString(@"Stop", @"Title for overlay view controller start/stop button");
    //[self.startStopButton setAction:@selector(stopTakingPicturesAtIntervals:)];

    //self.doneButton.enabled = NO;
    self.takePictureButton.enabled = NO;

   // self.cameraTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(timedPhotoFire:) userInfo:nil repeats:YES];
    //[self.cameraTimer fire]; // Start taking pictures right away.
}

//- (IBAction)stopTakingPicturesAtIntervals:(id)sender
//{
//    // Stop and reset the timer.
//    [self.cameraTimer invalidate];
//    self.cameraTimer = nil;
//
//    [self finishAndUpdate];
//}

- (void)finishAndUpdate
{
    // Dismiss the image picker.
    [self dismissViewControllerAnimated:YES completion:nil];

    if ([self.capturedImages count] > 0)
    {
        if ([self.capturedImages count] == 1)
        {
            // Camera took a single picture.
            [self.imageView setImage:[self.capturedImages objectAtIndex:0]];
        }
        else
        {
            // Camera took multiple pictures; use the list of images for animation.
            self.imageView.animationImages = self.capturedImages;
            self.imageView.animationDuration = 5.0;    // Show each captured photo for 5 seconds.
            self.imageView.animationRepeatCount = 0;   // Animate forever (show all photos).
            [self.imageView startAnimating];
        }
        
        // To be ready to start again, clear the captured images array.
        [self.capturedImages removeAllObjects];
    }

    _imagePickerController = nil;
}


#pragma mark - Timer

// Called by the timer to take a picture.
//- (void)timedPhotoFire:(NSTimer *)timer
//{
//    [self.imagePickerController takePicture];
//}
//

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self.capturedImages addObject:image];
//
//    if ([self.cameraTimer isValid])
//    {
//        return;
//    }
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.faceResults.hidden = true;
    self.labelResults.hidden = true;
    [self.spinner startAnimating];
    
    // Base64 encode the image and create the request
    NSString *binaryImageData = [self base64EncodeImage:image];
    [self createRequest:binaryImageData];
    [picker dismissViewControllerAnimated:true completion:NULL];
    [self finishAndUpdate];
    
}
- (UIImage *) resizeImage: (UIImage*) image toSize: (CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (NSString *) base64EncodeImage: (UIImage*)image {
    NSData *imagedata = UIImagePNGRepresentation(image);
    
    // Resize the image if it exceeds the 2MB API limit
    if ([imagedata length] > 2097152) {
        CGSize oldSize = [image size];
        CGSize newSize = CGSizeMake(800, oldSize.height / oldSize.width * 800);
        image = [self resizeImage: image toSize: newSize];
        imagedata = UIImagePNGRepresentation(image);
    }
    
    NSString *base64String = [imagedata base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    return base64String;
}

- (void) createRequest: (NSString*)imageData {
    // Create our request URL
    
    NSString *urlString = @"https://vision.googleapis.com/v1/images:annotate?key=";
    NSString *API_KEY = @"AIzaSyDB2KlTfnanJWhny5YLl00uU-_DakTpriU";
    
    NSString *requestString = [NSString stringWithFormat:@"%@%@", urlString, API_KEY];
    
    NSURL *url = [NSURL URLWithString: requestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod: @"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request
     addValue:[[NSBundle mainBundle] bundleIdentifier]
     forHTTPHeaderField:@"X-Ios-Bundle-Identifier"];
    
    // Build our API request
    NSDictionary *paramsDictionary =
    @{@"requests":@[
              @{@"image":
                    @{@"content":imageData},
                @"features":@[
                        @{@"type":@"TEXT_DETECTION",
                          @"maxResults":@50},
                        @{@"type":@"FACE_DETECTION",
                          @"maxResults":@10}]}]};
    
    NSError *error;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:paramsDictionary options:0 error:&error];
    [request setHTTPBody: requestData];
    
    // Run the request on a background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self runRequestOnBackgroundThread: request];
    });
}

- (void)runRequestOnBackgroundThread: (NSMutableURLRequest*) request {
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^ (NSData *data, NSURLResponse *response, NSError *error) {
        [self analyzeResults:data];
    }];
    [task resume];
}

- (void)analyzeResults: (NSData*)dataToParse {
    
    // Update UI on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSError *e = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataToParse options:kNilOptions error:&e];
        
        NSArray *responses = [json objectForKey:@"responses"];
        NSLog(@"%@", responses);
        NSDictionary *responseData = [responses objectAtIndex: 0];
        NSDictionary *errorObj = [json objectForKey:@"error"];
        
        [self.spinner stopAnimating];
        self.imageView.hidden = true;
        self.labelResults.hidden = false;
        self.faceResults.hidden = false;
        
        // Check for errors
        if (errorObj) {
            NSString *errorString1 = @"Error code ";
            NSString *errorCode = [errorObj[@"code"] stringValue];
            NSString *errorString2 = @": ";
            NSString *errorMsg = errorObj[@"message"];
            self.labelResults.text = [NSString stringWithFormat:@"%@%@%@%@", errorString1, errorCode, errorString2, errorMsg];
        } else {
            // Get face annotations
            NSDictionary *faceAnnotations = [responseData objectForKey:@"faceAnnotations"];
            if (faceAnnotations != NULL) {
                // Get number of faces detected
                NSInteger numPeopleDetected = [faceAnnotations count];
                NSString *peopleStr = [NSString stringWithFormat:@"%lu", (unsigned long)numPeopleDetected];
                NSString *faceStr1 = @"People detected: ";
                NSString *faceStr2 = @"\n\nEmotions detected:\n";
                self.faceResults.text = [NSString stringWithFormat:@"%@%@%@", faceStr1, peopleStr, faceStr2];
                
                NSArray *emotions = @[@"joy", @"sorrow", @"surprise", @"anger"];
                NSMutableDictionary *emotionTotals = [NSMutableDictionary dictionaryWithObjects:@[@0.0,@0.0,@0.0,@0.0]forKeys:@[@"sorrow",@"joy",@"surprise",@"anger"]];
                NSDictionary *emotionLikelihoods = @{@"VERY_LIKELY": @0.9, @"LIKELY": @0.75, @"POSSIBLE": @0.5, @"UNLIKELY": @0.25, @"VERY_UNLIKELY": @0.0};
                
                // Sum all detected emotions
                for (NSDictionary *personData in faceAnnotations) {
                    for (NSString *emotion in emotions) {
                        NSString *lookup = [emotion stringByAppendingString:@"Likelihood"];
                        NSString *result = [personData objectForKey:lookup];
                        double newValue = [emotionLikelihoods[result] doubleValue] + [emotionTotals[emotion] doubleValue];
                        NSNumber *tempNumber = [[NSNumber alloc] initWithDouble:newValue];
                        [emotionTotals setValue:tempNumber forKey:emotion];
                    }
                }
                
                // Get emotion likelihood as a % and display it in the UI
                for (NSString *emotion in emotionTotals) {
                    double emotionSum = [emotionTotals[emotion] doubleValue];
                    double totalPeople = [faceAnnotations count];
                    double likelihoodPercent = emotionSum / totalPeople;
                    NSString *percentString = [[NSString alloc] initWithFormat:@"%2.0f%%",(likelihoodPercent*100)];
                    NSString *emotionPercentString = [NSString stringWithFormat:@"%@%@%@%@", emotion, @": ", percentString, @"\r\n"];
                    self.faceResults.text = [self.faceResults.text stringByAppendingString:emotionPercentString];
                }
            } else {
                self.faceResults.text = @"No faces found";
            }
            
            // Get label annotations
            NSDictionary *labelAnnotations = [responseData objectForKey:@"textAnnotations"];
            NSInteger numLabels = [labelAnnotations count];
            NSMutableArray *labels = [[NSMutableArray alloc] init];
            if (numLabels > 0) {
                NSString *labelResultsText = @"Text found: ";
                for (NSDictionary *label in labelAnnotations) {
                    NSString *labelString = [label objectForKey:@"description"];
                    [labels addObject:labelString];
                }
                for (NSString *label in labels) {
                    // if it's not the last item add a comma
                    if (labels[labels.count - 1] != label) {
                        NSString *commaString = [label stringByAppendingString:@", "];
                        labelResultsText = [labelResultsText stringByAppendingString:commaString];
                    } else {
                        labelResultsText = [labelResultsText stringByAppendingString:label];
                    }
                }
                self.labelResults.text = labelResultsText;
            } else {
                self.labelResults.text = @"No texts found";
            }
        }
    });
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        //.. done dismissing
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

