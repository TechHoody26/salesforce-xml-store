public class PermissionSetExample {
    
    /**
     * Example method showing how to parse and store the HR Administration permission set
     */
    public static void processHrAdministrationPermissionSet() {
        // Your permission set XML data
        String hrAdminXml = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">' +
                '<description>Grants all rights needed for an HR administrator to manage employees.</description>' +
                '<label>HR Administration</label>' +
                '<userLicense>Salesforce</userLicense>' +
                '<applicationVisibilities>' +
                    '<application>JobApps__Recruiting</application>' +
                    '<visible>true</visible>' +
                '</applicationVisibilities>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>ApiEnabled</name>' +
                '</userPermissions>' +
                '<objectPermissions>' +
                    '<allowCreate>true</allowCreate>' +
                    '<allowDelete>true</allowDelete>' +
                    '<allowEdit>true</allowEdit>' +
                    '<allowRead>true</allowRead>' +
                    '<viewAllRecords>true</viewAllRecords>' +
                    '<modifyAllRecords>true</modifyAllRecords>' +
                    '<viewAllFields>true</viewAllFields>' +
                    '<object>Job_Request__c</object>' +
                '</objectPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Job_Request__c.Salary__c</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<pageAccesses>' +
                    '<apexPage>Job_Request_Web_Form</apexPage>' +
                    '<enabled>true</enabled>' +
                '</pageAccesses>' +
                '<classAccesses>' +
                    '<apexClass>Send_Email_Confirmation</apexClass>' +
                    '<enabled>true</enabled>' +
                '</classAccesses>' +
                '<tabSettings>' +
                    '<tab>Job_Request__c</tab>' +
                    '<visibility>Available</visibility>' +
                '</tabSettings>' +
                '<recordTypeVisibilities>' +
                    '<recordType>Recruiting.DevManager</recordType>' +
                    '<visible>true</visible>' +
                '</recordTypeVisibilities>' +
            '</PermissionSet>';
        
        try {
            // Step 1: Create the custom objects and fields (run once)
            System.debug('Creating permission set objects...');
            PermissionSetMetadataManager.createPermissionSetObjects();
            
            // Step 2: Parse and store the permission set data
            System.debug('Parsing and storing HR Administration permission set...');
            PermissionSetDataManager.parseAndStorePermissionSet(hrAdminXml, 'HR_Administration');
            
            System.debug('Successfully processed HR Administration permission set');
            
        } catch (Exception e) {
            System.debug('Error processing permission set: ' + e.getMessage());
            throw new PermissionSetExampleException('Failed to process permission set: ' + e.getMessage());
        }
    }
    
    /**
     * Example method showing how to process multiple permission sets
     */
    public static void processMultiplePermissionSets() {
        // Example of processing multiple permission sets
        List<String> permissionSetNames = new List<String>{
            'HR_Administration',
            'Sales_Manager',
            'System_Administrator'
        };
        
        for (String permissionSetName : permissionSetNames) {
            try {
                // In a real scenario, you would retrieve the XML for each permission set
                // from your org or external source
                String permissionSetXml = getPermissionSetXml(permissionSetName);
                
                if (permissionSetXml != null) {
                    PermissionSetDataManager.parseAndStorePermissionSet(permissionSetXml, permissionSetName);
                    System.debug('Successfully processed permission set: ' + permissionSetName);
                }
                
            } catch (Exception e) {
                System.debug('Error processing permission set ' + permissionSetName + ': ' + e.getMessage());
            }
        }
    }
    
    /**
     * Example method showing how to retrieve and display stored permission set data
     */
    public static void displayStoredPermissionSetData(String permissionSetName) {
        // This would query the custom objects to retrieve stored data
        // For demonstration, we'll show the structure
        
        System.debug('=== Permission Set Data for: ' + permissionSetName + ' ===');
        
        // In a real implementation, you would query the custom objects:
        // SELECT Id, Name, Description__c, Label__c, User_License__c 
        // FROM Permission_Set_Admin__c 
        // WHERE Name = :permissionSetName
        
        // SELECT Id, Permission_Set_Name__c, Application__c, Visible__c 
        // FROM Application_Visibility__c 
        // WHERE Permission_Set_Name__r.Name = :permissionSetName
        
        // SELECT Id, Permission_Set_Name__c, Permission_Name__c, Enabled__c 
        // FROM User_Permission__c 
        // WHERE Permission_Set_Name__r.Name = :permissionSetName
        
        // And so on for other permission types...
        
        System.debug('Permission set data structure created successfully');
    }
    
    /**
     * Helper method to get permission set XML (placeholder)
     */
    private static String getPermissionSetXml(String permissionSetName) {
        // In a real implementation, this would retrieve the XML from your org
        // or external source based on the permission set name
        
        if (permissionSetName == 'HR_Administration') {
            return '<?xml version="1.0" encoding="UTF-8"?>' +
                '<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">' +
                    '<description>Grants all rights needed for an HR administrator to manage employees.</description>' +
                    '<label>HR Administration</label>' +
                    '<userLicense>Salesforce</userLicense>' +
                    '<applicationVisibilities>' +
                        '<application>JobApps__Recruiting</application>' +
                        '<visible>true</visible>' +
                    '</applicationVisibilities>' +
                    '<userPermissions>' +
                        '<enabled>true</enabled>' +
                        '<name>ApiEnabled</name>' +
                    '</userPermissions>' +
                    '<objectPermissions>' +
                        '<allowCreate>true</allowCreate>' +
                        '<allowDelete>true</allowDelete>' +
                        '<allowEdit>true</allowEdit>' +
                        '<allowRead>true</allowRead>' +
                        '<viewAllRecords>true</viewAllRecords>' +
                        '<modifyAllRecords>true</modifyAllRecords>' +
                        '<viewAllFields>true</viewAllFields>' +
                        '<object>Job_Request__c</object>' +
                    '</objectPermissions>' +
                    '<fieldPermissions>' +
                        '<editable>true</editable>' +
                        '<field>Job_Request__c.Salary__c</field>' +
                        '<readable>true</readable>' +
                    '</fieldPermissions>' +
                    '<pageAccesses>' +
                        '<apexPage>Job_Request_Web_Form</apexPage>' +
                        '<enabled>true</enabled>' +
                    '</pageAccesses>' +
                    '<classAccesses>' +
                        '<apexClass>Send_Email_Confirmation</apexClass>' +
                        '<enabled>true</enabled>' +
                    '</classAccesses>' +
                    '<tabSettings>' +
                        '<tab>Job_Request__c</tab>' +
                        '<visibility>Available</visibility>' +
                    '</tabSettings>' +
                    '<recordTypeVisibilities>' +
                        '<recordType>Recruiting.DevManager</recordType>' +
                        '<visible>true</visible>' +
                    '</recordTypeVisibilities>' +
                '</PermissionSet>';
        }
        
        return null;
    }
    
    /**
     * Example method showing how to create a summary report of permission sets
     */
    public static void generatePermissionSetSummary() {
        System.debug('=== Permission Set Summary Report ===');
        
        // This would query all stored permission set data and generate a summary
        // For demonstration, we'll show the structure
        
        System.debug('1. Main Permission Set Object (Permission_Set_Admin__c)');
        System.debug('   - Stores basic permission set information');
        System.debug('   - Fields: Name, Description__c, Label__c, User_License__c');
        
        System.debug('2. Application Visibility Object (Application_Visibility__c)');
        System.debug('   - Stores application visibility settings');
        System.debug('   - Fields: Permission_Set_Name__c (Lookup), Application__c, Visible__c');
        
        System.debug('3. User Permission Object (User_Permission__c)');
        System.debug('   - Stores user permission settings');
        System.debug('   - Fields: Permission_Set_Name__c (Lookup), Permission_Name__c, Enabled__c');
        
        System.debug('4. Object Permission Object (Object_Permission__c)');
        System.debug('   - Stores object-level permissions');
        System.debug('   - Fields: Permission_Set_Name__c (Lookup), Object_Name__c, Allow_Create__c, etc.');
        
        System.debug('5. Field Permission Object (Field_Permission__c)');
        System.debug('   - Stores field-level permissions');
        System.debug('   - Fields: Permission_Set_Name__c (Lookup), Field_Name__c, Editable__c, Readable__c');
        
        System.debug('6. Page Access Object (Page_Access__c)');
        System.debug('   - Stores Visualforce page access');
        System.debug('   - Fields: Permission_Set_Name__c (Lookup), Apex_Page__c, Enabled__c');
        
        System.debug('7. Class Access Object (Class_Access__c)');
        System.debug('   - Stores Apex class access');
        System.debug('   - Fields: Permission_Set_Name__c (Lookup), Apex_Class__c, Enabled__c');
        
        System.debug('8. Tab Setting Object (Tab_Setting__c)');
        System.debug('   - Stores tab visibility settings');
        System.debug('   - Fields: Permission_Set_Name__c (Lookup), Tab_Name__c, Visibility__c');
        
        System.debug('9. Record Type Visibility Object (Record_Type_Visibility__c)');
        System.debug('   - Stores record type visibility settings');
        System.debug('   - Fields: Permission_Set_Name__c (Lookup), Record_Type__c, Visible__c');
        
        System.debug('=== End Summary ===');
    }
    
    /**
     * Custom exception class
     */
    public class PermissionSetExampleException extends Exception {}
}