//
//  ViewController.m
//  CollectionViewTest
//
//  Created by Earl Hsieh on 2014/12/24.
//  Copyright (c) 2014年 Earl Hsieh. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    screenWidth = self.view.frame.size.width;
    screenHeight = self.view.frame.size.height;

    inputSpaceImageViews = [[NSMutableArray alloc] init];
    outputSpaceImageViews = [[NSMutableArray alloc] init];

    nullImage = [self createColorImage];
    movingImage = [[UIImageView alloc] init];

    moveState = NON_SELECTED_MOVED;

    [self createDynamicSceneUI];
    [self createSceneUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIImage *)createColorImage
{
    CGRect imageRect = CGRectMake(0, 0, 64, 64);
    CGFloat red = (rand() / (float) RAND_MAX);
    CGFloat green = (rand() / (float) RAND_MAX);
    CGFloat blue = (rand() / (float) RAND_MAX);
    UIColor *color = [[UIColor alloc] initWithRed:red green:green blue:blue alpha:1.0];

    UIGraphicsBeginImageContext(imageRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, imageRect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

-(void) createDynamicSceneUI
{
    NSArray *imageNameArray = [[NSArray alloc] initWithObjects:nullImage, nullImage, nullImage,
                                                                nullImage, nullImage, nil];
    CGFloat dynamicSceneFrameWidth = 50;
    CGFloat dynamicSceneFrameHeight = 50;
    CGFloat dynamicSceneStartX = (screenWidth - (dynamicSceneFrameWidth * 5)) / 2;
    CGFloat dynamicSceneStartY = 100;

    for (int i = 0; i < imageNameArray.count; ++i) {

        UIImageView *cellView = [[UIImageView alloc] initWithImage:[imageNameArray objectAtIndex:i]];
        cellView.frame = CGRectMake(dynamicSceneStartX + (dynamicSceneFrameWidth * i),
                                    dynamicSceneStartY,
                                    dynamicSceneFrameWidth,
                                    dynamicSceneFrameHeight);

        [self.view addSubview:cellView];
        [inputSpaceImageViews addObject:cellView];
    }
}

-(void) createSceneUI
{
    CGFloat sceneFrameWidth = 60;
    CGFloat sceneFrameHieght = 70;
    CGFloat sceneStartX = (screenWidth - (50 * 5)) / 2;
    CGFloat sceneStartY = 100 + 50 + 20;
    CGFloat sceneRowWidth = 30;
    CGFloat sceneRowHeight = 20;
    NSArray *imageNameArray = [[NSArray alloc] initWithObjects:[self createColorImage],
                                                                [self createColorImage],
                                                                [self createColorImage],
                                                                [self createColorImage],
                                                                [self createColorImage],
                                                                [self createColorImage],
                                                                [self createColorImage],
                                                                [self createColorImage],
                                                                [self createColorImage],
                                                                [self createColorImage],
                                                                [self createColorImage],
                                                                [self createColorImage], nil];

    for (int i = 0; i < imageNameArray.count; ++i) {

        UIImageView *cellView = [[UIImageView alloc] initWithImage:[imageNameArray objectAtIndex:i]];
        cellView.frame = CGRectMake(sceneStartX + ((sceneRowWidth + sceneFrameWidth) * (i % 3)),
                                    sceneStartY + (sceneRowHeight + sceneFrameHieght) * (i / 3),
                                    sceneFrameWidth, sceneFrameHieght);

        [self.view addSubview:cellView];
        [outputSpaceImageViews addObject:cellView];
    }
}

-(BOOL) isTouchedValid:(CGPoint)touchPoint imageFrame:(CGRect)frame
{
    if (touchPoint.x > frame.origin.x &&
        touchPoint.x < frame.origin.x + frame.size.width &&
        touchPoint.y > frame.origin.y &&
        touchPoint.y < frame.origin.y + frame.size.height) {
        return YES;
    }

    return NO;
}

-(void) showMovingImage:(UIImage *)image centerPoint:(CGPoint)point
{
    [movingImage removeFromSuperview];

    movingImage.image = image;
    movingImage.frame = CGRectMake(point.x - (image.size.width / 2),
                                   point.y - (image.size.height / 2),
                                   image.size.width,
                                   image.size.height);
    [self.view addSubview:movingImage];
}

-(void) changeViewImage:(UIImageView *)imageView image:(UIImage *)image order:(NSInteger)order
{
    [imageView removeFromSuperview];
    imageView.image = image;
    [inputSpaceImageViews replaceObjectAtIndex:order withObject:imageView];
    [self.view addSubview:imageView];
}

-(void) replaceInputSpaceAfterAddView
{
    for (int i = 0; i < inputSpaceImageViews.count; ++i) {
        UIImageView *replaceCellView = [inputSpaceImageViews objectAtIndex:i];
        if ([replaceCellView.image isEqual:nullImage]) {
            [self changeViewImage:replaceCellView image:movingImage.image order:i];
            break;
        }
    }
}

-(void) replaceInputSpaceAfterRemoveView
{
    for (int i = 0; i < inputSpaceImageViews.count - selectedInputImageView; ++i) {
        NSInteger checkNum = selectedInputImageView + i + 1;

        if (checkNum == inputSpaceImageViews.count ) {
            break;
        }

        UIImageView *checkNullCellView = [inputSpaceImageViews objectAtIndex:checkNum];
        if (![checkNullCellView isEqual:nullImage]) {
            UIImageView *tmp1 = [inputSpaceImageViews objectAtIndex:(checkNum - 1)];

            [tmp1 removeFromSuperview];
            [checkNullCellView removeFromSuperview];

            tmp1.image = checkNullCellView.image;
            checkNullCellView.image = nullImage;

            [self.view addSubview:tmp1];
            [self.view addSubview:checkNullCellView];

            [inputSpaceImageViews replaceObjectAtIndex:(checkNum - 1) withObject:tmp1];
            [inputSpaceImageViews replaceObjectAtIndex:checkNum withObject:checkNullCellView];
        }
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint beganPoint = [[touches anyObject] locationInView:self.view];

    for (int i = 0; i < inputSpaceImageViews.count + outputSpaceImageViews.count; ++i) {
        UIImageView *cellView = [[UIImageView alloc] init];

        if (i < inputSpaceImageViews.count) {
            cellView = [inputSpaceImageViews objectAtIndex:i];

            if ([self isTouchedValid:beganPoint imageFrame:cellView.frame] &&
                ![cellView.image isEqual:nullImage]) {
                [self showMovingImage:cellView.image centerPoint:beganPoint];

                selectedInputImageView = i;
                moveState = INPUT_SPACE_SELECTED_MOVED;
            }
        } else {
            cellView = [outputSpaceImageViews objectAtIndex:(i - inputSpaceImageViews.count)];

            if ([self isTouchedValid:beganPoint imageFrame:cellView.frame]) {
                [self showMovingImage:cellView.image centerPoint:beganPoint];
                moveState = OUTPUT_SPACE_SELECTED_MOVED;
            }
        }
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint movedPoint = [[touches anyObject] locationInView:self.view];

    if (moveState != NON_SELECTED_MOVED) {
        [self showMovingImage:movingImage.image centerPoint:movedPoint];
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint endedPoint = [[touches anyObject] locationInView:self.view];
    [movingImage removeFromSuperview];

    if (moveState == INPUT_SPACE_SELECTED_MOVED) {
        UIImageView *cellView = [inputSpaceImageViews objectAtIndex:selectedInputImageView];

        if (![self isTouchedValid:endedPoint imageFrame:cellView.frame]) {
            [cellView removeFromSuperview];
            cellView.image = nullImage;

            [self.view addSubview:cellView];
            [inputSpaceImageViews replaceObjectAtIndex:selectedInputImageView withObject:cellView];
            [self replaceInputSpaceAfterRemoveView];
        }
    } else if (moveState == OUTPUT_SPACE_SELECTED_MOVED) {
        for (int i = 0; i < inputSpaceImageViews.count; ++i) {

            UIImageView *cellView = [inputSpaceImageViews objectAtIndex:i];
            if ([self isTouchedValid:endedPoint imageFrame:cellView.frame]) {
                if (![cellView.image isEqual:nullImage]) {
                    [self changeViewImage:cellView image:movingImage.image order:i];
                    break;
                } else {
                    [self replaceInputSpaceAfterAddView];
                }
            }
        }
    }

    moveState = NON_SELECTED_MOVED;
}

@end
