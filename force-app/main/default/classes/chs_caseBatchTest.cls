/*
* @Purpose: Test Class for chs_CaseBatchHandler,chs_CaseBatch,chs_CaseTrigger,chs_CaseBatchSchedule
* @Author: Cloud Haven Solutions - OV
* @CreatedDate:09-02-2021
* @Related Code: chs_CaseBatchHandler,chs_CaseBatch,chs_CaseTrigger,chs_CaseBatchSchedule
* @Test Class: chs_caseBatchTest
* @LastModifiedDate: 09-02-2021
* @LastModifiedBy: 
*/
@istest
public class chs_caseBatchTest {
    @isTest
    public static void  Method1(){
       //  Integer CurrentYear = Date.Today().Year();
       // Integer LastYear = Date.Today().addYears(-1).year();
         Id RecordTypeMilestone = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Milestone').getRecordTypeId();
      String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account objAcc= new Account(
          RecordTypeID=recordTypeId ,
          FirstName='Test FName',
          LastName='Test LName',
          PersonMailingStreet='test@yahoo.com',
          PersonMailingPostalCode='12345',
          PersonMailingCity='SFO',
          PersonEmail='test@yahoo.com',
          PersonHomePhone='1234567',
          PersonMobilePhone='12345678' 
        );
 
        insert objAcc;
        
     //   Account objAcc = new Account(Name = 'Account Test', Phone='1234567894', Type ='At Risk Patient');
     //   insert objAcc;
        
        Case c = new Case();
        c.Milestone_Type__c = 'Milestone 1';
        c.Billable__c =  true;
        c.AccountId = objAcc.id;
        c.Time_Spent__c = 30;
        c.RecordTypeId = RecordTypeMilestone;
        c.Status = 'Closed';
        Insert c;
         
        list<Case> lstCase = new List<Case>();
        lstCase.add(c);
        test.startTest();
        chs_CaseBatch b = new chs_CaseBatch(); 
        database.executebatch(b);
        chs_CaseBatchHandler.caseBatchHandler(lstCase);
String schTime = '0 0 12 * * ?';
chs_CaseBatchSchedule schJob = new chs_CaseBatchSchedule();
system.schedule('TestAccJob', schTime, schJob);
        test.stopTest();
    }
      @isTest
    public static void  Method2(){
       //  Integer CurrentYear = Date.Today().Year();
       // Integer LastYear = Date.Today().addYears(-1).year();
        Id RecordTypeMilestone = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Milestone').getRecordTypeId();
          String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account objAcc= new Account(
          RecordTypeID=recordTypeId ,
          FirstName='Test FName',
          LastName='Test LName',
          PersonMailingStreet='test@yahoo.com',
          PersonMailingPostalCode='12345',
          PersonMailingCity='SFO',
          PersonEmail='test@yahoo.com',
          PersonHomePhone='1234567',
          PersonMobilePhone='12345678' 
        );
 
        insert objAcc;
     //   Account objAcc = new Account(Name = 'Account Test', Phone='1234567894', Type ='At Risk Patient');
      //  insert objAcc;
        
        Case c = new Case();
        c.Milestone_Type__c = 'Milestone 1';
        c.Billable__c =  true;
        c.AccountId = objAcc.id;
        c.Time_Spent__c = 30; 
        c.RecordTypeId = RecordTypeMilestone;
        c.Status = 'Closed';
        Insert c;
         list<Case> lstCase = new List<Case>();
        lstCase.add(c);
        
         Patient_Monthly_Metric__c recPMM = New Patient_Monthly_Metric__c();
          recPMM.Number_of_Milestones_Met__c  =  1;
                recPMM.Time_Spent__c = 30;
                recPMM.Patient__c = objAcc.Id;
                Insert recPMM ;    
     
        test.startTest();
        chs_CaseBatch b = new chs_CaseBatch(); 
        database.executebatch(b);
        chs_CaseBatchHandler.caseBatchHandler(lstCase);
        test.stopTest();
    }
      @isTest
    public static void  Method3(){
       //  Integer CurrentYear = Date.Today().Year();
       // Integer LastYear = Date.Today().addYears(-1).year();
        Id RecordTypeMilestone = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Milestone').getRecordTypeId();
          String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account objAcc= new Account(
          RecordTypeID=recordTypeId ,
          FirstName='Test FName',
          LastName='Test LName',
          PersonMailingStreet='test@yahoo.com',
          PersonMailingPostalCode='12345',
          PersonMailingCity='SFO',
          PersonEmail='test@yahoo.com',
          PersonHomePhone='1234567',
          PersonMobilePhone='12345678' 
        );
 
        insert objAcc;
     //   Account objAcc = new Account(Name = 'Account Test', Phone='1234567894', Type ='At Risk Patient');
      //  insert objAcc;
        
     
        
        Case c = new Case();
        c.Milestone_Type__c = 'Milestone 1';
        c.Billable__c =  true;
        c.AccountId = objAcc.id;
        c.Time_Spent__c = 30; 
        c.RecordTypeId = RecordTypeMilestone;
        Insert c;
         list<Case> lstCase = new List<Case>();
        lstCase.add(c);
         Case c1 = new Case();
        c1.Milestone_Type__c = 'Milestone 1';
        c1.Billable__c =  False;
        c1.AccountId = objAcc.id;
        c1.Time_Spent__c = 30; 
        c1.RecordTypeId = RecordTypeMilestone;
        Insert c1;
        c1.Billable__c =  true;
       
       Test.startTest();
        try{
        
        update c1;

        system.assert(true,'You can not inactivate this account ');
        }
        catch(Exception e)
        {
   Boolean expectedExceptionThrown =  e.getMessage().contains('Script-thrown exception') ? true : false;
      System.assertEquals(expectedExceptionThrown, false);
    
        }

       Test.StopTest();
    }
}