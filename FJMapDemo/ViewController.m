//
//  ViewController.m
//  FJHistoryLine
//
//  Created by 熊伟 on 2018/1/20.
//  Copyright © 2018年 熊伟. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "FJMKAnnotation.h"

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) MKMapView *mapView;
/** 定位管理 **/
@property (nonatomic, strong) CLLocationManager *locationManager;
/** 点数组 */
@property (nonatomic, strong) NSMutableDictionary<NSNumber*, CLPlacemark*> *locationDic;
@property (nonatomic, strong) NSMutableArray<CLLocation*> *locationArray; //有序
@property (nonatomic, strong) NSMutableArray <CLPlacemark*> *placeMarkArray;//有序
/** 轨迹线 */
@property (nonatomic, strong) MKPolyline *polyLine;


/**
 火车头
 */
@property (nonatomic, strong) UIImageView *trainHead;

@property (nonatomic, strong) MKUserTrackingButton *trackingButton;

@property (nonatomic, strong) MKUserTrackingBarButtonItem *trackingBar;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.mapView];
    
    [self.view addSubview:self.trackingButton];
    [_trackingButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15].active = YES;
    [_trackingButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-15].active = YES;
    
    
    [self startLocationsWithDirectionRoute:NO];
}

- (void)dealloc {
    self.mapView.delegate = nil;
    self.mapView = nil;
}

#pragma mark - screen functions utils
-(void)startOnScreenAnimate {
    //将图标放置在起点
    CGPoint startPoint = [self.mapView convertCoordinate:_locationArray[0].coordinate toPointToView:self.view];
    self.trainHead.center = startPoint;
    [self.view addSubview:self.trainHead];
    
    //将图标移动到第二个点，然后定位目标位置，并将图标移动到屏幕中心
    CGPoint secondPoint = [self.mapView convertCoordinate:_locationArray[1].coordinate toPointToView:self.view];
    [UIView animateWithDuration:3 animations:^{
        self.trainHead.center = secondPoint;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:1 animations:^{
            self.trainHead.center = self.view.center;
        }];
        [self zoomInToRegin:_locationArray[1]];
    });
    
    // zoom out 到第二个点
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self zoomOutToRegin:_locationArray[1]];
    });
    
    
    
    //将图标移动到第三个点，然后定位目标位置，并将图标移动到屏幕中心
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        CGPoint thirdPoint = [self.mapView convertCoordinate:_locationArray[2].coordinate toPointToView:self.view];
        [UIView animateWithDuration:3 animations:^{
            self.trainHead.center = thirdPoint;
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:1 animations:^{
                self.trainHead.center = self.view.center;
            }];
            [self zoomInToRegin:_locationArray[2]];
        });
        

    });
}

#pragma mark - map function utils
-(void)startLocationsWithDirectionRoute:(BOOL)showDirectionRoute {
    
//start data
    NSArray * locationStr = @[@"团风镇",@"天津",@"苏州",@"上海",@"南京",@"杭州"];
//end
    
//start get location
    dispatch_group_t groupToken = dispatch_group_create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [locationStr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_async(groupToken, dispatch_get_global_queue(0, 0), ^{
            [self getAddressLocation:obj withBlock:^(CLPlacemark *placemark) {
                @synchronized(_locationDic){
                    [self.locationDic setObject:placemark forKey:[NSNumber numberWithUnsignedInteger:idx]];
                }
                dispatch_semaphore_signal(semaphore);
            }];
        });
    }];
//end
    
    dispatch_group_notify(groupToken, dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i<locationStr.count; i++) {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        
//start 对搜索结果进行排序
        NSArray * sortedArray = [self.locationDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            if (obj1 < obj2) {
                return NSOrderedAscending;
            }
            else if(obj1 == obj2){
                return NSOrderedSame;
            }
            else {
                return NSOrderedDescending;
            }
        }];
//end
        
//start 保存排序后的结果
        [sortedArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.locationArray addObject:[self.locationDic objectForKey:[NSNumber numberWithUnsignedInteger:idx]].location];
            [self.placeMarkArray addObject:[self.locationDic objectForKey:[NSNumber numberWithUnsignedInteger:idx]]];
        }];
//end

