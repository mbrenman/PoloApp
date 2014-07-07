//
//  SettingsViewController.h
//  PoloApp
//
//  Created by Matt Brenman on 5/20/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FCColorPickerViewController.h>


@interface SettingsViewController : UIViewController <FCColorPickerViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *unitsSwitch;

-(IBAction)chooseColor:(id)sender;


@end
