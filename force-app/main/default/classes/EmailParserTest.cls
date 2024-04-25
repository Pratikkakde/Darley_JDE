@isTest
public class EmailParserTest {
    @isTest
    public static void testEmailParser(){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.plainTextBody =  'DODAAC INFORMATION\n' +
                   '\nDoDAAC: 965118         UIC: test*             CREATION DATE: 02/23/1979\n' +
                   'DODAAD SERVICE/AGENCY: Civil Corps of Engineers\n' +
                   'ORGANIZATION TYPE CODE: Federal Agencies      DELETION DATE:\n' +
                   'AUTHORITY CODE: 00 - Requisitioner      CONTRACTOR:  No\n' +
                   'MAJ COMMAND:         CONT ADMIN OFF: No\n' +
                   '               LAST UPDATE:  08-AUG-22\n' +
                   'SUB TIER CODE:         CGAC:\n' +
                   'PROCUREMENT AUTHORITY:  No                GRANT AUTHORITY:  No      FUNDING OFFICE:  No\n' +
                   '\nCOMMRI(s) INFORMATION\n' +
                   '\nDP: RUTTTTT  BILL: RUQAYBR\n' +
                   '\nNote: RI(s) RUMMMMM, RUTTTTT, RURRRRR, RESERVE, RDELETE - for DAAS Use Only\n' +
                   '\nTAC1 (OWNER)\n' +
                   '\nLINE 1: ARMY CORPS OF ENGINEERS CIVIL WORKS  EFF DATE: 06/17/2011\n' +
                   'LINE 2: REND LAKE PROJECT OFFICE\n' +
                   'LINE 3: 11981 REND CITY ROAD\n' +
                   'LINE 4: BENTON IL 62812\n' +
                   'LINE 5:\n' +
                   'CITY: BENTON ZIP: 62812    IPC:\n' +
                   'STATE/PROVINCE: Illinois  STATE(A)/PROVINCE: IL\n' +
                   'COUNTRY NAME: UNITED STATES\n' +
                   'GENC CC: US/USA\n' +
                   '\nPOC:\n' +
                   'POC PHONE:\n' +
                   '\nTAC2 (SHIP TO)\n' +
                   '\nLINE 1:     EFF DATE:      \n' +
                   'LINE 2:     DEL DATE:   \n' +
                   'LINE 3:   \n' +
                   'LINE 4:   \n' +
                   'LINE 5:   \n' +
                   'CITY:     ZIP:     IPC: \n' +
                   'STATE/PROVINCE:        STATE(A)/PROVINCE:  \n' +
                   'COUNTRY NAME:  \n' +
                   'GENC CC:  \n' +
                   'COCOM: USNORTHCOM  CCP:   \n' +
                   'SPLC: 398130000  BBP:   \n' +
                   'ALOC:     \n' +
                   'CONUS/OCONUS: C WPOD: APOD:  \n' +
                   '\nPOC:\n' +
                   'POC PHONE:\n' +
                   '\nTAC3 (BILLING)\n' +
                   '\nLINE 1: USACE FINANCE CTR 40042  EFF DATE: 05/13/2009\n' +
                   'LINE 2: 5722 INTEGRITY DRIVE DEL DATE:   \n' +
                   'LINE 3: MILLINGTON TN 38054-5005  ADSN/FSN:   \n' +
                   'LINE 4:   \n' +
                   'LINE 5:   \n' +
                   'CITY: MILLINGTON ZIP: 38054-5005    IPC: \n' +
                   'STATE/PROVINCE: Tennessee  STATE(A)/PROVINCE: TN\n' +
                   'COUNTRY NAME: UNITED STATES\n' +
                   'GENC CC: US/USA\n' +
                   '\nPOC:\n' +
                   'POC PHONE:\n' +
                   '\nCONTRACT INFORMATION\n' +
                   'Note: If multiple contracts are authorized use of this DoDAAC, only the longest running contract is recorded and displayed.\n' +
                   '\nCONTRACT NUMBER:\n' +
                   'CAGE CODE:\n' +
                   'CAGE CODE NAME:\n' +
                   'ORDER NUMBER:\n' +
                   'ISSUING OFFICE DODAAC:\n' +
                   'POP END DATE:\n' +
                   'CLOSEOUT DATE:\n' +
                   '\nCSP INFORMATION\n' +
                   'AGENCY/SERVICE COORDINATOR: FEDERAL AGENCIES\n' +
                   'PHONE:';

// Now you can use the 'emailBody' string to send your email in plain text.

            
        Messaging.InboundEnvelope envelope = new messaging.InboundEnvelope();
        
        EmailParser epIns = new EmailParser();
        Messaging.InboundEmailResult result = epIns.handleInboundEmail(email,envelope);
        
        
    }

}