//start 添加大头针
        [self.placeMarkArray enumerateObjectsUsingBlock:^(CLPlacemark * _Nonnull placemark, NSUInteger idx, BOOL * _Nonnull stop) {
            FJMKAnnotation *annotation=[[FJMKAnnotation alloc]init];
            annotation.title = locationStr[idx];
            annotation.subtitle = locationStr[idx];
            annotation.coordinate = placemark.location.coordinate;
            annotation.streetAddress = placemark.thoroughfare ;
            annotation.city = placemark.locality;
            annotation.state = placemark.administrativeArea ;
            annotation.zip = placemark.postalCode;
            annotation.coordinate = placemark.location.coordinate;
            [_mapView addAnnotation:annotation];
        }];
//end
        
//start 绘制两点间的路线
        if (showDirectionRoute) {
            for (NSUInteger i = 0; i < self.placeMarkArray.count-1; i++) {
                [self drawDirectionRouteWithSourcePlaceMark:self.placeMarkArray[i] destinationPlaceMark:self.placeMarkArray[i+1]];
            }
        }
//end

//start 缩放地图以显示所有内容
        dispatch_async(dispatch_get_main_queue(), ^{
            [self zoomToMapPoints:self.mapView];
            [self startOnScreenAnimate];
        });
    });
//end
}




/**
 顺序移动屏幕区域

 @param locationArray 位置数组
 */
-(void)animateRegin:(NSArray<CLLocation*>*)locationArray withPauseTime:(int)sleepTime {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [locationArray enumerateObjectsUsingBlock:^(CLLocation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self zoomInToRegin:[self.locationDic objectForKey:[NSNumber numberWithUnsignedInteger:idx]].location];
            });
            sleep(sleepTime);
        }];
    });
}


/**
 绘制两点之间的可行路径，根据地图API返回

 @param sourcePlaceMark 出发地
 @param destinationPlaceMark 目的地
 */
-(void)drawDirectionRouteWithSourcePlaceMark:(CLPlacemark*)sourcePlaceMark
                        destinationPlaceMark:(CLPlacemark*)destinationPlaceMark {
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    request.source = [[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc]initWithPlacemark:sourcePlaceMark]];
    request.destination = [[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc]initWithPlacemark:destinationPlaceMark]];
    request.requestsAlternateRoutes = YES;
    [request setTransportType:(MKDirectionsTransportTypeWalking)];
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler: ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             // Handle Error
         } else {
             /**
              MKDirectionsResponse对象解析
              source ：开始位置
              destination ：结束位置
              routes ： 路线信息 （MKRoute对象）
              
              MKRoute对象解析
              name ： 路的名称
              advisoryNotices ： 注意警告信息
              distance ： 路线长度（实际物理距离，单位是m）
              polyline ： 路线对应的在地图上的几何线路（由很多点组成，可绘制在地图上）
              steps ： 多个行走步骤组成的数组（例如“前方路口左转”，“保持直行”等等， MKRouteStep 对象）
              
              MKRouteStep对象解析
              instructions ： 步骤说明（例如“前方路口左转”，“保持直行”等等）
              transportType ： 通过方式（驾车，步行等）
              polyline ： 路线对应的在地图上的几何线路（由很多点组成，可绘制在地图上）
              
              注意：
              MKRoute是一整条长路；MKRouteStep是这条长路中的每一截；
              
              */

//打印导航
//             [response.routes enumerateObjectsUsingBlock:^(MKRoute * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                 NSLog(@"%@--", obj.name);
//                 [obj.steps enumerateObjectsUsingBlock:^(MKRouteStep * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                     NSLog(@"%@", obj.instructions);
//                 }];
//             }];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 for (MKRoute *route in response.routes) {
                     [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
                     break;//只画一条~ =。=
                 }
             });
         }
     }];
}

/**
 打印位置信息

 @param location CLLocationCoordinate2D
 */
-(void)printLocation:(CLLocationCoordinate2D)location{
    NSLog(@"%f---%f", location.latitude,location.longitude);
}


/**
 在地图上按顺序画出两点间的直线轨迹
 */
