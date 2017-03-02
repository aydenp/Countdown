// DDTMColours.m
// TranslucentApps
//
// Copyright (c) 2017 Dynastic Development
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// DDTMColours.m
// TranslucentApps
//
// Copyright (c) 2017 Dynastic Development
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
