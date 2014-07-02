//
//  SettingsViewController.m
//  PoloApp
//
//  Created by Matt Brenman on 5/20/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "SettingsViewController.h"
#import "iAd/iAd.h"


@interface SettingsViewController ()

@end

@implementation SettingsViewController


-(IBAction)chooseColor:(id)sender {
    FCColorPickerViewController *colorPicker = [[FCColorPickerViewController alloc]
                                                initWithNibName:@"FCColorPickerViewController"
                                                bundle:[NSBundle mainBundle]];
    colorPicker.color = self.view.backgroundColor;
    colorPicker.delegate = self;
    
    [colorPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:colorPicker animated:YES completion:nil];
    
}

-(void)colorPickerViewController:(FCColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color {
    self.view.backgroundColor = color;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)colorPickerViewControllerDidCancel:(FCColorPickerViewController *)colorPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)getUserSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _unitsSwitch.on = [defaults boolForKey:@"units_preference"];
}

- (void)saveUserSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_unitsSwitch.on forKey:@"units_preference"];
}

- (IBAction)saveButtonClicked:(id)sender {
    [self saveUserSettings];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.canDisplayBannerAds = YES;
    
    //Round the corners on the save settings button
    _saveSettingsButton.layer.cornerRadius = 10;
    _saveSettingsButton.clipsToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"SETTINGS!");
    [self getUserSettings];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
