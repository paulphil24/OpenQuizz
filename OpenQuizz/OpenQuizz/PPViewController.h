//
//  PPViewController.h
//  OpenQuizz
//
//  Created by Paul on 10/04/2015.
//  Copyright (c) 2015 Paul Philipon-Dollet. All rights reserved.
//

#import <UIKit/UIKit.h>
// #import <QuartzCore/QuartzCore.h>

@interface PPViewController : UIViewController <UIPickerViewDelegate>
{
    IBOutletCollection(UIView) NSArray *appViews;
    IBOutlet UISlider *qzSlider;
    IBOutlet UILabel *qzQuestionText;
    IBOutlet UILabel *qzQuestionCount;
    IBOutlet UILabel *qzChosenAnswer;
    IBOutlet UILabel *qzAppTitle;
    
    NSArray * qzKeys;
    NSArray * qzMap;
    NSArray * qzDims;
    NSArray * qzQuestions;
    NSArray * qzAnswers;
    NSArray * qzComments;
    
    NSMutableDictionary * qzScores;
    NSMutableDictionary * qzResults;
    
    NSString * userDataPath;
    
    UIAlertView *noChoiceAlert;
    UIView *modalView;
    UIPickerView *pickerAge;
    UIPickerView *pickerGenre;
    UIButton *modalValidate;
    
    int qzCurrent;
}

@property (retain, nonatomic) NSArray *appViews;
@property (retain, nonatomic) UISlider *qzSlider;
@property (retain, nonatomic) UILabel *qzChosenAnswer;
@property (retain, nonatomic) UILabel *qzQuestionText;
@property (retain, nonatomic) UILabel *qzQuestionCount;
@property (retain, nonatomic) UIPickerView *pickerAge;
@property (retain, nonatomic) UIPickerView *pickerGenre;
@property (retain, nonatomic) UIButton *modalValidate;

-(IBAction)qzStart:(id)sender;
-(IBAction)qzNext:(id)sender;

@end
