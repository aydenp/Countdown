//
//  DDCreditCell.h
//  CellTest
//
//  Created by AppleBetas on 2017-02-24.
//  Copyright © 2017 AppleBetas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSEditableTableCell.h>

// The text field isn't in a lot of header sets, so let's make it ourselves
@interface PSEditableTableCell (TextField)
-(UITextField *)textField;
-(id)value;
-(void)setValue:(id)arg1;
-(void)_setValueChanged;
@end

@interface DDDatePickerCell : PSEditableTableCell <UITextFieldDelegate>
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
- (void)_setInitialText;
- (void)_setupDatePicker;
@end
