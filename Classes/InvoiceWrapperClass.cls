public class InvoiceWrapperClass {
	public String Type;	
	public cls_Contact Contact;
	public Date InvoiceDate;	
	public String DateString;	
	public Date DueDate;	
	public String DueDateString;	
	public String LineAmountTypes;	
	public cls_LineItems[] LineItems;
	public class cls_Contact {
		public String ContactID;	
	}
	public class cls_LineItems {
		public String Description;	
		public String Quantity;	
		public String UnitAmount;	
		public String AccountCode;	
		public String DiscountRate;	
	}
	public static InvoiceWrapperClass parse(String json){
		return (InvoiceWrapperClass) System.JSON.deserialize(json, InvoiceWrapperClass.class);
	}



}