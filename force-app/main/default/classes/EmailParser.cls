global class EmailParser implements Messaging.InboundEmailHandler  {
    private Boolean isTac1Owner = false;
    Private Boolean isTac2ShipTo = false;
    Private Boolean isTac3Billing = false;
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        string emailBody;
         String subject = email.subject;
        system.debug('Subject-->'+ email.subject);
        if(email.plainTextBody !=null){
            emailBody  = email.plainTextBody;
            system.debug(' formatted emailBody' +  emailBody);
            integer s1= emailBody.lastindexof('LINE 1:');
                        integer s2= emailBody.lastindexof('EFF');

                        system.debug('  emailBody' +  emailBody.lastindexof('LINE 1:'));
                        system.debug('  emailBody' +  emailBody.lastindexof('EFF'));
            String result1 = emailBody.substring(s1, s2);
                String result2 = emailBody.substring(s1 + 'LINE 1:'.length(), s2).trim();

            system.debug('result1'+result1);
                        system.debug('result2'+result2);


            
        }
        list<DoDAAC__c> insertDodaac = new List<DoDAAC__c>();
        list<DoDAAC__c> updateDodaac = new List<DoDAAC__c>();
        Map<String , Id> ExistingDodaacNumberMap = new Map<string , Id>(); 
       List<DoDAAC__c> existingDodaacRecordList = [Select Id , Name from DoDAAC__c];
        for(DoDAAC__c dodaacExisting : existingDodaacRecordList){
            ExistingDodaacNumberMap.put(dodaacExisting.Name , dodaacExisting.Id);
            system.debug('Existing Dodaac Map-->'+ ExistingDodaacNumberMap.put(dodaacExisting.Name , dodaacExisting.Id));
        }
            
      
        List<String> mailBodySplitted  = new List<String>();
        mailBodySplitted = emailBody.split('\n');
        
        system.debug('splitbody'+ mailBodySplitted);
       
      
         DoDAAC__c dodaacRecords = new DoDAAC__c();
        for(string body : mailBodySplitted){
            system.debug('Body-->>>>>>'+ body );
            if(subject != Null){
                dodaacRecords.Created_By_User__c = subject;
            }
            if (body.contains('TAC2 (SHIP TO)')) {
                isTac2ShipTo = true;
                isTac1Owner = false;
                isTac3Billing = false;
                continue; // Skip this line and move to the next iteration
            }
            
            // Check if we switch to the "TAC1 (OWNER)" section
            if (body.contains('TAC1 (OWNER)')) {
                isTac1Owner = true;
                isTac2ShipTo = false;
                isTac3Billing = false;
                continue; // Skip this line and move to the next iteration
            }
            // Check if we switch to the "TAC3 (BILLING)" section
            if (body.contains('TAC3 (BILLING)')) {
                isTac1Owner = false;
                isTac2ShipTo = false;
                isTac3Billing = true;
                continue; // Skip this line and move to the next iteration
            }
            
            //DODAAC
             if(body.contains('DoDAAC:')){
                system.debug('body'+ body);
                Integer IndexValueDodaac = body.indexOf('DoDAAC:') + 'DoDAAC:'.length();
                  system.debug('Index' +IndexValueDodaac); 
                string getsubstringDodaac = body.substring(IndexValueDodaac).trim();
                 system.debug('getsubstringDodaac'+getsubstringDodaac);
                string mainSubstringDodaac = getsubstringDodaac.substring(0, getsubstringDodaac.indexOf(' '));
                dodaacRecords.Name = mainSubstringDodaac;
                 system.debug('Dodaac number-->' +dodaacRecords.Name);
                if(ExistingDodaacNumberMap.containsKey(dodaacRecords.Name)){
                    system.debug('in if-->');
                dodaacRecords.Id = ExistingDodaacNumberMap.get(dodaacRecords.Name);
                    system.debug('ExistingDodaacNumberMap.containsKey(dodaacRecords.Name)-->'+ ExistingDodaacNumberMap.containsKey(dodaacRecords.Name));
                    system.debug('dodaacRecords.Id-->'+ dodaacRecords.Id);
                system.debug('Dodaac Id-->' +dodaacRecords.Id);
            }
             }
            // logic for the Mannually putting fields by the User...........
             if(body.toLowerCase().contains('branch:')){
               Integer IndexValue = body.toLowerCase().indexOf('branch:') + 'branch:'.length();  
                 System.debug('IndexValue-->'+ IndexValue);
                 string getsubstring = body.substring(IndexValue).trim();
                 dodaacRecords.Branch__c = getsubstring;
                 system.debug('getsubstring Branch---->'+getsubstring);
                  system.debug('Branch---->'+dodaacRecords.Branch__c);
             }
             if(body.toLowerCase().contains('unit information:')){
               Integer IndexValue = body.toLowerCase().indexOf('unit information:') + 'unit information:'.length();  
                 string getsubstring = body.substring(IndexValue).trim();
                 System.debug('IndexValue-->'+ IndexValue);
                 dodaacRecords.Unit_Information__c = getsubstring;
                 system.debug('getsubstring Unit Info---->'+getsubstring);
                 system.debug(' Unit Info---->'+dodaacRecords.Unit_Information__c );
             }
             if(body.toLowerCase().contains('base/camp:')){
               Integer IndexValue = body.toLowerCase().indexOf('base/camp:') + 'base/camp:'.length(); 
                 System.debug('IndexValue-->'+ IndexValue);
                 string getsubstring = body.substring(IndexValue).trim();
                 dodaacRecords.Base_Camp__c = getsubstring;
                 system.debug('getsubstring Base Camp---->'+getsubstring);
                 system.debug('Base Camp---->'+dodaacRecords.Base_Camp__c);
             }
            //UIC
            if(body.contains('UIC:')){
                system.debug('body'+ body);
                Integer IndexValue = body.indexOf('UIC:') + 'UIC:'.length();
                system.debug('Index' +IndexValue);
                string getsubstring = body.substring(IndexValue).trim();
               string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('CREATION'));
                dodaacRecords.UIC__c = mainSubstring;
                system.debug('UIC-->' +mainSubstring);
            }
            //Creation date
            if (body.contains('CREATION DATE:')) {
                system.debug('body' + body);
                Integer indexValue = body.indexOf('CREATION DATE:') + 'CREATION DATE:'.length();
                system.debug('index value creation date-->'+indexValue);
                string getSubstring = body.substring(indexValue).trim();
                system.debug('now index value-->' + getSubstring);
                Integer endIndex = getSubstring.indexOf('*');
                if (endIndex != -1) {
                    getSubstring = getSubstring.substring(0, endIndex).trim();
                }
                
                if (getSubstring != null && getSubstring != '') {
                    List<String> dateParts = getSubstring.split('/');
                    if (dateParts.size() == 3) {
                        Integer month = Integer.valueOf(dateParts[0]);
                        Integer day = Integer.valueOf(dateParts[1]);
                        Integer year = Integer.valueOf(dateParts[2]);
                        
                        try {
                            Date creationDate = Date.newInstance(year, month, day);
                            dodaacRecords.Creation_Date__c = creationDate;
                            system.debug('creation date --> ' + creationDate);
                        } catch (Exception e) {
                            system.debug('Invalid creation date format');
                        }
                    }
                }
            }
            
            
            //dodaac service agency
            if(body.contains('DODAAD SERVICE/AGENCY:')){
                system.debug('body'+ body);
                Integer IndexValue = body.indexOf('DODAAD SERVICE/AGENCY:') + 'DODAAD SERVICE/AGENCY:'.length();
                system.debug('Index' +IndexValue);
                string getsubstring = body.substring(IndexValue).trim();
                system.debug('now index value-->'+ getsubstring);
                dodaacRecords.DoDAAC_Service_Agency__c = getsubstring;
                system.debug('Dodaac service agency-->' +getsubstring);
            }
            //Organisation type code....................
            if(body.contains('ORGANIZATION TYPE CODE:')){
                system.debug('body'+ body);
                Integer IndexValue = body.indexOf('ORGANIZATION TYPE CODE:') + 'ORGANIZATION TYPE CODE:'.length();
                
                string getsubstring = body.substring(IndexValue).trim();
                system.debug('now index value-->'+ getsubstring);
               string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('DELETION DATE:'));
                dodaacRecords.Organization_Type_Code__c = mainSubstring;
                system.debug('Organisation type code -->' +mainSubstring);
            }
            // DELETION DATE: 
            if (body.contains('DELETION DATE:')) {
                system.debug('body' + body);
                Integer indexValue = body.indexOf('DELETION DATE:') + 'DELETION DATE:'.length();
                system.debug('index value DELETION date-->'+indexValue);
                string getSubstring = body.substring(indexValue).trim();
                system.debug('now index value-->' + getSubstring);
                Integer endIndex = getSubstring.indexOf('*');
                if (endIndex != -1) {
                    getSubstring = getSubstring.substring(0, endIndex).trim();
                }
                
                if (getSubstring != null && getSubstring != '') {
                    List<String> dateParts = getSubstring.split('/');
                    if (dateParts.size() == 3) {
                        Integer month = Integer.valueOf(dateParts[0]);
                        Integer day = Integer.valueOf(dateParts[1]);
                        Integer year = Integer.valueOf(dateParts[2]);
                        
                        try {
                            Date deletionDate = Date.newInstance(year, month, day);
                            dodaacRecords.Deletion_Date__c = deletionDate;
                            system.debug('DELETION date --> ' + deletionDate);
                        } catch (Exception e) {
                            system.debug('Invalid creation date format');
                        }
                    }
                }
            }
            
            
            // Authority code .............................................
            if(body.contains('AUTHORITY CODE:')){
                system.debug('body'+ body);
                Integer IndexValue = body.indexOf('AUTHORITY CODE:') + 'AUTHORITY CODE:'.length();
                system.debug('Index value'+ IndexValue);
                string getsubstring = body.substring(IndexValue).trim();
               string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('CONTRACTOR'));
                dodaacRecords.Authority_Code__c = mainSubstring;
                system.debug('Authority code-->'+ mainSubstring);
            }
            //Maj Command...................
            if(body.contains('MAJ COMMAND:')){
                system.debug('body'+ body);
                Integer IndexValue = body.indexOf('MAJ COMMAND:') + 'MAJ COMMAND:'.length();
                system.debug('Index' +IndexValue);
                string getsubstring = body.substring(IndexValue).trim();
                system.debug('now index value-->'+ getsubstring);
                string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('CONT'));
                dodaacRecords.Major_Command__c = mainSubstring;
                system.debug('Maj command-->' +mainSubstring);
                
            }
            
            // SUB TIER CODE
            if(body.contains('SUB TIER CODE:')){
                system.debug('body'+ body);
                Integer IndexValue = body.indexOf('SUB TIER CODE:') + 'SUB TIER CODE:'.length();
                system.debug('Index' +IndexValue);
                string getsubstring = body.substring(IndexValue).trim();
               string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('CGAC'));
                dodaacRecords.Sub_Tier_Code__c = mainSubstring;
                system.debug('sub tier code -->' +mainSubstring);
            }  
            
            // PROCUREMENT AUTHORITY:
            if(body.contains('PROCUREMENT AUTHORITY:')){
                system.debug('body'+ body);
                Integer IndexValue = body.indexOf('PROCUREMENT AUTHORITY:') + 'PROCUREMENT AUTHORITY:'.length();
                system.debug('Index' +IndexValue);
                string getsubstring = body.substring(IndexValue).trim();
                string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('GRANT'));
                dodaacRecords.Procurement_Authority__c = mainSubstring;
                system.debug('PROCUREMENT AUTHORITY-->' +mainSubstring);
            }
            // GRANT AUTHORITY: 
            if (body.contains('GRANT AUTHORITY:')) {
                system.debug('body' + body);
                Integer indexValue = body.indexOf('GRANT AUTHORITY:') + 'GRANT AUTHORITY:'.length();
                string getSubstring = body.substring(indexValue).trim();
                system.debug('now index value-->' + getSubstring);
                
                Integer endIndex = getSubstring.indexOf('*');
                if (endIndex != -1) {
                    getSubstring = getSubstring.substring(0, endIndex).trim();
                }
                
                if (getSubstring != null && getSubstring != '') {
                  string mainSubstring = getsubstring.substring(0, getsubstring.indexOf(' '));
                    dodaacRecords.Grant_Authority_Number__c = mainSubstring;
                    system.debug('Grant Authority Number  --> ' + mainSubstring);
                }
            }
            //  LAST UPDATE:
            if (body.contains('LAST UPDATE:')) {
                system.debug('body' + body);
                Integer indexValue = body.indexOf('LAST UPDATE:') + 'LAST UPDATE:'.length();
                string getSubstring = body.substring(indexValue).trim();
                system.debug('now index value-->' + getSubstring);
                
                Integer endIndex = getSubstring.indexOf('*');
                if (endIndex != -1) {
                    getSubstring = getSubstring.substring(0, endIndex).trim();
                }
                
                try {
                    List<String> dateParts = getSubstring.split('-');
                    if (dateParts.size() == 3) {
                        Integer day = Integer.valueOf(dateParts[0]);
                        String monthString = dateParts[1];
                        Integer year = Integer.valueOf(dateParts[2]);
                        
                        Map<String, Integer> monthMap = new Map<String, Integer>{
                            'JAN' => 1, 'FEB' => 2, 'MAR' => 3, 'APR' => 4, 'MAY' => 5, 'JUN' => 6,
                                'JUL' => 7, 'AUG' => 8, 'SEP' => 9, 'OCT' => 10, 'NOV' => 11, 'DEC' => 12
                                };
                                    
                                    Integer month;
                        if (monthMap.containsKey(monthString.toUpperCase())) {
                            month = monthMap.get(monthString.toUpperCase());
                            Integer fullYear = (year < 100) ? 2000 + year : year;
                            Date lastUpdateDate = Date.newInstance(fullYear, month, day);
                            String formattedDate = String.valueOf(day) + '-' + monthString.toUpperCase() + '-' + String.valueOf(fullYear);
                            dodaacRecords.Last_Update__c = lastUpdateDate;
                            system.debug('last Update --> ' + formattedDate);
                        } else {
                            system.debug('Invalid month in the date string');
                        }
                    } else {
                        system.debug('Invalid date format');
                    }
                } catch (Exception e) {
                    system.debug('Error occurred while parsing the date');
                }
            }
            // CONTRACTOR:
            if (body.contains('CONTRACTOR:')) {
                system.debug('body' + body);
                Integer indexValue = body.indexOf('CONTRACTOR:') + 'CONTRACTOR:'.length();
                string getSubstring = body.substring(indexValue).trim();
                system.debug('now index value-->' + getSubstring);
                
                Integer endIndex = getSubstring.indexOf('*');
                if (endIndex != -1) {
                    getSubstring = getSubstring.substring(0, endIndex).trim();
                }
                dodaacRecords.Contractor__c = getSubstring;
                system.debug('Contractor  --> ' + getSubstring);
                
            }
            // CONT ADMIN OFF: 
            if (body.contains('CONT ADMIN OFF:')) {
                system.debug('body' + body);
                Integer indexValue = body.indexOf('CONT ADMIN OFF:') + 'CONT ADMIN OFF:'.length();
                string getSubstring = body.substring(indexValue).trim();
                system.debug('now index value-->' + getSubstring);
                
                Integer endIndex = getSubstring.indexOf('*');
                if (endIndex != -1) {
                    getSubstring = getSubstring.substring(0, endIndex).trim();
                }
                dodaacRecords.Cont_Admin_Off__c = getSubstring;
                system.debug('Cont admin off--> ' + getSubstring);
                
            }         
            // CGAC:
            if (body.contains('CGAC:')) {
                system.debug('body' + body);
                Integer indexValue = body.indexOf('CGAC:') + 'CGAC:'.length();
                string getSubstring = body.substring(indexValue).trim();
                system.debug('now index value-->' + getSubstring);
                
                Integer endIndex = getSubstring.indexOf('*');
                if (endIndex != -1) {
                    getSubstring = getSubstring.substring(0, endIndex).trim();
                }
                dodaacRecords.CGAC__c = getSubstring;
                system.debug('CGAC --> ' + getSubstring);
                
            }
            // FUNDING OFFICE:
            if (body.contains('OFFICE:')) {
                system.debug('body funding office ' + body);
                Integer indexValue = body.indexOf('OFFICE:') + 'OFFICE:'.length();
                string getSubstring = body.substring(indexValue).trim();
                system.debug('now index Funding Office  value-->' + getSubstring);
                
                Integer endIndex = getSubstring.indexOf('*');
                if (endIndex != -1) {
                    getSubstring = getSubstring.substring(0, endIndex).trim();
                }
                dodaacRecords.Funding_Office__c = getSubstring;
                system.debug('FUNDING OFFICE --> ' + getSubstring);
                
            }
            //DP:
           if (body.contains('DP:')) {
    System.debug('body: ' + body);
    
    // Find the position of "DP:"
    Integer dpIndex = body.indexOf('DP:');
    
    if (dpIndex != -1) {
        // Find the position of "BILL:" after "DP:"
        Integer billIndex = body.indexOf('BILL:', dpIndex);
        
        // Check if "BILL:" was found after "DP:"
        if (billIndex != -1) {
            // Extract the text between "DP:" and "BILL:"
            String extractedText = body.substring(dpIndex + 'DP:'.length(), billIndex).trim();
            
            // Check if the extracted text contains a link and remove it
            if (extractedText.contains('<')) {
                Integer linkIndex = extractedText.indexOf('<');
                extractedText = extractedText.substring(0, linkIndex).trim();
            }
            
            // Check if the extracted text is not blank
            if (!String.isBlank(extractedText)) {
                dodaacRecords.DP__c = extractedText;
                System.debug('DP: --> ' + extractedText);
            }
        } else {
            // "BILL:" not found after "DP:", so we extract text after "DP:"
            String extractedText = body.substring(dpIndex + 'DP:'.length()).trim();
            
            // Check if the extracted text contains a link and remove it
            if (extractedText.contains('<')) {
                Integer linkIndex = extractedText.indexOf('<');
                extractedText = extractedText.substring(0, linkIndex).trim();
            }
            
            // Check if the extracted text is not blank
            if (!String.isBlank(extractedText)) {
                dodaacRecords.DP__c = extractedText;
                System.debug('DP: --> ' + extractedText);
            }
        }
    }
}



        // BILL
           if (body.contains('BILL:')) {
              System.debug('body: ' + body);
              Integer startIndex = body.indexOf('BILL:') + 'BILL:'.length();
               System.debug('Index: ' + startIndex);

    // Find the position of the first '<' character after "BILL:"
         Integer endIndex = body.indexOf('<', startIndex);
   // Extract the text between "BILL:" and '<' (if found)
        String extractedText = (endIndex != -1) ? body.substring(startIndex, endIndex).trim() : body.substring(startIndex).trim();
   // Set the extracted text to your dodaacRecords.Bill__c
       dodaacRecords.Bill__c = extractedText;

    System.debug('BILL: --> ' + extractedText);
}
            
            //Parsing the data ....................................................
            if(isTac1Owner){
                // EFF DATE
                if (body.contains('EFF DATE:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('EFF DATE:') + 'EFF DATE:'.length();
                    system.debug('index value eff date-->'+indexValue);
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                        List<String> dateParts = getSubstring.split('/');
                        if (dateParts.size() == 3) {
                            Integer month = Integer.valueOf(dateParts[0]);
                            Integer day = Integer.valueOf(dateParts[1]);
                            Integer year = Integer.valueOf(dateParts[2]);
                            
                            try {
                                Date creationDate = Date.newInstance(year, month, day);
                                dodaacRecords.TAC1_Owner_Effective_Date__c = creationDate;
                                system.debug('Tac1(Eff date)--> ' + creationDate);
                            } catch (Exception e) {
                                system.debug('Invalid creation date format');
                            }
                        }
                    }
                }
                
                // Tac1(owner)LINE 1:
                if(body.contains('LINE 1:')){
                    system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('LINE 1:') + 'LINE 1:'.length();
                    system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                   string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('EFF'));
                    dodaacRecords.TAC1_Owner_Line_1__c = mainSubstring;
                    system.debug('Line 1(owner)-->' +mainSubstring);
                }
                //Tac1(owner) LINE 2:
                if(body.contains('LINE 2:')){
                    system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('LINE 2:') + 'LINE 2:'.length();
                    system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                    
                    dodaacRecords.TAC1_Owner_Line_2__c = getsubstring;
                    system.debug('Line 2(owner)-->' +getsubstring);
                }
                // Tac1(owner)LINE 3:
                if(body.contains('LINE 3:')){
                    system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('LINE 3:') + 'LINE 3:'.length();
                    system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                    
                    dodaacRecords.TAC1_Owner_Line_3__c = getsubstring;
                    system.debug('Line 3(owner)-->' +getsubstring);
                }
                // Tac1(owner)LINE 4:
                if(body.contains('LINE 4:')){
                    system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('LINE 4:') + 'LINE 4:'.length();
                    system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                    
                    dodaacRecords.TAC1_Owner_Line_4__c = getsubstring;
                    system.debug('Line 4(Owner)-->' +getsubstring);
                }
                // Tac1(owner)LINE 5:
                if (body.contains('LINE 5:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('LINE 5:') + 'LINE 5:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                       // string mainSubstring = getsubstring.substring(0, getsubstring.indexOf(' '));
                        dodaacRecords.TAC1_Owner_Line_5__c = getSubstring;
                        system.debug('Line 5 --> ' + getSubstring);
                    }
                }
                //Tac1(owner)city..................................
                if(body.contains('CITY:')){
                    system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('CITY:') + 'CITY:'.length();
                    system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                    string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('ZIP'));
                    dodaacRecords.TAC1_Owner_City__c = mainSubstring;
                    system.debug(' TAC1(OWNER)city-->' +mainSubstring);
                } 
                // TAC1(OWNER)STATE/PROVINCE...................................
                if(body.contains('STATE/PROVINCE:')){
                    system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('STATE/PROVINCE:') + 'STATE/PROVINCE:'.length();
                    system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                    string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('STATE(A)/PROVINCE'));
                    dodaacRecords.TAC1_Owner_State_Province__c = mainSubstring;
                    system.debug('TAC1(OWNER)state/PROVINCE-->' +mainSubstring);
                }  
                //  TAC1(Owner) ZIP:
                if (body.contains('ZIP:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('ZIP:') + 'ZIP:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                      string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('IPC'));
                        dodaacRecords.TAC1_Owner_Zip__c = mainSubstring;
                        system.debug(' Tac1(owner)Zip code --> ' + mainSubstring);
                    }
                }
                
                //  TAC1(Owner) IPC:
                if (body.contains('IPC:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('IPC:') + 'IPC:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                        dodaacRecords.TAC1_Owner_Line_5__c = getSubstring;
                        system.debug('Line 5 --> ' + getSubstring);
                    }
                } 
                
                // TAC1(OWNER) STATE(A)/PROVINCE...................................
                if (body.contains('STATE(A)/PROVINCE:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('STATE(A)/PROVINCE:') + 'STATE(A)/PROVINCE:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                        
                        dodaacRecords.TAC1_Owner_State_A_Province__c = getSubstring;
                        system.debug('Tac1(owner) state(A)/Province --> ' + getSubstring);
                    }
                }  
                // TAC1(Owner) COUNTRY NAME:
                if(body.contains('COUNTRY NAME:')){
                    //system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('COUNTRY NAME:') + 'COUNTRY NAME:'.length();
                    //system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                    dodaacRecords.TAC1_Owner_Country_Name__c = getsubstring;
                    system.debug('TAC1(Owner) COUNTRY NAME-->' +getsubstring);
                }  
                //  TAC1(Owner)GENC CC:
                if(body.contains('GENC CC:')){
                    //system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('GENC CC:') + 'GENC CC:'.length();
                    //system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                    dodaacRecords.TAC1_Owner_GENC_CC__c = getsubstring;
                    system.debug('TAC1(Owner)GENC CC-->' +getsubstring);
                }  
                // TAC1(Owner)POC:
                if(body.contains('POC:')){
                    //system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('POC:') + 'POC:'.length();
                    //system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                    dodaacRecords.TAC1_Owner_POC__c = getsubstring;
                    system.debug('TAC1(Owner)POC-->' +getsubstring);
                } 
                //TAC1(OWNER) POC PHONE:
                if(body.contains('POC PHONE:')){
                    //system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('POC PHONE:') + 'POC PHONE:'.length();
                    //system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                    dodaacRecords.TAC1_Owner_POC_Phone__c = getsubstring;
                    system.debug('TAC1(OWNER) POC PHONE-->' +getsubstring);
                } 
            }
            else if(isTac2ShipTo) {
                //Tac2(Ship To).......................................
                if (body.contains('EFF DATE:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('EFF DATE:') + 'EFF DATE:'.length();
                    system.debug('index value eff date-->'+indexValue);
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                        List<String> dateParts = getSubstring.split('/');
                        if (dateParts.size() == 3) {
                            Integer month = Integer.valueOf(dateParts[0]);
                            Integer day = Integer.valueOf(dateParts[1]);
                            Integer year = Integer.valueOf(dateParts[2]);
                            
                            try {
                                Date creationDate = Date.newInstance(year, month, day);
                                dodaacRecords.TAC2_Ship_To_Effective_Date__c = creationDate;
                                system.debug('Tac2 Ship To(Eff date)--> ' + creationDate);
                            } catch (Exception e) {
                                system.debug('Invalid creation date format');
                            }
                        }
                    }
                }
                
                // Tac2(Ship To)LINE 1:
                if(body.contains('LINE 1:')){
                    system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('LINE 1:') + 'LINE 1:'.length();
                    system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                   string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('EFF'));
                    dodaacRecords.TAC2_Ship_To_Line_1__c = mainSubstring;
                    system.debug('Line 1(Ship To)-->' +mainSubstring);
                }
                //Tac2(Ship To) LINE 2:
                if(body.contains('LINE 2:')){
                    system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('LINE 2:') +'LINE 2:'.length();
                    system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                   string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('DEL'));
                    dodaacRecords.TAC2_Ship_To_Line_2__c = mainSubstring;
                    system.debug('Line 2(Ship To)-->' +mainSubstring);
                }
                // Tac2(Ship To)LINE 3:
                if(body.contains('LINE 3:')){
                    system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('LINE 3:') +'LINE 3:'.length();
                    system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                    
                    dodaacRecords.TAC2_Ship_To_Line_3__c = getsubstring;
                    system.debug('Line 3(Ship To)-->' +getsubstring);
                }
                // Tac2(Ship To)LINE 4:
                if(body.contains('LINE 4:')){
                    system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('LINE 4:')+'LINE 4:'.length();
                    system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                    
                    dodaacRecords.TAC2_Ship_To_Line_4__c = getsubstring;
                    system.debug('Line 4(Ship To)-->' +getsubstring);
                }
                // Tac2(Ship To)LINE 5:
                if (body.contains('LINE 5:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('LINE 5:') + 'LINE 5:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                        
                        dodaacRecords.TAC2_Ship_To_Line_5__c = getSubstring;
                        system.debug('Line 5(Tac2)Ship To --> ' + getSubstring);
                    }
                }
                //Tac2(Ship To)city..................................
                if(body.contains('CITY:')){
                    system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('CITY:') + 'CITY:'.length();
                    system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                   string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('ZIP'));
                    dodaacRecords.TAC2_Ship_To_City__c = mainSubstring;
                    system.debug(' TAC2(Ship To)city-->' +mainSubstring);
                } 
                // TAC2(Ship To)STATE/PROVINCE...................................
                if(body.contains('STATE/PROVINCE:')){
                    system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('STATE/PROVINCE:') + 'STATE/PROVINCE:'.length();
                    system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                    string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('STATE(A)/PROVINCE'));
                    dodaacRecords.TAC2_Ship_To_State_Province__c = mainSubstring;
                    system.debug('TAC1(OWNER)state/PROVINCE-->' +mainSubstring);
                }  
                //  TAC2(Ship To) ZIP:
                if (body.contains('ZIP:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('ZIP:') + 'ZIP:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                   Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                       string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('IPC:'));
                        dodaacRecords.TAC2_Ship_To_Zip__c = mainSubstring;
                        system.debug(' Tac2(Ship To)Zip code --> ' + mainSubstring);
                    }
                } 
                
                //  TAC2(Ship To) IPC:
                if (body.contains('IPC:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('IPC:') + 'IPC:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                        
                        dodaacRecords.TAC2_Ship_To_IPC__c = getSubstring;
                        system.debug('(Tac2)Ship To  IPC --> ' + getSubstring);
                    }
                } 
                
                // TAC2(Ship To) STATE(A)/PROVINCE...................................
                if (body.contains('STATE(A)/PROVINCE:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('STATE(A)/PROVINCE:') + 'STATE(A)/PROVINCE:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                        
                        dodaacRecords.TAC2_Ship_To_State_A_Province__c = getSubstring;
                        system.debug('Tac2(Ship To) state(A)/Province --> ' + getSubstring);
                    }
                }  
                // TAC2(Ship To) COUNTRY NAME:
                if(body.contains('COUNTRY NAME:')){
                    //system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('COUNTRY NAME:') + 'COUNTRY NAME:'.length();
                    //system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                    dodaacRecords.TAC2_Ship_To_Country_Name__c = getsubstring;
                    system.debug('TAC2(Ship To) COUNTRY NAME-->' +getsubstring);
                }  
                //  TAC2(Ship To)GENC CC:
                if(body.contains('GENC CC:')){
                    //system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('GENC CC:') + 'GENC CC:'.length();
                    //system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                    dodaacRecords.TAC2_Ship_To_GENC_CC__c = getsubstring;
                    system.debug('TAC2(Ship To)GENC CC-->' +getsubstring);
                }
                // COCOM:-----------------------------
                if (body.contains('COCOM:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('COCOM:') + 'COCOM:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                       string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('CCP:'));
                        dodaacRecords.COCOM__c = mainSubstring;
                        system.debug('Tac2(Ship To) COCOM --> ' + mainSubstring);
                    }
                } 
                 // COCOM:-----------------------------
                if (body.contains('CCP:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('CCP:') + 'CCP:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                      // string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('CCP:'));
                       dodaacRecords.CCP__c = getSubstring;
                        system.debug('Tac2(Ship To) CCP--> ' + getSubstring);
                    }
                } 
                //BBP:
                if (body.contains('BBP:')) {
    System.debug('body: ' + body);
    Integer indexValue = body.indexOf('BBP:') + 'BBP:'.length();
    String getSubstring = body.substring(indexValue).trim();
    System.debug('now index value of BBP--> ' + getSubstring);
    
    // Check if '<' exists in getSubstring
    if (getSubstring.contains('<')) {
        String mainSubstring = getSubstring.substring(0, getSubstring.indexOf('<'));
        dodaacRecords.BBP__c = mainSubstring;
        System.debug('Tac2(Ship To) BBP--> ' + mainSubstring);
    } else {
        dodaacRecords.BBP__c = getSubstring;
        System.debug('Tac2(Ship To) BBP--> ' + getSubstring);
    }
}

                //CONUS/OCONUS:
                if (body.contains('CONUS/OCONUS:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('CONUS/OCONUS:') + 'CONUS/OCONUS:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                       string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('WPOD:'));
                        dodaacRecords.CONUS_OCONUS__c = mainSubstring;
                        system.debug('Tac2(Ship To) CONUS/OCONUS:--> ' + mainSubstring);
                    }
                } 
                //SPLC:
                if (body.contains('SPLC:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('SPLC:') + 'SPLC:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                   Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                       getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                       string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('BBP:'));
                        dodaacRecords.SPLC__c = mainSubstring;
                        system.debug('Tac2(Ship To) SPLC:--> ' + mainSubstring);
                   }
                } 
                //ALOC:
                if (body.contains('ALOC:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('ALOC:') + 'ALOC:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                       // string mainSubstring = getsubstring.substring(0, getsubstring.indexOf(' '));
                        dodaacRecords.ALOC__c = getSubstring;
                        system.debug('Tac2(Ship To) ALOC:--> ' + getSubstring);
                    }
                }
                //WPOD:
                if (body.contains('WPOD:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('WPOD:') + 'WPOD:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                       string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('APOD'));
                        dodaacRecords.WPOD__c = mainSubstring;
                        system.debug('Tac2(Ship To) WPOD:--> ' + mainSubstring);
                    }
                }
                //APOD:
                
                if (body.contains('APOD:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('APOD:') + 'APOD:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                  //  Integer endIndex = getSubstring.indexOf('*');
                    //if (endIndex != -1) {
                   //     getSubstring = getSubstring.substring(0, endIndex).trim();
                    //}
                    
                   // if (getSubstring != null && getSubstring != '') {
                       // string mainSubstring = getsubstring.substring(0, getsubstring.indexOf(' '));
                        dodaacRecords.APOD__c = getSubstring;
                        system.debug('Tac2(Ship To) APOD:--> ' + getSubstring);
                   // }
                }
                
                
                // Tac2(Ship To)DEL DATE: 
               if (body.contains('DEL DATE:')) {
                system.debug('body' + body);
                Integer indexValue = body.indexOf('DEL DATE:') + 'DEL DATE:'.length();
                system.debug('index value DELETION date-->'+indexValue);
                string getSubstring = body.substring(indexValue).trim();
                system.debug('now index value-->' + getSubstring);
                Integer endIndex = getSubstring.indexOf('*');
                if (endIndex != -1) {
                    getSubstring = getSubstring.substring(0, endIndex).trim();
                }
                
                if (getSubstring != null && getSubstring != '') {
                    List<String> dateParts = getSubstring.split('/');
                    if (dateParts.size() == 3) {
                        Integer month = Integer.valueOf(dateParts[0]);
                        Integer day = Integer.valueOf(dateParts[1]);
                        Integer year = Integer.valueOf(dateParts[2]);
                        
                        try {
                            Date creationDate = Date.newInstance(year, month, day);
                            dodaacRecords.TAC2_Ship_To_Date_Deleted__c = creationDate;
                            system.debug('DELETION date --> ' + creationDate);
                        } catch (Exception e) {
                            system.debug('Invalid creation date format');
                        }
                    }
                }
            }
                // TAC2(Ship To)POC:
                if(body.contains('POC:')){
                    //system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('POC:')+ 'POC:'.length();
                    //system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                    dodaacRecords.TAC2_Ship_To_POC__c = getsubstring;
                    system.debug('TAC2(Ship To)POC-->' +getsubstring);
                } 
                //TAC2(Ship To) POC PHONE:
                if(body.contains('POC PHONE:')){
                    //system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('POC PHONE:') + 'POC PHONE:'.length();
                    //system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                    dodaacRecords.TAC2_Ship_To_POC_Phone__c = getsubstring;
                    system.debug('TAC2(Ship To) POC PHONE-->' +getsubstring);
                } 
                
                
            }
            else if(isTac3Billing){
                //Tac3(Billing) EFF Date.......................................
                if (body.contains('EFF DATE:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('EFF DATE:') + 'EFF DATE:'.length();
                    system.debug('index value eff date-->'+indexValue);
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                        List<String> dateParts = getSubstring.split('/');
                        if (dateParts.size() == 3) {
                            Integer month = Integer.valueOf(dateParts[0]);
                            Integer day = Integer.valueOf(dateParts[1]);
                            Integer year = Integer.valueOf(dateParts[2]);
                            
                            try {
                                Date creationDate = Date.newInstance(year, month, day);
                                dodaacRecords.TAC3_Billing_Effective_Date__c = creationDate;
                                system.debug('Tac3 Billing(Eff date)--> ' + creationDate);
                            } catch (Exception e) {
                                system.debug('Invalid creation date format');
                            }
                        }
                    }
                }
                // Tac3(Billing)LINE 1:
               if (body.contains('LINE 1:')) {
    system.debug('body' + body);
    Integer indexValue = body.indexOf('LINE 1:') + 'LINE 1:'.length();
    system.debug('Index' + indexValue);

    string getSubstring = body.substring(indexValue).trim();

    // Check if 'EFF' is present in the substring
    Integer endIndex = getSubstring.indexOf('EFF');
    if (endIndex != -1) {
        string mainSubstring = getSubstring.substring(0, endIndex);
        dodaacRecords.TAC3_Billing_Line_1__c = mainSubstring;
        system.debug('Line 1(Ship To) --> ' + mainSubstring);
    } else {
        integer s1= emailBody.lastindexof('LINE 1:');
                  integer s2= emailBody.lastindexof('EFF');
 
                        system.debug('  emailBody' +  emailBody.lastindexof('LINE 1:'));
                        system.debug('  emailBody' +  emailBody.lastindexof('EFF'));
                String result2 = emailBody.substring(s1 + 'LINE 1:'.length(), s2).trim();
      dodaacRecords.TAC3_Billing_Line_1__c = result2;
                        system.debug('result2'+result2);
    }
}

                //Tac3(Billing) LINE 2:
                if(body.contains('LINE 2:')){
                    system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('LINE 2:') + 'LINE 2:'.length();
                    system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                    string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('DEL'));
                    dodaacRecords.TAC3_Billing_Line_2__c= mainSubstring;
                    system.debug('Tac3(Billing) LINE 2-->' +mainSubstring);
                }
                // Tac3(Billing)LINE 3:
                if(body.contains('LINE 3:')){
                    system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('LINE 3:') + 'LINE 3:'.length();
                    system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                    string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('ADSN/FSN'));
                    dodaacRecords.TAC3_Billing_Line_3__c = mainSubstring;
                    system.debug('Tac3(Billing)LINE 3-->' +mainSubstring);
                }
                // Tac3(Billing)LINE 4:
                if(body.contains('LINE 4:')){
                    system.debug('body'+ body);
                    Integer IndexValue = body.indexOf('LINE 4:') + 'LINE 4:'.length();
                    system.debug('Index' +IndexValue);
                    string getsubstring = body.substring(IndexValue).trim();
                    
                    dodaacRecords.TAC3_Billing_Line_4__c = getsubstring;
                    system.debug('Tac3(Billing)LINE 4:-->' +getsubstring);
                }
                // Tac3(Billing)LINE 5:
                if (body.contains('LINE 5:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('LINE 5:') + 'LINE 5:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                        
                        dodaacRecords.TAC3_Billing_Line_5__c = getSubstring;
                        system.debug('Tac3(Billing)LINE 5 --> ' + getSubstring);
                    }
                    
                }
                //DEl Date
                if (body.contains('DEL DATE:')) {
                system.debug('body' + body);
                Integer indexValue = body.indexOf('DEL DATE:') + 'DEL DATE:'.length();
                system.debug('index value DELETION date-->'+indexValue);
                string getSubstring = body.substring(indexValue).trim();
                system.debug('now index value-->' + getSubstring);
                Integer endIndex = getSubstring.indexOf('*');
                if (endIndex != -1) {
                    getSubstring = getSubstring.substring(0, endIndex).trim();
                }
                
                if (getSubstring != null && getSubstring != '') {
                    List<String> dateParts = getSubstring.split('/');
                    if (dateParts.size() == 3) {
                        Integer month = Integer.valueOf(dateParts[0]);
                        Integer day = Integer.valueOf(dateParts[1]);
                        Integer year = Integer.valueOf(dateParts[2]);
                        
                        try {
                            Date creationDate = Date.newInstance(year, month, day);
                            dodaacRecords.TAC3_Billing_Date_Deleted__c = creationDate;
                            system.debug('DELETION date --> ' + creationDate);
                        } catch (Exception e) {
                            system.debug('Invalid creation date format');
                        }
                    }
                }
            }
                //CITY:
                if (body.contains('CITY:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('CITY:') + 'CITY:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                       string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('ZIP:'));
                        dodaacRecords.TAC3_Billing_City__c = mainSubstring;
                        system.debug('Tac3(Billing)CITY:--> ' + mainSubstring);
                    }
                }
                //STATE/PROVINCE:
                if (body.contains('STATE/PROVINCE:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('STATE/PROVINCE:') + 'STATE/PROVINCE:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                   if (endIndex != -1) {
                    getSubstring = getSubstring.substring(0, endIndex).trim();
                   }
                    
                    if (getSubstring != null && getSubstring != '') {
                       string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('STATE(A)/PROVINCE:'));
                        dodaacRecords.TAC3_Billing_State_Province__c = mainSubstring;
                        system.debug('Tac3(Billing)STATE/PROVINCE:--> ' + mainSubstring);
                    }
                }
                //COUNTRY NAME:
                if (body.contains('COUNTRY NAME:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('COUNTRY NAME:') + 'COUNTRY NAME:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                        
                        dodaacRecords.TAC3_Billing_Country_Name__c = getSubstring;
                        system.debug('Tac3(Billing)COUNTRY NAME:--> ' + getSubstring);
                    }
                }            
                //GENC CC:
                if (body.contains('GENC CC:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('GENC CC:') + 'GENC CC:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                        
                        dodaacRecords.TAC3_Billing_GENC_CC__c = getSubstring;
                        system.debug('Tac3(Billing)GENC CC:--> ' + getSubstring);
                    }
                } 
                //Zip :..........................
                if (body.contains('ZIP:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('ZIP:') + 'ZIP:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                   Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                       getSubstring = getSubstring.substring(0, endIndex).trim();
                   }
                    
                   if (getSubstring != null && getSubstring != '') {
                       string mainSubstring = getsubstring.substring(0, getsubstring.indexOf('IPC:'));
                        dodaacRecords.TAC3_Billing_Zip__c = mainSubstring;
                        system.debug('Tac3(Billing)	ZIP:--> ' + mainSubstring);
                    }
                }
                //IPC:..........................
                if (body.contains('IPC:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('IPC:') + 'IPC:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                        
                        dodaacRecords.TAC3_Billing_IPC__c = getSubstring;
                        system.debug('Tac3(Billing)	IPC:--> ' + getSubstring);
                    }
                }
                //ADSN/FSN:..........................
                if (body.contains('ADSN/FSN:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('ADSN/FSN:') + 'ADSN/FSN:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                        
                        dodaacRecords.ADSN_FSN__c = getSubstring;
                        system.debug('Tac3(Billing)	ADSN/FSN:--> ' + getSubstring);
                    }
                }
                
                //STATE(A)/PROVINCE:..........................
                if (body.contains('STATE(A)/PROVINCE:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('STATE(A)/PROVINCE:') + 'STATE(A)/PROVINCE:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                        
                        dodaacRecords.TAC3_Billing_State_A_Province__c = getSubstring;
                        system.debug('Tac3(Billing)	STATE(A)/PROVINCE:--> ' + getSubstring);
                    }
                }
                //POC:
                if (body.contains('POC:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('POC:') + 'POC:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                        
                        dodaacRecords.TAC3_Billing_POC__c = getSubstring;
                        system.debug('Tac3(Billing)POC:--> ' + getSubstring);
                    }
                }
                // POC PHONE:	
                if (body.contains('POC PHONE:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('POC PHONE:') + 'POC PHONE:'.length();
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                        
                        dodaacRecords.TAC3_Billing_POC_Phone__c = getSubstring;
                        system.debug('Tac3(Billing)POC PHONE:--> ' + getSubstring);
                    }
                }
                
            }
            // CSP INFORMATION .................................................................................................
            // AGENCY/SERVICE COORDINATOR:
            if (body.contains('AGENCY/SERVICE COORDINATOR:')) {
                system.debug('body' + body);
                Integer indexValue = body.indexOf('AGENCY/SERVICE COORDINATOR:') + 'AGENCY/SERVICE COORDINATOR:'.length();
                string getSubstring = body.substring(indexValue).trim();
                system.debug('now index value-->' + getSubstring);
                
                Integer endIndex = getSubstring.indexOf('*');
                if (endIndex != -1) {
                    getSubstring = getSubstring.substring(0, endIndex).trim();
                }
                
                if (getSubstring != null && getSubstring != '') {
                    
                    dodaacRecords.Agency_Service_Coordinator__c = getSubstring;
                    system.debug('Agency service coordinator --> ' + getSubstring);
                }
            }  
            //Phone:
            if (body.contains('PHONE:')) {
                system.debug('body' + body);
                Integer indexValue = body.indexOf('PHONE:') + 'PHONE:'.length();
                string getSubstring = body.substring(indexValue).trim();
                system.debug('now index value-->' + getSubstring);
                
                Integer endIndex = getSubstring.indexOf('*');
                if (endIndex != -1) {
                    getSubstring = getSubstring.substring(0, endIndex).trim();
                }
                
                if (getSubstring != null && getSubstring != '') {
                    
                    dodaacRecords.Phone__c = getSubstring;
                    system.debug('Phone --> ' + getSubstring);
                }
            } 
            // CONTRACT INFORMATION
            //CONTRACT NUMBER: 
            if (body.contains('CONTRACT NUMBER:')) {
                system.debug('body' + body);
                Integer indexValue = body.indexOf('CONTRACT NUMBER:') + 'CONTRACT NUMBER:'.length();
                string getSubstring = body.substring(indexValue).trim();
                system.debug('now index value-->' + getSubstring);
                
                Integer endIndex = getSubstring.indexOf('*');
                if (endIndex != -1) {
                    getSubstring = getSubstring.substring(0, endIndex).trim();
                }
                
                if (getSubstring != null && getSubstring != '') {
                    
                    dodaacRecords.Contract_Number__c = getSubstring;
                    system.debug('Contract Number --> ' + getSubstring);
                }
            }
            //CAGE CODE: 
            if (body.contains('CAGE CODE:')) {
                system.debug('body' + body);
                Integer indexValue = body.indexOf('CAGE CODE:') + 'CAGE CODE:'.length();
                string getSubstring = body.substring(indexValue).trim();
                system.debug('now index value-->' + getSubstring);
                
                Integer endIndex = getSubstring.indexOf('*');
                if (endIndex != -1) {
                    getSubstring = getSubstring.substring(0, endIndex).trim();
                }
                
                if (getSubstring != null && getSubstring != '') {
                    
                    dodaacRecords.Cage_Code__c = getSubstring;
                    system.debug('Cage Code  --> ' + getSubstring);
                }
            }
            
            //CAGE CODE NAME:
            if (body.contains('CAGE CODE NAME:')) {
                system.debug('body' + body);
                Integer indexValue = body.indexOf('CAGE CODE NAME:') + 'CAGE CODE NAME:'.length();
                string getSubstring = body.substring(indexValue).trim();
                system.debug('now index value-->' + getSubstring);
                
                Integer endIndex = getSubstring.indexOf('*');
                if (endIndex != -1) {
                    getSubstring = getSubstring.substring(0, endIndex).trim();
                }
                
                if (getSubstring != null && getSubstring != '') {
                    
                    dodaacRecords.Cage_Code_Name__c = getSubstring;
                    system.debug('CAGE CODE NAME:--> ' + getSubstring);
                }
            }  
            //ORDER NUMBER:
            if (body.contains('ORDER NUMBER:')) {
                system.debug('body' + body);
                Integer indexValue = body.indexOf('ORDER NUMBER:') + 'ORDER NUMBER:'.length();
                string getSubstring = body.substring(indexValue).trim();
                system.debug('now index value-->' + getSubstring);
                
                Integer endIndex = getSubstring.indexOf('*');
                if (endIndex != -1) {
                    getSubstring = getSubstring.substring(0, endIndex).trim();
                }
                
                if (getSubstring != null && getSubstring != '') {
                    
                    dodaacRecords.Order_Number__c = getSubstring;
                    system.debug('ORDER NUMBER:--> ' + getSubstring);
                }
            }             
            //ISSUING OFFICE DODAAC:
            if (body.contains('ISSUING OFFICE DODAAC:')) {
                system.debug('body' + body);
                Integer indexValue = body.indexOf('ISSUING OFFICE DODAAC:') + 'ISSUING OFFICE DODAAC:'.length();
                string getSubstring = body.substring(indexValue).trim();
                system.debug('now index value-->' + getSubstring);
                
                Integer endIndex = getSubstring.indexOf('*');
                if (endIndex != -1) {
                    getSubstring = getSubstring.substring(0, endIndex).trim();
                }
                
                if (getSubstring != null && getSubstring != '') {
                    
                    dodaacRecords.Issuing_Office_Dodaac__c = getSubstring;
                    system.debug('ISSUING OFFICE DODAAC:--> ' + getSubstring);
                }
            }
            //  LAST UPDATE:
            if (body.contains('POP END DATE:')) {
                system.debug('body' + body);
                Integer indexValue = body.indexOf('POP END DATE:') + 'POP END DATE:'.length();
                string getSubstring = body.substring(indexValue).trim();
                system.debug('now index value-->' + getSubstring);
                
                Integer endIndex = getSubstring.indexOf('*');
                if (endIndex != -1) {
                    getSubstring = getSubstring.substring(0, endIndex).trim();
                }
                
                try {
                    List<String> dateParts = getSubstring.split('-');
                    if (dateParts.size() == 3) {
                        Integer day = Integer.valueOf(dateParts[0]);
                        String monthString = dateParts[1];
                        Integer year = Integer.valueOf(dateParts[2]);
                        
                        Map<String, Integer> monthMap = new Map<String, Integer>{
                            'JAN' => 1, 'FEB' => 2, 'MAR' => 3, 'APR' => 4, 'MAY' => 5, 'JUN' => 6,
                                'JUL' => 7, 'AUG' => 8, 'SEP' => 9, 'OCT' => 10, 'NOV' => 11, 'DEC' => 12
                                };
                                    
                                    Integer month;
                        if (monthMap.containsKey(monthString.toUpperCase())) {
                            month = monthMap.get(monthString.toUpperCase());
                            Integer fullYear = (year < 100) ? 2000 + year : year;
                            Date lastUpdateDate = Date.newInstance(fullYear, month, day);
                            String formattedDate = String.valueOf(day) + '-' + monthString.toUpperCase() + '-' + String.valueOf(fullYear);
                            dodaacRecords.Pop_End_Date__c = lastUpdateDate;
                            system.debug('Pop End Date --> ' + formattedDate);
                        } else {
                            system.debug('Invalid month in the date string');
                        }
                    } else {
                        system.debug('Invalid date format');
                    }
                } catch (Exception e) {
                    system.debug('Error occurred while parsing the date');
                }
            }
            //Created by :-
          //  dodaacRecords.CreatedById = '0056w000000Zeo2AAC';
            // CLOSEOUT DATE:
                if (body.contains('CLOSEOUT DATE:')) {
                    system.debug('body' + body);
                    Integer indexValue = body.indexOf('CLOSEOUT DATE:') + 'CLOSEOUT DATE:'.length();
                    system.debug('index value eff date-->'+indexValue);
                    string getSubstring = body.substring(indexValue).trim();
                    system.debug('now index value-->' + getSubstring);
                    Integer endIndex = getSubstring.indexOf('*');
                    if (endIndex != -1) {
                        getSubstring = getSubstring.substring(0, endIndex).trim();
                    }
                    
                    if (getSubstring != null && getSubstring != '') {
                        List<String> dateParts = getSubstring.split('/');
                        if (dateParts.size() == 3) {
                            Integer month = Integer.valueOf(dateParts[0]);
                            Integer day = Integer.valueOf(dateParts[1]);
                            Integer year = Integer.valueOf(dateParts[2]);
                            
                            try {
                                Date creationDate = Date.newInstance(year, month, day);
                                dodaacRecords.Closeout_Date__c = creationDate;
                                system.debug('CloseOut Date--> ' + creationDate);
                            } catch (Exception e) {
                                system.debug('Invalid creation date format');
                            }
                        }
                    }
                }
            
            }
        if(ExistingDodaacNumberMap.containsKey(dodaacRecords.Name)) { 
            updateDodaac.add(dodaacRecords);
            
            }
            else if(!ExistingDodaacNumberMap.containsKey(dodaacRecords.Name)){
            insertDodaac.add(dodaacRecords);
        }
         system.debug('updateDodaac' + updateDodaac);   
        if(updateDodaac != null){
            update updateDodaac;
        }
        if(insertDodaac != null){
            insert insertDodaac;
            // system.debug('DodaacList'+dodaacRecords);
        }
       
        
        
        
        
        
        result.success = true;
        return result;
        
        
    }
    
    
}