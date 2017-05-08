//
//  XXGJMapViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/11.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJMapViewController.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import "XXGJAnnotationView.h"

@interface XXGJMapViewController () <BMKMapViewDelegate>
@property (weak, nonatomic) IBOutlet BMKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *correctUserLocationBtn;
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationAddressLabel;

@end

@implementation XXGJMapViewController

+ (instancetype)mapViewController
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mapView setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.mapView setDelegate:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /** 设置导航栏信息*/
    [self setNavigationBarTitle:@"位置信息"];
    [self.mapView setZoomLevel:19.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setter and getter
- (void)setLocationInfo:(XXGJLocationInfo *)locationInfo
{
    _locationInfo = locationInfo;
    /** 设置位置的详细信息*/
    [self.locationNameLabel setText:_locationInfo.name];
    [self.locationAddressLabel setText:_locationInfo.address];
}

#pragma mark - private delegate
- (void)addUserLocationAnnotionWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    /** 创建标注*/
    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
    annotation.coordinate = coordinate;
    [self.mapView addAnnotation:annotation];
    /** 设置地图的中心点和缩放等级*/
    [self.mapView setZoomLevel:19.0f];
    [self.mapView setCenterCoordinate:coordinate animated:YES];
}
- (IBAction)correctUserLocation:(id)sender
{
    [self addUserLocationAnnotionWithCoordinate:self.locationInfo.location];
}


#pragma mark - bmk mapview delegate
/**
 *地图初始化完毕时会调用此接口
 *@param mapView 地图View
 */
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView
{
    /** 将矫正按钮提到最上层来*/
    [self.mapView bringSubviewToFront:self.correctUserLocationBtn];
    /** 标定传过来的位置*/
    [self addUserLocationAnnotionWithCoordinate:_locationInfo.location];
}

/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]])
    {
        /** 返回一个大头针*/
        XXGJAnnotationView *annotationView = [[XXGJAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        annotationView.image = [UIImage imageNamed:@"chat_ui_icon_location_annation"];
        return annotationView;
    }
    return nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
