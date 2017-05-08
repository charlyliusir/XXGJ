//
//  XXGJUpdateAddressViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/28.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJUpdateAddressViewController.h"
#import "NSString+XXGJFileStore.h"

@interface XXGJUpdateAddressViewController () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (nonatomic, copy)UpdateAddressConfirmBlock confirmBlock; // 确定按钮被点击后执行回调
@property (nonatomic, copy)NSDictionary *provinceDictionary; // 行省列表
@property (nonatomic, copy)NSDictionary *cityDictionary;     // 城市列表
@property (nonatomic, copy)NSArray *provinceKeyArray; // 行省编号列表
@property (nonatomic, copy)NSArray *currCityArray;  // 城市编号列表
@property (nonatomic, copy)NSString *currProvince; // 当前选择的行省
@property (nonatomic, copy)NSString *currCity; // 当前选择的城市

@end

@implementation XXGJUpdateAddressViewController

+ (instancetype)updateAddressViewController
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}

/**
 *  设置位置宽高
 */
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
//    self.view.frame = CGRectMake(self.view.frame.origin.x, DeviceHeight / 2, DeviceWidth, DeviceHeight / 2);
    //self.view.backgroundColor = [UIColor clearColor];
    //self.view.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.868f];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* 功能描述:
     * 这个控制器实现了一个城市二级选择器，用以修改用户的地址信息
     * 1. 获取本地存放的城市json文件，将json文件解析成一个字典
     * 2. 根据字典显示城市二级选择器
     * 3. 滚动二级选择器，点击确定-> 通过block回调更新用户信息
     */
    NSDictionary *cityJsonDict = [NSString getCityDictonary];
    // 行省信息
    self.provinceDictionary    = cityJsonDict[@"provinces"];
    // 城市信息
    self.cityDictionary        = cityJsonDict[@"cities"];
    // 排序
    self.provinceKeyArray = [self.provinceDictionary.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *keyObj1 = obj1;
        NSString *keyObj2 = obj2;
        return [keyObj1 compare:keyObj2];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy method
- (NSDictionary *)provinceDictionary
{
    if (!_provinceDictionary)
    {
        _provinceDictionary = [NSDictionary dictionary];
    }
    return _provinceDictionary;
}
- (NSDictionary *)cityDictionary
{
    if (!_cityDictionary)
    {
        _cityDictionary = [NSDictionary dictionary];
    }
    return _cityDictionary;
}
- (NSArray *)provinceKeyArray
{
    if (!_provinceKeyArray)
    {
        _provinceKeyArray = [NSArray array];
    }
    return _provinceKeyArray;
}

- (NSArray *)currCityArray
{
    if (!_currCityArray)
    {
        _currCityArray = [NSArray array];
    }
    return _currCityArray;
}

#pragma mark - open method
- (void)setUserCityInfo:(NSString *)cityInfo
{
    // 这里用来处理行省和城市名称的保存
    self.currCity     = cityInfo;
    self.currProvince = [cityInfo stringByReplacingCharactersInRange:NSMakeRange(2, cityInfo.length-2) withString:@"0000"];
    
    // 更新到用户的信息
    self.currCityArray    = [self.cityDictionary objectForKey:self.currProvince];
    
    NSUInteger provinceRow     = [self.provinceKeyArray indexOfObject:self.currProvince];
    __block NSUInteger cityRow = 0;
    
    [self.currCityArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *cityInfoArray = (NSArray *)obj;
        if ([cityInfoArray.firstObject isEqualToString:self.currCity])
        {
            cityRow = idx;
            return ;
        }
    }];
    
    [self.pickerView reloadAllComponents];
    [self.pickerView selectRow:provinceRow inComponent:0 animated:YES];
    [self.pickerView selectRow:cityRow inComponent:1 animated:YES];
}

- (void)setConfirmBlock:(UpdateAddressConfirmBlock)confirmBlock
{
    _confirmBlock = confirmBlock;
}

#pragma mark - private method
- (IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)confirmAction:(id)sender
{
    self.confirmBlock(self.currCity);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - delegate
#pragma mark - picker delegate
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
//{
//    
//}

/**
 pickerView 选中行列方法
 
 @param pickerView pickerView
 @param row 行
 @param component 列
 */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0)
    {
        /*
         * 首先, 获取选择行对应的行省编号
         * 然后, 判断当前行省编号是否与之一致
         * 如不一致, 则更新对应的城市编号, 并自动滚动到第一个城市位置
         */
        NSString *provinceKey = self.provinceKeyArray[row];
        if (![provinceKey isEqualToString:self.currProvince])
        {
            self.currCityArray = self.cityDictionary[provinceKey];
            [pickerView reloadComponent:1];
            [pickerView selectRow:0 inComponent:1 animated:YES];
            self.currCity      = [[self.currCityArray firstObject] firstObject];
            self.currProvince  = provinceKey;
        }
    }
    else if (component == 1)
    {
        self.currCity = [self.currCityArray[row] firstObject];
    }
    
}

/**
 pickerView 的行高度

 @param pickerView pickerView
 @param component 行
 @return 高度
 */
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 35;
}

/**
 pickerView 行内容

 @param pickerView pickerView
 @param row 行
 @param component 列
 @return 内容
 */
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0)
    {
        NSString *provinceKey = self.provinceKeyArray[row];
        return self.provinceDictionary[provinceKey];
    }
    else if (component == 1)
    {
        NSArray *cityInfoArray = self.currCityArray[row];
        return cityInfoArray.lastObject;
    }
    return nil;
}

#pragma mark - picker datasource
/**
 pickerView 一共多上列

 @param pickerView pickerView
 @return 列数
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

/**
 pickerView 每一列一共多少行

 @param pickerView pickerView
 @param component 列
 @return 行数
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component==0)
    {
        return self.provinceKeyArray.count;
    }
    else if (component == 1)
    {
        return self.currCityArray.count;
    }
    
    return 0;
}

@end
