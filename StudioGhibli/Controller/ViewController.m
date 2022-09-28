//
//  ViewController.m
//  StudioGhibli
//
//  Created by Nicolás Cárdenas on 26/09/22.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSArray *filmData;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController
NSString *filmsUrl = @"https://ghibliapi.herokuapp.com/films";
NSString *selectedFilmId;

- (void)viewDidLoad {
    [super viewDidLoad];
    filmData = [[NSMutableArray alloc] init];
    [self fetchFilms];
}

- (void)fetchFilms {
    NSURL *url = [NSURL URLWithString:filmsUrl];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error making request: %@", error);
            return;
        }
        NSError *parseError;
        NSArray *films = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if (parseError != nil) {
            NSLog(@"Error parsing request: %@", parseError);
            return;
        }
        self->filmData = films;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_tableView reloadData];
        });
    }];
    [task resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [filmData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"filmCell"];
    NSDictionary *dict = filmData[indexPath.row];
    [cell.textLabel setText: [dict objectForKey:@"title"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *selectedFilm = filmData[indexPath.row];
    selectedFilmId = [selectedFilm objectForKey:@"id"];
    [self performSegueWithIdentifier:@"listToDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destination = [segue destinationViewController];
    ((DetailViewController *)destination).filmId = selectedFilmId;
}

@end
