/*
* @Purpose: Batch to Sum Unique MilesStone Type and Sum of Time Spent
* @Author: Cloud Haven Solutions - OV
* @CreatedDate: 09-02-2021
* @Related Code: chs_CaseBatch
* @Test Class: chs_caseBatchTest
* @LastModifiedDate: 09-02-2021
* @LastModifiedBy: 
l*/
public class chs_CaseBatchHandler {
    public static void caseBatchHandler(List<Case> caseList){
        system.debug('caseList' +caseList);
        Set<Id> setAccountId = new Set<Id>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        Map<Id,Decimal> timeSpent = new Map<Id,Decimal>();
        Map<Id,Decimal> mileStoneNumber = new Map<Id,Decimal>();
        Map<Id,list<Case>> caseListMap = new  Map<Id,list<Case>>();
        Map<String,String> mileStoneMap = new  Map<String,String>();
        Set<String> mileStoneSet = new Set<String>();
        List<Patient_Monthly_Metric__c> lstPatientMonthlyMetric = new List<Patient_Monthly_Metric__c>();
        Decimal Total;
        Decimal mileStoneSize;
            /*For (Case c : caseList){
    Total = 0;
    mileStoneSize = 0;
    setAccountId.add(c.AccountId);
    if(mileStoneNumber.containsKey(c.AccountId)){
    mileStoneSize = mileStoneNumber.get(c.AccountId);
    system.debug('mileStoneSize1--' +mileStoneSize);
    mileStoneSet.add(c.Milestone_Type__c);
    mileStoneSize = mileStoneSize + 1;
    mileStoneNumber.put(c.AccountId,mileStoneSize);
    Total = timeSpent.get(c.AccountId);
    if(c.Time_Spent__c != null){
    Total = Total +c.Time_Spent__c ;
    
    }
    timeSpent.put(c.AccountId,Total);
    }
    else{
    mileStoneSize = 0;
    mileStoneSet = new Set<String>();
    mileStoneSet.add(c.Milestone_Type__c);
    mileStoneSize = mileStoneSet.Size();
    system.debug('mileStoneSize' +mileStoneSize);
    mileStoneNumber.put(c.AccountId,mileStoneSize);
    if(c.Time_Spent__c != null){
    
    Total = c.Time_Spent__c ;
    
    }
    timeSpent.put(c.AccountId,Total);
    }
    
    
    }*/
        for (Case ar : caseList)  {
            System.debug('Count' + ar.get('countId'));
            System.debug('Average amount' + ar.get('TS'));
        }
        
        list<Account> queryAccount = [Select Id,(Select id from Patient_Monthly_Metrics__r) From account where id =:setAccountId];
        for (Account acc : queryAccount){
            Patient_Monthly_Metric__c recPMM = New Patient_Monthly_Metric__c();
            if(acc.Patient_Monthly_Metrics__r.size()>0){
                recPMM.Number_of_Milestones_Met__c  =  mileStoneNumber.get(acc.Id);
                recPMM.Time_Spent__c = timeSpent.get(Acc.Id);
                recPMM.Patient__c = acc.Id;
                recPMM.Id = acc.Patient_Monthly_Metrics__r[0].id;
            }
            else{
                recPMM.Number_of_Milestones_Met__c  =  mileStoneNumber.get(acc.Id);
                recPMM.Time_Spent__c = timeSpent.get(Acc.Id);
                recPMM.Patient__c = acc.Id;
            }
            lstPatientMonthlyMetric.add(recPMM);
        }
        if(lstPatientMonthlyMetric.size()>0){
            System.debug(lstPatientMonthlyMetric);
            Upsert lstPatientMonthlyMetric;
        }
                
    }     
    
}