//
//  AGViewController.m
//  Example
//
//  Created by Karim Sallam on 12/12/2013.
//  Copyright (c) 2013 K-Apps. All rights reserved.
//

#import "AGViewController.h"
#import "AGLayerView.h"
#import "AGScene.h"

@interface AGViewController ()

@property (weak, nonatomic) IBOutlet AGLayerView *layerView;
@property (strong, nonatomic) AGScene *scene;
@property (weak, nonatomic) IBOutlet UILabel *valuesLabel;

@end

@implementation AGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.scene = [[AGScene alloc] initWithLayers:@[self.layerView]];
    BOOL started = [self.scene start];
    if (!started)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"This device is not supported."
                                   delegate:nil
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:nil]
         show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
