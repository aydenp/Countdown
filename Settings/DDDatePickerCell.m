//
//  DDCreditCell.m
//  CellTest
//
//  Created by AppleBetas on 2017-02-24.
//  Copyright © 2017 AppleBetas. All rights reserved.
//

#import "DDDatePickerCell.h"

@implementation DDDatePickerCell
    
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    if (self) {
        [self _setupDatePicker];
    }
    return self;
}
    
-(void)refreshCellContentsWithSpecifier:(id)arg1 {
    [super refreshCellContentsWithSpecifier:arg1];
    // Set initial text if we don't have a value
    [self _setInitialText];
    // Set the current text to the date
    [self.datePicker setDate:[self.dateFormatter dateFromString:self.value]];
}
    
- (void)_setInitialText {
    if(self.value == nil || [self.value isEqualToString:@""]) {
        [self setValue:[self.dateFormatter stringFromDate:[NSDate date]]];
        [self _setValueChanged];
    }
}

- (void)_setupDatePicker {
    // Make a new UIDatePicker
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.datePicker addTarget:self
                        action:@selector(dateUpdated:)
              forControlEvents:UIControlEventValueChanged];
    // Set it to our text field's input view
    self.textField.inputView = self.datePicker;
    // Get rid of the blinking cursor
    [self.textField setTintColor:[UIColor clearColor]];
}
    
- (void)dateUpdated:(UIDatePicker *)datePicker {
    [self setValue:[self.dateFormatter stringFromDate:datePicker.date]];
    [self _setValueChanged];
}
    
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return NO;
}
    
@end
