public class PermissionSetDataManager {
    
    // Inner class to represent permission set data structure
    public class PermissionSetData {
        public String name;
        public String description;
        public String label;
        public String userLicense;
        public List<ApplicationVisibility> applicationVisibilities;
        public List<UserPermission> userPermissions;
        public List<ObjectPermission> objectPermissions;
        public List<FieldPermission> fieldPermissions;
        public List<PageAccess> pageAccesses;
        public List<ClassAccess> classAccesses;
        public List<TabSetting> tabSettings;
        public List<RecordTypeVisibility> recordTypeVisibilities;
        
        public PermissionSetData() {
            applicationVisibilities = new List<ApplicationVisibility>();
            userPermissions = new List<UserPermission>();
            objectPermissions = new List<ObjectPermission>();
            fieldPermissions = new List<FieldPermission>();
            pageAccesses = new List<PageAccess>();
            classAccesses = new List<ClassAccess>();
            tabSettings = new List<TabSetting>();
            recordTypeVisibilities = new List<RecordTypeVisibility>();
        }
    }
    
    // Supporting classes for different permission types
    public class ApplicationVisibility {
        public String application;
        public Boolean visible;
    }
    
    public class UserPermission {
        public String name;
        public Boolean enabled;
    }
    
    public class ObjectPermission {
        public String objectName;
        public Boolean allowCreate;
        public Boolean allowDelete;
        public Boolean allowEdit;
        public Boolean allowRead;
        public Boolean viewAllRecords;
        public Boolean modifyAllRecords;
        public Boolean viewAllFields;
    }
    
    public class FieldPermission {
        public String field;
        public Boolean editable;
        public Boolean readable;
    }
    
    public class PageAccess {
        public String apexPage;
        public Boolean enabled;
    }
    
    public class ClassAccess {
        public String apexClass;
        public Boolean enabled;
    }
    
    public class TabSetting {
        public String tab;
        public String visibility;
    }
    
    public class RecordTypeVisibility {
        public String recordType;
        public Boolean visible;
    }
    
    /**
     * Parse permission set XML and create objects to store the data
     * @param permissionSetXml The XML string of the permission set
     * @param permissionSetName The name of the permission set
     */
    public static void parseAndStorePermissionSet(String permissionSetXml, String permissionSetName) {
        try {
            // Parse the XML
            PermissionSetData psData = parsePermissionSetXml(permissionSetXml);
            psData.name = permissionSetName;
            
            // Create the main permission set record
            createPermissionSetRecord(psData);
            
            // Create related records for each permission type
            createApplicationVisibilityRecords(psData);
            createUserPermissionRecords(psData);
            createObjectPermissionRecords(psData);
            createFieldPermissionRecords(psData);
            createPageAccessRecords(psData);
            createClassAccessRecords(psData);
            createTabSettingRecords(psData);
            createRecordTypeVisibilityRecords(psData);
            
            System.debug('Successfully parsed and stored permission set: ' + permissionSetName);
            
        } catch (Exception e) {
            System.debug('Error parsing permission set: ' + e.getMessage());
            throw new PermissionSetDataManagerException('Failed to parse permission set: ' + e.getMessage());
        }
    }
    