- (void)drawWalkPolyline {
    //轨迹点
    NSUInteger count = self.locationArray.count;
    // 手动分配存储空间，结构体：地理坐标点，用直角地理坐标表示 X：横坐标 Y：纵坐标
    MKMapPoint *tempPoints =  malloc(sizeof(MKMapPoint)*count);
    
    [self.locationArray enumerateObjectsUsingBlock:^(CLLocation *location, NSUInteger idx, BOOL *stop) {
        MKMapPoint locationPoint = MKMapPointForCoordinate(location.coordinate);
        tempPoints[idx] = locationPoint;
        
    }];
    //移除原有的绘图
    if (self.polyLine) {
        [_mapView removeOverlay:self.polyLine];
    }
    // 通过points构建MKPolyline
    self.polyLine = [MKPolyline polylineWithPoints:tempPoints count:count];
    
    //添加路线,绘图
    if (self.polyLine) {
        [_mapView addOverlay:self.polyLine];
    }
    // 清空 tempPoints 内存
    free(tempPoints);
}

/**
 缩放地图，以显示所有线路
 */
- (void)zoomToMapPoints:(MKMapView*)mapView {
    if(self.locationArray.count)
    {//保证self.loc.locArray不为空，才执行
        CLLocation *firstLoc = self.locationArray[0];
        CLLocationCoordinate2D location = firstLoc.coordinate;
        
        //放大地图到自身的经纬度位置。
        MKCoordinateSpan span ;
        //        span.latitudeDelta = 0.009 ;
        //        span.longitudeDelta = 0.009 ;
        //根据跑步数据结果来微调地图区域设定
        double min_Long = 180;
        double max_Long = -180;
        double min_Lat = 90;
        double max_Lat = -90;
        double temp_val = 0;
        double deltaLong = 0;
        double deltaLat = 0;
        
        for (int j = 0; j<self.locationArray.count; j++)
        {
            CLLocation *loc = self.locationArray[j];
            CLLocationCoordinate2D  tempLoca = loc.coordinate;
            temp_val = tempLoca.longitude;
            if(temp_val < min_Long) min_Long = temp_val;
            if(temp_val > max_Long) max_Long = temp_val;
            
            temp_val = tempLoca.latitude;
            if(temp_val > max_Lat) max_Lat = temp_val;
            if(temp_val < min_Lat) min_Lat = temp_val;
        }
        deltaLong = max_Long - min_Long;
        deltaLat = max_Lat - min_Lat;
        if( deltaLong > deltaLat)
        {
            span.latitudeDelta = deltaLong /0.5;
            span.longitudeDelta = deltaLong /0.5;
        }
        else
        {
            span.latitudeDelta = deltaLat /0.5;
            span.longitudeDelta = deltaLat /0.5;
        }
        location.latitude = (3*max_Lat + 7*min_Lat)/10;
        location.longitude = (max_Long + min_Long)/2;
        MKCoordinateRegion region={location,span};
        [_mapView setRegion:region animated:YES];
    }
}


/**
 根据地址得到位置信息，异步返回

 @param addressStr 地址
 @param callBackBlock 回调
 */
-(void)getAddressLocation:(NSString*)addressStr
                withBlock:(void(^)(CLPlacemark *placemark))callBackBlock{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:addressStr completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        callBackBlock(placemark);
    }];
}

//经纬度转地址信息
- (void)geocodeLocation:(CLLocation*)location {
    
    CLGeocoder * geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location
                   completionHandler: ^(NSArray* placemarks, NSError* error) {
         if ([placemarks count] > 0) {
             // TODO:地址信息
             
         }
     }];
}


/**
 根据地址得到位置信息，并定位到区域

 @param addressStr 地址
 */
-(void)searchAddress:(NSString*)addressStr {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:addressStr completionHandler:^(NSArray *placemarks, NSError *error) {
        //Error checking
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        MKCoordinateSpan span = MKCoordinateSpanMake(0.077919, 0.044529);
        MKCoordinateRegion region= MKCoordinateRegionMake(placemark.location.coordinate, span);
        
        [self.mapView setRegion:region animated:YES];
    }];
}


/**
 根据位置信息定位到区域

 @param location 中心位置
 @param span 经纬度区间
 */
-(void)zoomToRegin:(CLLocation*)location withMKCoordinateSpan:(MKCoordinateSpan)span {
    CLLocationCoordinate2D center = location.coordinate;
    // 创建一个区域
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    // 设置地图显示区域
    [self.mapView setRegion:region animated:YES];
}

/**
 根据位置信息定位到区域

 @param location 位置信息CLLocation
 */
