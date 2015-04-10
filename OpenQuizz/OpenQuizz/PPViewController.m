//
//  PPViewController.m
//  OpenQuizz
//
//  Created by Paul on 10/04/2015.
//  Copyright (c) 2015 Paul Philipon-Dollet. All rights reserved.
//

#import "PPViewController.h"

@interface PPViewController ()

@end

@implementation PPViewController


@synthesize appViews, qzSlider, qzChosenAnswer, qzQuestionCount, qzQuestionText, pickerAge, pickerGenre, modalValidate;

#define TEXT_COLOR [UIColor colorWithRed:44.0/255.0 green:72.0/255.0 blue:123.0/255.0 alpha:1.0]
#define RESULT_GREEN [UIColor colorWithRed:191.0/255.0 green:216.0/255.0 blue:62.0/255.0 alpha:1.0]
#define RESULT_YELLOW [UIColor colorWithRed:242.0/255.0 green:152.0/255.0 blue:45.0/255.0 alpha:1.0]
#define RESULT_RED [UIColor colorWithRed:242.0/255.0 green:33.0/255.0 blue:113.0/255.0 alpha:1.0]

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    qzCurrent = 1;
    
    [qzAppTitle setText:NSLocalizedString(@"Comment va mon couple ?",nil)];
    
    [self getCommonParams];
    
    [self getLocalizedParams];
    
    [self qzSliderInit];
    
    qzScores = [NSMutableDictionary dictionaryWithCapacity:25];
    
    qzResults = [NSMutableDictionary dictionaryWithCapacity:9];
    
    [self initPlistStore];
    
    [self switchToView:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)switchToView:(int)vdx {
	for (UIView *appView in appViews) {
        if(appView.tag==vdx) {
            [appView setHidden:NO];
        } else {
            [appView setHidden:YES];
        }
    }
}

#pragma mark - SURVEY METHODS

-(IBAction)qzStart:(id)sender {
    [self setQuestionCountLabel];
    [qzQuestionText setText:[qzQuestions objectAtIndex:(qzCurrent-1)]];
    [qzChosenAnswer setText:[qzAnswers objectAtIndex:0]];
    [qzChosenAnswer setFont:[UIFont systemFontOfSize:13.0]];
    [self switchToView:1];
}

- (IBAction)qzNext:(id)sender {
    if ([qzSlider value] == 0.0) {
        noChoiceAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attention",nil)
                                                   message:NSLocalizedString(@"Choisissez une option avant de passer à la question suivante",nil)
                                                  delegate:nil
                                         cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                         otherButtonTitles: nil];
        [noChoiceAlert show];
        noChoiceAlert=nil;
        return;
    }
    //[self modalUserInfoActionSheet];
    [qzScores setObject:[NSNumber numberWithFloat:[qzSlider value]]
                 forKey:[qzKeys objectAtIndex:(qzCurrent -1)]];
    if (qzCurrent < [qzKeys count]) {
        [self displayNextQuestion];
    } else {
        NSLog(@"Last question reached");
        [self calculateResults];
        [self modalUserInfoActionSheet];
        [self switchToView:2];
    }
}

-(void)calculateResults {
    for (id key in qzDims) {
        int result = 0;
        for (NSDictionary *_dict in qzMap) {
            NSString * kret = [NSString stringWithFormat:@"%@%@",key,[_dict objectForKey:@"ret"]];
            NSString * kdex = [NSString stringWithFormat:@"%@%@",key,[_dict objectForKey:@"dex"]];
            NSString * klev = [NSString stringWithFormat:@"%@%@",key,[_dict objectForKey:@"lev"]];
            int vret = [[qzScores objectForKey:kret ] intValue];
            if (vret > 3) {
                int vdex = [[qzScores objectForKey:kdex] intValue];
                if (vdex < 6) {
                    vdex ++;
                }
                [qzScores setObject:[NSNumber numberWithInt:vdex] forKey:kdex];
            } else {
                int vlev = [[qzScores objectForKey:klev] intValue];
                if (vlev > 0) {
                    vlev --;
                }
                [qzScores setObject:[NSNumber numberWithInt:vlev] forKey:klev];
            }
        }
        for (NSDictionary *_dict in qzMap) {
            NSString * kret = [NSString stringWithFormat:@"%@%@",key,[_dict objectForKey:@"ret"]];
            result += [[qzScores objectForKey:kret ] intValue];
        }
        [qzResults setObject:[NSNumber numberWithInt:result] forKey:key];
    }
    for (NSDictionary *_dict in qzMap) {
        int fret = [[qzResults objectForKey:[_dict objectForKey:@"ret"]] intValue];
        if (fret > 15) {
            int fdex = [[qzResults objectForKey:[_dict objectForKey:@"dex"]] intValue];
            if (fdex < 25) {
                fdex = fdex +5;
            }
            [qzResults setObject:[NSNumber numberWithInt:fdex] forKey:[_dict objectForKey:@"lev"]];
        } else {
            int flev = [[qzResults objectForKey:[_dict objectForKey:@"lev"]] intValue];
            if (flev >= 5) {
                flev = flev -5;
            }
            [qzResults setObject:[NSNumber numberWithInt:flev] forKey:[_dict objectForKey:@"lev"]];
        }
    }
}

