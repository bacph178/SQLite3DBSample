//
//  ViewController.m
//  SQLite3DBSample
//
//  Created by Gabriel Theodoropoulos on 25/6/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "ViewController.h"
#import "DBManager.h"


@interface ViewController ()

@property (nonatomic, strong) DBManager *dbManager;

@property (nonatomic, strong) NSArray *arrPeopleInfo;

@property (nonatomic) int recordIDToEdit;


-(void)loadData;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tblPeople.delegate = self;
    _tblPeople.dataSource = self;
    _dbManager = [[DBManager alloc] initWithDatabaseFilename:@"sampledb.sql"];
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    EditInfoViewController *editInfoViewController = [segue destinationViewController];
    editInfoViewController.delegate = self;
    editInfoViewController.recordIDToEdit = self.recordIDToEdit;
}


#pragma mark - IBAction method implementation

- (IBAction)addNewRecord:(id)sender {
    _recordIDToEdit = -1;
    [self performSegueWithIdentifier:@"idSegueEditInfo" sender:self];
}


#pragma mark - Private method implementation

-(void)loadData{
    // Form the query.
    NSString *query = @"select * from peopleInfo";
    
    // Get the results.
    if (_arrPeopleInfo != nil) {
        _arrPeopleInfo = nil;
    }
    _arrPeopleInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    [self.tblPeople reloadData];
}


#pragma mark - UITableView method implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrPeopleInfo.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellRecord" forIndexPath:indexPath];
    NSInteger indexOfFirstname = [_dbManager.arrColumnNames indexOfObject:@"firstname"];
    NSInteger indexOfLastname = [_dbManager.arrColumnNames indexOfObject:@"lastname"];
    NSInteger indexOfAge = [_dbManager.arrColumnNames indexOfObject:@"age"];
    
    // Set the loaded data to the appropriate cell labels.
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",
                           [[_arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfFirstname],
                           [[_arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfLastname]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Age: %@",
                                 [[_arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfAge]];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}


-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    _recordIDToEdit = [[[_arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
    [self performSegueWithIdentifier:@"idSegueEditInfo" sender:self];
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        int recordIDToDelete = [[[_arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
        NSString *query = [NSString stringWithFormat:@"delete from peopleInfo where peopleInfoID=%d", recordIDToDelete];
        [_dbManager executeQuery:query];
        [self loadData];
    }
}


#pragma mark - EditInfoViewControllerDelegate method implementation

-(void)editingInfoWasFinished{
    [self loadData];
}


@end
