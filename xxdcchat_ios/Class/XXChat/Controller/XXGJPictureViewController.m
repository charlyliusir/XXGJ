//
//  XXGJPictureViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/5.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJPictureViewController.h"
#import "VIPhotoView.h"

#define TopHeight 84

@interface XXGJPictureViewController () <VIPhotoViewDelegate>
@property (nonatomic, strong)UIScrollView *scrollView;
@property (nonatomic, strong)UIView *photoAlbum;
@property (nonatomic, strong)NSMutableArray *flagArrays;

@property (nonatomic, strong)VIPhotoView *photoView;
@property (nonatomic, strong)VIPhotoView *pastView;
@property (nonatomic, strong)VIPhotoView *presentView;
@property (nonatomic, strong)VIPhotoView *futureView;
@property (nonatomic, strong)UITapGestureRecognizer *dimssAction;
@end

@implementation XXGJPictureViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.photoAlbum = [[UIView alloc] initWithFrame:self.view.bounds];
    self.photoAlbum.backgroundColor = [UIColor clearColor];
    
    if (self.image)
    {
        self.photoView = [[VIPhotoView alloc] initWithFrame:self.view.frame andImage:self.image];
    }else
    {
        self.photoView = [[VIPhotoView alloc] initWithFrame:self.view.frame andNetWorkString:self.imgUrl];
    }
    self.photoView.tapDelegate = self;
    self.photoView.backgroundColor = [UIColor blackColor];
    [self.photoAlbum addSubview:self.photoView];
    
    [self.view addSubview:self.photoAlbum];
}

#pragma mark - receive memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - delegate
#pragma mark - photo delegate
- (void)tapHandler
{
    [self.photoView stopTimer];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
