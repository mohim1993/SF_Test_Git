public with sharing class chs_questionnaireController{
    @AuraEnabled(Cacheable = true)
    public static String getRecordIdObjectName(Id recordIdToGetSobjectName){
        String sObjName = recordIdToGetSobjectName.getSObjectType().getDescribe().getName();
        return sObjName;
    }
    
    @AuraEnabled(Cacheable = true)
    public static List<WrapCallQuestionnaire> getCallQuestionnaireList(Id accountRecordId){
        system.debug('accountRecordId'+accountRecordId);
        List<WrapCallQuestionnaire> ListwWcQuestionnaire = new List<WrapCallQuestionnaire>();
        List<Call_Questionnaire__c> listCallQuestionnaire = [Select Id,Name,Short_Name__c, Type__c, CreatedDate,IsActive__c 
                                                             from Call_Questionnaire__c where IsActive__c = true];
        system.debug('listCallQuestionnaire'+listCallQuestionnaire.size());
        for(Call_Questionnaire__c cq : listCallQuestionnaire){
            system.debug('cq.Name'+cq.Name);
            system.debug('cq.Short_Name__c'+cq.Short_Name__c);
            WrapCallQuestionnaire wcQuestionnaire = new WrapCallQuestionnaire();
            wcQuestionnaire.createdDate = cq.CreatedDate.format('MM-dd-yyyy');
            //wcQuestionnaire.name = cq.Name+': '+cq.Short_Name__c;
            wcQuestionnaire.name = cq.Short_Name__c;
            wcQuestionnaire.Id = cq.Id;
            ListwWcQuestionnaire.add(wcQuestionnaire);
        }
        return ListwWcQuestionnaire;
    }
    
     
    @AuraEnabled(Cacheable = true)
    public static WrapQuestionnaire getQuestionnaireSectionList(Id patientQuestionnaireOrContactId,Id callQuestionnaireSelectedId){
        system.debug('patientQuestionnaireOrContactId'+patientQuestionnaireOrContactId);
        system.debug('callQuestionnaireSelectedId'+callQuestionnaireSelectedId);
        List<WrapSection> listWrapSection = new List<WrapSection>();
        String sObjName = patientQuestionnaireOrContactId.getSObjectType().getDescribe().getName();
        Account acc = new Account();
        Boolean itIsFromContact 		= false;
        WrapQuestionnaire wq 			= new WrapQuestionnaire();
        List<String> listOptions 		= new List<String>();
        List<Question__c> listQuestions = new List <Question__c>();
        Patient_Questionnaire__c patientQuestionnaire;
        list<Patient_Questionnaire__c> listPatientQuestionnaire = new list<Patient_Questionnaire__c>();
        if(sObjName=='Patient_Questionnaire__c'){
            patientQuestionnaire = [SELECT Id,Name, Patient__r.name,Call_Questionnaire__c, Call_Questionnaire__r.name,Is_Submitted__c, LastModifiedDate,Patient__c
                                    FROM Patient_Questionnaire__c
                                    where Id = :patientQuestionnaireOrContactId];
            system.debug('patientQuestionnaire'+patientQuestionnaire);
            if(patientQuestionnaire == null){
                wq.message 			= 'No patientQuestionnaire found';
                wq.listSections 	= null;
                return wq;
            }
        }else{
            acc = [select id,Name,LastName, FirstName,PersonContactid from Account where Id = :patientQuestionnaireOrContactId limit 1];
        }
        
        system.debug('sObjName-----'+sObjName);
        Call_Questionnaire__c  questionnaire = new Call_Questionnaire__c();
        
        if(sObjName == 'Patient_Questionnaire__c'){
            List<Call_Questionnaire__c> cq = [SELECT Id,Name,Short_Name__c, Type__c FROM Call_Questionnaire__c
                                              where Id = :patientQuestionnaire.Call_Questionnaire__c AND IsActive__c = true    limit 1];
            questionnaire = cq.isEmpty() ? null : cq[0];
        }else{
            List<Call_Questionnaire__c> cq = [SELECT Id,Name,Short_Name__c, Type__c FROM Call_Questionnaire__c
                                              where Id = :callQuestionnaireSelectedId AND IsActive__c = true limit 1];
            questionnaire = cq.isEmpty() ? null : cq[0];
        }
        
        
        if(questionnaire == null){
            wq.message 			= 'No questionnaire found';
            wq.listSections 	= null;
            return wq;
        }
        
        set<Id>setQuestionId = new set<Id>();
        List<QuestionLink__c> listQuestionLink = new List<QuestionLink__c>();
        if(sObjName == 'Patient_Questionnaire__c'){
            listQuestionLink = [SELECT Id, Question__c, Call_Questionnaire__c,Questionnaire_Section__c,Questionnaire_Section__r.Name,Questionnaire_Section__r.Title__c,Order_By__c,Questionnaire_Section__r.Sort_Order__c
                                FROM QuestionLink__c 
                                where Call_Questionnaire__c = :patientQuestionnaire.Call_Questionnaire__c order by Questionnaire_Section__r.Sort_Order__c ASC];
                                //where Call_Questionnaire__c = :patientQuestionnaire.Call_Questionnaire__c order by Order_By__c ASC];
        }
        else{
            listQuestionLink = [SELECT Id, Question__c, Call_Questionnaire__c,Questionnaire_Section__c,Questionnaire_Section__r.Name,Questionnaire_Section__r.Title__c,Order_By__c,Questionnaire_Section__r.Sort_Order__c 
                                FROM QuestionLink__c 
                                where Call_Questionnaire__c = :callQuestionnaireSelectedId  order by Questionnaire_Section__r.Sort_Order__c  ASC];
            					//where Call_Questionnaire__c = :callQuestionnaireSelectedId order by Order_By__c  ASC];
        }
        
        Map<String, List<String>> mapQuesIdVsSection = new Map<String, List<String>>();
        
        for(QuestionLink__c ql : listQuestionLink){
            setQuestionId.add(ql.Question__c);
            system.debug('setQuestionId'+setQuestionId.size()); 
            if(ql.Question__c != null && ql.Questionnaire_Section__c != null){
                mapQuesIdVsSection.put(ql.Question__c, new List<String> {ql.Questionnaire_Section__c, ql.Questionnaire_Section__r.Name, ql.Questionnaire_Section__r.Title__c});
            }   
        } 
        
        Map<Id,Question__c>mapIdVsQuestion = new  Map<Id,Question__c>([SELECT Name, Id, Order_By__c, Questionnaire_Section__c, Question__c, Available_for__c, Response_Type__c, Picklist_Options_if_applicable__c FROM Question__c where ID IN :setQuestionId ]);
        
        system.debug('setQuestionId'+setQuestionId.size());
        integer count = 0;
        WrapSection wrapsec = new WrapSection();
        for(/*Question__c  qs : [SELECT Id, Question__c, Response_Type__c, Available_for__c, Picklist_Options_if_applicable__c, Name,
                               Questionnaire_Section__c, Questionnaire_Section__r.Name, Questionnaire_Section__r.Sort_Order__c,Questionnaire_Section__r.Title__c,Order_By__c
                               FROM Question__c
                               where Id IN :setQuestionId order by Order_By__c asc])*///order by Questionnaire_Section__r.Sort_Order__c asc
            QuestionLink__c  ql :[SELECT Id, Question__c,Question__r.Response_Type__c,Question__r.Available_for__c,Question__r.Picklist_Options_if_applicable__c,Question__r.Name,Question__r.Questionnaire_Section__c,Question__r.Questionnaire_Section__r.Name,Question__r.Questionnaire_Section__r.Sort_Order__c,Question__r.Questionnaire_Section__r.Title__c,Order_By__c 
            FROM QuestionLink__c where Id IN :listQuestionLink order by Questionnaire_Section__r.Sort_Order__c  ASC, Order_By__c ASC ])
        {
            //system.debug('Questionnaire_Section__r.Name'+qs.Questionnaire_Section__r.Name);
            if(mapQuesIdVsSection.containsKey(ql.Question__c)) {
                List<String> qsec = mapQuesIdVsSection.get(ql.Question__c);
                if( !wq.setSectionId.contains(qsec[0])){
                    WrapSection wrapSection = new WrapSection();
                    wrapSection.sectionTitle = qsec[2];
                    wrapSection.sectionId = qsec[0];
                    wq.listSections.add(wrapSection);
                    wq.setSectionId.add(qsec[0]);
                }
            }
            
            if(!mapQuesIdVsSection.containsKey(ql.Question__c)){
                if( wrapsec.sectionTitle 	!= 	'Blank Section'){ // To ensure that only single Blank Section creation
                    wrapsec.SectionTitle 	= 	'Blank Section';
                    wq.listSections.add(wrapsec);
                }
                wrapsec.listQuestions.add(mapIdVsQuestion.get(ql.Question__c));
            }
             
            for(WrapSection ws : wq.listSections) {
                if(mapQuesIdVsSection.containsKey(ql.Question__c)){
                    List<String> qsec = mapQuesIdVsSection.get(ql.Question__c);
                    if(ws.sectionId == qsec[0]) {
                        ws.listQuestions.add(mapIdVsQuestion.get(ql.Question__c));
                    }
                } 
            }
            
        }
        
        if(wq.listSections.isEmpty()){
            wq.message 			= 'No Questions found';
            wq.listSections 	= null;
            return wq;
        }
        wq.status  					= 'success';
        wq.callQuestionnaireId	  	= questionnaire.Id;
        if(sObjName == 'Patient_Questionnaire__c'){
            wq.patientId 				= patientQuestionnaire.Patient__c;
            wq.PatientName 				= patientQuestionnaire.Patient__r.name;
            wq.QuestionnaireName 		= patientQuestionnaire.Call_Questionnaire__r.name;
            wq.QuestionnaireType        = questionnaire.Type__c;
            if(patientQuestionnaire.Is_Submitted__c == true){
                wq.patientQuestionnaireDate = patientQuestionnaire.LastModifiedDate;
            }else{
                wq.patientQuestionnaireDate = Date.today(); 
            }
            wq.itIsFromContact = false;
        } else {
            wq.PatientName 				= acc.name;
            wq.QuestionnaireType        = questionnaire.Type__c;
            wq.patientQuestionnaireDate = Date.today(); 
            wq.itIsFromContact = true;
        }
        
        return wq;
    }
    
    
    @AuraEnabled
    public static WrapResponse createResponse(String responseList)
    {	
        system.debug('responseList'+responseList);
        WrapResponse wr = new WrapResponse();
        Boolean isSubmitted;
        Boolean responseFound = false;
        List<Response__c>listExistingResponse       = new List<Response__c>();
        Map<Id,Response__c>mapQuestionIdVsResponse  = new  Map<Id,Response__c>();
        List<Object> mapMainRes 	        	 	= (List<Object>)JSON.deserializeUntyped(responseList);
        system.debug('mapMainRes--'+mapMainRes);
        Map<String, Object> firstMap 				= (Map<String, Object>)mapMainRes[0];
        isSubmitted = Boolean.valueOf(firstMap.get('isSubmitted'));
        ID patientQuestionaireOrContactId = String.valueOf(firstMap.get('recordId'));
        system.debug('patientQuestionaireOrContactId'+patientQuestionaireOrContactId);
        for(Object response : mapMainRes){
            Map<String, Object>mapResponse 			= (Map<String, Object>)response;
            system.debug('String.valueof(mapResponse.get(response))'+String.valueof(mapResponse.get('response')));
            if(mapResponse.get('response') != null && !String.isEmpty(String.valueof(mapResponse.get('response'))))
            {   
                responseFound = true;          
            }
        }
        
        String sObjNameToUpdatePatientQuestionnaire = patientQuestionaireOrContactId.getSObjectType().getDescribe().getName();
        if(isSubmitted == true && sObjNameToUpdatePatientQuestionnaire != 'Account'){
            Patient_Questionnaire__c  PatientQuestionnaireRecord = [SELECT Name, Is_Submitted__c, Id FROM Patient_Questionnaire__c 
                                                                    where Id = :patientQuestionaireOrContactId];
            PatientQuestionnaireRecord.Is_Submitted__c = True;
            update PatientQuestionnaireRecord;
        }
        
        system.debug('responseFound'+responseFound);
        if(!responseFound){
            wr.status = 'success';
            wr.message = 'You have not made/select any question response';
            wr.isSubmitted = isSubmitted;
            return wr;
        }
        
        Id recordId = String.valueof(firstMap.get('recordId'));
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        Patient_Questionnaire__c patientQuestion 		= new Patient_Questionnaire__c();
        if(responseFound){
            
            if(sObjName =='Account' && String.valueof(firstMap.get('createdPatientQuestionnaireId')) == null){
                Account acc = [select id,PersonContactid from Account where Id = :String.valueof(firstMap.get('recordId')) limit 1];
                patientQuestion.Call_Questionnaire__c 	 	= String.valueof(firstMap.get('callQuestionnaireId'));
                patientQuestion.Patient__c 				 	= acc.PersonContactId;
                system.debug('recordId--'+String.valueof(firstMap.get('recordId')));
                if(isSubmitted == true){
                    patientQuestion.Is_Submitted__c = True;
                }
                insert patientQuestion;
                
                system.debug('patientQuestion--'+patientQuestion);
                listExistingResponse = [SELECT Id, Name, Response_FreeText__c, Response_Picklist__c, Response_Date__c, 
                                        Response_DateTime__c, Response_MultiSelect__c, Response_Boolean__c, Patient_Questionnaire__c,Patient_Questionnaire__r.Is_Submitted__c,
                                        Is_Submitted__c, Available_for__c, Question__c FROM Response__c where Patient_Questionnaire__c =:patientQuestion.Id];
            }
            
            
            else{
                listExistingResponse = [SELECT Id, Name, Response_FreeText__c, Response_Picklist__c, Response_Date__c, 
                                        Response_DateTime__c, Response_MultiSelect__c, Response_Boolean__c, Patient_Questionnaire__c,Patient_Questionnaire__r.Is_Submitted__c,
                                        Is_Submitted__c, Available_for__c, Question__c FROM Response__c where Patient_Questionnaire__c =:String.valueof(firstMap.get('recordId'))];
            }
            
            for(Response__c res : listExistingResponse){
                mapQuestionIdVsResponse.put(res.Question__c,res);
            }
        }
        
        
        List<Response__c> responseLstToUpsert = new List<Response__c>();
        List<Response__c> responseLstToUpdate = new List<Response__c>();
        for(Object response : mapMainRes){
            Map<String, Object>mapResponse 			= (Map<String, Object>)response;
            if(mapResponse.get('response') != null && !String.isEmpty(String.valueof(mapResponse.get('response'))) && mapResponse.get('responseType') == 'Free text')
            {   Response__c responseObj;
             if(mapQuestionIdVsResponse.containsKey(String.valueof(mapResponse.get('questionId')))){
                 responseObj = mapQuestionIdVsResponse.get(String.valueof(mapResponse.get('questionId')));
                 
             }else{
                 responseObj 				=  new Response__c(); 
                 
             }
             responseObj.Gathered_Response__c 		=  String.valueof(mapResponse.get('response'));
             responseObj.Question__c 				=  String.valueof(mapResponse.get('questionId'));
             responseObj.Response_FreeText__c 		=  String.valueof(mapResponse.get('response'));
             if(sObjName == 'Account'){
                 responseObj.Patient_Questionnaire__c	=  patientQuestion.Id;    
             }else{
                 responseObj.Patient_Questionnaire__c	=  String.valueof(firstMap.get('recordId'));  
             } 
             
             responseLstToUpsert.add(responseObj);
            }
            
            if(mapResponse.get('response') != null && !String.isEmpty(String.valueof(mapResponse.get('response'))) && mapResponse.get('responseType') == 'Boolean')
            {   Response__c responseObj;
             if(mapQuestionIdVsResponse.containsKey(String.valueof(mapResponse.get('questionId')))){
                 responseObj 				= mapQuestionIdVsResponse.get(String.valueof(mapResponse.get('questionId')));
             }else{
                 responseObj 				=  new Response__c(); 
             }
             responseObj.Gathered_Response__c 		=  String.valueof(mapResponse.get('response'));
             responseObj.Question__c 				=  String.valueof(mapResponse.get('questionId'));
             responseObj.Response_Boolean__c 		=  Boolean.valueof(mapResponse.get('response'));
             system.debug('response boolean    : '+mapResponse.get('response'));
             if(sObjName == 'Account'){
                 responseObj.Patient_Questionnaire__c	=  patientQuestion.Id;    
             }else{
                 responseObj.Patient_Questionnaire__c	=  String.valueof(firstMap.get('recordId'));  
             }
             system.debug('questionnaireID---'+mapResponse.get('questionnaireID'));
             
             responseLstToUpsert.add(responseObj);
            }
            
            
            
            if(mapResponse.get('response') != null && !String.isEmpty(String.valueof(mapResponse.get('response'))) && mapResponse.get('responseType') == 'Picklist')
            {   
                Response__c responseObj;				   
                if(mapQuestionIdVsResponse.containsKey(String.valueof(mapResponse.get('questionId')))){
                    responseObj 				= mapQuestionIdVsResponse.get(String.valueof(mapResponse.get('questionId')));
                }else{
                    responseObj 				=  new Response__c();
                } 
                responseObj.Gathered_Response__c 		=  String.valueof(mapResponse.get('response'));
                responseObj.Question__c 				=  String.valueof(mapResponse.get('questionId'));
                responseObj.Response_Picklist__c 		=  String.valueof(mapResponse.get('response'));
                if(sObjName == 'Account'){
                    responseObj.Patient_Questionnaire__c	=  patientQuestion.Id;    
                }else{
                    responseObj.Patient_Questionnaire__c	=  String.valueof(firstMap.get('recordId'));  
                }
                
                responseLstToUpsert.add(responseObj);
            }              
            
            
            if(mapResponse.get('response') != null && !String.isEmpty(String.valueof(mapResponse.get('response'))) && mapResponse.get('responseType') == 'MultiSelect Picklist')
            {    
                Response__c responseObj;
                if(mapQuestionIdVsResponse.containsKey(String.valueof(mapResponse.get('questionId')))){
                    responseObj 				= mapQuestionIdVsResponse.get(String.valueof(mapResponse.get('questionId')));
                }else{
                    responseObj 				=  new Response__c();
                }
                responseObj.Gathered_Response__c 		=  String.valueof(mapResponse.get('response'));
                responseObj.Question__c 				=  String.valueof(mapResponse.get('questionId'));
                String multiselectValues = String.valueof(mapResponse.get('response'));
                String multiselectValuesWithoutFirstParenthesis = multiselectValues.replace('(', '');
                String multiselectValuesWithoutSecondParenthesis = multiselectValuesWithoutFirstParenthesis.replace(')', '');
                String multiselectValuesWithoutCarriageReturn = multiselectValuesWithoutSecondParenthesis.replace('\r','');
                responseObj.Response_MultiSelect__c  = multiselectValuesWithoutCarriageReturn.trim();
                
                if(sObjName == 'Account'){
                    responseObj.Patient_Questionnaire__c	=  patientQuestion.Id;    
                }else{
                    responseObj.Patient_Questionnaire__c	=  String.valueof(firstMap.get('recordId'));  
                }
                system.debug('multi---'+String.valueof(mapResponse.get('response')));
                
                responseLstToUpsert.add(responseObj); 
            }
            
            if(mapResponse.get('response') != null && !String.isEmpty(String.valueof(mapResponse.get('response'))) && mapResponse.get('responseType') == 'Date')
            {   Response__c responseObj ;
             if(mapQuestionIdVsResponse.containsKey(String.valueof(mapResponse.get('questionId')))){
                 responseObj 							= mapQuestionIdVsResponse.get(String.valueof(mapResponse.get('questionId'))); 
             }else{
                 responseObj 				=  new Response__c();
             }
             responseObj.Gathered_Response__c 		=  String.valueof(mapResponse.get('response'));
             responseObj.Question__c 				=  String.valueof(mapResponse.get('questionId'));
             responseObj.Response_Date__c 			=  Date.valueOf(String.valueof(mapResponse.get('response')));
             if(sObjName == 'Account'){
                 responseObj.Patient_Questionnaire__c	=  patientQuestion.Id;    
             }else{
                 responseObj.Patient_Questionnaire__c	=  String.valueof(firstMap.get('recordId'));  
             }
             
             responseLstToUpsert.add(responseObj);
             
            }
            
            if(mapResponse.get('response') != null && !String.isEmpty(String.valueof(mapResponse.get('response'))) && mapResponse.get('responseType') == 'Date/Time')
            {   
                Response__c responseObj;
                if(mapQuestionIdVsResponse.containsKey(String.valueof(mapResponse.get('questionId')))){
                    responseObj 				= mapQuestionIdVsResponse.get(String.valueof(mapResponse.get('questionId'))); 
                    
                }else{
                    responseObj 					= new Response__c(); 
                }
                responseObj.Gathered_Response__c 		=  String.valueof(mapResponse.get('response'));
                responseObj.Question__c 					=  String.valueof(mapResponse.get('questionId'));
                String data = String.valueof(mapResponse.get('response'));
                Datetime dt = (DateTime)JSON.deserialize('"' + data + '"', DateTime.class);
                responseObj.Response_DateTime__c 			= dt;
                if(sObjName == 'Account'){
                    responseObj.Patient_Questionnaire__c	=  patientQuestion.Id;    
                }else{
                    responseObj.Patient_Questionnaire__c	=  String.valueof(firstMap.get('recordId'));  
                }
                
                responseLstToUpsert.add(responseObj);
            } 
        }
        if(responseLstToUpsert.size()>0){
            upsert responseLstToUpsert;
            system.debug('responseLstToUpsert---'+responseLstToUpsert.size());
            wr.status = 'success';
            wr.message = 'Records Saved Successfully!!';
            wr.isSubmitted = isSubmitted;
            wr.createdPatientQuestionnaireId = patientQuestion.Id;
        }
        return wr;
    } 
    
    @AuraEnabled
    public static list<Response__c> getResponse(Id patientQuestionnaireOrContactId)
    {	
        system.debug('i am from getResponse');
        system.debug('patientQuestionnaireId--'+patientQuestionnaireOrContactId);
        List<Response__c> listResponse = new List<Response__c>();
        String sObjName = patientQuestionnaireOrContactId.getSObjectType().getDescribe().getName();
        if(sObjName=='Patient_Questionnaire__c'){
            listResponse = [SELECT Id, Name, Response_FreeText__c, Response_Picklist__c, Response_Date__c, 
                            Response_DateTime__c, Response_MultiSelect__c, Response_Boolean__c, Patient_Questionnaire__c,Patient_Questionnaire__r.Is_Submitted__c,
                            Is_Submitted__c, Available_for__c, Question__c FROM Response__c where Patient_Questionnaire__c =:patientQuestionnaireOrContactId];
        }else{
            Patient_Questionnaire__c patientQuestionnaire = [SELECT Id, Patient__c, Is_Submitted__c, Name, Date_Completed__c, Call_Questionnaire__c 
                                                             FROM Patient_Questionnaire__c
                                                             where Patient__c = :patientQuestionnaireOrContactId limit 1]; 
            listResponse = [SELECT Id, Name, Response_FreeText__c, Response_Picklist__c, Response_Date__c, 
                            Response_DateTime__c, Response_MultiSelect__c, Response_Boolean__c, Patient_Questionnaire__c,Patient_Questionnaire__r.Is_Submitted__c,
                            Is_Submitted__c, Available_for__c, Question__c FROM Response__c where Patient_Questionnaire__c =:patientQuestionnaire.Id];
        }
        
        return listResponse;
    }
    
    public class WrapQuestionnaire{
        @AuraEnabled public List<WrapSection> listSections;
        @AuraEnabled public List<String> options; 
        @AuraEnabled public String status;
        @AuraEnabled public String message;
        @AuraEnabled public String patientId;
        @AuraEnabled public String callQuestionnaireId;
        @AuraEnabled public String QuestionnaireName;
        @AuraEnabled public String QuestionnaireType;
        @AuraEnabled public String PatientName;
        @AuraEnabled public DateTime patientQuestionnaireDate;
        @AuraEnabled public Boolean itIsFromContact = false;
        @AuraEnabled public Boolean isSubmitted;
        public Set<Id> setSectionId; 
        public  WrapQuestionnaire(){
            listSections = new List <WrapSection>();
            setSectionId = new Set<Id>();
        }
        
    }
    Public class WrapSection{
        @AuraEnabled public Id sectionId;
        @AuraEnabled public String SectionTitle;
        @AuraEnabled public WrapQuestionnaire WrapSec;
        @AuraEnabled public List<Question__c> listQuestions;
        public  WrapSection(){
            listQuestions = new List <Question__c>();
        }
    }
    
    public class WrapResponse{
        @AuraEnabled public String status;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean isSubmitted;
        @AuraEnabled public String createdPatientQuestionnaireId;
    }
    
    
    
    Public class WrapCallQuestionnaire{
        @AuraEnabled public String name;
        @AuraEnabled public String createdDate;
        @AuraEnabled public Id Id;
        
    }
    
    
}