-(void)zoomInToRegin:(CLLocation*)location {
    [self zoomToRegin:location withMKCoordinateSpan:MKCoordinateSpanMake(0.077919, 0.044529)];
}

/**
 根据位置信息定位到区域
 
 @param location 位置信息CLLocation
 */
-(void)zoomOutToRegin:(CLLocation*)location {
    [self zoomToRegin:location withMKCoordinateSpan:MKCoordinateSpanMake(20, 16)];
}

//注册区间定位
- (void)registerRegionWithCircularOverlay:(MKCircle*)overlay andIdentifier:(NSString*)identifier {
    
    // If the overlay's radius is too large, registration fails automatically,
    // so clamp the radius to the max value.
    CLLocationDistance radius = overlay.radius;
    if (radius > self.locationManager.maximumRegionMonitoringDistance) {
        radius = self.locationManager.maximumRegionMonitoringDistance;
    }
    
    // Create the geographic region to be monitored.
    CLCircularRegion *geoRegion = [[CLCircularRegion alloc]
                                   initWithCenter:overlay.coordinate
                                   radius:radius
                                   identifier:identifier];
    [self.locationManager startMonitoringForRegion:geoRegion];
}

//方向感知
- (void)startHeadingEvents {
    
    // Start location services to get the true heading.
    self.locationManager.distanceFilter = 1000;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [self.locationManager startUpdatingLocation];
    
    // Start heading updates.
    if ([CLLocationManager headingAvailable]) {
        self.locationManager.headingFilter = 5;
        [self.locationManager startUpdatingHeading];
    }
}

//在地图上搜索
-(void)searchInfoOf:(NSString*)content {
    // Create and initialize a search request object.
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = content;
    request.region = self.mapView.region;
    
    // Create and initialize a search object.
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    
    // Start the search and display the results as annotations on the map.
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSMutableArray *placemarks = [NSMutableArray array];
        for (MKMapItem *item in response.mapItems) {
            [placemarks addObject:item.placemark];
        }
        [self.mapView removeAnnotations:[self.mapView annotations]];
        [self.mapView showAnnotations:placemarks animated:NO];
    }];
}

#pragma mark - setter and getter

/**
 3D Map

 @param ground a coordinate structure for the location.
 @param eye a coordinate structure for the point on the ground from which to view the location.
 */
- (void)set3DMapWithGround:(CLLocationCoordinate2D)ground eye:(CLLocationCoordinate2D)eye {
    // Ask Map Kit for a camera that looks at the location from an altitude of 100 meters above the eye coordinates.
    MKMapCamera *myCamera = [MKMapCamera cameraLookingAtCenterCoordinate:ground fromEyeCoordinate:eye eyeAltitude:100];
    
    // Assign the camera to your map view.
    self.mapView.camera = myCamera;
}

-(void)setTrackingBar {
    self.trackingBar = [[MKUserTrackingBarButtonItem alloc]initWithMapView:self.mapView];
    self.navigationItem.leftBarButtonItem = self.trackingBar;
}

-(MKUserTrackingButton *)trackingButton {
    if (!_trackingButton) {
        _trackingButton = [MKUserTrackingButton userTrackingButtonWithMapView:self.mapView];
        _trackingButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _trackingButton;
}

-(UIImageView *)trainHead {
    if (!_trainHead) {
        _trainHead = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"fj_train"]];
    }
    return _trainHead;
}


-(MKMapView *)mapView {
    if (_mapView) {
        return _mapView;
    }
    MKMapView *mapView = [[MKMapView alloc]initWithFrame:self.view.bounds];
    
    MKCoordinateSpan span;
    span.latitudeDelta = 0.077919;
    span.longitudeDelta = 0.044529;
    
    MKCoordinateRegion region ;
    
    region.center = self.locationManager.location.coordinate;
    region.span = span;
    
    //设置显示区域
    [mapView setRegion:region];
    
    //跟踪
    mapView.userTrackingMode = MKUserTrackingModeFollow;
    //显示定位
    mapView.showsUserLocation = YES;
    mapView.showsCompass = YES;
    mapView.showsScale = YES;
    mapView.delegate = self;
    
    _mapView = mapView;
    return _mapView;
}

