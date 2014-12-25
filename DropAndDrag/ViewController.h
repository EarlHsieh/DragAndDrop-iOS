//
//  ViewController.h
//  CollectionViewTest
//
//  Created by Earl Hsieh on 2014/12/24.
//  Copyright (c) 2014年 Earl Hsieh. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NON_SELECTED_MOVED                  (-1)
#define INPUT_SPACE_SELECTED_MOVED          (0)
#define OUTPUT_SPACE_SELECTED_MOVED         (1)

@interface ViewController : UIViewController
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    NSInteger moveState;
    NSInteger selectedInputImageView;
    UIImage *nullImage;
    UIImageView *movingImage;
    NSMutableArray *inputSpaceImageViews;
    NSMutableArray *outputSpaceImageViews;
}

@end
