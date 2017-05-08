//
//  XXGJLocationViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/11.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJLocationViewController.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import <BaiduMapAPI_Search/BMKPoiSearch.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import "XXGJLocationInfoTableViewCell.h"
#import "XXGJLocationInfo.h"
#import "XXGJAnnotationView.h"
#import "XXGJMessage.h"

@interface XXGJLocationViewController () <UISearchBarDelegate, BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISearchBar *locationSearchBar;
@property (weak, nonatomic) IBOutlet BMKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *correctUserLocationBtn;
@property (nonatomic, strong)BMKGeoCodeSearch *geoCodeSearch; /** 百度地图逆编码搜索服务*/
@property (nonatomic, strong)BMKLocationService *locationService; /** 百度地图定位服务*/
@property (nonatomic, strong)BMKLocationViewDisplayParam *locationParam; /** 定位标注样式*/
@property (nonatomic, strong)BMKReverseGeoCodeOption *reverseGeoCodeOption;/** 逆编码搜索参数*/
@property (nonatomic, strong)BMKUserLocation *userLocation;
@property (nonatomic, strong)NSMutableArray *poiInfoList; /** 附近坐标的集合*/
@property (nonatomic, assign)NSUInteger selectIndex; /** 选择发送位置*/
@property (nonatomic, assign)BOOL needSearchPoiList; /** 是否需要重新搜索周边*/
@property (nonatomic, copy)LocationCompeleteBlock dismissBlock;
@end

@implementation XXGJLocationViewController

+ (instancetype)locationViewControllerComeBackBlock:(void (^)(XXGJMessage *))dismissBlock
{
    XXGJLocationViewController *locationViewController = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
    locationViewController.dismissBlock = dismissBlock;
    return locationViewController;
}