-(void)modalUserInfoActionSheet {
    modalView = [[UIView alloc] initWithFrame:CGRectMake(20.0,120.0,280.0,320.0)];
    [modalView setBackgroundColor:[UIColor whiteColor]];
    modalView.layer.borderColor = RESULT_GREEN.CGColor;
    modalView.layer.borderWidth = 1.0f;
    
    CGFloat vertical = modalView.frame.size.height - 20.0;
    UILabel *modalTitle = [[UILabel alloc] initWithFrame:CGRectMake(20.0,10.0,240.0,21.0)];
    [modalTitle setText:NSLocalizedString(@"Complément d'information",nil)];
    [modalTitle setTextAlignment:NSTextAlignmentCenter];
    [modalTitle setTextColor:TEXT_COLOR];
    [modalView addSubview:modalTitle];
    
    UILabel *pickerAgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0,50.0,120.0,21.0)];
    [pickerAgeLabel setText:NSLocalizedString(@"Age",nil)];
    [pickerAgeLabel setFont:[UIFont systemFontOfSize:13]];
    [pickerAgeLabel setTextAlignment:NSTextAlignmentCenter];
    [pickerAgeLabel setTextColor:TEXT_COLOR];
    [modalView addSubview:pickerAgeLabel];
    
    pickerAge = [[UIPickerView alloc] initWithFrame:
                 CGRectMake(10.0, 60.0, 120.0, 42.0)];
    pickerAge.delegate = self;
    pickerAge.showsSelectionIndicator = YES;
    pickerAge.tintColor = TEXT_COLOR;
    [modalView addSubview:pickerAge];
    
    UILabel *pickerGenreLabel = [[UILabel alloc] initWithFrame:CGRectMake(150.0,50.0,120.0,21.0)];
    [pickerGenreLabel setText:NSLocalizedString(@"Genre",nil)];
    [pickerGenreLabel setFont:[UIFont systemFontOfSize:13]];
    [pickerGenreLabel setTextAlignment:NSTextAlignmentCenter];
    [pickerGenreLabel setTextColor:TEXT_COLOR];
    [modalView addSubview:pickerGenreLabel];
    
    pickerGenre = [[UIPickerView alloc] initWithFrame:
                   CGRectMake(150.0, 60.0, 120.0, 42.0)];
    pickerGenre.delegate = self;
    pickerGenre.showsSelectionIndicator = YES;
    [modalView addSubview:pickerGenre];
    
    //For button image
    UIImage *img = [UIImage imageNamed:@"maquette_app_aforpel_survey-screen_15.png"];
    //Custom type button
    modalValidate = [UIButton buttonWithType:UIButtonTypeCustom];
    //Set frame of button means position
    modalValidate.frame = CGRectMake(110, 230, 64, 64);
    //Button with 0 border so it's shape like image shape
    [modalValidate.layer setBorderWidth:0];
    //Set title of button
    [modalValidate setTitle:nil forState:UIControlStateNormal];
    [modalValidate addTarget:self action:@selector(modalSend:) forControlEvents:UIControlEventTouchUpInside];
    //Font size of title
    modalValidate.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    //Set image of button
    [modalValidate setBackgroundImage:img forState:UIControlStateNormal];
    [modalView addSubview:modalValidate];
    
    [self.view addSubview:modalView];
    [UIView animateWithDuration:0.4 animations:^{
        [modalView setCenter:CGPointMake(modalView.frame.size.width / 1.75, vertical)];
    } completion:^(BOOL finished) {
        NSLog(@"finished");
    }];
    [qzQuestionCount setHidden:YES];
}

