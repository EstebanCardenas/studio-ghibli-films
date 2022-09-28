//
//  DetailViewController.m
//  StudioGhibli
//
//  Created by Nicolás Cárdenas on 27/09/22.
//

#import "DetailViewController.h"

@interface DetailViewController () {
    NSDictionary *detailDict;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *directorLabel;
@property (weak, nonatomic) IBOutlet UILabel *producerLabel;
@property (weak, nonatomic) IBOutlet UILabel *releaseDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *runningTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *scoreProgress;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation DetailViewController
NSString *detailUrl = @"https://ghibliapi.herokuapp.com/films";

- (void)viewDidLoad {
    [super viewDidLoad];
    [_activityIndicator setAlpha:1];
    [self fetchDetail];
}

- (void)fetchDetail {
    NSString *filmDetailUrl = [NSString stringWithFormat:@"%@/%@", detailUrl, _filmId];
    NSURL *url = [NSURL URLWithString:filmDetailUrl];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"%@", error);
            return;
        }
        NSError *parseError;
        self->detailDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if (parseError != nil) {
            NSLog(@"Error parsing data: %@", parseError);
            return;
        }
        [self updateUI];
    }];
    [task resume];
}

- (void)updateUI {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_activityIndicator setAlpha:0];
        [_titleLabel setText:[detailDict objectForKey:@"title"]];
        [_subtitleLabel setText:[detailDict objectForKey:@"original_title"]];
        [_descriptionLabel setText:[detailDict objectForKey:@"description"]];
        [_directorLabel setText:[detailDict objectForKey:@"director"]];
        [_producerLabel setText:[detailDict objectForKey:@"producer"]];
        [_releaseDateLabel setText:[detailDict objectForKey:@"release_date"]];
        [_runningTimeLabel setText:[NSString stringWithFormat:@"%@ minutes", [detailDict objectForKey:@"running_time"]]];
        NSString *scoreText = [detailDict objectForKey:@"rt_score"];
        [_scoreLabel setText:[NSString stringWithFormat:@"%@/100", scoreText]];
        float scoreFloat = [scoreText floatValue];
        float progress = scoreFloat / 100.0f;
        [_scoreProgress setProgress:progress];
    });
}

@end
