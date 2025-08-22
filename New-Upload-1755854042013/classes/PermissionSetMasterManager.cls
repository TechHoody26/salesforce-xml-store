public class PermissionSetMasterManager {
    
    /**
     * Main method to parse and store permission set XML data
     * Creates master record and multiple child records for each permission type
     */
    public static void parseAndStorePermissionSet(String permissionSetXml, String permissionSetName) {
        try {
            System.debug('Starting to parse and store permission set: ' + permissionSetName);
            
            // Parse the XML
            Dom.Document doc = new Dom.Document();
            doc.load(permissionSetXml);
            Dom.XmlNode root = doc.getRootElement();
            
            // Create master permission set record
            Permission_Set__c masterRecord = createMasterRecord(root, permissionSetName);
            insert masterRecord;
            System.debug('Created master record with ID: ' + masterRecord.Id);
            
            // Create child records for each permission type
            createTabSettings(root, masterRecord.Id);
            createClassAccesses(root, masterRecord.Id);
            createRecordTypeVisibilities(root, masterRecord.Id);
            createPageAccesses(root, masterRecord.Id);
            createFieldPermissions(root, masterRecord.Id);
            createObjectPermissions(root, masterRecord.Id);
            createApplicationVisibilities(root, masterRecord.Id);
            createUserPermissions(root, masterRecord.Id);
            
            System.debug('Successfully stored all permission set data for: ' + permissionSetName);
            
        } catch (Exception e) {
            System.debug('Error parsing and storing permission set: ' + e.getMessage());
            throw new PermissionSetMasterManagerException('Failed to parse and store permission set: ' + e.getMessage());
        }
    }
    
    /**
     * Create the master Permission_Set__c record
     */
    private static Permission_Set__c createMasterRecord(Dom.XmlNode root, String permissionSetName) {
        Permission_Set__c record = new Permission_Set__c();
        record.Label__c = getNodeText(root, 'label');
        record.Description__c = getNodeText(root, 'description');
        record.User_License__c = getNodeText(root, 'userLicense');
        return record;
    }
    
    /**
     * Create Tab_Setting__c records for each tabSettings node
     */
    private static void createTabSettings(Dom.XmlNode root, Id masterRecordId) {
        List<Tab_Setting__c> tabSettings = new List<Tab_Setting__c>();
        
        for (Dom.XmlNode tabSetting : root.getChildElements()) {
            if (tabSetting.getName() == 'tabSettings') {
                Tab_Setting__c record = new Tab_Setting__c();
                record.Permission_Set__c = masterRecordId;
                record.Tab__c = getNodeText(tabSetting, 'tab');
                record.Visibility__c = getNodeText(tabSetting, 'visibility');
                tabSettings.add(record);
            }
        }
        
        if (!tabSettings.isEmpty()) {
            insert tabSettings;
            System.debug('Created ' + tabSettings.size() + ' tab setting records');
        }
    }
    
    /**
     * Create Class_Access__c records for each classAccesses node
     */
    private static void createClassAccesses(Dom.XmlNode root, Id masterRecordId) {
        List<Class_Access__c> classAccesses = new List<Class_Access__c>();
        
        for (Dom.XmlNode classAccess : root.getChildElements()) {
            if (classAccess.getName() == 'classAccesses') {
                Class_Access__c record = new Class_Access__c();
                record.Permission_Set__c = masterRecordId;
                record.Apex_Class__c = getNodeText(classAccess, 'apexClass');
                record.Enabled__c = Boolean.valueOf(getNodeText(classAccess, 'enabled'));
                classAccesses.add(record);
            }
        }
        
        if (!classAccesses.isEmpty()) {
            insert classAccesses;
            System.debug('Created ' + classAccesses.size() + ' class access records');
        }
    }
    
    /**
     * Create Record_Type_Visibility__c records for each recordTypeVisibilities node
     */
    private static void createRecordTypeVisibilities(Dom.XmlNode root, Id masterRecordId) {
        List<Record_Type_Visibility__c> recordTypeVisibilities = new List<Record_Type_Visibility__c>();
        
        for (Dom.XmlNode recordTypeVisibility : root.getChildElements()) {
            if (recordTypeVisibility.getName() == 'recordTypeVisibilities') {
                Record_Type_Visibility__c record = new Record_Type_Visibility__c();
                record.Permission_Set__c = masterRecordId;
                record.Record_Type__c = getNodeText(recordTypeVisibility, 'recordType');
                record.Visible__c = Boolean.valueOf(getNodeText(recordTypeVisibility, 'visible'));
                recordTypeVisibilities.add(record);
            }
        }
        
        if (!recordTypeVisibilities.isEmpty()) {
            insert recordTypeVisibilities;
            System.debug('Created ' + recordTypeVisibilities.size() + ' record type visibility records');
        }
    }
    
    /**
     * Create Page_Access__c records for each pageAccesses node
     */
    private static void createPageAccesses(Dom.XmlNode root, Id masterRecordId) {
        List<Page_Access__c> pageAccesses = new List<Page_Access__c>();
        
        for (Dom.XmlNode pageAccess : root.getChildElements()) {
            if (pageAccess.getName() == 'pageAccesses') {
                Page_Access__c record = new Page_Access__c();
                record.Permission_Set__c = masterRecordId;
                record.Apex_Page__c = getNodeText(pageAccess, 'apexPage');
                record.Enabled__c = Boolean.valueOf(getNodeText(pageAccess, 'enabled'));
                pageAccesses.add(record);
            }
        }
        
        if (!pageAccesses.isEmpty()) {
            insert pageAccesses;
            System.debug('Created ' + pageAccesses.size() + ' page access records');
        }
    }
    
    /**
     * Create Field_Permission__c records for each fieldPermissions node
     */
    private static void createFieldPermissions(Dom.XmlNode root, Id masterRecordId) {
        List<Field_Permission__c> fieldPermissions = new List<Field_Permission__c>();
        
        for (Dom.XmlNode fieldPermission : root.getChildElements()) {
            if (fieldPermission.getName() == 'fieldPermissions') {
                Field_Permission__c record = new Field_Permission__c();
                record.Permission_Set__c = masterRecordId;
                record.Field__c = getNodeText(fieldPermission, 'field');
                record.Editable__c = Boolean.valueOf(getNodeText(fieldPermission, 'editable'));
                record.Readable__c = Boolean.valueOf(getNodeText(fieldPermission, 'readable'));
                fieldPermissions.add(record);
            }
        }
        
        if (!fieldPermissions.isEmpty()) {
            insert fieldPermissions;
            System.debug('Created ' + fieldPermissions.size() + ' field permission records');
        }
    }
    
    /**
     * Create Object_Permission__c records for each objectPermissions node
     */
    private static void createObjectPermissions(Dom.XmlNode root, Id masterRecordId) {
        List<Object_Permission__c> objectPermissions = new List<Object_Permission__c>();
        
        for (Dom.XmlNode objectPermission : root.getChildElements()) {
            if (objectPermission.getName() == 'objectPermissions') {
                Object_Permission__c record = new Object_Permission__c();
                record.Permission_Set__c = masterRecordId;
                record.Object__c = getNodeText(objectPermission, 'object');
                record.Allow_Create__c = Boolean.valueOf(getNodeText(objectPermission, 'allowCreate'));
                record.Allow_Delete__c = Boolean.valueOf(getNodeText(objectPermission, 'allowDelete'));
                record.Allow_Edit__c = Boolean.valueOf(getNodeText(objectPermission, 'allowEdit'));
                record.Allow_Read__c = Boolean.valueOf(getNodeText(objectPermission, 'allowRead'));
                record.View_All_Records__c = Boolean.valueOf(getNodeText(objectPermission, 'viewAllRecords'));
                record.Modify_All_Records__c = Boolean.valueOf(getNodeText(objectPermission, 'modifyAllRecords'));
                record.View_All_Fields__c = Boolean.valueOf(getNodeText(objectPermission, 'viewAllFields'));
                objectPermissions.add(record);
            }
        }
        
        if (!objectPermissions.isEmpty()) {
            insert objectPermissions;
            System.debug('Created ' + objectPermissions.size() + ' object permission records');
        }
    }
    
    /**
     * Create Application_Visibility__c records for each applicationVisibilities node
     */
    private static void createApplicationVisibilities(Dom.XmlNode root, Id masterRecordId) {
        List<Application_Visibility__c> applicationVisibilities = new List<Application_Visibility__c>();
        
        for (Dom.XmlNode applicationVisibility : root.getChildElements()) {
            if (applicationVisibility.getName() == 'applicationVisibilities') {
                Application_Visibility__c record = new Application_Visibility__c();
                record.Permission_Set__c = masterRecordId;
                record.Application__c = getNodeText(applicationVisibility, 'application');
                record.Visible__c = Boolean.valueOf(getNodeText(applicationVisibility, 'visible'));
                applicationVisibilities.add(record);
            }
        }
        
        if (!applicationVisibilities.isEmpty()) {
            insert applicationVisibilities;
            System.debug('Created ' + applicationVisibilities.size() + ' application visibility records');
        }
    }
    
    /**
     * Create User_Permission__c records for each userPermissions node
     */
    private static void createUserPermissions(Dom.XmlNode root, Id masterRecordId) {
        List<User_Permission__c> userPermissions = new List<User_Permission__c>();
        
        for (Dom.XmlNode userPermission : root.getChildElements()) {
            if (userPermission.getName() == 'userPermissions') {
                User_Permission__c record = new User_Permission__c();
                record.Permission_Set__c = masterRecordId;
                record.Permission_Name__c = getNodeText(userPermission, 'name');
                record.Enabled__c = Boolean.valueOf(getNodeText(userPermission, 'enabled'));
                userPermissions.add(record);
            }
        }
        
        if (!userPermissions.isEmpty()) {
            insert userPermissions;
            System.debug('Created ' + userPermissions.size() + ' user permission records');
        }
    }
    
    /**
     * Utility method to get text content of a child node
     */
    private static String getNodeText(Dom.XmlNode parent, String childName) {
        if (parent == null) return '';
        
        for (Dom.XmlNode child : parent.getChildElements()) {
            if (child.getName() == childName) {
                return child.getText();
            }
        }
        return '';
    }
    
    /**
     * Retrieve all permission sets with their child records
     */
    public static List<Permission_Set__c> getAllPermissionSets() {
        return [
            SELECT Id, Name, Label__c, Description__c, User_License__c,
                   (SELECT Id, Tab__c, Visibility__c FROM Tab_Settings__r),
                   (SELECT Id, Apex_Class__c, Enabled__c FROM Class_Accesses__r),
                   (SELECT Id, Record_Type__c, Visible__c FROM Record_Type_Visibilities__r),
                   (SELECT Id, Apex_Page__c, Enabled__c FROM Page_Accesses__r),
                   (SELECT Id, Field__c, Editable__c, Readable__c FROM Field_Permissions__r),
                   (SELECT Id, Object__c, Allow_Create__c, Allow_Delete__c, Allow_Edit__c, 
                           Allow_Read__c, View_All_Records__c, Modify_All_Records__c, View_All_Fields__c 
                    FROM Object_Permissions__r),
                   (SELECT Id, Application__c, Visible__c FROM Application_Visibilities__r),
                   (SELECT Id, Permission_Name__c, Enabled__c FROM User_Permissions__r)
            FROM Permission_Set__c
            ORDER BY Name
        ];
    }
    
    /**
     * Custom exception class
     */
    public class PermissionSetMasterManagerException extends Exception {}
}