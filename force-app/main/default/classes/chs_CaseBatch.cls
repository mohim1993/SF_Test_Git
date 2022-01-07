/*
* @Background: Patient needs to report on billable time and milestones.  Milestones are specific tasks that need to be completed for the patient.  Billable hours 
* is time spent completing those tasks. 
* @Purpose: Batch to Sum Unique MilesStone Type and Sum of Time Spent for cases that are billable.  This provides billing and operational tracking information
* @Author: Cloud Haven Solutions - OV
* @CreatedDate: 09-02-2021
* @Related Code: chs_CaseBatchHandler
* @Test Class: chs_caseBatchTest
* @LastModifiedDate: 09-23-2021
* @LastModifiedBy: Mohim Ahmad
*/

global class chs_CaseBatch implements Database.Batchable<AggregateResult>, Database.Stateful{
    // The batch job starts
    global Date firstDayOfMonth;
    global Iterable<AggregateResult> start(Database.BatchableContext bc){
        //Case_Batch_Custom_setting__c cs = [SELECT id, Name,Default_Month_and_Year__c FROM Case_Batch_Custom_setting__c WHERE name = 'Case Batch Default Month (Profile)']; // TODO :: Please Review Updated by Sean Milam 2021-09-27
        Case_Batch_Custom_setting__c cs = [SELECT id, Name,Default_Month_and_Year__c FROM Case_Batch_Custom_setting__c]; // TODO :: Please Review Updated by Sean Milam 2021-09-27
        firstDayOfMonth = cs.Default_Month_and_Year__c.toStartOfMonth();
        String strFirstDayOfMonth = String.valueOf(firstDayOfMonth);
        strFirstDayOfMonth = strFirstDayOfMonth.substringBefore('T');
        system.debug('strFirstDayOfMonth'+strFirstDayOfMonth);
        Date lastDayOfMonth  = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
        //Date lastDayOfMonth = Date.valueOf('2021-09-30 00:00:00');
        String strlastDayOfMonth = String.valueOf(lastDayOfMonth);
        strlastDayOfMonth = strlastDayOfMonth.substringBefore('T');
        system.debug('strlastDayOfMonth'+strlastDayOfMonth);
        Id RecordTypeMilestone = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Milestone').getRecordTypeId();
        
        /*String query =  'Select count(id) countId, AccountId,Milestone_Type__c, Sum(Time_Spent__c) TotalTime FROM Case where Billable__c = true '+  
            ' AND Milestone_type__c != NULL AND Metric_Date__c >= '+strFirstDayOfMonth+' AND Metric_Date__c <= '+strlastDayOfMonth+
            ' AND Status = \''+'Closed'+'\' AND RecordTypeId = \'' +RecordTypeMilestone + '\' GROUP BY AccountId,Milestone_Type__c';*/
        
        String query =  'Select AccountId,count_distinct(Milestone_Type__c) ctDistMilestone, Sum(Time_Spent__c) TotalTime FROM Case where Billable__c = true '+  
            ' AND Metric_Date__c >= '+strFirstDayOfMonth+' AND Metric_Date__c <= '+strlastDayOfMonth+
            ' AND RecordTypeId = \'' +RecordTypeMilestone + '\' GROUP BY AccountId';
        system.debug('q'+query);
        return new AggregateResultIterable(query);
    }
    
    // The batch job executes and operates on one batch of records
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        List<Patient_Monthly_Metric__c> lstPatientMonthlyMetric = new List<Patient_Monthly_Metric__c>();
        for(sObject sObj : scope) {
            Patient_Monthly_Metric__c recPMM = New Patient_Monthly_Metric__c();
            String AccountId     = String.valueOf(sObj.get('AccountId'));
            Decimal TotalTime    = Double.valueOf(sObj.get('TotalTime'));
            Decimal mileStoneType = Double.valueOf(sObj.get('ctDistMilestone'));            
            String externalId = AccountId+'_'+firstDayOfMonth.month()+'_'+firstDayOfMonth.year();
            recPMM.ExternalId__c = externalId;
            recPMM.Patient__c = AccountId;
            recPMM.Time_Spent__c = TotalTime;
            recPMM.Number_of_Milestones_Met__c = mileStoneType;
            recPMM.Month__c = firstDayOfMonth.month();
            recPMM.Year__c = firstDayOfMonth.year();
            lstPatientMonthlyMetric.add(recPMM);
        }

        System.debug('firstDayOfMonth ------ '+firstDayOfMonth);
        system.debug('lstPatientMonthlyMetric--'+lstPatientMonthlyMetric.size());
        // system.debug('AccountIdVsTimeSpent--'+AccountIdVsTimeSpent);
        // system.debug('AccountIdVsMileStoneNumber--'+AccountIdVsMileStoneNumber);

        for(Patient_Monthly_Metric__c pmm :lstPatientMonthlyMetric){
            system.debug('pmm'+pmm);            
        }

        if(!lstPatientMonthlyMetric.isEmpty()){
            Schema.SObjectField externalId = Patient_Monthly_Metric__c.Fields.ExternalId__c;
            Database.UpsertResult [] cr = Database.upsert(lstPatientMonthlyMetric,externalId, false);
            system.debug('cr'+cr);
        }
        
      
    }
    // The batch job finishes
    global void finish(Database.BatchableContext bc){ }
}