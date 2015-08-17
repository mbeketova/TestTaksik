//
//  ViewController.m
//  TestTaksik
//
//  Created by Admin on 17.08.15.
//  Copyright (c) 2015 Mariya Beketova. All rights reserved.
//

#import "ViewController.h"
#import "CustomTableViewCell.h"
#import "CitiesRKObjectManager.h"
#import "Cities.h"


/* Тестовое задание от Таксика:
 //---------------------------------
 Условие:
 данный URL возвращает JSON в след. виде
 {
 "cities": [
 {
 "city_id": 1,
 "city_name": "Москва",
 "city_api_url": "http://beta.taxistock.ru/taxik/api/client/",
 "city_domain": "beta.taxistock.ru",
 "city_mobile_server": "protobuf.taxistock.ru:7777",
 "city_doc_url": "http://beta.taxistock.ru/taxik/api/doc/",
 "city_latitude": 55.755773,
 "city_longitude": 37.617761,
 "city_spn_latitude": 0.964953,
 "city_spn_longitude": 2.757568,
 "last_app_android_version": 7045,
 "android_driver_apk_link": "http://www.taxik.ru/a/taxik.apk",
 "inapp_pay_methods": [
 "chronopay"
 ],
 "transfers": true,
 "experimental_econom_plus": 5,
 "experimental_econom_plus_time": 40,
 "registration_promocode": true
 }, …………]
 }
 Нужно создать приложение, которое показывает список городов в табличном виде и
 при выборе города из списка, показать его координаты на карте.
//------------------------------------
 
 Реализация: 
 Задание выполнено с использованием библиотеки RestKit.
 Данные, полученные с сервера записываются/обновляются через CoreData
 Кроме того, в таблицу добавлено небольшое дополнение - это расстояние от локации пользователя до выбранной локации.
 При выборе города из списка - город центрируется на карте, и ставится маркер с координатами.
 На задание ушло примерно 12 часов.
 */


@interface ViewController () <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic,strong) NSMutableArray * arrayLatitude;
@property (nonatomic,strong) NSMutableArray * arrayLongitude;
@property (nonatomic, strong) NSMutableArray *arrayName;

@end

@implementation ViewController{
    NSInteger numberOfCities;
    BOOL noRequestsMade;
     BOOL isCurrentLocation;
}

