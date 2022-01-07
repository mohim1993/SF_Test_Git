/*
* @Purpose: Trigger For Case
* @Author: Cloud Haven Solutions - Sajjad
* @CreatedDate: 08/31/2021
* @Related Code: 
* @Test Class: 
* @LastModifiedDate: 09-06-2021
* @LastModifiedBy: OV
*/

trigger chs_CaseTrigger on Case (before delete, before insert, before update, after delete, after insert, after update) {
     Id RecordTypeMilestone = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Milestone').getRecordTypeId();
    if (Trigger.isBefore && (Trigger.isInsert)) {
       Set<String> milestoneType                    = new Set<String> ();
        Set<Id> setPatientId                    = new Set<Id> ();
        Map<Id,Case> mapCaseThisMonthBillable   = new Map<Id,Case> ();
        
        for(Case c : Trigger.new) {
            if(c.AccountId != NULL && c.Billable__c == True) {
                setPatientId.add(c.AccountId);
                milestoneType.add(c.Milestone_Type__c);
            }
        }
        
        if(!setPatientId.isEmpty()) {
            for(Case c : [Select AccountId FROM Case WHERE AccountId = :setPatientId AND(Metric_Date__c = THIS_MONTH OR Metric_Date__c = This_YEAR) AND Billable__c = True AND Milestone_Type__c=:milestoneType AND RecordTypeId =:RecordTypeMilestone]) {
                mapCaseThisMonthBillable.put(c.AccountId, c);
            }
            
            if(!mapCaseThisMonthBillable.isEmpty()) {
                for(Case c : Trigger.new) {
                    if(c.AccountId != NULL && mapCaseThisMonthBillable.ContainsKey(c.AccountId)  ) {
                        c.addError('Already a Case is marked as billable for that patient and month');
                    }
                }
            }
        }
    }
    
    
    if (Trigger.isBefore && Trigger.isUpdate) {
         
        Set<Id> setPatientId                    = new Set<Id> ();
        Set<String> milestoneType                   = new Set<String> ();
        Map<Id,Case> mapCaseThisMonthBillable   = new Map<Id,Case> ();
        
        for(Case c : Trigger.new) {
            if(c.AccountId != NULL && c.Billable__c == True && c.Milestone_Type__c != null) {
                setPatientId.add(c.AccountId);
                milestoneType.add(c.Milestone_Type__c);
                
            }
        }
        
        if(!setPatientId.isEmpty() && !milestoneType.isEmpty()) {
            System.debug('milestoneType'+milestoneType);
            for(Case c : [Select AccountId FROM Case WHERE AccountId = :setPatientId AND (Metric_Date__c = THIS_MONTH OR Metric_Date__c = This_YEAR) AND Billable__c = True AND Milestone_Type__c=:milestoneType AND RecordTypeId =:RecordTypeMilestone]) {
                mapCaseThisMonthBillable.put(c.AccountId, c);
            }
            
            if(!mapCaseThisMonthBillable.isEmpty()) {
                 System.debug('mapCaseThisMonthBillable'+mapCaseThisMonthBillable);
                for(Case c : Trigger.new) {
                    Case oldCase = Trigger.oldMap.get(c.Id);
                    if(c.AccountId != NULL  && (c.Billable__c != oldCase.get('Billable__c') || c.Milestone_Type__c !=  oldCase.get('Milestone_Type__c') ))
                    {
                    
                        if((mapCaseThisMonthBillable.get(c.AccountId) != null) )
                        {
                        c.addError('Already a Case is marked as billable for that patient and month');
                    }
                    }
                  
                }
            }
        }
    }

}