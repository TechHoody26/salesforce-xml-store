public class ProfileXMLMetadataManager {
    
    /**
     * Creates custom objects and fields to store profile data
     * This method uses the Metadata API to create the necessary objects
     */
    public static void createProfileObjects() {
        try {
            // Create the main Profile object
            createProfileObject();
            
            // Create related objects for different permission types
            createApplicationVisibilityObject();
            createUserPermissionObject();
            createObjectPermissionObject();
            createFieldPermissionObject();
            createPageAccessObject();
            createClassAccessObject();
            createTabVisibilityObject();
            createRecordTypeVisibilityObject();
            createLayoutAssignmentObject();
            createLoginHoursObject();
            createLoginIpRangesObject();
            
            System.debug('Successfully created all profile objects');
            
        } catch (Exception e) {
            System.debug('Error creating profile objects: ' + e.getMessage());
            throw new ProfileXMLMetadataManagerException('Failed to create profile objects: ' + e.getMessage());
        }
    }
    
    /**
     * Create the main Profile object
     */
    private static void createProfileObject() {
        // This would use Metadata API to create the object
        // For demonstration, we'll create the object structure
        
        Map<String, Object> objectMetadata = new Map<String, Object>();
        objectMetadata.put('fullName', 'Profile_Admin__c');
        objectMetadata.put('label', 'Profile Admin');
        objectMetadata.put('pluralLabel', 'Profile Admins');
        objectMetadata.put('nameField', new Map<String, Object>{
            'type' => 'Text',
            'label' => 'Profile Name'
        });
        objectMetadata.put('deploymentStatus', 'Deployed');
        objectMetadata.put('enableSharing', true);
        objectMetadata.put('enableBulkApi', true);
        objectMetadata.put('enableStreamingApi', true);
        objectMetadata.put('enableReports', true);
        objectMetadata.put('enableSearch', true);
        objectMetadata.put('enableHistory', false);
        objectMetadata.put('enableLicensing', false);
        
        // Add fields
        List<Map<String, Object>> fields = new List<Map<String, Object>>();
        
        // Description field
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Admin__c.Description__c',
            'label' => 'Description',
            'type' => 'TextArea',
            'length' => 32768,
            'visibleLines' => 3
        });
        
        // User License field
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Admin__c.User_License__c',
            'label' => 'User License',
            'type' => 'Text',
            'length' => 255
        });
        
        // Custom field
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Admin__c.Custom__c',
            'label' => 'Custom',
            'type' => 'Checkbox',
            'defaultValue' => false
        });
        
        objectMetadata.put('fields', fields);
        
        System.debug('Profile Object Metadata: ' + objectMetadata);
    }
    
    /**
     * Create Application Visibility object
     */
    private static void createApplicationVisibilityObject() {
        Map<String, Object> objectMetadata = new Map<String, Object>();
        objectMetadata.put('fullName', 'Profile_Application_Visibility__c');
        objectMetadata.put('label', 'Profile Application Visibility');
        objectMetadata.put('pluralLabel', 'Profile Application Visibilities');
        objectMetadata.put('nameField', new Map<String, Object>{
            'type' => 'AutoNumber',
            'label' => 'Application Visibility Number',
            'displayFormat' => 'PAV-{0000}'
        });
        objectMetadata.put('deploymentStatus', 'Deployed');
        objectMetadata.put('enableSharing', true);
        objectMetadata.put('enableBulkApi', true);
        objectMetadata.put('enableStreamingApi', true);
        objectMetadata.put('enableReports', true);
        objectMetadata.put('enableSearch', true);
        objectMetadata.put('enableHistory', false);
        objectMetadata.put('enableLicensing', false);
        
        // Add fields
        List<Map<String, Object>> fields = new List<Map<String, Object>>();
        
        // Profile Name (Lookup)
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Application_Visibility__c.Profile_Name__c',
            'label' => 'Profile Name',
            'type' => 'Lookup',
            'referenceTo' => 'Profile_Admin__c',
            'relationshipName' => 'Application_Visibilities',
            'relationshipLabel' => 'Application Visibilities',
            'deleteConstraint' => 'SetNull'
        });
        
        // Application field
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Application_Visibility__c.Application__c',
            'label' => 'Application',
            'type' => 'Text',
            'length' => 255
        });
        
        // Visible field
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Application_Visibility__c.Visible__c',
            'label' => 'Visible',
            'type' => 'Checkbox',
            'defaultValue' => false
        });
        
        objectMetadata.put('fields', fields);
        
        System.debug('Profile Application Visibility Object Metadata: ' + objectMetadata);
    }
    
    /**
     * Create User Permission object
     */
    private static void createUserPermissionObject() {
        Map<String, Object> objectMetadata = new Map<String, Object>();
        objectMetadata.put('fullName', 'Profile_User_Permission__c');
        objectMetadata.put('label', 'Profile User Permission');
        objectMetadata.put('pluralLabel', 'Profile User Permissions');
        objectMetadata.put('nameField', new Map<String, Object>{
            'type' => 'AutoNumber',
            'label' => 'User Permission Number',
            'displayFormat' => 'PUP-{0000}'
        });
        objectMetadata.put('deploymentStatus', 'Deployed');
        objectMetadata.put('enableSharing', true);
        objectMetadata.put('enableBulkApi', true);
        objectMetadata.put('enableStreamingApi', true);
        objectMetadata.put('enableReports', true);
        objectMetadata.put('enableSearch', true);
        objectMetadata.put('enableHistory', false);
        objectMetadata.put('enableLicensing', false);
        
        // Add fields
        List<Map<String, Object>> fields = new List<Map<String, Object>>();
        
        // Profile Name (Lookup)
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_User_Permission__c.Profile_Name__c',
            'label' => 'Profile Name',
            'type' => 'Lookup',
            'referenceTo' => 'Profile_Admin__c',
            'relationshipName' => 'User_Permissions',
            'relationshipLabel' => 'User Permissions',
            'deleteConstraint' => 'SetNull'
        });
        
        // Permission Name field
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_User_Permission__c.Permission_Name__c',
            'label' => 'Permission Name',
            'type' => 'Text',
            'length' => 255
        });
        
        // Enabled field
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_User_Permission__c.Enabled__c',
            'label' => 'Enabled',
            'type' => 'Checkbox',
            'defaultValue' => false
        });
        
        objectMetadata.put('fields', fields);
        
        System.debug('Profile User Permission Object Metadata: ' + objectMetadata);
    }
    
    /**
     * Create Object Permission object
     */
    private static void createObjectPermissionObject() {
        Map<String, Object> objectMetadata = new Map<String, Object>();
        objectMetadata.put('fullName', 'Profile_Object_Permission__c');
        objectMetadata.put('label', 'Profile Object Permission');
        objectMetadata.put('pluralLabel', 'Profile Object Permissions');
        objectMetadata.put('nameField', new Map<String, Object>{
            'type' => 'AutoNumber',
            'label' => 'Object Permission Number',
            'displayFormat' => 'POP-{0000}'
        });
        objectMetadata.put('deploymentStatus', 'Deployed');
        objectMetadata.put('enableSharing', true);
        objectMetadata.put('enableBulkApi', true);
        objectMetadata.put('enableStreamingApi', true);
        objectMetadata.put('enableReports', true);
        objectMetadata.put('enableSearch', true);
        objectMetadata.put('enableHistory', false);
        objectMetadata.put('enableLicensing', false);
        
        // Add fields
        List<Map<String, Object>> fields = new List<Map<String, Object>>();
        
        // Profile Name (Lookup)
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Object_Permission__c.Profile_Name__c',
            'label' => 'Profile Name',
            'type' => 'Lookup',
            'referenceTo' => 'Profile_Admin__c',
            'relationshipName' => 'Object_Permissions',
            'relationshipLabel' => 'Object Permissions',
            'deleteConstraint' => 'SetNull'
        });
        
        // Object Name field
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Object_Permission__c.Object_Name__c',
            'label' => 'Object Name',
            'type' => 'Text',
            'length' => 255
        });
        
        // Permission fields
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Object_Permission__c.Allow_Create__c',
            'label' => 'Allow Create',
            'type' => 'Checkbox',
            'defaultValue' => false
        });
        
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Object_Permission__c.Allow_Delete__c',
            'label' => 'Allow Delete',
            'type' => 'Checkbox',
            'defaultValue' => false
        });
        
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Object_Permission__c.Allow_Edit__c',
            'label' => 'Allow Edit',
            'type' => 'Checkbox',
            'defaultValue' => false
        });
        
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Object_Permission__c.Allow_Read__c',
            'label' => 'Allow Read',
            'type' => 'Checkbox',
            'defaultValue' => false
        });
        
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Object_Permission__c.View_All_Records__c',
            'label' => 'View All Records',
            'type' => 'Checkbox',
            'defaultValue' => false
        });
        
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Object_Permission__c.Modify_All_Records__c',
            'label' => 'Modify All Records',
            'type' => 'Checkbox',
            'defaultValue' => false
        });
        
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Object_Permission__c.View_All_Fields__c',
            'label' => 'View All Fields',
            'type' => 'Checkbox',
            'defaultValue' => false
        });
        
        objectMetadata.put('fields', fields);
        
        System.debug('Profile Object Permission Object Metadata: ' + objectMetadata);
    }
    
    /**
     * Create Field Permission object
     */
    private static void createFieldPermissionObject() {
        Map<String, Object> objectMetadata = new Map<String, Object>();
        objectMetadata.put('fullName', 'Profile_Field_Permission__c');
        objectMetadata.put('label', 'Profile Field Permission');
        objectMetadata.put('pluralLabel', 'Profile Field Permissions');
        objectMetadata.put('nameField', new Map<String, Object>{
            'type' => 'AutoNumber',
            'label' => 'Field Permission Number',
            'displayFormat' => 'PFP-{0000}'
        });
        objectMetadata.put('deploymentStatus', 'Deployed');
        objectMetadata.put('enableSharing', true);
        objectMetadata.put('enableBulkApi', true);
        objectMetadata.put('enableStreamingApi', true);
        objectMetadata.put('enableReports', true);
        objectMetadata.put('enableSearch', true);
        objectMetadata.put('enableHistory', false);
        objectMetadata.put('enableLicensing', false);
        
        // Add fields
        List<Map<String, Object>> fields = new List<Map<String, Object>>();
        
        // Profile Name (Lookup)
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Field_Permission__c.Profile_Name__c',
            'label' => 'Profile Name',
            'type' => 'Lookup',
            'referenceTo' => 'Profile_Admin__c',
            'relationshipName' => 'Field_Permissions',
            'relationshipLabel' => 'Field Permissions',
            'deleteConstraint' => 'SetNull'
        });
        
        // Field Name field
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Field_Permission__c.Field_Name__c',
            'label' => 'Field Name',
            'type' => 'Text',
            'length' => 255
        });
        
        // Permission fields
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Field_Permission__c.Editable__c',
            'label' => 'Editable',
            'type' => 'Checkbox',
            'defaultValue' => false
        });
        
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Field_Permission__c.Readable__c',
            'label' => 'Readable',
            'type' => 'Checkbox',
            'defaultValue' => false
        });
        
        objectMetadata.put('fields', fields);
        
        System.debug('Profile Field Permission Object Metadata: ' + objectMetadata);
    }
    
    /**
     * Create Page Access object
     */
    private static void createPageAccessObject() {
        Map<String, Object> objectMetadata = new Map<String, Object>();
        objectMetadata.put('fullName', 'Profile_Page_Access__c');
        objectMetadata.put('label', 'Profile Page Access');
        objectMetadata.put('pluralLabel', 'Profile Page Accesses');
        objectMetadata.put('nameField', new Map<String, Object>{
            'type' => 'AutoNumber',
            'label' => 'Page Access Number',
            'displayFormat' => 'PPA-{0000}'
        });
        objectMetadata.put('deploymentStatus', 'Deployed');
        objectMetadata.put('enableSharing', true);
        objectMetadata.put('enableBulkApi', true);
        objectMetadata.put('enableStreamingApi', true);
        objectMetadata.put('enableReports', true);
        objectMetadata.put('enableSearch', true);
        objectMetadata.put('enableHistory', false);
        objectMetadata.put('enableLicensing', false);
        
        // Add fields
        List<Map<String, Object>> fields = new List<Map<String, Object>>();
        
        // Profile Name (Lookup)
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Page_Access__c.Profile_Name__c',
            'label' => 'Profile Name',
            'type' => 'Lookup',
            'referenceTo' => 'Profile_Admin__c',
            'relationshipName' => 'Page_Accesses',
            'relationshipLabel' => 'Page Accesses',
            'deleteConstraint' => 'SetNull'
        });
        
        // Apex Page field
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Page_Access__c.Apex_Page__c',
            'label' => 'Apex Page',
            'type' => 'Text',
            'length' => 255
        });
        
        // Enabled field
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Page_Access__c.Enabled__c',
            'label' => 'Enabled',
            'type' => 'Checkbox',
            'defaultValue' => false
        });
        
        objectMetadata.put('fields', fields);
        
        System.debug('Profile Page Access Object Metadata: ' + objectMetadata);
    }
    
    /**
     * Create Class Access object
     */
    private static void createClassAccessObject() {
        Map<String, Object> objectMetadata = new Map<String, Object>();
        objectMetadata.put('fullName', 'Profile_Class_Access__c');
        objectMetadata.put('label', 'Profile Class Access');
        objectMetadata.put('pluralLabel', 'Profile Class Accesses');
        objectMetadata.put('nameField', new Map<String, Object>{
            'type' => 'AutoNumber',
            'label' => 'Class Access Number',
            'displayFormat' => 'PCA-{0000}'
        });
        objectMetadata.put('deploymentStatus', 'Deployed');
        objectMetadata.put('enableSharing', true);
        objectMetadata.put('enableBulkApi', true);
        objectMetadata.put('enableStreamingApi', true);
        objectMetadata.put('enableReports', true);
        objectMetadata.put('enableSearch', true);
        objectMetadata.put('enableHistory', false);
        objectMetadata.put('enableLicensing', false);
        
        // Add fields
        List<Map<String, Object>> fields = new List<Map<String, Object>>();
        
        // Profile Name (Lookup)
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Class_Access__c.Profile_Name__c',
            'label' => 'Profile Name',
            'type' => 'Lookup',
            'referenceTo' => 'Profile_Admin__c',
            'relationshipName' => 'Class_Accesses',
            'relationshipLabel' => 'Class Accesses',
            'deleteConstraint' => 'SetNull'
        });
        
        // Apex Class field
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Class_Access__c.Apex_Class__c',
            'label' => 'Apex Class',
            'type' => 'Text',
            'length' => 255
        });
        
        // Enabled field
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Class_Access__c.Enabled__c',
            'label' => 'Enabled',
            'type' => 'Checkbox',
            'defaultValue' => false
        });
        
        objectMetadata.put('fields', fields);
        
        System.debug('Profile Class Access Object Metadata: ' + objectMetadata);
    }
    
    /**
     * Create Tab Visibility object
     */
    private static void createTabVisibilityObject() {
        Map<String, Object> objectMetadata = new Map<String, Object>();
        objectMetadata.put('fullName', 'Profile_Tab_Visibility__c');
        objectMetadata.put('label', 'Profile Tab Visibility');
        objectMetadata.put('pluralLabel', 'Profile Tab Visibilities');
        objectMetadata.put('nameField', new Map<String, Object>{
            'type' => 'AutoNumber',
            'label' => 'Tab Visibility Number',
            'displayFormat' => 'PTV-{0000}'
        });
        objectMetadata.put('deploymentStatus', 'Deployed');
        objectMetadata.put('enableSharing', true);
        objectMetadata.put('enableBulkApi', true);
        objectMetadata.put('enableStreamingApi', true);
        objectMetadata.put('enableReports', true);
        objectMetadata.put('enableSearch', true);
        objectMetadata.put('enableHistory', false);
        objectMetadata.put('enableLicensing', false);
        
        // Add fields
        List<Map<String, Object>> fields = new List<Map<String, Object>>();
        
        // Profile Name (Lookup)
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Tab_Visibility__c.Profile_Name__c',
            'label' => 'Profile Name',
            'type' => 'Lookup',
            'referenceTo' => 'Profile_Admin__c',
            'relationshipName' => 'Tab_Visibilities',
            'relationshipLabel' => 'Tab Visibilities',
            'deleteConstraint' => 'SetNull'
        });
        
        // Tab Name field
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Tab_Visibility__c.Tab_Name__c',
            'label' => 'Tab Name',
            'type' => 'Text',
            'length' => 255
        });
        
        // Visibility field
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Tab_Visibility__c.Visibility__c',
            'label' => 'Visibility',
            'type' => 'Text',
            'length' => 255
        });
        
        objectMetadata.put('fields', fields);
        
        System.debug('Profile Tab Visibility Object Metadata: ' + objectMetadata);
    }
    
    /**
     * Create Record Type Visibility object
     */
    private static void createRecordTypeVisibilityObject() {
        Map<String, Object> objectMetadata = new Map<String, Object>();
        objectMetadata.put('fullName', 'Profile_Record_Type_Visibility__c');
        objectMetadata.put('label', 'Profile Record Type Visibility');
        objectMetadata.put('pluralLabel', 'Profile Record Type Visibilities');
        objectMetadata.put('nameField', new Map<String, Object>{
            'type' => 'AutoNumber',
            'label' => 'Record Type Visibility Number',
            'displayFormat' => 'PRTV-{0000}'
        });
        objectMetadata.put('deploymentStatus', 'Deployed');
        objectMetadata.put('enableSharing', true);
        objectMetadata.put('enableBulkApi', true);
        objectMetadata.put('enableStreamingApi', true);
        objectMetadata.put('enableReports', true);
        objectMetadata.put('enableSearch', true);
        objectMetadata.put('enableHistory', false);
        objectMetadata.put('enableLicensing', false);
        
        // Add fields
        List<Map<String, Object>> fields = new List<Map<String, Object>>();
        
        // Profile Name (Lookup)
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Record_Type_Visibility__c.Profile_Name__c',
            'label' => 'Profile Name',
            'type' => 'Lookup',
            'referenceTo' => 'Profile_Admin__c',
            'relationshipName' => 'Record_Type_Visibilities',
            'relationshipLabel' => 'Record Type Visibilities',
            'deleteConstraint' => 'SetNull'
        });
        
        // Record Type field
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Record_Type_Visibility__c.Record_Type__c',
            'label' => 'Record Type',
            'type' => 'Text',
            'length' => 255
        });
        
        // Visible field
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Record_Type_Visibility__c.Visible__c',
            'label' => 'Visible',
            'type' => 'Checkbox',
            'defaultValue' => false
        });
        
        objectMetadata.put('fields', fields);
        
        System.debug('Profile Record Type Visibility Object Metadata: ' + objectMetadata);
    }
    
    /**
     * Create Layout Assignment object
     */
    private static void createLayoutAssignmentObject() {
        Map<String, Object> objectMetadata = new Map<String, Object>();
        objectMetadata.put('fullName', 'Profile_Layout_Assignment__c');
        objectMetadata.put('label', 'Profile Layout Assignment');
        objectMetadata.put('pluralLabel', 'Profile Layout Assignments');
        objectMetadata.put('nameField', new Map<String, Object>{
            'type' => 'AutoNumber',
            'label' => 'Layout Assignment Number',
            'displayFormat' => 'PLA-{0000}'
        });
        objectMetadata.put('deploymentStatus', 'Deployed');
        objectMetadata.put('enableSharing', true);
        objectMetadata.put('enableBulkApi', true);
        objectMetadata.put('enableStreamingApi', true);
        objectMetadata.put('enableReports', true);
        objectMetadata.put('enableSearch', true);
        objectMetadata.put('enableHistory', false);
        objectMetadata.put('enableLicensing', false);
        
        // Add fields
        List<Map<String, Object>> fields = new List<Map<String, Object>>();
        
        // Profile Name (Lookup)
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Layout_Assignment__c.Profile_Name__c',
            'label' => 'Profile Name',
            'type' => 'Lookup',
            'referenceTo' => 'Profile_Admin__c',
            'relationshipName' => 'Layout_Assignments',
            'relationshipLabel' => 'Layout Assignments',
            'deleteConstraint' => 'SetNull'
        });
        
        // Layout field
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Layout_Assignment__c.Layout__c',
            'label' => 'Layout',
            'type' => 'Text',
            'length' => 255
        });
        
        // Record Type field
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Layout_Assignment__c.Record_Type__c',
            'label' => 'Record Type',
            'type' => 'Checkbox',
            'defaultValue' => false
        });
        
        objectMetadata.put('fields', fields);
        
        System.debug('Profile Layout Assignment Object Metadata: ' + objectMetadata);
    }
    
    /**
     * Create Login Hours object
     */
    private static void createLoginHoursObject() {
        Map<String, Object> objectMetadata = new Map<String, Object>();
        objectMetadata.put('fullName', 'Profile_Login_Hours__c');
        objectMetadata.put('label', 'Profile Login Hours');
        objectMetadata.put('pluralLabel', 'Profile Login Hours');
        objectMetadata.put('nameField', new Map<String, Object>{
            'type' => 'AutoNumber',
            'label' => 'Login Hours Number',
            'displayFormat' => 'PLH-{0000}'
        });
        objectMetadata.put('deploymentStatus', 'Deployed');
        objectMetadata.put('enableSharing', true);
        objectMetadata.put('enableBulkApi', true);
        objectMetadata.put('enableStreamingApi', true);
        objectMetadata.put('enableReports', true);
        objectMetadata.put('enableSearch', true);
        objectMetadata.put('enableHistory', false);
        objectMetadata.put('enableLicensing', false);
        
        // Add fields
        List<Map<String, Object>> fields = new List<Map<String, Object>>();
        
        // Profile Name (Lookup)
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Login_Hours__c.Profile_Name__c',
            'label' => 'Profile Name',
            'type' => 'Lookup',
            'referenceTo' => 'Profile_Admin__c',
            'relationshipName' => 'Login_Hours',
            'relationshipLabel' => 'Login Hours',
            'deleteConstraint' => 'SetNull'
        });
        
        // Time fields
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Login_Hours__c.Weekday_Start__c',
            'label' => 'Weekday Start',
            'type' => 'Text',
            'length' => 10
        });
        
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Login_Hours__c.Weekday_End__c',
            'label' => 'Weekday End',
            'type' => 'Text',
            'length' => 10
        });
        
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Login_Hours__c.Weekend_Start__c',
            'label' => 'Weekend Start',
            'type' => 'Text',
            'length' => 10
        });
        
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Login_Hours__c.Weekend_End__c',
            'label' => 'Weekend End',
            'type' => 'Text',
            'length' => 10
        });
        
        objectMetadata.put('fields', fields);
        
        System.debug('Profile Login Hours Object Metadata: ' + objectMetadata);
    }
    
    /**
     * Create Login IP Ranges object
     */
    private static void createLoginIpRangesObject() {
        Map<String, Object> objectMetadata = new Map<String, Object>();
        objectMetadata.put('fullName', 'Profile_Login_Ip_Ranges__c');
        objectMetadata.put('label', 'Profile Login IP Ranges');
        objectMetadata.put('pluralLabel', 'Profile Login IP Ranges');
        objectMetadata.put('nameField', new Map<String, Object>{
            'type' => 'AutoNumber',
            'label' => 'Login IP Range Number',
            'displayFormat' => 'PLIR-{0000}'
        });
        objectMetadata.put('deploymentStatus', 'Deployed');
        objectMetadata.put('enableSharing', true);
        objectMetadata.put('enableBulkApi', true);
        objectMetadata.put('enableStreamingApi', true);
        objectMetadata.put('enableReports', true);
        objectMetadata.put('enableSearch', true);
        objectMetadata.put('enableHistory', false);
        objectMetadata.put('enableLicensing', false);
        
        // Add fields
        List<Map<String, Object>> fields = new List<Map<String, Object>>();
        
        // Profile Name (Lookup)
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Login_Ip_Ranges__c.Profile_Name__c',
            'label' => 'Profile Name',
            'type' => 'Lookup',
            'referenceTo' => 'Profile_Admin__c',
            'relationshipName' => 'Login_Ip_Ranges',
            'relationshipLabel' => 'Login IP Ranges',
            'deleteConstraint' => 'SetNull'
        });
        
        // IP Range fields
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Login_Ip_Ranges__c.Start_Address__c',
            'label' => 'Start Address',
            'type' => 'Text',
            'length' => 45
        });
        
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Login_Ip_Ranges__c.End_Address__c',
            'label' => 'End Address',
            'type' => 'Text',
            'length' => 45
        });
        
        fields.add(new Map<String, Object>{
            'fullName' => 'Profile_Login_Ip_Ranges__c.Description__c',
            'label' => 'Description',
            'type' => 'Text',
            'length' => 255
        });
        
        objectMetadata.put('fields', fields);
        
        System.debug('Profile Login IP Ranges Object Metadata: ' + objectMetadata);
    }
    
    /**
     * Custom exception class
     */
    public class ProfileXMLMetadataManagerException extends Exception {}
}