    /**
     * Parse the permission set XML string
     */
    private static PermissionSetData parsePermissionSetXml(String xmlString) {
        PermissionSetData psData = new PermissionSetData();
        
        // Use DOM parsing for XML
        Dom.Document doc = new Dom.Document();
        doc.load(xmlString);
        Dom.XmlNode root = doc.getRootElement();
        
        // Parse basic information
        psData.description = getNodeText(root, 'description');
        psData.label = getNodeText(root, 'label');
        psData.userLicense = getNodeText(root, 'userLicense');
        
        // Parse application visibilities
        Dom.XmlNode appVisNode = root.getChildElement('applicationVisibilities', null);
        if (appVisNode != null) {
            for (Dom.XmlNode child : appVisNode.getChildElements()) {
                if (child.getName() == 'applicationVisibilities') {
                    ApplicationVisibility av = new ApplicationVisibility();
                    av.application = getNodeText(child, 'application');
                    av.visible = Boolean.valueOf(getNodeText(child, 'visible'));
                    psData.applicationVisibilities.add(av);
                }
            }
        }
        
        // Parse user permissions
        Dom.XmlNode userPermNode = root.getChildElement('userPermissions', null);
        if (userPermNode != null) {
            for (Dom.XmlNode child : userPermNode.getChildElements()) {
                if (child.getName() == 'userPermissions') {
                    UserPermission up = new UserPermission();
                    up.name = getNodeText(child, 'name');
                    up.enabled = Boolean.valueOf(getNodeText(child, 'enabled'));
                    psData.userPermissions.add(up);
                }
            }
        }
        
        // Parse object permissions
        Dom.XmlNode objPermNode = root.getChildElement('objectPermissions', null);
        if (objPermNode != null) {
            for (Dom.XmlNode child : objPermNode.getChildElements()) {
                if (child.getName() == 'objectPermissions') {
                    ObjectPermission op = new ObjectPermission();
                    op.objectName = getNodeText(child, 'object');
                    op.allowCreate = Boolean.valueOf(getNodeText(child, 'allowCreate'));
                    op.allowDelete = Boolean.valueOf(getNodeText(child, 'allowDelete'));
                    op.allowEdit = Boolean.valueOf(getNodeText(child, 'allowEdit'));
                    op.allowRead = Boolean.valueOf(getNodeText(child, 'allowRead'));
                    op.viewAllRecords = Boolean.valueOf(getNodeText(child, 'viewAllRecords'));
                    op.modifyAllRecords = Boolean.valueOf(getNodeText(child, 'modifyAllRecords'));
                    op.viewAllFields = Boolean.valueOf(getNodeText(child, 'viewAllFields'));
                    psData.objectPermissions.add(op);
                }
            }
        }
        
        // Parse field permissions
        Dom.XmlNode fieldPermNode = root.getChildElement('fieldPermissions', null);
        if (fieldPermNode != null) {
            for (Dom.XmlNode child : fieldPermNode.getChildElements()) {
                if (child.getName() == 'fieldPermissions') {
                    FieldPermission fp = new FieldPermission();
                    fp.field = getNodeText(child, 'field');
                    fp.editable = Boolean.valueOf(getNodeText(child, 'editable'));
                    fp.readable = Boolean.valueOf(getNodeText(child, 'readable'));
                    psData.fieldPermissions.add(fp);
                }
            }
        }
        
        // Parse page accesses
        Dom.XmlNode pageAccessNode = root.getChildElement('pageAccesses', null);
        if (pageAccessNode != null) {
            for (Dom.XmlNode child : pageAccessNode.getChildElements()) {
                if (child.getName() == 'pageAccesses') {
                    PageAccess pa = new PageAccess();
                    pa.apexPage = getNodeText(child, 'apexPage');
                    pa.enabled = Boolean.valueOf(getNodeText(child, 'enabled'));
                    psData.pageAccesses.add(pa);
                }
            }
        }
        
        // Parse class accesses
        Dom.XmlNode classAccessNode = root.getChildElement('classAccesses', null);
        if (classAccessNode != null) {
            for (Dom.XmlNode child : classAccessNode.getChildElements()) {
                if (child.getName() == 'classAccesses') {
                    ClassAccess ca = new ClassAccess();
                    ca.apexClass = getNodeText(child, 'apexClass');
                    ca.enabled = Boolean.valueOf(getNodeText(child, 'enabled'));
                    psData.classAccesses.add(ca);
                }
            }
        }
        
        // Parse tab settings
        Dom.XmlNode tabSettingNode = root.getChildElement('tabSettings', null);
        if (tabSettingNode != null) {
            for (Dom.XmlNode child : tabSettingNode.getChildElements()) {
                if (child.getName() == 'tabSettings') {
                    TabSetting ts = new TabSetting();
                    ts.tab = getNodeText(child, 'tab');
                    ts.visibility = getNodeText(child, 'visibility');
                    psData.tabSettings.add(ts);
                }
            }
        }
        
        // Parse record type visibilities
        Dom.XmlNode recordTypeNode = root.getChildElement('recordTypeVisibilities', null);
        if (recordTypeNode != null) {
            for (Dom.XmlNode child : recordTypeNode.getChildElements()) {
                if (child.getName() == 'recordTypeVisibilities') {
                    RecordTypeVisibility rtv = new RecordTypeVisibility();
                    rtv.recordType = getNodeText(child, 'recordType');
                    rtv.visible = Boolean.valueOf(getNodeText(child, 'visible'));
                    psData.recordTypeVisibilities.add(rtv);
                }
            }
        }
        
        return psData;
    }
    
    /**
     * Helper method to get text from XML node
     */
    private static String getNodeText(Dom.XmlNode parent, String childName) {
        Dom.XmlNode child = parent.getChildElement(childName, null);
        return child != null ? child.getText() : '';
    }
    
