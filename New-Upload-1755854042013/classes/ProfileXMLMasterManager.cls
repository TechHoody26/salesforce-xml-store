/**
 * ProfileXMLMasterManager - Handles DML operations for Profile XML data
 * 
 * IMPORTANT: This class is designed to work with custom objects that need to be created first.
 * The custom objects are defined in ProfileXMLMetadataManager and include:
 * - Profile_Admin__c (main object)
 * - Profile_Tab_Visibility__c, Profile_User_Permission__c, etc. (child objects)
 * 
 * DML operations in this class will work once the custom objects are created in the org.
 * Until then, compilation errors about "Invalid type" are expected.
 * 
 * Use ProfileXMLDataManager for XML parsing functionality that works immediately.
 */
public class ProfileXMLMasterManager {
    
    // Static maps to store relationships for internal lookups
    private static Map<Id, Map<String, Id>> tabVisibilityMapByProfile;
    private static Map<Id, Map<String, Id>> objectPermissionMapByProfile;
    private static Map<Id, Map<String, Id>> classAccessMapByProfile;
    private static Map<Id, Map<String, Id>> pageAccessMapByProfile;
    
    /**
     * Main method to parse and store profile XML data
     * Creates master record and multiple child records for each permission type
     * 
     * Note: This method requires custom objects to be created first.
     * Use ProfileXMLDataManager.parseAndStoreProfile() for parsing only.
     */
    public static void parseAndStoreProfile(String profileXml, String profileName) {
        try {
            System.debug('Starting to parse and store profile: ' + profileName);
            
            // Parse the XML
            Dom.Document doc = new Dom.Document();
            doc.load(profileXml);
            Dom.XmlNode root = doc.getRootElement();
            
            // Create master profile record
            Profile_Admin__c masterRecord = createMasterRecord(root, profileName);
            insert masterRecord;
            System.debug('Created master record with ID: ' + masterRecord.Id);
            
            // Create child records for each permission type in order to establish relationships
            // First create the base objects that others will reference
            createObjectPermissions(root, masterRecord.Id);
            createTabVisibilities(root, masterRecord.Id);
            createClassAccesses(root, masterRecord.Id);
            
            // Then create objects that reference the base objects
            createFieldPermissions(root, masterRecord.Id);
            createRecordTypeVisibilities(root, masterRecord.Id);
            createPageAccesses(root, masterRecord.Id);
            createLayoutAssignments(root, masterRecord.Id);
            
            // Finally create objects that don't have internal relationships
            createApplicationVisibilities(root, masterRecord.Id);
            createUserPermissions(root, masterRecord.Id);
            createLoginHours(root, masterRecord.Id);
            createLoginIpRanges(root, masterRecord.Id);
            
            System.debug('Successfully stored all profile data for: ' + profileName);
            
        } catch (Exception e) {
            System.debug('Error parsing and storing profile: ' + e.getMessage());
            throw new ProfileXMLMasterManagerException('Failed to parse and store profile: ' + e.getMessage());
        }
    }
    
    /**
     * Create the master Profile_Admin__c record
     */
    private static Profile_Admin__c createMasterRecord(Dom.XmlNode root, String profileName) {
        Profile_Admin__c record = new Profile_Admin__c();
        record.Name = profileName;
        record.Description__c = getNodeText(root, 'description');
        record.User_License__c = getNodeText(root, 'userLicense');
        record.Custom__c = Boolean.valueOf(getNodeText(root, 'custom'));
        return record;
    }
    
