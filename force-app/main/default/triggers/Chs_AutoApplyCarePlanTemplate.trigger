/*
* @Purpose: Trigger to auto apply care plan template to case(Care Plan) 
* @Author: Cloud Haven Solutions - PC
* @CreatedDate: 11/06/2020
* @Related Code: 
* @Test Class: 
* @LastModifiedDate: 
* @LastModifiedBy: 
*/
trigger Chs_AutoApplyCarePlanTemplate on Case (after insert) {
    
   
    String CaseRecId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CarePlan').getRecordTypeId();
    
    Set<Id> caseId=new Set<Id>();
    Map<Id,Id> mapCaseToContact=new Map<Id,Id>();
    
    if (Trigger.isAfter && Trigger.isInsert) {
        
        for (Case c : Trigger.new) {
            
            if (c.RecordTypeId==CaseRecId){ 
                
                mapCaseToContact.put(c.Id,c.ContactId);
                caseId.add(c.id);
                
            }
        }
    }

    Chs_AutoApplyCarePlanTemplateHandler.createTaskRecord(caseId);
   
    
}