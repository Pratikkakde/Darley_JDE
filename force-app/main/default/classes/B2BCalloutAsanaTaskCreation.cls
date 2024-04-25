public class B2BCalloutAsanaTaskCreation {
	
    public static string createAsanaTask(Product2 prod) {
        HttpRequest request = new HttpRequest();
		request.setEndpoint(B2B_Asana__mdt.getInstance('EndPoint').Value__c);
		request.setMethod('POST');
        request.setHeader( 'Authorization', 'Bearer ' + B2B_Asana__mdt.getInstance('Token').Value__c );
		request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');

        B2BSettings__c settings = B2BSettings__c.getOrgDefaults();
        string productUrl = settings.OrganizationURL__c + '/' + prod.Id;
        
        String body = '{"data": {'+
                    '"name": "The product '+ prod.Name +' was created",'+
                    '"resource_subtype": "default_task",'+
                    '"approval_status": "pending",'+
                    '"projects": ["' + B2B_Asana__mdt.getInstance('Project_Id').Value__c + '"],'+
                    '"html_notes": ' +
                        '"<body>' +
                            'The produc <b>' + prod.Name + '</b> was created for your review. Please visit the link to see the product details <b>' + productUrl + '</b>' +
                        '</body>"' +
                '}}';
        request.setBody(body);
        
        Http http = new Http();
		HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 201) {
            Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
			Map<String, Object> dataMap = (Map<String, Object>) responseData.get('data');
			String asanaTaskId = (String) dataMap.get('gid');
            return asanaTaskId;
        }else {
            return null;
        }
    }
}