    /**
     * Create Tab_Visibility__c records for each tabVisibilities node
     */
    private static void createTabVisibilities(Dom.XmlNode root, Id masterRecordId) {
        List<Profile_Tab_Visibility__c> tabVisibilities = new List<Profile_Tab_Visibility__c>();
        
        for (Dom.XmlNode tabVisibility : root.getChildElements()) {
            if (tabVisibility.getName() == 'tabVisibilities') {
                Profile_Tab_Visibility__c record = new Profile_Tab_Visibility__c();
                record.Profile_Name__c = masterRecordId;
                record.Profile_Name_Lookup__c = masterRecordId; // Populate lookup field with parent name
                record.Tab_Name__c = getNodeText(tabVisibility, 'tab');
                record.Visibility__c = getNodeText(tabVisibility, 'visibility');
                
                // Populate internal lookup fields - link to object permission if available
                String objectName = getObjectNameFromTab(record.Tab_Name__c);
                if (objectName != null && objectPermissionMapByProfile != null && 
                    objectPermissionMapByProfile.containsKey(masterRecordId) && 
                    objectPermissionMapByProfile.get(masterRecordId).containsKey(objectName)) {
                    record.Object_Permission_Lookup__c = objectPermissionMapByProfile.get(masterRecordId).get(objectName);
                }
                
                tabVisibilities.add(record);
            }
        }
        
        if (!tabVisibilities.isEmpty()) {
            insert tabVisibilities;
            System.debug('Created ' + tabVisibilities.size() + ' tab visibility records');
            
            // Store tab visibility IDs for later use in internal lookups
            Map<String, Id> tabVisibilityMap = new Map<String, Id>();
            for (Profile_Tab_Visibility__c tv : tabVisibilities) {
                tabVisibilityMap.put(tv.Tab_Name__c, tv.Id);
            }
            
            // Store in a static map for use in other methods
            if (tabVisibilityMapByProfile == null) {
                tabVisibilityMapByProfile = new Map<Id, Map<String, Id>>();
            }
            tabVisibilityMapByProfile.put(masterRecordId, tabVisibilityMap);
        }
    }
    
    /**
     * Create Class_Access__c records for each classAccesses node
     */
    private static void createClassAccesses(Dom.XmlNode root, Id masterRecordId) {
        List<Profile_Class_Access__c> classAccesses = new List<Profile_Class_Access__c>();
        
        for (Dom.XmlNode classAccess : root.getChildElements()) {
            if (classAccess.getName() == 'classAccesses') {
                Profile_Class_Access__c record = new Profile_Class_Access__c();
                record.Profile_Name__c = masterRecordId;
                record.Profile_Name_Lookup__c = masterRecordId; // Populate lookup field with parent name
                record.Apex_Class__c = getNodeText(classAccess, 'apexClass');
                record.Enabled__c = Boolean.valueOf(getNodeText(classAccess, 'enabled'));
                classAccesses.add(record);
            }
        }
        
        if (!classAccesses.isEmpty()) {
            insert classAccesses;
            System.debug('Created ' + classAccesses.size() + ' class access records');
            
            // Store class access IDs for later use in internal lookups
            Map<String, Id> classAccessMap = new Map<String, Id>();
            for (Profile_Class_Access__c ca : classAccesses) {
                classAccessMap.put(ca.Apex_Class__c, ca.Id);
            }
            
            // Store in a static map for use in other methods
            if (classAccessMapByProfile == null) {
                classAccessMapByProfile = new Map<Id, Map<String, Id>>();
            }
            classAccessMapByProfile.put(masterRecordId, classAccessMap);
        }
    }
    
