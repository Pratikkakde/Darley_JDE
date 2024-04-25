import { LightningElement, wire, api, track } from 'lwc';
import getFilesImparitve from '@salesforce/apex/DeleteFileHandler.getFilesUpdate';
import deleteFile from '@salesforce/apex/DeleteFileHandler.deleteFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DeleteFileComponent extends LightningElement {
    data;
    @api recordId;
    error;
    docIds;
    datas
    loaded = false;

    connectedCallback(){
      console.log('c');
      console.log('recordId',this.recordId)
      setTimeout(() => {
      this.getData();
      },50);
    }
  
  
    handleDelete(event) {
      this.docIds = event.target.value;
      console.log('this.docIds', this.docIds);
    this.getDeleteData();
    
      
      
    }
      getDeleteData(){
      deleteFile({ docId: this.docIds })
      .then(result => {
          console.log('result', result)
          this.datas = result;
         this.loaded = true;
  
         setTimeout(() => {
           const evt = new ShowToastEvent({
              title: 'File Deleted',
              message: 'File Deleted Successfully',
              variant: 'success',
              mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.loaded = false;
            this.getData();
        }, 1500);
      
     })
  
        .catch(error => {
          this.error = error;
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error in deleting file',
              message: error.body.message,
              variant: 'error',
            }),
          );
        });
    }
  
     getData(){
       getFilesImparitve({recordId:this.recordId })
      
       .then((result) => {
         console.log('data', result);
           this.data = result;
          this.error = undefined;
      })
      .catch((error) => {
          this.error = error;
          this.data = undefined;
      });
    }
}