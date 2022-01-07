import { LightningElement,api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCallQuestionnaireList from '@salesforce/apex/Chs_SectionOrderingUIController.getCallQuestionnaireList';
import getQuestionnaireSectionsList from '@salesforce/apex/Chs_SectionOrderingUIController.getQuestionnaireSectionsList';
import getOrderItem from '@salesforce/apex/Chs_SectionOrderingUIController.reOrderItem';


import Name from "@salesforce/schema/Questionnaire_Section__c.Name";
import CallQuestionnaire from "@salesforce/schema/Questionnaire_Section__c.Call_Questionnaire__c";
import SortOrder from "@salesforce/schema/Questionnaire_Section__c.Sort_Order__c";
import Title from "@salesforce/schema/Questionnaire_Section__c.Title__c";


export default class Chs_SectionOrderingUI extends LightningElement {
    @track TypeOptions;
    @track orderedSection = [];
    @track unOrderedSection = [];
    stratedDragIndx;
    @track selectedCallQuestionnaireId = 'a1x7d0000041b2KAAQ';

    @track isModalOpen = false;
    fields = [Name, CallQuestionnaire, SortOrder,Title];

    createSection() {
        this.isModalOpen = true;
    }
    closeModal(){
        this.isModalOpen = false;
    }

    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: 'Account created',
            message: 'Record ID: ' + event.detail.id,
            variant: 'success',
        });
        this.dispatchEvent(evt);
        this.isModalOpen = false;
    }





    @wire(getCallQuestionnaireList)
    wireGetCallQuestionnaireList({error,data}){
        if(data){
            console.log('data',data);
            let options = [];
            for (var key in data) {
                options.push({ label: data[key].Name, value: data[key].Id  });
            }
            this.TypeOptions = options;
            this.handleCallQuestionnaireChange();
        }else{
           
        }
    }

    handleCallQuestionnaireChange(event){
        console.log('inside handleCallQuestionnaireChange');
        this.orderedSection = [];
        this.unOrderedSection = [];
        if(event!= undefined){
            this.selectedCallQuestionnaireId = event.target.value;
        }else{
            console.log('i am here');
            this.selectedCallQuestionnaireId = this.selectedCallQuestionnaireId;
        }
        
        getQuestionnaireSectionsList({selectedCallQuestionnaireId : this.selectedCallQuestionnaireId})
        .then(result => {
            this.orderedSection = [];
            this.unOrderedSection = [];
            console.log('result',result);
            for(var i =0;i<result.length;i++){
                //this.orderedSection.push(result[i]);
                if(result[i].Sort_Order__c != null){
                    this.orderedSection.push(result[i]);
                    console.log('ordered---',result[i]);
                }else{
                    this.unOrderedSection.push(result[i]);
                    console.log('unordered---',result[i]);
                }
            } 
            
        })
        .catch(error => {
            console.log('error found');
        });
    }

    DragStart(event) {
        console.log('drag start');
        event.target.classList.add('drag'); 
        this.stratedDragIndx = event.target.dataset.indx;
    }
    onDragEnter(event) {
        console.log('onDragEnter');
        event.preventDefault();
        event.dataTransfer.dropEffect = 'move'
        event.target.closest('div').classList.add('droppable');
    }

    onDragLeave(event) {
        event.target.closest('div').classList.remove('droppable');
    }

    onDragOver(event) {
        event.preventDefault();
    }

    onDrop(event) {
        console.log('onDrop');
        //event.stopPropagation();
        let dropIndx = event.target.closest('div').dataset.indx;
        console.log('dropIndx',dropIndx);
        event.target.closest('div').classList.remove('droppable');
        if(this.stratedDragIndx === dropIndx) {
            return false;
        }
        getOrderItem({'selectedCallQuestionnaireId':this.selectedCallQuestionnaireId, srcIndx: parseInt(this.stratedDragIndx)+1, destIndx: parseInt(dropIndx)+1})
        .then(result =>{
            this.orderedSection = [];
            this.unOrderedSection = [];
            console.log('result'+result);
           for(var i =0;i<result.length;i++){
            this.orderedSection.push(result[i]);
                /*if(result[i].Sort_Order__c != null){
                    this.orderedSection.push(result[i]);
                }else{
                    this.unOrderedSection.push(result[i]);
                }*/
            }
            const event = new ShowToastEvent({
                title: 'Success!',
                message: 'Question Dragged successfully!!',
                variant: 'success'
            });
            this.dispatchEvent(event);
        });
        return false;
    }


}