    /**
     * Create Record_Type_Visibility__c records for each recordTypeVisibilities node
     */
    private static void createRecordTypeVisibilities(Dom.XmlNode root, Id masterRecordId) {
        List<Profile_Record_Type_Visibility__c> recordTypeVisibilities = new List<Profile_Record_Type_Visibility__c>();
        
        for (Dom.XmlNode recordTypeVisibility : root.getChildElements()) {
            if (recordTypeVisibility.getName() == 'recordTypeVisibilities') {
                Profile_Record_Type_Visibility__c record = new Profile_Record_Type_Visibility__c();
                record.Profile_Name__c = masterRecordId;
                record.Profile_Name_Lookup__c = masterRecordId; // Populate lookup field with parent name
                record.Record_Type__c = getNodeText(recordTypeVisibility, 'recordType');
                record.Visible__c = Boolean.valueOf(getNodeText(recordTypeVisibility, 'visible'));
                
                // Populate internal lookup fields
                String objectName = getObjectNameFromRecordType(record.Record_Type__c);
                if (objectName != null && objectPermissionMapByProfile != null && 
                    objectPermissionMapByProfile.containsKey(masterRecordId) && 
                    objectPermissionMapByProfile.get(masterRecordId).containsKey(objectName)) {
                    record.Object_Permission_Lookup__c = objectPermissionMapByProfile.get(masterRecordId).get(objectName);
                }
                
                // Link to tab visibility if the object has a tab
                if (objectName != null && tabVisibilityMapByProfile != null && 
                    tabVisibilityMapByProfile.containsKey(masterRecordId) && 
                    tabVisibilityMapByProfile.get(masterRecordId).containsKey(objectName)) {
                    record.Tab_Visibility_Lookup__c = tabVisibilityMapByProfile.get(masterRecordId).get(objectName);
                }
                
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
        List<Profile_Page_Access__c> pageAccesses = new List<Profile_Page_Access__c>();
        
        for (Dom.XmlNode pageAccess : root.getChildElements()) {
            if (pageAccess.getName() == 'pageAccesses') {
                Profile_Page_Access__c record = new Profile_Page_Access__c();
                record.Profile_Name__c = masterRecordId;
                record.Profile_Name_Lookup__c = masterRecordId; // Populate lookup field with parent name
                record.Apex_Page__c = getNodeText(pageAccess, 'apexPage');
                record.Enabled__c = Boolean.valueOf(getNodeText(pageAccess, 'enabled'));
                
                // Populate internal lookup fields - link to class access if available
                if (classAccessMapByProfile != null && 
                    classAccessMapByProfile.containsKey(masterRecordId) && 
                    classAccessMapByProfile.get(masterRecordId).containsKey(record.Apex_Page__c)) {
                    record.Class_Access_Lookup__c = classAccessMapByProfile.get(masterRecordId).get(record.Apex_Page__c);
                }
                
                pageAccesses.add(record);
            }
        }
        
        if (!pageAccesses.isEmpty()) {
            insert pageAccesses;
            System.debug('Created ' + pageAccesses.size() + ' page access records');
            
            // Store page access IDs for later use in internal lookups
            Map<String, Id> pageAccessMap = new Map<String, Id>();
            for (Profile_Page_Access__c pa : pageAccesses) {
                pageAccessMap.put(pa.Apex_Page__c, pa.Id);
            }
            
            // Store in a static map for use in other methods
            if (pageAccessMapByProfile == null) {
                pageAccessMapByProfile = new Map<Id, Map<String, Id>>();
            }
            pageAccessMapByProfile.put(masterRecordId, pageAccessMap);
        }
    }
    
    /**
     * Create Field_Permission__c records for each fieldPermissions node
     */
    private static void createFieldPermissions(Dom.XmlNode root, Id masterRecordId) {
        List<Profile_Field_Permission__c> fieldPermissions = new List<Profile_Field_Permission__c>();
        
        for (Dom.XmlNode fieldPermission : root.getChildElements()) {
            if (fieldPermission.getName() == 'fieldPermissions') {
                Profile_Field_Permission__c record = new Profile_Field_Permission__c();
                record.Profile_Name__c = masterRecordId;
                record.Profile_Name_Lookup__c = masterRecordId; // Populate lookup field with parent name
                record.Field_Name__c = getNodeText(fieldPermission, 'field');
                record.Editable__c = Boolean.valueOf(getNodeText(fieldPermission, 'editable'));
                record.Readable__c = Boolean.valueOf(getNodeText(fieldPermission, 'readable'));
                
                // Populate internal lookup fields
                String objectName = getObjectNameFromField(record.Field_Name__c);
                if (objectName != null && objectPermissionMapByProfile != null && 
                    objectPermissionMapByProfile.containsKey(masterRecordId) && 
                    objectPermissionMapByProfile.get(masterRecordId).containsKey(objectName)) {
                    record.Object_Permission_Lookup__c = objectPermissionMapByProfile.get(masterRecordId).get(objectName);
                }
                
                // Link to tab visibility if the object has a tab
                if (objectName != null && tabVisibilityMapByProfile != null && 
                    tabVisibilityMapByProfile.containsKey(masterRecordId) && 
                    tabVisibilityMapByProfile.get(masterRecordId).containsKey(objectName)) {
                    record.Tab_Visibility_Lookup__c = tabVisibilityMapByProfile.get(masterRecordId).get(objectName);
                }
                
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
        List<Profile_Object_Permission__c> objectPermissions = new List<Profile_Object_Permission__c>();
        
        for (Dom.XmlNode objectPermission : root.getChildElements()) {
            if (objectPermission.getName() == 'objectPermissions') {
                Profile_Object_Permission__c record = new Profile_Object_Permission__c();
                record.Profile_Name__c = masterRecordId;
                record.Profile_Name_Lookup__c = masterRecordId; // Populate lookup field with parent name
                record.Object_Name__c = getNodeText(objectPermission, 'object');
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
            
            // Store object permission IDs for later use in internal lookups
            Map<String, Id> objectPermissionMap = new Map<String, Id>();
            for (Profile_Object_Permission__c op : objectPermissions) {
                objectPermissionMap.put(op.Object_Name__c, op.Id);
            }
            
            // Store in a static map for use in other methods
            if (objectPermissionMapByProfile == null) {
                objectPermissionMapByProfile = new Map<Id, Map<String, Id>>();
            }
            objectPermissionMapByProfile.put(masterRecordId, objectPermissionMap);
        }
    }
    
    /**
     * Create Application_Visibility__c records for each applicationVisibilities node
     */
    private static void createApplicationVisibilities(Dom.XmlNode root, Id masterRecordId) {
        List<Profile_Application_Visibility__c> applicationVisibilities = new List<Profile_Application_Visibility__c>();
        
        for (Dom.XmlNode applicationVisibility : root.getChildElements()) {
            if (applicationVisibility.getName() == 'applicationVisibilities') {
                Profile_Application_Visibility__c record = new Profile_Application_Visibility__c();
                record.Profile_Name__c = masterRecordId;
                record.Profile_Name_Lookup__c = masterRecordId; // Populate lookup field with parent name
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
        List<Profile_User_Permission__c> userPermissions = new List<Profile_User_Permission__c>();
        
        for (Dom.XmlNode userPermission : root.getChildElements()) {
            if (userPermission.getName() == 'userPermissions') {
                Profile_User_Permission__c record = new Profile_User_Permission__c();
                record.Profile_Name__c = masterRecordId;
                record.Profile_Name_Lookup__c = masterRecordId; // Populate lookup field with parent name
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
     * Create Layout_Assignment__c records for each layoutAssignments node
     */
    private static void createLayoutAssignments(Dom.XmlNode root, Id masterRecordId) {
        List<Profile_Layout_Assignment__c> layoutAssignments = new List<Profile_Layout_Assignment__c>();
        
        for (Dom.XmlNode layoutAssignment : root.getChildElements()) {
            if (layoutAssignment.getName() == 'layoutAssignments') {
                Profile_Layout_Assignment__c record = new Profile_Layout_Assignment__c();
                record.Profile_Name__c = masterRecordId;
                record.Profile_Name_Lookup__c = masterRecordId; // Populate lookup field with parent name
                record.Layout__c = getNodeText(layoutAssignment, 'layout');
                record.Record_Type__c = Boolean.valueOf(getNodeText(layoutAssignment, 'recordType'));
                
                // Populate internal lookup fields - link to page access if available
                if (pageAccessMapByProfile != null && 
                    pageAccessMapByProfile.containsKey(masterRecordId) && 
                    pageAccessMapByProfile.get(masterRecordId).containsKey(record.Layout__c)) {
                    record.Page_Access_Lookup__c = pageAccessMapByProfile.get(masterRecordId).get(record.Layout__c);
                }
                
                layoutAssignments.add(record);
            }
        }
        
        if (!layoutAssignments.isEmpty()) {
            insert layoutAssignments;
            System.debug('Created ' + layoutAssignments.size() + ' layout assignment records');
        }
    }
    
    /**
     * Create Login_Hours__c records for loginHours node
     */
    private static void createLoginHours(Dom.XmlNode root, Id masterRecordId) {
        List<Profile_Login_Hours__c> loginHours = new List<Profile_Login_Hours__c>();
        
        Dom.XmlNode loginHoursNode = root.getChildElement('loginHours', null);
        if (loginHoursNode != null) {
            Profile_Login_Hours__c record = new Profile_Login_Hours__c();
            record.Profile_Name__c = masterRecordId;
            record.Profile_Name_Lookup__c = masterRecordId; // Populate lookup field with parent name
            record.Weekday_Start__c = getNodeText(loginHoursNode, 'weekdayStart');
            record.Weekday_End__c = getNodeText(loginHoursNode, 'weekdayEnd');
            record.Weekend_Start__c = getNodeText(loginHoursNode, 'weekendStart');
            record.Weekend_End__c = getNodeText(loginHoursNode, 'weekendEnd');
            loginHours.add(record);
        }
        
        if (!loginHours.isEmpty()) {
            insert loginHours;
            System.debug('Created ' + loginHours.size() + ' login hours records');
        }
    }
    
    /**
     * Create Login_Ip_Ranges__c records for each loginIpRanges node
     */
    private static void createLoginIpRanges(Dom.XmlNode root, Id masterRecordId) {
        List<Profile_Login_Ip_Ranges__c> loginIpRanges = new List<Profile_Login_Ip_Ranges__c>();
        
        for (Dom.XmlNode loginIpRange : root.getChildElements()) {
            if (loginIpRange.getName() == 'loginIpRanges') {
                Profile_Login_Ip_Ranges__c record = new Profile_Login_Ip_Ranges__c();
                record.Profile_Name__c = masterRecordId;
                record.Profile_Name_Lookup__c = masterRecordId; // Populate lookup field with parent name
                record.Start_Address__c = getNodeText(loginIpRange, 'startAddress');
                record.End_Address__c = getNodeText(loginIpRange, 'endAddress');
                record.Description__c = getNodeText(loginIpRange, 'description');
                loginIpRanges.add(record);
            }
        }
        
        if (!loginIpRanges.isEmpty()) {
            insert loginIpRanges;
            System.debug('Created ' + loginIpRanges.size() + ' login IP range records');
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
     * Utility method to extract object name from field name (e.g., "Account.Name" -> "Account")
     */
    private static String getObjectNameFromField(String fieldName) {
        if (fieldName == null || !fieldName.contains('.')) return null;
        return fieldName.split('\\.')[0];
    }
    
    /**
     * Utility method to extract object name from record type (e.g., "Account.Customer" -> "Account")
     */
    private static String getObjectNameFromRecordType(String recordType) {
        if (recordType == null || !recordType.contains('.')) return null;
        return recordType.split('\\.')[0];
    }
    
    /**
     * Utility method to extract object name from tab name (e.g., "Accounts" -> "Account")
     */
    private static String getObjectNameFromTab(String tabName) {
        if (tabName == null) return null;
        
        // Common tab to object mappings
        Map<String, String> tabToObjectMap = new Map<String, String>{
            'Accounts' => 'Account',
            'Contacts' => 'Contact',
            'Leads' => 'Lead',
            'Opportunities' => 'Opportunity',
            'Cases' => 'Case',
            'Tasks' => 'Task',
            'Events' => 'Event',
            'Campaigns' => 'Campaign',
            'Products' => 'Product2',
            'Assets' => 'Asset',
            'Contracts' => 'Contract',
            'Orders' => 'Order',
            'Invoices' => 'Invoice',
            'Reports' => 'Report',
            'Dashboards' => 'Dashboard'
        };
        
        return tabToObjectMap.get(tabName);
    }
    
    /**
     * Retrieve all profiles with their child records
     */
    public static List<Profile_Admin__c> getAllProfiles() {
        return [
            SELECT Id, Name, Description__c, User_License__c, Custom__c,
                   (SELECT Id, Tab_Name__c, Visibility__c FROM Tab_Visibilities__r),
                   (SELECT Id, Apex_Class__c, Enabled__c FROM Class_Accesses__r),
                   (SELECT Id, Record_Type__c, Visible__c FROM Record_Type_Visibilities__r),
                   (SELECT Id, Apex_Page__c, Enabled__c FROM Page_Accesses__r),
                   (SELECT Id, Field_Name__c, Editable__c, Readable__c FROM Field_Permissions__r),
                   (SELECT Id, Object_Name__c, Allow_Create__c, Allow_Delete__c, Allow_Edit__c, 
                           Allow_Read__c, View_All_Records__c, Modify_All_Records__c, View_All_Fields__c 
                    FROM Object_Permissions__r),
                   (SELECT Id, Application__c, Visible__c FROM Application_Visibilities__r),
                   (SELECT Id, Permission_Name__c, Enabled__c FROM User_Permissions__r),
                   (SELECT Id, Layout__c, Record_Type__c FROM Layout_Assignments__r),
                   (SELECT Id, Weekday_Start__c, Weekday_End__c, Weekend_Start__c, Weekend_End__c FROM Login_Hours__r),
                   (SELECT Id, Start_Address__c, End_Address__c, Description__c FROM Login_Ip_Ranges__r)
            FROM Profile_Admin__c
            ORDER BY Name
        ];
    }
    
    /**
     * Get a specific profile by name with all child records
     */
    public static Profile_Admin__c getProfileByName(String profileName) {
        List<Profile_Admin__c> profiles = [
            SELECT Id, Name, Description__c, User_License__c, Custom__c,
                   (SELECT Id, Tab_Name__c, Visibility__c FROM Tab_Visibilities__r),
                   (SELECT Id, Apex_Class__c, Enabled__c FROM Class_Accesses__r),
                   (SELECT Id, Record_Type__c, Visible__c FROM Record_Type_Visibilities__r),
                   (SELECT Id, Apex_Page__c, Enabled__c FROM Page_Accesses__r),
                   (SELECT Id, Field_Name__c, Editable__c, Readable__c FROM Field_Permissions__r),
                   (SELECT Id, Object_Name__c, Allow_Create__c, Allow_Delete__c, Allow_Edit__c, 
                           Allow_Read__c, View_All_Records__c, Modify_All_Records__c, View_All_Fields__c 
                    FROM Object_Permissions__r),
                   (SELECT Id, Application__c, Visible__c FROM Application_Visibilities__r),
                   (SELECT Id, Permission_Name__c, Enabled__c FROM User_Permissions__r),
                   (SELECT Id, Layout__c, Record_Type__c FROM Layout_Assignments__r),
                   (SELECT Id, Weekday_Start__c, Weekday_End__c, Weekend_Start__c, Weekend_End__c FROM Login_Hours__r),
                   (SELECT Id, Start_Address__c, End_Address__c, Description__c FROM Login_Ip_Ranges__r)
            FROM Profile_Admin__c
            WHERE Name = :profileName
            LIMIT 1
        ];
        
        return profiles.isEmpty() ? null : profiles[0];
    }
    
    /**
     * Delete a profile and all its child records
     */
    public static void deleteProfile(String profileName) {
        try {
            Profile_Admin__c profile = getProfileByName(profileName);
            if (profile != null) {
                delete profile;
                System.debug('Successfully deleted profile: ' + profileName);
            } else {
                System.debug('Profile not found: ' + profileName);
            }
        } catch (Exception e) {
            System.debug('Error deleting profile: ' + e.getMessage());
            throw new ProfileXMLMasterManagerException('Failed to delete profile: ' + e.getMessage());
        }
    }
    
    /**
     * Update profile data from XML
     */
    public static void updateProfileFromXML(String profileXml, String profileName) {
        try {
            // First delete existing profile
            deleteProfile(profileName);
            
            // Then create new profile from XML
            parseAndStoreProfile(profileXml, profileName);
            
            System.debug('Successfully updated profile: ' + profileName);
            
        } catch (Exception e) {
            System.debug('Error updating profile: ' + e.getMessage());
            throw new ProfileXMLMasterManagerException('Failed to update profile: ' + e.getMessage());
        }
    }
    
    /**
     * Custom exception class
     */
    public class ProfileXMLMasterManagerException extends Exception {}
}