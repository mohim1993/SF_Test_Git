@istest(SeeAllData=true)
public class Chs_AutoApplyCarePlanTemplateHandlerTest {
    
    //@isTest
    public static testMethod void test1(){
        
        String AccRecId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Patient Account').getRecordTypeId();
        //String ContRecId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        //String CaseRecId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CarePlan').getRecordTypeId();
        
        Id CaseRecId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CarePlan').getRecordTypeId();
        // Id AccRecId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        // Id ContRecId = Schema.SObjectType.COntact.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        
        Set<Id> caseId=new Set<Id>();
        
        Account acc=new Account();
        acc.FirstName='Test';
        acc.LastName='Person';
        acc.RecordTypeId=AccRecId;
        acc.Status__c='Identified At-Risk';
        insert acc;
        
        Case c=new Case();
        c.Priority='Medium';
        c.Subject='test care plan';
        c.RecordTypeId=CaseRecId;
        c.Status='New';
        c.AccountId=acc.Id;
        c.ContactId=acc.PersonContactId;  
        insert c;
        
        caseId.add(c.id);
        
        HealthCloudGA__CarePlanTemplate__c cpt=new HealthCloudGA__CarePlanTemplate__c();
        cpt.Name='Increased Risk Confirmation';
        cpt.HealthCloudGA__Active__c=True;
        cpt.HealthCloudGA__Description__c='desc test';
        insert cpt;
        
        HealthCloudGA__CarePlanTemplateProblem__c cptp=new HealthCloudGA__CarePlanTemplateProblem__c();
        cptp.HealthCloudGA__CarePlanTemplate__c=cpt.Id;
        cptp.Name='Increased Risk';
        cptp.HealthCloudGA__Active__c=True;
        cptp.HealthCloudGA__SortOrder__c=1;
        insert cptp;
        
        HealthCloudGA__CarePlanProblem__c cpp = new HealthCloudGA__CarePlanProblem__c();
        cpp.HealthCloudGA__CarePlanTemplate__c=cpt.Id;
        cpp.name='Increased Risk';
        insert cpp;
        
        HealthCloudGA__CarePlanTemplateGoal__c cptg=new HealthCloudGA__CarePlanTemplateGoal__c();
        cptg.Name='Confirmation Testing';
        cptg.HealthCloudGA__CarePlanTemplateProblem__c=cptp.Id;
        cptg.HealthCloudGA__SortOrder__c=1;
        insert cptg;
        
        HealthCloudGA__CarePlanGoal__c cpg = new HealthCloudGA__CarePlanGoal__c();
        cpg.Name='Confirmation Testing';
        cpg.HealthCloudGA__CarePlanTemplate__c=cpt.Id;
        cpg.HealthCloudGA__SortOrder__c=1;
        insert cpg;
        
        
        HealthCloudGA__CarePlanTemplateTask__c cptt=new HealthCloudGA__CarePlanTemplateTask__c();
        cptt.Name='Inform Patient of Risk Status';
        cptt.HealthCloudGA__CarePlanTemplateGoal__c=cptg.id;
        cptt.HealthCloudGA__AssignedTo__c='Care Coordinator';
        cptt.HealthCloudGA__Active__c=True;
        cptt.HealthCloudGA__Priority__c='Normal';
        cptt.HealthCloudGA__Status__c='Not Started';
        cptt.HealthCloudGA__SortOrder__c=1;
        cptt.HealthCloudGA__Subject__c='Inform Patient of Risk Status';
        insert cptt;
        
        
        Chs_AutoApplyCarePlanTemplateHandler.createTaskRecord(caseId);
    }
    
    
}