- (void)setNavigationUI
{
    [self setNavigationBarTitle:@"获取定位"];
    
    /** 设置导航按钮，左边按钮样式*/
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:CGRectMake(0, 0, 44, 44)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:XX_RGBCOLOR_WITHOUTA(102, 102, 102) forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [cancelBtn addTarget:self action:@selector(backMethod:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    /** 设置导航按钮，右边按钮样式*/
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(sendLocation:)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.needSearchPoiList = NO;
    [self.mapView setDelegate:nil]; /** 必要要清空,不然地图内存不会释放*/
    [self.locationService setDelegate:nil];
    [self.geoCodeSearch setDelegate:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.needSearchPoiList = YES;
    [self.mapView setDelegate:self];
    [self.locationService setDelegate:self];
    [self.geoCodeSearch setDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNavigationUI];
    /** 开始定位*/
    self.mapView.showsUserLocation = NO;//先关闭显示的定位图层
    self.mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    self.mapView.showsUserLocation = YES;//显示定位图层
    [self.locationService startUserLocationService];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy method
- (NSMutableArray *)poiInfoList
{
    if (!_poiInfoList)
    {
        _poiInfoList = [NSMutableArray array];
    }
    return _poiInfoList;
}
- (BMKLocationService *)locationService
{
    if (!_locationService)
    {
        _locationService = [[BMKLocationService alloc] init];
    }
    return _locationService;
}

- (BMKLocationViewDisplayParam *)locationParam
{
    if (!_locationParam)
    {
        _locationParam = [[BMKLocationViewDisplayParam alloc] init];
        _locationParam.isAccuracyCircleShow = NO; /** 不要精度圈*/
        _locationParam.locationViewImgName = @"my_location"; /** 自定义我的位置的标注*/
    }
    return _locationParam;
}

- (BMKGeoCodeSearch *)geoCodeSearch
{
    if (!_geoCodeSearch)
    {
        _geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
    }
    return _geoCodeSearch;
}

- (BMKReverseGeoCodeOption *)reverseGeoCodeOption
{
    if (!_reverseGeoCodeOption)
    {
        _reverseGeoCodeOption = [[BMKReverseGeoCodeOption alloc] init];
    }
    return _reverseGeoCodeOption;
}

#pragma mark - open method

#pragma mark - private method
- (void)backMethod:(UIBarButtonItem *)leftBarButtonItem
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
/**
 地图截屏

 @return 截屏后的照片
 */
- (UIImage *)cutScreenMapView
{
    // 1. 创建位图上下文
    /** size 是要截取图片的大小, opaque 是否需要透明, scale 是否需要缩放 0 表示不用缩放*/
    UIGraphicsBeginImageContextWithOptions(self.mapView.frame.size, NO, 0);
    // 2. 获取上下文
    CGContextRef imgContext = UIGraphicsGetCurrentContext();
    // 3. 把控件上的图层渲染到上下文
    [self.mapView.layer renderInContext:imgContext];
    // 4. 生成一张图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 5. 测试将图片写入相册
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    return image;
}

- (NSString *)locationMessageWithName:(NSString *)name imgUrl:(NSString *)imgUrl
{
    NSMutableString *locationMessageStr = [NSMutableString string];
    [locationMessageStr appendString:@"<font>"];
    [locationMessageStr appendString:name];
    [locationMessageStr appendString:@"</font><br/>"];
    [locationMessageStr appendString:@"<img src=\""];
    [locationMessageStr appendString:imgUrl];
    [locationMessageStr appendFormat:@"\"/>"];
    return locationMessageStr.copy;
}

/**
 发送地址和定位

 @param rightBarButtonItem 按钮
 */
- (void)sendLocation:(UIBarButtonItem *)rightBarButtonItem
{
    /** 选中地址信息*/
    XXGJLocationInfo *locationInfo = self.poiInfoList[self.selectIndex];
    /** 先把地图截屏*/
    UIImage *cutMapView = [self.mapView takeSnapshot];
    /** 将图片转成二进制*/
    NSData *fileData = UIImageJPEGRepresentation(cutMapView, 1.0f);
    NSString *newDate = [NSDate dateForDateFormatter:@"yyyy-MM-dd HH:mm:ss"];
    /** 图片参数*/
    float width  = cutMapView.size.width;
    float height = cutMapView.size.height;
    float lenth  = fileData.length;
    float size   = round(lenth/1024.f*100)/100;
    /** 制作消息体*/
    XXGJMessage *message = [[XXGJMessage alloc] init];
    message.MessageType  = @(XXGJRichText);
    [message addArgsObject:@{XXGJ_ARGS_PARAM_BITMPTIME:@""}];
    [message addArgsObject:@{XXGJ_ARGS_PARAM_BITMPHEIGHT:@(height)}];
    [message addArgsObject:@{XXGJ_ARGS_PARAM_BITMPWIDTH:@(width)}];
    [message addArgsObject:@{XXGJ_ARGS_PARAM_BITMPSIZE:@(size)}];
    [message addArgsObject:@{XXGJ_ARGS_PARAM_UPDATETIME:newDate}];
    [message addArgsObject:@{XXGJ_ARGS_PARAM_ADDRESS:[[locationInfo.name stringByAppendingString:@"||"] stringByAppendingString:locationInfo.address]}];
    [message addArgsObject:@{XXGJ_ARGS_PARAM_LONGITUDE:@(locationInfo.location.longitude)}];
    [message addArgsObject:@{XXGJ_ARGS_PARAM_LATITUDE:@(locationInfo.location.latitude)}];
    /** 将截屏地图图片上传到服务器*/
    [MBProgressHUD showLoadHUDText:@"正在发送..."];
    __weak typeof(self)weakSelf = self;
    [XXGJNetKit uploadImageWithData:fileData rProgress:nil rBlock:^(id obj, BOOL success, NSError *error) {
        __strong typeof(self)strongSelf = weakSelf;
        if (success && obj && [obj[@"status"][@"msg"] isEqualToString:@"success"])
        {
            NSDictionary *data = obj[@"data"];
            [message addArgsObject:@{XXGJ_ARGS_PARAM_IMAGEURL:data[@"url"]}];
            message.Content = [[self locationMessageWithName:message.Args[XXGJ_ARGS_PARAM_ADDRESS] imgUrl:data[@"url"]] stringByReplacingOccurrencesOfString:@"||" withString:@""];
            NSLog(@"message content : %@", message.Content);
            /** 返回到上一页,并发送图片*/
            [MBProgressHUD hiddenHUD];
            [strongSelf dismissViewControllerAnimated:YES completion:^{
                /** 执行代理回调*/
                if (strongSelf.dismissBlock)
                    /** 如果block回调参数存在, 则执行回调方法*/
                {
                    strongSelf.dismissBlock(message);
                }
            }];
            
        }else
        {
            [MBProgressHUD showLoadHUDText:@"发送失败,请检查当前网络!" during:0.25];
        }
    }];
    
}

/**
 重新矫正定位, 定位到当前位置

 @param sender 矫正按钮
 */
- (IBAction)correctUserLocation:(id)sender
{
    /** 判断是否已经获取到当前位置*/
    if (self.userLocation)
    {
        /** 重新标定地图的中心点*/
        [self.mapView setZoomLevel:19.0f];
        [self.mapView setCenterCoordinate:self.userLocation.location.coordinate animated:YES];
        /** 重新检索周边位置*/
        [self searchNearByWithLocation:self.userLocation.location.coordinate];
    }
}

- (void)searchNearByWithLocation:(CLLocationCoordinate2D)location
{
    /** 重新更新选中列表*/
    self.selectIndex = 0;
    /** 设置逆编码参数*/
    self.reverseGeoCodeOption.reverseGeoPoint = location;
    /** 执行逆编码检索*/
    if([self.geoCodeSearch reverseGeoCode:self.reverseGeoCodeOption])
    {
        NSLog(@"逆编码检索成功");
    }else
    {
        NSLog(@"逆编码检索失败");
    }
}


#pragma mark - delegate
#pragma mark - search bar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.locationSearchBar setShowsCancelButton:YES];
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [self.locationSearchBar setShowsCancelButton:NO];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"text Did change");
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"Should change in range");
    return YES;
}

/**
 搜索按钮被点击
 
 @param searchBar 搜索视图
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.locationSearchBar resignFirstResponder];
}

/**
 取消按钮被点击
 
 @param searchBar 搜索视图
 */
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.locationSearchBar setText:@""];
    [self.locationSearchBar resignFirstResponder];
}

