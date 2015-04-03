//
//  EditInfoViewController.m
//  SQLite3DBSample
//
//  Created by Gabriel Theodoropoulos on 25/6/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "EditInfoViewController.h"
#import "DBManager.h"


@interface EditInfoViewController ()

@property (nonatomic, strong) DBManager *dbManager;

-(void)loadInfoToEdit;

@end


@implementation EditInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _txtFirstname.delegate = self;
    _txtLastname.delegate = self;
    _txtAge.delegate = self;
    self.navigationController.navigationBar.tintColor = self.navigationItem.rightBarButtonItem.tintColor;
    _dbManager = [[DBManager alloc] initWithDatabaseFilename:@"sampledb.sql"];
    if (_recordIDToEdit != -1) {
        [self loadInfoToEdit];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - UITextFieldDelegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - IBAction method implementation

- (IBAction)saveInfo:(id)sender {
    // Prepare the query string.
    // If the recordIDToEdit property has value other than -1, then create an update query. Otherwise create an insert query.
    NSString *query;
    if (self.recordIDToEdit == -1) {
        query = [NSString stringWithFormat:@"insert into peopleInfo values(null, '%@', '%@', %d)",
                 _txtFirstname.text, _txtLastname.text, [_txtAge.text intValue]];
    }
    else{
        query = [NSString stringWithFormat:@"update peopleInfo set firstname='%@', lastname='%@', age=%d where peopleInfoID=%d",
                 _txtFirstname.text, _txtLastname.text, _txtAge.text.intValue, _recordIDToEdit];
    }
    [self.dbManager executeQuery:query];
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", _dbManager.affectedRows);
        [self.delegate editingInfoWasFinished];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        NSLog(@"Could not execute the query.");
    }
}


#pragma mark - Private method implementation

-(void)loadInfoToEdit{
    NSString *query = [NSString stringWithFormat:@"select * from peopleInfo where peopleInfoID=%d", _recordIDToEdit];
    NSArray *results = [[NSArray alloc] initWithArray:[_dbManager loadDataFromDB:query]];
    _txtFirstname.text = [[results objectAtIndex:0] objectAtIndex:[_dbManager.arrColumnNames indexOfObject:@"firstname"]];
    _txtLastname.text = [[results objectAtIndex:0] objectAtIndex:[_dbManager.arrColumnNames indexOfObject:@"lastname"]];
    _txtAge.text = [[results objectAtIndex:0] objectAtIndex:[_dbManager.arrColumnNames indexOfObject:@"age"]];
}

@end
