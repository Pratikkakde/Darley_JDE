import { LightningElement, api, wire, track } from 'lwc';
import getQuoteLineItemList from '@salesforce/apex/Edit_Product_Controller.getQuoteLineItemList';
import updateQliDetails from '@salesforce/apex/Edit_Product_Controller.updateQliDetails';
import deleteQli from '@salesforce/apex/Edit_Product_Controller.deleteQli';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import EMAIL_FIELD from '@salesforce/schema/QuoteLineItem.Quantity';
import ID_FIELD from '@salesforce/schema/QuoteLineItem.Id';




const actions = [

    { label: 'Edit', name: 'edit' },

    { label: 'Delete', name: 'delete' },

];
export default class EditProductButton extends NavigationMixin(LightningElement) {
    @api recordId;
    error;
    data;
    saveDraftValues;
    draftValues;
    showSpinner=false;


   @track quotelineList ;
    fldsItemValues=[];
   
    @track length;
    @track columns = [


        { label: 'LineDecimal', fieldName: 'LineNumber', type: 'Number', fixedWidth: 150 },
        { label: 'Quantity', fieldName: 'quantity', type: 'number', typeAttributes: { maximumFractionDigits: '2' }, editable: true, fixedWidth: 100, cellAttributes: { alignment: 'left' } },
        {
            label: 'product', fieldName: 'qliproduct', type: 'url', fixedWidth: 250,
            typeAttributes: { label: { fieldName: 'product' }, target: '_blank' }
        },
        { label: 'Temp Item Description', fieldName: 'tempItemDesc', type: 'text', editable: true, fixedWidth: 180 },
        { label: 'Temp Product Code', fieldName: 'tempProductCode', type: 'text', editable: true, fixedWidth: 180 },
        { label: 'Cost 22 ', fieldName: 'cost22', type: 'currency', fixedWidth: 100, cellAttributes: { alignment: 'left' } },
        {
            label: 'Mark-Up', fieldName: 'markup', type: 'number', typeAttributes: {
                step: '0.001',
                minimumFractionDigits: '2',
                maximumFractionDigits: '3',
            }, editable: true, fixedWidth: 120, cellAttributes: { alignment: 'left' }
        },
        { label: 'Sales Price', fieldName: 'salesPrice', type: 'currency', editable: true, fixedWidth: 120 },
        { label: 'Internal Notes', fieldName: 'internalNotes', type: 'Text', editable: true, fixedWidth: 150 },
        {
            type: 'action', typeAttributes: { rowActions: actions },
        },
    ];

    connectedCallback() {
        console.log('recordId', this.recordId)
        this.getData();
    }


    getData() {

        getQuoteLineItemList({ recordId: this.recordId })
            .then((result) => {
                var qoutedata = result;
                this.quotelineList = qoutedata;
                console.log('quotelineList', this.quotelineList);
                this.length = this.quotelineList.length;
                console.log('length ---> ', this.length);
                this.quotelineList1 = this.quotelineList;
                console.log('quotelineList1', this.quotelineList1);

                var tempOppList = [];
                for (var i = 0; i < this.quotelineList.length; i++) {
                    let tempRecord = Object.assign({}, result[i]); //cloning object  
                    console.log('tempRecord', tempRecord);
                    tempRecord.qliproduct = "/" + tempRecord.ProductId;
                    tempOppList.push(tempRecord);
                }
                this.quotelineList = tempOppList;
                console.table('this', this.quotelineList);
                console.log('lenght', this.quotelineList)
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.quotelineList = undefined;
            });
    }

    handleSave(event) {
        const updatedFields = event.target.draftValues;
        console.log('updatedFields:' + JSON.stringify(updatedFields));
        updateQliDetails({ QliData: updatedFields })
            .then(result => {
                if (result) {
                    console.log('apex Resultss:', result);
                    console.log('apex Result:' + JSON.stringify(result));
                    console.log('draft value--->',this.draftValues);
                  this.draftValues = [];
                  console.log('draft valuess--->',this.draftValues);
                  this.showSpinner=true;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record updated',
                            variant: 'success'
                        })
                    )
                    setTimeout(() => {
                        this.showSpinner=false;
                    }, 2000);
                  /*  setTimeout(() => {
                     //  this.getData();
                     return this.refresh();
                    }, 2000);*/ 
                    // this.getData();
                    // this.draftValues = null;
                    refreshApex(this.quotelineList);
                    this.getData();

                }
            }).catch(error => {
                console.log('apex error:' + JSON.stringify(result));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
   
      
    async refresh() {
        await refreshApex(this.quotelineList);
    }


    callRowAction(event) {
        const recId = event.detail.row.Id;
        console.log('recId', recId);
        const actionName = event.detail.action.name;
        console.log('actionName', actionName);
        if (actionName === 'edit') {

            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recId,
                    objectApiName: 'Quotelineitem',
                    actionName: 'edit'
                }
            })
        }
        else {
            deleteQli({ qliId: recId })
                .then((result) => {
                    this.showSpinner=true;
                    this.data = result;
                    this.error = undefined;
                    
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Quote Line Item Deleted',
                            variant: 'success'
                        })
                    );
                    setTimeout(() => {
                        this.getData();
                        this.showSpinner=false;
                    }, 2000);
                })
                .catch((error) => {
                    this.error = error;
                    this.data = undefined;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Error in deleting a record',
                            variant: 'Error'
                        })
                    );
                });
        }
    }
    refreshTimeline() {
        console.log('refresh')
        this.showSpinner=true;
     refreshApex(this.quotelineList);
        this.getData();
        setTimeout(() => {
            this.showSpinner=false;
        }, 2500);
    }
    navigateToRelatedList() {
        // Navigate to the CaseComments related list page
        // for a specific Case record.
        console.log('Navigate')
        console.log('navirec', this.recordId)
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Quote',
                relationshipApiName: 'QuoteLineItems',
                actionName: 'view'
            }
        });
    }
}