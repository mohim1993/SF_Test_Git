@isTest
public class CH_Account_UnsuccessfulCallBatch_Test{ 
    @isTest
    public static void testFunction() {
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Patient Account').getRecordTypeId();
        system.debug('recordTypeId'+recordTypeId);
        Account newAccount = new Account( Salutation='Mr.', FirstName='Joe', LastName='Schmoe',Type='Patient Account',First_Unsuccessful_Call__c = Date.today().addDays(-61),recordTypeId=recordTypeId);
        insert newAccount;
        
        Account acc 	= new Account();
        acc.Id 			= newAccount.Id;
        acc.FirstName 	= 'test';
        acc.First_Unsuccessful_Call__c = Date.today().addDays(-61);
        acc.Unsuccessful_Call_Count__c = 0;  
        acc.Unsuccessful_Call_Reset__c = null; 
        update acc;
        
        CH_Account_UnsuccessfulCallBatch pqb = new CH_Account_UnsuccessfulCallBatch();
        try {
        	Database.executeBatch(pqb);
        } catch (Exception e) {
            
        }
       
    }
    
    
}