import { LightningElement, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getJsonForXero from '@salesforce/apex/InvoiceController.getJsonForXero';
import createInvoice from '@salesforce/apex/InvoiceController.createInvoice';

export default class CreateInvoice extends NavigationMixin(LightningElement) {
    urlParams = {};
    jsonData = '';
    showJson = false;
    isLoading = false;

    columns = [
        { label: 'Parameter', fieldName: 'key', type: 'text' },
        { label: 'Value', fieldName: 'value', type: 'text' }
    ];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlParams = currentPageReference.state || {};
        }
    }

    get parameterEntries() {
        return Object.entries(this.urlParams).map(([key, value]) => ({ key, value }));
    }

    handleShowJson() {
    const originRecordId = this.urlParams['c__origin_record'] || this.urlParams.origin_record || null;

    if (!originRecordId) {
        console.error('Missing required parameters:', { originRecordId });
        return;
    }

    getJsonForXero({ 
        originRecordId: originRecordId 
    })
        .then(result => {
          
            const jsonBlob = new Blob([result], { type: 'application/json' });
            const jsonURL = URL.createObjectURL(jsonBlob);
            window.open(jsonURL, '_blank');
        })
        .catch(error => {
            console.error('Error fetching JSON:', error);
        });
}



    handleCreateInvoice() {
        createInvoice({ 
            originRecordId: this.urlParams.c__origin_record, 
            invoiceDueDate: this.urlParams.c__invoice_due_date,
            requiredQuantity: this.requiredQuantity
        })
        .then(result => {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: result,
                    objectApiName: 'Invoice__c',
                    actionName: 'view'
                }
            });
        })
        .catch(error => {
            console.error('Error creating Invoice:', error);
        });
    }
    handleQuantityChange(event) {
       this.requiredQuantity = event.target.value;}
}