    /**
     * Create the main permission set record
     */
    private static void createPermissionSetRecord(PermissionSetData psData) {
        // This would create a record in a custom object
        // For now, we'll use a Map to simulate the object structure
        Map<String, Object> permissionSetRecord = new Map<String, Object>();
        permissionSetRecord.put('Name', psData.name);
        permissionSetRecord.put('Description__c', psData.description);
        permissionSetRecord.put('Label__c', psData.label);
        permissionSetRecord.put('User_License__c', psData.userLicense);
        
        System.debug('Permission Set Record: ' + permissionSetRecord);
    }
    
    /**
     * Create application visibility records
     */
    private static void createApplicationVisibilityRecords(PermissionSetData psData) {
        for (ApplicationVisibility av : psData.applicationVisibilities) {
            Map<String, Object> record = new Map<String, Object>();
            record.put('Permission_Set_Name__c', psData.name);
            record.put('Application__c', av.application);
            record.put('Visible__c', av.visible);
            
            System.debug('Application Visibility Record: ' + record);
        }
    }
    
    /**
     * Create user permission records
     */
    private static void createUserPermissionRecords(PermissionSetData psData) {
        for (UserPermission up : psData.userPermissions) {
            Map<String, Object> record = new Map<String, Object>();
            record.put('Permission_Set_Name__c', psData.name);
            record.put('Permission_Name__c', up.name);
            record.put('Enabled__c', up.enabled);
            
            System.debug('User Permission Record: ' + record);
        }
    }
    
    /**
     * Create object permission records
     */
    private static void createObjectPermissionRecords(PermissionSetData psData) {
        for (ObjectPermission op : psData.objectPermissions) {
            Map<String, Object> record = new Map<String, Object>();
            record.put('Permission_Set_Name__c', psData.name);
            record.put('Object_Name__c', op.objectName);
            record.put('Allow_Create__c', op.allowCreate);
            record.put('Allow_Delete__c', op.allowDelete);
            record.put('Allow_Edit__c', op.allowEdit);
            record.put('Allow_Read__c', op.allowRead);
            record.put('View_All_Records__c', op.viewAllRecords);
            record.put('Modify_All_Records__c', op.modifyAllRecords);
            record.put('View_All_Fields__c', op.viewAllFields);
            
            System.debug('Object Permission Record: ' + record);
        }
    }
    
    /**
     * Create field permission records
     */
    private static void createFieldPermissionRecords(PermissionSetData psData) {
        for (FieldPermission fp : psData.fieldPermissions) {
            Map<String, Object> record = new Map<String, Object>();
            record.put('Permission_Set_Name__c', psData.name);
            record.put('Field_Name__c', fp.field);
            record.put('Editable__c', fp.editable);
            record.put('Readable__c', fp.readable);
            
            System.debug('Field Permission Record: ' + record);
        }
    }
    
    /**
     * Create page access records
     */
    private static void createPageAccessRecords(PermissionSetData psData) {
        for (PageAccess pa : psData.pageAccesses) {
            Map<String, Object> record = new Map<String, Object>();
            record.put('Permission_Set_Name__c', psData.name);
            record.put('Apex_Page__c', pa.apexPage);
            record.put('Enabled__c', pa.enabled);
            
            System.debug('Page Access Record: ' + record);
        }
    }
    
    /**
     * Create class access records
     */
    private static void createClassAccessRecords(PermissionSetData psData) {
        for (ClassAccess ca : psData.classAccesses) {
            Map<String, Object> record = new Map<String, Object>();
            record.put('Permission_Set_Name__c', psData.name);
            record.put('Apex_Class__c', ca.apexClass);
            record.put('Enabled__c', ca.enabled);
            
            System.debug('Class Access Record: ' + record);
        }
    }
    
    /**
     * Create tab setting records
     */
    private static void createTabSettingRecords(PermissionSetData psData) {
        for (TabSetting ts : psData.tabSettings) {
            Map<String, Object> record = new Map<String, Object>();
            record.put('Permission_Set_Name__c', psData.name);
            record.put('Tab_Name__c', ts.tab);
            record.put('Visibility__c', ts.visibility);
            
            System.debug('Tab Setting Record: ' + record);
        }
    }
    
    /**
     * Create record type visibility records
     */
    private static void createRecordTypeVisibilityRecords(PermissionSetData psData) {
        for (RecordTypeVisibility rtv : psData.recordTypeVisibilities) {
            Map<String, Object> record = new Map<String, Object>();
            record.put('Permission_Set_Name__c', psData.name);
            record.put('Record_Type__c', rtv.recordType);
            record.put('Visible__c', rtv.visible);
            
            System.debug('Record Type Visibility Record: ' + record);
        }
    }
    
    /**
     * Custom exception class
     */
    public class PermissionSetDataManagerException extends Exception {}
}