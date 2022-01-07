/*****************************************************
* 
* Purpose       : Trigger Hnadler to Update Name for the Case(care Plan) Task
* Test Class :  
* Created Date : 06/8/2020
* Created By : CHS - MB
* Last modified :  06/8/2020
* Last modified By : CHS - MB
* 
*****************************************************/


public class chs_TaskTriggerHandler {

    public static void TaskPatientUpdate(set<String> setCarePlan,  List<Task> lstTask)
    {
       String caseCarePlanRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CarePlan').getRecordTypeId();    

        List<Case> lstcase = [SELECT Id, ContactId, AccountId 
                              FROM Case 
                              where Id In:setCarePlan AND RecordTypeId =: caseCarePlanRecordTypeId];
        
        System.debug('lstcase'+lstcase);
        if(!lstcase.isEmpty())
        {
            for(Case ObjCase : lstcase)
            {
                for(Task objTask : lstTask)
                {
                    
                    objTask.WhoId= ObjCase.ContactId;
                }
            }
            
            
        }
    }
    
    
    
    
    
        
}