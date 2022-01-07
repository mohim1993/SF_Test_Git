// Author: Jim Weglin II / Cloud Haven
// Date: 01/18/2021 
// Purpose: Batch Class used to update Patient Person Account records based on their First Unsuccessful Call Date
// Context: Batch Class called via Scheduled Apex Functionality in Salesforce UI 
// Revision History:
//   01/18/2021 - Jim Weglin II / v1
global class CH_Account_UnsuccessfulCallBatch Implements Database.Batchable<sObject>,Schedulable{
    
    // Set the Batch context below by selecting Accounts with the following characteristics: 
    // Account Record Type = Patient (Person Account Record Type, not Regular Account)
    // First_Unsuccessful_Call__c != Null
    global Database.QueryLocator start(Database.BatchableContext bc) {
        string query = 'Select Id,RecordType.Name,First_Unsuccessful_Call__c, Unsuccessful_Call_Count__c,Unsuccessful_Call_Reset__c FROM Account WHERE RecordType.Name = \'Patient Account\' AND isPersonAccount = True AND First_Unsuccessful_Call__c != Null';
        system.debug('query----'+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    }
    
   global void execute(Database.BatchableContext bc, List<Account> scope) {
       // Variable used to store list of Accounts to be updated  
       List<Account> accountList = new List<Account>(); 
       // Check the Account record to see if Today's date is greater than 60 days from the First Unsuccessful Call
       // If so, Process each batch of records and sets the following values:
       //  First_Unsuccessful_call__c date = null
       //  Unsuccessful_Call_Count__c = 0 (zero)
       //  Unsuccessful_Call_Reset__c date = null
       for (Account acc : scope) {
            if (date.today() > acc.First_Unsuccessful_Call__c + Integer.ValueOf(Label.Unsuccessful_Call_Reset_After_days)) {
                system.debug('acc'+acc);
                acc.First_Unsuccessful_Call__c = null; 
                acc.Unsuccessful_Call_Count__c = 0;  
                acc.Unsuccessful_Call_Reset__c = null; 
                accountList.add(acc);
            }
            // Add records to collection for update
            //accountList.add(acc);
       }
       // If list size is greater than zero, update the batch of Accounts 
       if (accountList.size() > 0){
           system.debug('accountList'+accountList.size());
            update accountList;
       }
           
    }
    
    // Finish method used to send email after batch is completed
    global void finish(Database.BatchableContext bc){
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       
      AsyncApexJob a = [Select a.TotalJobItems, a.Status, a.NumberOfErrors,
      a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById,
      a.CompletedDate From AsyncApexJob a WHERE id = :BC.getJobId()];
       
      // below code will send an email to User about the status
      // String[] email = new String[]{'jim.weglin@cloudhaven.com'};
      String[] emailLabel = new String[]{Label.Batch_Job_Email_Address};
      mail.setToAddresses(emailLabel);
      mail.setReplyTo(emailLabel[0]); // Add here your email address
      mail.setSenderDisplayName('Apex Batch Processing Module');
      mail.setSubject('Batch Processing '+a.Status);
      mail.setPlainTextBody('The Batch Apex job processed '+ a.TotalJobItems+'batches with '+a.NumberOfErrors+'failures '+'Job Itemprocessed are '+a.JobItemsProcessed);
      Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
    }
    global void execute(SchedulableContext sc){
       CH_Account_UnsuccessfulCallBatch job = new CH_Account_UnsuccessfulCallBatch();
       Database.executeBatch(job,Integer.ValueOf(Label.CH_Account_UnsuccessfulCallBatch_Size));  
    }
}