-(void)setQuestionCountLabel {
    [qzQuestionCount setText:[NSString stringWithFormat:
                              NSLocalizedString(@"Question %lu sur %lu",nil),(long)qzCurrent,(long)[qzQuestions count]]];
}
-(void)displayNextQuestion {
    qzCurrent ++;
    [self setQuestionCountLabel];
    [qzQuestionText setText:[qzQuestions objectAtIndex:(qzCurrent-1)]];
    [qzSlider setValue:0.0 animated:NO];
}

-(void)modalSend:(id)sender {
    NSLog(@"modalSend clicked with age set to %lu and genre set to %@ and result %@",
          (long)[pickerAge selectedRowInComponent:0]+15,
          [self pickerView:pickerGenre titleForRow:[pickerGenre selectedRowInComponent:0] forComponent:0],
          qzResults);
}

#pragma mark - PARAMETERS METHODS

- (void)getCommonParams {
    NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:
                           [[NSBundle mainBundle] pathForResource:@"PPCommonParameters" ofType:@"plist" ]];
    qzKeys = [dict objectForKey:@"Keys"];
    qzMap = [dict objectForKey:@"ODSMap"];
    qzDims = [dict objectForKey:@"ODSDim"];
    dict = nil;
}

- (void)getLocalizedParams {
    NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:
                           [[NSBundle mainBundle] pathForResource:@"PPLocalizableParameters" ofType:@"plist"]];
    qzQuestions = [dict objectForKey:@"Values"];
    qzAnswers = [dict objectForKey:@"Answers"];
    qzComments = [dict objectForKey:@"ODSComments"];
    dict = nil;
}

#pragma mark - UISliderDelegate

- (void)qzSliderInit {
    [qzSlider setMinimumValue:0.0];
    [qzSlider setMaximumValue:6.0];
    [qzSlider setMinimumTrackImage:[UIImage imageNamed:@"uisliderimg_03.png"] forState:UIControlStateNormal];
    [qzSlider setMaximumTrackImage:[UIImage imageNamed:@"ios_slider_bkg_07.png"] forState:UIControlStateNormal];
    [qzSlider setThumbImage:[UIImage imageNamed:@"ios_slider_bkg_10.png"] forState:UIControlStateNormal];
    [qzSlider addTarget:self
                 action:@selector(sliderValueChanged:)
       forControlEvents:UIControlEventValueChanged];
}

- (void)sliderValueChanged:(UISlider *)sender {
    NSUInteger index = (NSUInteger) (qzSlider.value + 0.5);
    [qzSlider setValue:index animated:NO];
    [qzChosenAnswer setText:[qzAnswers objectAtIndex:index]];
    if(index > 0) {
        [qzChosenAnswer setFont:[UIFont boldSystemFontOfSize:14.0]];
    } else {
        [qzChosenAnswer setFont:[UIFont systemFontOfSize:12.0]];
    }
}

#pragma mark - USER DATA PLIST STORE

- (void)initPlistStore {
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    userDataPath = [documentsDirectory stringByAppendingPathComponent:@"OpenQuizzUserData.plist"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if(![fileMgr fileExistsAtPath:userDataPath]) {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"OpenQuizzUserData" ofType:@"plist"];
        [fileMgr copyItemAtPath:bundle toPath:userDataPath error:&error];
    }
}

- (void)writeToPlist {
    NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:userDataPath];
    NSMutableArray *records = [plist objectForKey:@"Records"];
    [records addObject:qzResults];
    [plist setObject:records forKey:@"Records"];
    [plist writeToFile:userDataPath atomically:YES];
    plist = nil;
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger numRows = 2;
    if (pickerView == pickerAge) {
        numRows = 79;
    }
    return numRows;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    if (pickerView == pickerAge) {
        NSDateComponents *dcomp = [[NSCalendar currentCalendar]
                                   components:NSYearCalendarUnit
                                   fromDate:[NSDate date]];
        int year = [dcomp year];
        title = [@"" stringByAppendingFormat:@"%d",(year - 15) - row];
    }
    if (pickerView == pickerGenre) {
        if (row == 0) {
            title = NSLocalizedString(@"Femme",nil);
        }
        if (row == 1) {
            title = NSLocalizedString(@"Homme",nil);
        }
        
    }
    return title;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 120;
    return sectionWidth;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    int rowHeight = 21;
    return rowHeight;
}

@end