- (void) firstStart {
    //метод, который срабатывает один раз при первом запуске, если версия IOS = 8, или выше.
    NSString * ver = [[UIDevice currentDevice]systemVersion];
    
    if ([ver intValue] >=8) {
        [self.locationManager requestAlwaysAuthorization];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstStart"];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrayLatitude = [[NSMutableArray alloc]init];
    self.arrayLongitude = [[NSMutableArray alloc]init];
    self.arrayName = [[NSMutableArray alloc]init];
    
    self.mapView.showsUserLocation = YES;
    self.locationManager = [[CLLocationManager alloc]init];
    [self.locationManager setDelegate:self];
    [self.locationManager startUpdatingLocation];
    
    //срабатывает только при первом запуске:
    BOOL isFirstStart = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstStart"];
    
    if (!isFirstStart) {
        [self firstStart];
    }
    
    
    isCurrentLocation = NO;

    [self refreshView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - RefreshControl

- (void) refreshView {
    //RefreshControl:
    UIView * refreshView = [[UIView alloc]initWithFrame:CGRectMake(0, 55, 0, 0)];
    [self.tableView addSubview:refreshView];
    UIRefreshControl * refreshControl = [[UIRefreshControl alloc]init];
    refreshControl.tintColor = [UIColor redColor];
    [refreshControl addTarget:self action:@selector(refreshingPlayList:) forControlEvents:UIControlEventValueChanged];
    NSMutableAttributedString * refreshString = [[NSMutableAttributedString alloc]initWithString:@"Ожидание..."];
    [refreshString addAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]} range:NSMakeRange(0, refreshString.length)];
    refreshControl.attributedTitle = refreshString;
    [refreshView addSubview:refreshControl];
}

- (void) refreshingPlayList: (UIRefreshControl*)refresh {
    [self linkingCitiesWhithObjectStore];
    [refresh endRefreshing];
    [self removeAllAnnotations];
}

#pragma mark - ReloadTableView

- (void) reload_TableView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        
    });
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return numberOfCities;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CustomTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    for (int i = 0; i < numberOfCities; i++) {
        Cities *curCities = [Cities classWithManagedObjectContext:[[CitiesRKObjectManager manager] managedObjectContext] andInnerID:i];
        [self.arrayName addObject:curCities.city_name];
        [self.arrayLatitude addObject:curCities.city_latitude];
        [self.arrayLongitude addObject:curCities.city_longitude];
    }
    
    
    NSInteger row = indexPath.row;
    
    if (numberOfCities > row) {
        
        cell.label_City.text = [self.arrayName objectAtIndex:row];
        
        //высчитываем координаты между пользователем и объектом и выводим их в label_Distance:

        CLLocation * newLocation = [[CLLocation alloc]initWithLatitude:[[self.arrayLatitude objectAtIndex:row] doubleValue]
                                                             longitude:[[self.arrayLongitude objectAtIndex:row] doubleValue]];
        CLLocation * locationManager = self.locationManager.location;
        float betweenDistance=[newLocation distanceFromLocation:locationManager]/1000;
        NSString * stringBetweenDistance = [NSString stringWithFormat:@"%f", betweenDistance];
        NSString * newStringDistance = [stringBetweenDistance substringToIndex:5];
        cell.label_Distance.text = [NSString stringWithFormat:@"%@ км", newStringDistance];

    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CLLocation * newLocation = [[CLLocation alloc]initWithLatitude:[[self.arrayLatitude objectAtIndex:indexPath.row] doubleValue]
                                                         longitude:[[self.arrayLongitude objectAtIndex:indexPath.row] doubleValue]];
    [self setupMapView:newLocation.coordinate];
    
    //по полученным координатам устанавливаем центр карты:
    CLGeocoder * geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        MKPointAnnotation * annotation = [[MKPointAnnotation alloc]init];
        annotation.coordinate = newLocation.coordinate;
        annotation.title = [[NSString alloc] initWithFormat: @"%@\n%@",
                            [self.arrayLatitude objectAtIndex:indexPath.row],
                            [self.arrayLongitude objectAtIndex:indexPath.row]];
        [self.mapView addAnnotation:annotation];
    }];
    
}

#pragma mark - RestKit

- (void)linkingCitiesWhithObjectStore {
    //Привязка Core Data к RKManagedObjectStore
    //идентифицируем по атрибуту: CITY_ID
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TestTaksik" withExtension:@"momd"];
    [[CitiesRKObjectManager manager] configureWithManagedObjectModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL]];
    // Затем добавим маппинг для нашего объекта:
    [[CitiesRKObjectManager manager] addMappingForEntityForName:@"Cities"
                           andAttributeMappingsFromDictionary:@{
                                                                CITY_ID:CITY_ID,
                                                                CITY_NAME:CITY_NAME,
                                                                CITY_LATITUDE:CITY_LATITUDE,
                                                                CITY_LONGITUDE:CITY_LONGITUDE
                                                                }
                                  andIdentificationAttributes:@[CITY_ID]];
   
    [self loadCities];
    
  
}