#pragma mark - location map delegate
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    /** 记录当前位置*/
    self.userLocation = userLocation;
    /** 地图更新当前位置*/
    [self.mapView setZoomLevel:19.0f]; /** 设置缩放比例*/
    [self.mapView updateLocationViewWithParam:self.locationParam]; /** 设置当前位置样式*/
    [self.mapView updateLocationData:userLocation]; /** 设置当前位置*/
    [self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    /** 关闭定位服务*/
    [self.locationService stopUserLocationService];
    [self.locationService setDelegate:nil];
    
    /** 检索*/
    [self searchNearByWithLocation:userLocation.location.coordinate];
}

#pragma mark - bmk geo code search delegate

/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    /** 清空原先搜索数据*/
    [self.poiInfoList removeAllObjects];
    /** 判断是否查询到数据*/
    if (result == NULL || error != BMK_SEARCH_NO_ERROR)
    {
        [MBProgressHUD showLoadHUDText:@"没有检索到数据" during:0.25];
    }else
    {
        /** 添加当前位置数据*/
        XXGJLocationInfo *locationInfo = [XXGJLocationInfo locationInfoWithName:@"[位置]" address:result.address city:result.addressDetail.city location:result.location];
        [self.poiInfoList addObject:locationInfo];
        /** 将附近信息添加到数组中*/
        NSArray *poiArrayList = result.poiList;
        for (BMKPoiInfo *poiInfo in poiArrayList)
        {
            XXGJLocationInfo *locationInfo = [XXGJLocationInfo locationInfoWithName:poiInfo.name address:poiInfo.address city:poiInfo.city location:poiInfo.pt];
            [self.poiInfoList addObject:locationInfo];
        }
    }
    
    /** 更新数据*/
    [self.tableView reloadData];
}

#pragma mark - bmk map view delegate
/**
 *地图初始化完毕时会调用此接口
 *@param mapView 地图View
 */
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView
{
    [self.mapView bringSubviewToFront:self.correctUserLocationBtn];
}

/**
 *地图区域改变完成后会调用此接口
 *@param mapView 地图View
 *@param animated 是否动画
 */
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.needSearchPoiList)
        /** 判断是否需要重新搜索周边, 如果需要则继续执行*/
    {
        /** 检索当前附近*/
        [self searchNearByWithLocation:mapView.centerCoordinate];
    }else
        /** 如果不需要, 将标记重置*/
    {
        self.needSearchPoiList = YES;
    }
    
}

/**
 *点中底图空白处会回调此接口
 *@param mapView 地图View
 *@param coordinate 空白处坐标点的经纬度
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate
{
    /** 打点...*/
    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
    annotation.coordinate = coordinate;
    /** 移除以前的大头针*/
    [self.mapView removeAnnotations:self.mapView.annotations];
    /** 添加新的大头针*/
    [self.mapView addAnnotation:annotation];
    /** 聚焦点中位置*/
    [self.mapView setZoomLevel:19.0f];
    [self.mapView setCenterCoordinate:coordinate animated:YES];
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

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /** 修改选择位置*/
    self.needSearchPoiList = NO;
    self.selectIndex = indexPath.row;
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    /** 在对应位置标记大头针*/
    XXGJLocationInfo *locationInfo = self.poiInfoList[self.selectIndex];
    [self mapView:self.mapView onClickedMapBlank:locationInfo.location];
    /** 刷新视图*/
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

#pragma mark - table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.poiInfoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXGJLocationInfo *locationInfo = self.poiInfoList[indexPath.row];
    XXGJLocationInfoTableViewCell *locationInfoCell = [XXGJLocationInfoTableViewCell locationInfoCell:tableView];
    locationInfoCell.locationInfo = locationInfo;
    locationInfoCell.isSelected = self.selectIndex == indexPath.row;
    return locationInfoCell;
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
