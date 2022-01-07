@isTest
public class chs_TaskTriggerTest {
    static testMethod void insertCase() {
      String carePlanRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByName().get('Care Plan Task').getRecordTypeId();    
       String caseCarePlanRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CarePlan').getRecordTypeId();    
		
        Contact conObj = new Contact();
        conObj.LastName = 'Test';
        insert conObj;
        
        Case caseObj = new Case();
        caseObj.RecordTypeId = caseCarePlanRecordTypeId;
        caseObj.ContactId = caseObj.Id;
        insert caseObj;
        
        Task t2 = new Task();
        t2.WhatId = caseObj.Id;
        t2.Subject='Other';
            t2.RecordtypeId = carePlanRecordTypeId;
        Insert t2;
        
        
        
    }
}