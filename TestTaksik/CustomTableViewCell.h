//
//  CustomTableViewCell.h
//  TestTaksik
//
//  Created by Admin on 17.08.15.
//  Copyright (c) 2015 Mariya Beketova. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label_City;
@property (weak, nonatomic) IBOutlet UILabel *label_Distance;

@end
