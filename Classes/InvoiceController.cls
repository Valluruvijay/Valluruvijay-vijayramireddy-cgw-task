public with sharing class InvoiceController {
    @AuraEnabled(cacheable=true)
    public static String getJsonForXero(String originRecordId) {
        system.debug('222222'+originRecordId);
        Opportunity opp = [SELECT Id, Name, Account.Name, CloseDate,Due_Date__c, 
                           (SELECT Id,Quantity, UnitPrice,description 
                            FROM OpportunityLineItems) 
                           FROM Opportunity 
                           WHERE Id =:originRecordId];

        InvoiceWrapperClass invoiceWrapper = new InvoiceWrapperClass();
        invoiceWrapper.Type = 'ACCREC'; 

        
        InvoiceWrapperClass.cls_Contact contact = new InvoiceWrapperClass.cls_Contact();
        contact.ContactID = '00000000-0000-0000-0000-000000000000'; 
        invoiceWrapper.Contact = contact;
        
        invoiceWrapper.InvoiceDate = opp.CloseDate;
        invoiceWrapper.DateString = opp.CloseDate.format();
        invoiceWrapper.DueDate = opp.Due_Date__c;
        invoiceWrapper.DueDateString = opp.Due_Date__c != null ? opp.Due_Date__c.format() : null;

        
        invoiceWrapper.LineAmountTypes = 'Exclusive';

        
        List<InvoiceWrapperClass.cls_LineItems> lineItems = new List<InvoiceWrapperClass.cls_LineItems>();
        for (OpportunityLineItem oli : opp.OpportunityLineItems) {
            InvoiceWrapperClass.cls_LineItems lineItem = new InvoiceWrapperClass.cls_LineItems();
            lineItem.Description = oli.Description;
            lineItem.Quantity = String.valueOf(oli.Quantity);
            lineItem.UnitAmount = String.valueOf(oli.UnitPrice);
            lineItem.AccountCode = '200';
            lineItems.add(lineItem);
        }
        invoiceWrapper.LineItems = lineItems;

        
        String jsonResult = JSON.serialize(invoiceWrapper);
        system.debug('Generated JSON: ' + jsonResult);

        return jsonResult;
        

       
        
    }
    
    @AuraEnabled
    public static String createInvoice(String originRecordId, String invoiceDueDate,String requiredQuantity) {
        Opportunity opp = [SELECT Id, Name, Account.Name, AccountId, CloseDate,Due_Date__c, 
                           (SELECT Id, Product2.Name, Quantity, UnitPrice,Description 
                            FROM OpportunityLineItems) 
                           FROM Opportunity 
                           WHERE Id = :originRecordId];

        Invoice__c newInvoice = new Invoice__c(
            Account__c = opp.AccountId,
            Invoice_Date__c = opp.CloseDate,
            Due_Date__c = opp.Due_Date__c,
            invoice_Reference__c= 'opportunity'
        );
        insert newInvoice;

        List<Line_Item__c> lineItems = new List<Line_Item__c>();
        for (OpportunityLineItem oli : opp.OpportunityLineItems) {
            Line_Item__c li = new Line_Item__c(
                Invoice__c = newInvoice.Id,
                Description__c = oli.Description,
                Quantity__c = Integer.valueOf(requiredQuantity),
                Unit_Price__c = oli.UnitPrice
                
            );
            lineItems.add(li);
        }
        insert lineItems;

        return newInvoice.Id;
    }
}