-(CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.distanceFilter = 5;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
        _locationManager.pausesLocationUpdatesAutomatically = YES;//节省电量，在一切场景下CLLocationManager会停用定位服务
        [_locationManager setActivityType:CLActivityTypeFitness];//指定定位使用场景，这样CLLocationManager会更好的判断何时暂停定位
        
        
#warning crash
//        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
//            _locationManager.allowsBackgroundLocationUpdates = YES;
//
//        }
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [_locationManager requestAlwaysAuthorization];
            }
        }
    }
    return _locationManager;
}

- (NSMutableArray *)locationArray {
    if (!_locationArray) {
        _locationArray = [NSMutableArray array];
    }
    return _locationArray;
}

-(NSMutableDictionary<NSNumber *, CLPlacemark *> *)locationDic {
    if (!_locationDic) {
        _locationDic = [NSMutableDictionary new];
    }
    return _locationDic;
}

-(NSMutableArray<CLPlacemark *> *)placeMarkArray {
    if (!_placeMarkArray) {
        _placeMarkArray = [NSMutableArray new];
    }
    return _placeMarkArray;
}

#pragma mark - button action
-(void)annotationViewRightButtonClicked:(id)sender {
    
}

#pragma mark - MKMapViewDelegate
/**
 *  当地图获取到用户位置时调用
 *
 *  @param mapView      地图
 *  @param userLocation 大头针数据模型
 */
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    /**
     *  MKUserLocation : 专业术语: 大头针模型 其实喊什么都行, 只不过这个类遵循了大头针数据模型必须遵循的一个协议 MKAnnotation
     // title : 标注的标题
     // subtitle : 标注的子标题
     */
    userLocation.title = @"熊大";
    userLocation.subtitle = @"坐在角落看世界";
    
    // 移动地图的中心,显示用户的当前位置
    //    [mapView setCenterCoordinate:userLocation.location.coordinate an、、imated:YES];
    // 控制区域中心
    CLLocationCoordinate2D center = userLocation.location.coordinate;
    // 设置区域跨度
    MKCoordinateSpan span = MKCoordinateSpanMake(0.077919, 0.044529);
    // 创建一个区域
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    // 设置地图显示区域
    [mapView setRegion:region animated:YES];
}


/**
 *  地图区域将要改变时调用
 *
 *  @param mapView  地图
 *  @param animated 动画
 */
-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    //当zoom变化时，我们需要将annotation进行合并
}

/**
 *  地图区域已经改变时调用 --- 先缩放 获取经纬度跨度，根据经纬度跨度显示区域
 *
 *  @param mapView  地图
 *  @param animated 动画
 */
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {

}

//添加overlay后，使用此回调添加 view
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor = [UIColor blueColor];
        renderer.lineWidth = 5.0;
        return renderer;
    }
    return nil;
}

//map 根据添加的annotation obj 创建 annotation view
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    //由于当前位置的标注也是一个大头针，所以此时需要判断，此代理方法返回nil使用默认大头针视图
    if ([annotation isKindOfClass:[FJMKAnnotation class]]) {
        static NSString  * key1 = @"Annotation";
        MKAnnotationView * annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:key1];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:key1];
            
            annotationView.draggable = YES;
            
            annotationView.canShowCallout = YES;              //允许交互点击
            annotationView.calloutOffset = CGPointMake(0, 0);  //定义详情视图偏移量
            annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fj_train"]];
            
            // Because this is an iOS app, add the detail disclosure button to display details about the annotation in another view.
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            annotationView.rightCalloutAccessoryView = rightButton;
            
        }
        annotationView.annotation = annotation;
        annotationView.image = [UIImage imageNamed:@"fj_location"];    //设置大头针视图的图片
        return annotationView;
    }else{
        return nil;
    }
}

//拖拽annotation
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    
}

//点击call out 右边的button时的回调
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
}

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    
}

-(void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered{
    
}


#pragma mark - CLLocationManagerDelegate
//定位成功后的回调
// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
    }
}

//定位失败后的回调
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}

//当location manager暂停定位时调用
-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    
}

//当location manager重新开启定位时调用
-(void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    
}

//进入监控区间
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    
}

//离开监控区间
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    
}

//无法添加监控区间
-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    
}

//方向感觉回调
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (newHeading.headingAccuracy < 0)
        return;
    
    // Use the true heading if it is valid.
    CLLocationDirection  theHeading = ((newHeading.trueHeading > 0) ?
                                       newHeading.trueHeading : newHeading.magneticHeading);
    
}


@end
