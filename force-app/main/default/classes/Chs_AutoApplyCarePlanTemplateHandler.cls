public class Chs_AutoApplyCarePlanTemplateHandler {
    
    public static void createTaskRecord(Set<Id> caseId){
        
        String leadPatientRecId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        String CaseRecId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CarePlan').getRecordTypeId();
        String taskRecId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByName().get('Care Plan Task').getRecordTypeId();
        
        Map<Id,Id> mapCaseToContact=new Map<Id,Id>();
        Map<Id,Id> mapCaseToProblem=new Map<Id,Id>();
        
        List<HealthCloudGA__CarePlanProblem__c> listProblem=new List<HealthCloudGA__CarePlanProblem__c>();
        List<HealthCloudGA__CarePlanGoal__c> listGoal=new List<HealthCloudGA__CarePlanGoal__c>();
        List<Task> listTask=new List<Task>();
        
        for(HealthCloudGA__CarePlanTemplate__c  lstHCCarePlanTemp : [SELECT  Name, HealthCloudGA__Active__c, HealthCloudGA__Description__c
                                                                     FROM HealthCloudGA__CarePlanTemplate__c 
                                                                     where Name = 'Increased Risk Confirmation' Limit 1])
        {
            
            List<HealthCloudGA__CarePlanProblem__c> carePlanProblem=[SELECT Id, Name, HealthCloudGA__CarePlanTemplate__c FROM HealthCloudGA__CarePlanProblem__c where HealthCloudGA__CarePlanTemplate__c =:lstHCCarePlanTemp.id limit 1];
            List<HealthCloudGA__CarePlanGoal__c> carePlanGoal=[SELECT Id, HealthCloudGA__CarePlanProblem__c, HealthCloudGA__CarePlan__c, Name FROM HealthCloudGA__CarePlanGoal__c where HealthCloudGA__CarePlanTemplate__c =:lstHCCarePlanTemp.id limit 1];
            HealthCloudGA__CarePlanTemplateProblem__c problemtemplate= [SELECT Id, Name, HealthCloudGA__CarePlanTemplate__c FROM HealthCloudGA__CarePlanTemplateProblem__c where HealthCloudGA__CarePlanTemplate__c =:lstHCCarePlanTemp.id limit 1];
            
            HealthCloudGA__CarePlanTemplateGoal__c goalTemplate=[SELECT Id, Name, HealthCloudGA__CarePlanTemplateProblem__c FROM HealthCloudGA__CarePlanTemplateGoal__c where HealthCloudGA__CarePlanTemplateProblem__c =:problemtemplate.Id ];
            
            List<HealthCloudGA__CarePlanTemplateTask__c> taskTemplate =[SELECT Id, Name, HealthCloudGA__CarePlanTemplateGoal__c, HealthCloudGA__Priority__c, HealthCloudGA__Status__c, HealthCloudGA__SortOrder__c, HealthCloudGA__Subject__c, HealthCloudGA__AssignedTo__c, HealthCloudGA__Active__c FROM HealthCloudGA__CarePlanTemplateTask__c where HealthCloudGA__CarePlanTemplateGoal__c =:goalTemplate.Id];
            
            List<Case> caseRecord=[Select Id,ContactId,AccountId,OwnerId  from Case where Id IN:caseId ];
            
            for(Case objCase:caseRecord){
                
                HealthCloudGA__CarePlanProblem__c problem=new HealthCloudGA__CarePlanProblem__c();
                problem.Name=carePlanProblem[0].Name;
                problem.HealthCloudGA__CarePlan__c=objCase.id;
                problem.HealthCloudGA__CarePlanTemplate__c=lstHCCarePlanTemp.id;
                listProblem.add(problem);
                
                for(HealthCloudGA__CarePlanTemplateTask__c obj:taskTemplate){
                    
                    Task t=new Task();
                    t.RecordTypeId=taskRecId;
                    t.OwnerId=objCase.OwnerId;
                    t.Subject=obj.HealthCloudGA__Subject__c;
                    t.Status=obj.HealthCloudGA__Status__c;
                    t.Priority=obj.HealthCloudGA__Priority__c;
                    t.WhoId=objCase.ContactId;
                    t.ActivityDate=system.today();
                    t.WhatId=objCase.Id;
                    listTask.add(t);
                    
                }
                
            }
            
            
            if(!listProblem.isEmpty()){
                insert listProblem;       
                for(HealthCloudGA__CarePlanProblem__c hcp:listProblem){
                    mapCaseToProblem.put(hcp.Id, hcp.HealthCloudGA__CarePlan__c);
                }
            }
            for(Id key : mapCaseToProblem.keyset()){
                
                HealthCloudGA__CarePlanGoal__c goal=new HealthCloudGA__CarePlanGoal__c();
                goal.Name=carePlanGoal[0].Name;
                goal.HealthCloudGA__CarePlanProblem__c=key;
                goal.HealthCloudGA__CarePlan__c=mapCaseToProblem.get(Key);
                goal.HealthCloudGA__CarePlanTemplate__c=lstHCCarePlanTemp.id;
                listGoal.add(goal);
            }
            
            if(!listGoal.isEmpty()){
                insert listGoal;       
            }
            if(!listTask.isEmpty()){
                insert listTask;       
            }
        }

    }
    
}