- (void)loadCities {
    //В данном методе сначала получаем кол-во городов,
    //а затем производим запрос на получение массива городов с сервера, используя RKObjectManager
    
    numberOfCities = [Cities allClassCountWithContext:[[CitiesRKObjectManager manager] managedObjectContext]];
    
    if (numberOfCities == 0)
        NSLog(@"Ничего нет!");
    else if (noRequestsMade && numberOfCities > 0) {
        noRequestsMade = NO;
        return;
    }
    
    noRequestsMade = NO;
    
    [[CitiesRKObjectManager manager] getUrlObjectsAtPath:nil
                                                  parameters:@{INNER_ID : @(numberOfCities)}
                                                     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                         
                                                         
                                                         NSInteger newInnerID = 0;
                                                         for (Cities *curCities in mappingResult.array) {
                                                             if ([curCities isKindOfClass:[Cities class]]) {
                                                                 curCities.innerID = @(newInnerID);
                                                                 newInnerID++;
                                                                 [self saveToStore];
                                                             }
                                                         }
                                                         
                                                         numberOfCities = newInnerID;
                                                         
                                                         [self reload_TableView];
                                                         
                                                     }
                                                     failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                         [[[UIAlertView alloc] initWithTitle:@"Cities API Error" message:operation.error.localizedDescription delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil] show];
                                                     }];
    
    
}

- (void)saveToStore {
    NSError *saveError;
    if (![[[CitiesRKObjectManager manager] managedObjectContext] saveToPersistentStore:&saveError])
        NSLog(@"%@", [saveError localizedDescription]);
}

#pragma mark - MKMapViewDelegate


- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView{
    //отправим запрос на сервер, пока загружается карта
    [self linkingCitiesWhithObjectStore];
    
}



- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    //метод, который работает после того, как полностью загружена карта
    
    if (fullyRendered) {
        [self.locationManager startUpdatingLocation];
    }
    
}

- (void) setupMapView: (CLLocationCoordinate2D) coord {
    
    //увеличение карты с анимацией
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 10000, 10000);
    [self.mapView setRegion:region animated:YES];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    //метод будет срабатывать, когда позиция пользователя изменилась
    
    if (!isCurrentLocation) {
        isCurrentLocation = YES;
        [self setupMapView:newLocation.coordinate];
    }
    
}

#pragma mark - MKAnnotation

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    //устанавливаем маркер (из определенной картинки) на карту
    if (![annotation isKindOfClass:MKUserLocation.class]) {
        
        MKAnnotationView*annView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Annotation"];
        annView.canShowCallout = NO;
        annView.image = [UIImage imageNamed:@"icon.png"];
        [annView addSubview:[self getCalloutView:annotation.title]]; //вызываем метод, который подписывает адрес над маркером
        return annView;
        
    }
    
    
    return nil;
}

//метод, который убирает аннотации с карты:
- (void) removeAllAnnotations {
    id userAnnotation = self.mapView.userLocation;
    NSMutableArray*annotations = [NSMutableArray arrayWithArray:self.mapView.annotations];
    [annotations removeObject:userAnnotation];
    [self.mapView removeAnnotations:annotations];
    
}

- (UIView*) getCalloutView: (NSString*) title {
    // метод, который подписывает данные над маркером
    
    //создаем вью для вывода адреса:
    UIView * callView = [[UIView alloc]initWithFrame:CGRectMake(-12, -35, 80, 30)];
    callView.backgroundColor = [UIColor yellowColor];
    callView.layer.borderWidth = 1.0;
    callView.layer.cornerRadius = 7.0;
    
    //создаем лейбл для координат:
    UILabel * labelCoordinate = [[UILabel alloc] initWithFrame:CGRectMake(1, 1, 80, 30)];
    labelCoordinate.numberOfLines = 0;
    labelCoordinate.lineBreakMode = NSLineBreakByWordWrapping; // перенос по словам
    labelCoordinate.textAlignment = NSTextAlignmentCenter; //выравнивание по центру
    labelCoordinate.textColor = [UIColor blackColor];
    labelCoordinate.text = title;
    labelCoordinate.font = [UIFont fontWithName: @"Arial" size: 10.0];
    
    [callView addSubview:labelCoordinate];
    

    
    
    return callView;
    
    
}


@end
