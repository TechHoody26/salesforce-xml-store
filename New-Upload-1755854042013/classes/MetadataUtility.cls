/**
 * Utility class for Metadata API operations
 * This class provides methods for creating custom fields dynamically and processing Permission Set XML
 */
public class MetadataUtility {
    
    /**
     * Creates a custom field on an object
     */
    public static void createCustomField(String objectName, String fieldName, String fieldType, Map<String, Object> properties) {
        // This is a placeholder for Metadata API calls
        // In a real implementation, you would use the Metadata API
        System.debug('Creating field: ' + fieldName + ' on object: ' + objectName + ' of type: ' + fieldType);
        System.debug('Properties: ' + properties);
        
        // Log the field creation details
        String logMessage = 'Field Creation Request:' +
            '\nObject: ' + objectName +
            '\nField: ' + fieldName +
            '\nType: ' + fieldType +
            '\nProperties: ' + properties;
        
        System.debug(logMessage);
    }
    
    /**
     * Creates a picklist field
     */
    public static void createPicklistField(String objectName, String fieldName, String label, List<String> values) {
        Map<String, Object> properties = new Map<String, Object>();
        properties.put('label', label);
        properties.put('type', 'Picklist');
        properties.put('values', values);
        properties.put('required', false);
        
        createCustomField(objectName, fieldName, 'Picklist', properties);
    }
    
    /**
     * Creates a boolean field
     */
    public static void createBooleanField(String objectName, String fieldName, String label) {
        Map<String, Object> properties = new Map<String, Object>();
        properties.put('label', label);
        properties.put('type', 'Checkbox');
        properties.put('defaultValue', false);
        
        createCustomField(objectName, fieldName, 'Checkbox', properties);
    }
    
    /**
     * Creates a text field
     */
    public static void createTextField(String objectName, String fieldName, String label, Integer length) {
        Map<String, Object> properties = new Map<String, Object>();
        properties.put('label', label);
        properties.put('type', 'Text');
        properties.put('length', length);
        properties.put('required', false);
        
        createCustomField(objectName, fieldName, 'Text', properties);
    }
    
    /**
     * Creates a multiselect picklist field
     */
    public static void createMultiselectPicklistField(String objectName, String fieldName, String label, List<String> values) {
        Map<String, Object> properties = new Map<String, Object>();
        properties.put('label', label);
        properties.put('type', 'MultiselectPicklist');
        properties.put('values', values);
        properties.put('required', false);
        
        createCustomField(objectName, fieldName, 'MultiselectPicklist', properties);
    }
    
    /**
     * Checks if a field exists on an object
     */
    public static Boolean fieldExists(String objectName, String fieldName) {
        try {
            // Try to describe the field
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
            if (sObjectType != null) {
                Schema.SObjectField sObjectField = sObjectType.getDescribe().fields.getMap().get(fieldName);
                return sObjectField != null;
            }
        } catch (Exception e) {
            System.debug('Error checking if field exists: ' + e.getMessage());
        }
        return false;
    }
    
    /**
     * Gets all field names for an object
     */
    public static Set<String> getObjectFieldNames(String objectName) {
        Set<String> fieldNames = new Set<String>();
        try {
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
            if (sObjectType != null) {
                Map<String, Schema.SObjectField> fieldMap = sObjectType.getDescribe().fields.getMap();
                fieldNames.addAll(fieldMap.keySet());
            }
        } catch (Exception e) {
            System.debug('Error getting field names: ' + e.getMessage());
        }
        return fieldNames;
    }
    
    /**
     * Validates field name according to Salesforce naming conventions
     */
    public static Boolean isValidFieldName(String fieldName) {
        if (String.isBlank(fieldName)) {
            return false;
        }
        
        // Check length (max 40 characters for custom fields)
        if (fieldName.length() > 40) {
            return false;
        }
        
        // Check for valid characters (letters, numbers, underscores)
        // Use Pattern class for regex matching
        Pattern validPattern = Pattern.compile('^[a-zA-Z][a-zA-Z0-9_]*$');
        Matcher matcher = validPattern.matcher(fieldName);
        return matcher.matches();
    }
    
    /**
     * Generates a valid field API name
     */
    public static String generateFieldApiName(String label) {
        if (String.isBlank(label)) {
            return null;
        }
        
        // Remove special characters and spaces, replace with underscores
        String apiName = label.replaceAll('[^a-zA-Z0-9]', '_');
        
        // Remove multiple consecutive underscores
        apiName = apiName.replaceAll('_+', '_');
        
        // Remove leading/trailing underscores
        apiName = apiName.removeStart('_').removeEnd('_');
        
        // Ensure it starts with a letter
        Pattern letterPattern = Pattern.compile('^[a-zA-Z].*');
        Matcher letterMatcher = letterPattern.matcher(apiName);
        if (!letterMatcher.matches()) {
            apiName = 'Field_' + apiName;
        }
        
        // Ensure it ends with __c for custom fields
        if (!apiName.endsWith('__c')) {
            apiName += '__c';
        }
        
        // Truncate if too long
        if (apiName.length() > 40) {
            apiName = apiName.substring(0, 37) + '__c';
        }
        
        return apiName;
    }
    
    /**
     * Dynamic Permission Set XML Processor
     * This method can handle any permission type automatically without code changes
     * It dynamically creates records based on the XML structure
     */
    public static void processPermissionSetXMLDynamic(String xmlContent) {
        try {
            System.debug('=== Starting Dynamic Permission Set XML Processing ===');
            
            // Parse the XML
            Dom.Document doc = new Dom.Document();
            doc.load(xmlContent);
            Dom.XMLNode root = doc.getRootElement();
            
            // Extract basic permission set information
            String label = getNodeText(root, 'label');
            String description = getNodeText(root, 'description');
            String userLicense = getNodeText(root, 'userLicense');
            Boolean hasActivationRequired = Boolean.valueOf(getNodeText(root, 'hasActivationRequired'));
            
            System.debug('Permission Set Label: ' + label);
            System.debug('Description: ' + description);
            System.debug('User License: ' + userLicense);
            System.debug('Has Activation Required: ' + hasActivationRequired);
            
            // Create master permission set record
            Permission_Set__c masterRecord = new Permission_Set__c();
            masterRecord.Label__c = label;
            masterRecord.Description__c = description;
            masterRecord.User_License__c = userLicense;
            
            insert masterRecord;
            System.debug('Created master Permission Set record with ID: ' + masterRecord.Id);
            
            // Process all child nodes dynamically
            processAllPermissionTypes(root, masterRecord.Id, label);
            
            System.debug('=== Dynamic XML Processing Completed Successfully ===');
            
        } catch (Exception e) {
            System.debug('Error processing Permission Set XML: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new MetadataUtilityException('Error processing Permission Set XML: ' + e.getMessage());
        }
    }
    
    /**
     * Process all permission types dynamically
     * This method automatically detects and processes any permission type
     */
    private static void processAllPermissionTypes(Dom.XMLNode root, Id permissionSetId, String permissionSetName) {
        // Define permission type mappings
        Map<String, PermissionTypeConfig> permissionTypeConfigs = getPermissionTypeConfigs();
        
        // Group nodes by type
        Map<String, List<Dom.XMLNode>> permissionGroups = new Map<String, List<Dom.XMLNode>>();
        
        for (Dom.XMLNode child : root.getChildElements()) {
            String nodeName = child.getName();
            
            // Skip basic permission set fields
            if (nodeName == 'label' || nodeName == 'description' || nodeName == 'userLicense' || 
                nodeName == 'hasActivationRequired') {
                continue;
            }
            
            // Group by permission type
            if (!permissionGroups.containsKey(nodeName)) {
                permissionGroups.put(nodeName, new List<Dom.XMLNode>());
            }
            permissionGroups.get(nodeName).add(child);
        }
        
        System.debug('Found permission types: ' + permissionGroups.keySet());
        
        // Process each permission type
        for (String permissionType : permissionGroups.keySet()) {
            List<Dom.XMLNode> nodes = permissionGroups.get(permissionType);
            
            if (permissionTypeConfigs.containsKey(permissionType)) {
                PermissionTypeConfig config = permissionTypeConfigs.get(permissionType);
                processPermissionType(nodes, permissionSetId, permissionSetName, config);
            } else {
                // Handle unknown permission types by storing as generic data
                processUnknownPermissionType(nodes, permissionSetId, permissionSetName, permissionType);
            }
        }
    }
    
    /**
     * Process a specific permission type using its configuration
     */
    private static void processPermissionType(List<Dom.XMLNode> nodes, Id permissionSetId, 
                                            String permissionSetName, PermissionTypeConfig config) {
        try {
            List<SObject> records = new List<SObject>();
            Map<String, Id> objectPermissionMap = new Map<String, Id>();
            
            // First, get or create Object Permission records for the objects referenced in this permission set
            if (config.objectType == 'Field_Permission__c' || config.objectType == 'Tab_Setting__c' || 
                config.objectType == 'Record_Type_Visibility__c') {
                objectPermissionMap = getOrCreateObjectPermissions(nodes, permissionSetId, permissionSetName);
            }
            
            for (Dom.XMLNode node : nodes) {
                SObject record = (SObject)Type.forName(config.objectType).newInstance();
                
                // Set the permission set relationship
                record.put(config.permissionSetField, permissionSetId);
                
                // Set permission set name if the field exists
                if (config.permissionSetNameField != null) {
                    record.put(config.permissionSetNameField, permissionSetName);
                }
                
                // Process all child nodes dynamically
                for (Dom.XMLNode child : node.getChildElements()) {
                    String fieldName = child.getName();
                    String fieldValue = child.getText();
                    
                    if (config.fieldMappings.containsKey(fieldName)) {
                        String mappedField = config.fieldMappings.get(fieldName);
                        Object convertedValue = convertValue(fieldValue, config.fieldTypes.get(fieldName));
                        record.put(mappedField, convertedValue);
                    }
                }
                
                // Set Object Permission lookup if applicable
                if (config.objectType == 'Field_Permission__c' || config.objectType == 'Tab_Setting__c' || 
                    config.objectType == 'Record_Type_Visibility__c') {
                    String objectName = extractObjectName(record, config.objectType);
                    if (objectPermissionMap.containsKey(objectName)) {
                        record.put('Object_Permission__c', objectPermissionMap.get(objectName));
                    }
                }
                
                records.add(record);
            }
            
            if (!records.isEmpty()) {
                insert records;
                System.debug('Created ' + records.size() + ' ' + config.objectType + ' records');
            }
            
        } catch (Exception e) {
            System.debug('Error processing ' + config.objectType + ': ' + e.getMessage());
        }
    }
    
    /**
     * Process unknown permission types by storing as generic data
     */
    private static void processUnknownPermissionType(List<Dom.XMLNode> nodes, Id permissionSetId, 
                                                   String permissionSetName, String permissionType) {
        System.debug('Processing unknown permission type: ' + permissionType);
        
        // Store unknown permission types in a generic way
        // This could be extended to create dynamic custom objects or store in a generic table
        for (Dom.XMLNode node : nodes) {
            Map<String, Object> permissionData = new Map<String, Object>();
            permissionData.put('permissionType', permissionType);
            permissionData.put('permissionSetId', permissionSetId);
            permissionData.put('permissionSetName', permissionSetName);
            
            for (Dom.XMLNode child : node.getChildElements()) {
                permissionData.put(child.getName(), child.getText());
            }
            
            System.debug('Unknown permission data: ' + permissionData);
        }
    }
    
    /**
     * Convert string value to appropriate data type
     */
    private static Object convertValue(String value, String dataType) {
        if (String.isBlank(value)) {
            return null;
        }
        
        switch on dataType.toLowerCase() {
            when 'boolean' {
                return Boolean.valueOf(value);
            }
            when 'integer' {
                return Integer.valueOf(value);
            }
            when 'double' {
                return Double.valueOf(value);
            }
            when 'date' {
                return Date.valueOf(value);
            }
            when 'datetime' {
                return DateTime.valueOf(value);
            }
            when else {
                return value;
            }
        }
    }
    
    /**
     * Get or create Object Permission records for the objects referenced in the permission set
     */
    private static Map<String, Id> getOrCreateObjectPermissions(List<Dom.XMLNode> nodes, Id permissionSetId, String permissionSetName) {
        Map<String, Id> objectPermissionMap = new Map<String, Id>();
        Set<String> objectNames = new Set<String>();
        
        // Extract object names from the nodes
        for (Dom.XMLNode node : nodes) {
            String objectName = extractObjectNameFromNode(node);
            if (String.isNotBlank(objectName)) {
                objectNames.add(objectName);
            }
        }
        
        // Check for existing Object Permission records
        List<Object_Permission__c> existingPermissions = [
            SELECT Id, Object__c 
            FROM Object_Permission__c 
            WHERE Permission_Set__c = :permissionSetId 
            AND Object__c IN :objectNames
        ];
        
        for (Object_Permission__c op : existingPermissions) {
            objectPermissionMap.put(op.Object__c, op.Id);
        }
        
        // Create new Object Permission records for missing objects
        List<Object_Permission__c> newPermissions = new List<Object_Permission__c>();
        for (String objectName : objectNames) {
            if (!objectPermissionMap.containsKey(objectName)) {
                Object_Permission__c newOp = new Object_Permission__c(
                    Permission_Set__c = permissionSetId,
                    Object__c = objectName,
                    Allow_Create__c = false,
                    Allow_Delete__c = false,
                    Allow_Edit__c = false,
                    Allow_Read__c = true,
                    Modify_All_Records__c = false,
                    View_All_Fields__c = false,
                    View_All_Records__c = false
                );
                newPermissions.add(newOp);
            }
        }
        
        if (!newPermissions.isEmpty()) {
            insert newPermissions;
            for (Object_Permission__c op : newPermissions) {
                objectPermissionMap.put(op.Object__c, op.Id);
            }
        }
        
        return objectPermissionMap;
    }
    
    /**
     * Extract object name from XML node
     */
    private static String extractObjectNameFromNode(Dom.XMLNode node) {
        for (Dom.XMLNode child : node.getChildElements()) {
            if (child.getName() == 'field' || child.getName() == 'tab' || child.getName() == 'recordType') {
                String value = child.getText();
                if (String.isNotBlank(value) && value.contains('.')) {
                    return value.split('\\.')[0];
                }
            }
        }
        return null;
    }
    
    /**
     * Extract object name from SObject record
     */
    private static String extractObjectName(SObject record, String objectType) {
        if (objectType == 'Field_Permission__c') {
            String fieldValue = (String)record.get('Field__c');
            if (String.isNotBlank(fieldValue) && fieldValue.contains('.')) {
                return fieldValue.split('\\.')[0];
            }
        } else if (objectType == 'Tab_Setting__c') {
            String tabValue = (String)record.get('Tab__c');
            if (String.isNotBlank(tabValue) && tabValue.contains('.')) {
                return tabValue.split('\\.')[0];
            }
        } else if (objectType == 'Record_Type_Visibility__c') {
            String recordTypeValue = (String)record.get('Record_Type__c');
            if (String.isNotBlank(recordTypeValue) && recordTypeValue.contains('.')) {
                return recordTypeValue.split('\\.')[0];
            }
        }
        return null;
    }
    
    /**
     * Get permission type configurations
     * This defines how each permission type should be processed
     */
    private static Map<String, PermissionTypeConfig> getPermissionTypeConfigs() {
        Map<String, PermissionTypeConfig> configs = new Map<String, PermissionTypeConfig>();
        
        // Field Permissions Configuration
        PermissionTypeConfig fieldConfig = new PermissionTypeConfig();
        fieldConfig.objectType = 'Field_Permission__c';
        fieldConfig.permissionSetField = 'Permission_Set__c';
        fieldConfig.permissionSetNameField = null; // Don't set Permission_Set_Name__c as it's a lookup field
        fieldConfig.fieldMappings = new Map<String, String>{
            'field' => 'Field__c',
            'editable' => 'Editable__c',
            'readable' => 'Readable__c'
        };
        fieldConfig.fieldTypes = new Map<String, String>{
            'field' => 'string',
            'editable' => 'boolean',
            'readable' => 'boolean'
        };
        configs.put('fieldPermissions', fieldConfig);
        
        // Object Permissions Configuration
        PermissionTypeConfig objectConfig = new PermissionTypeConfig();
        objectConfig.objectType = 'Object_Permission__c';
        objectConfig.permissionSetField = 'Permission_Set__c';
        objectConfig.permissionSetNameField = null; // Don't set Permission_Set_Name__c as it's a lookup field
        objectConfig.fieldMappings = new Map<String, String>{
            'object' => 'Object__c',
            'allowCreate' => 'Allow_Create__c',
            'allowDelete' => 'Allow_Delete__c',
            'allowEdit' => 'Allow_Edit__c',
            'allowRead' => 'Allow_Read__c',
            'modifyAllRecords' => 'Modify_All_Records__c',
            'viewAllFields' => 'View_All_Fields__c',
            'viewAllRecords' => 'View_All_Records__c'
        };
        objectConfig.fieldTypes = new Map<String, String>{
            'object' => 'string',
            'allowCreate' => 'boolean',
            'allowDelete' => 'boolean',
            'allowEdit' => 'boolean',
            'allowRead' => 'boolean',
            'modifyAllRecords' => 'boolean',
            'viewAllFields' => 'boolean',
            'viewAllRecords' => 'boolean'
        };
        configs.put('objectPermissions', objectConfig);
        
        // Tab Settings Configuration
        PermissionTypeConfig tabConfig = new PermissionTypeConfig();
        tabConfig.objectType = 'Tab_Setting__c';
        tabConfig.permissionSetField = 'Permission_Set__c';
        tabConfig.permissionSetNameField = null; // No permission set name field
        tabConfig.fieldMappings = new Map<String, String>{
            'tab' => 'Tab__c',
            'visibility' => 'Visibility__c'
        };
        tabConfig.fieldTypes = new Map<String, String>{
            'tab' => 'string',
            'visibility' => 'string'
        };
        configs.put('tabSettings', tabConfig);
        
        // Class Access Configuration
        PermissionTypeConfig classConfig = new PermissionTypeConfig();
        classConfig.objectType = 'Class_Access__c';
        classConfig.permissionSetField = 'Permission_Set__c';
        classConfig.permissionSetNameField = null;
        classConfig.fieldMappings = new Map<String, String>{
            'apexClass' => 'Apex_Class__c',
            'enabled' => 'Enabled__c'
        };
        classConfig.fieldTypes = new Map<String, String>{
            'apexClass' => 'string',
            'enabled' => 'boolean'
        };
        configs.put('classAccesses', classConfig);
        
        // Record Type Visibility Configuration
        PermissionTypeConfig recordTypeConfig = new PermissionTypeConfig();
        recordTypeConfig.objectType = 'Record_Type_Visibility__c';
        recordTypeConfig.permissionSetField = 'Permission_Set__c';
        recordTypeConfig.permissionSetNameField = null;
        recordTypeConfig.fieldMappings = new Map<String, String>{
            'recordType' => 'Record_Type__c',
            'visible' => 'Visible__c'
        };
        recordTypeConfig.fieldTypes = new Map<String, String>{
            'recordType' => 'string',
            'visible' => 'boolean'
        };
        configs.put('recordTypeVisibilities', recordTypeConfig);
        
        // Page Access Configuration
        PermissionTypeConfig pageConfig = new PermissionTypeConfig();
        pageConfig.objectType = 'Page_Access__c';
        pageConfig.permissionSetField = 'Permission_Set__c';
        pageConfig.permissionSetNameField = null; // Don't set Permission_Set_Name__c as it's a lookup field
        pageConfig.fieldMappings = new Map<String, String>{
            'apexPage' => 'Apex_Page__c',
            'enabled' => 'Enabled__c'
        };
        pageConfig.fieldTypes = new Map<String, String>{
            'apexPage' => 'string',
            'enabled' => 'boolean'
        };
        configs.put('pageAccesses', pageConfig);
        
        // Application Visibility Configuration
        PermissionTypeConfig appConfig = new PermissionTypeConfig();
        appConfig.objectType = 'Application_Visibility__c';
        appConfig.permissionSetField = 'Permission_Set__c';
        appConfig.permissionSetNameField = null; // Don't set Permission_Set_Name__c as it's a lookup field
        appConfig.fieldMappings = new Map<String, String>{
            'application' => 'Application__c',
            'visible' => 'Visible__c'
        };
        appConfig.fieldTypes = new Map<String, String>{
            'application' => 'string',
            'visible' => 'boolean'
        };
        configs.put('applicationVisibilities', appConfig);
        
        // User Permission Configuration
        PermissionTypeConfig userConfig = new PermissionTypeConfig();
        userConfig.objectType = 'User_Permission__c';
        userConfig.permissionSetField = 'Permission_Set__c';
        userConfig.permissionSetNameField = null; // Don't set Permission_Set_Name__c as it's a lookup field
        userConfig.fieldMappings = new Map<String, String>{
            'name' => 'Permission_Name__c',
            'enabled' => 'Enabled__c'
        };
        userConfig.fieldTypes = new Map<String, String>{
            'name' => 'string',
            'enabled' => 'boolean'
        };
        configs.put('userPermissions', userConfig);
        
        return configs;
    }
    
    /**
     * Configuration class for permission types
     */
    public class PermissionTypeConfig {
        public String objectType;
        public String permissionSetField;
        public String permissionSetNameField;
        public Map<String, String> fieldMappings;
        public Map<String, String> fieldTypes;
    }
    
    /**
     * Process Permission Set XML and store data in custom objects
     * This method properly handles the XML namespace and stores all permission data
     */
    public static void processPermissionSetXML(String xmlContent) {
        try {
            System.debug('Starting to process Permission Set XML...');
            
            // Parse the XML with namespace handling
            Dom.Document doc = new Dom.Document();
            doc.load(xmlContent);
            Dom.XMLNode root = doc.getRootElement();
            
            // Extract basic permission set information
            String label = getNodeText(root, 'label');
            String description = getNodeText(root, 'description');
            String userLicense = getNodeText(root, 'userLicense');
            Boolean hasActivationRequired = Boolean.valueOf(getNodeText(root, 'hasActivationRequired'));
            
            System.debug('Permission Set Label: ' + label);
            System.debug('Description: ' + description);
            System.debug('User License: ' + userLicense);
            System.debug('Has Activation Required: ' + hasActivationRequired);
            
            // Create master permission set record
            Permission_Set__c masterRecord = new Permission_Set__c();
            masterRecord.Label__c = label;
            masterRecord.Description__c = description;
            masterRecord.User_License__c = userLicense;
            
            insert masterRecord;
            System.debug('Created master Permission Set record with ID: ' + masterRecord.Id);
            
            // Process field permissions
            processFieldPermissions(root, masterRecord.Id);
            
            // Process object permissions
            processObjectPermissions(root, masterRecord.Id);
            
            // Process other permission types if they exist
            processTabSettings(root, masterRecord.Id);
            processClassAccesses(root, masterRecord.Id);
            processRecordTypeVisibilities(root, masterRecord.Id);
            processPageAccesses(root, masterRecord.Id);
            processApplicationVisibilities(root, masterRecord.Id);
            processUserPermissions(root, masterRecord.Id);
            
            System.debug('Successfully processed and stored all Permission Set data');
            
        } catch (Exception e) {
            System.debug('Error processing Permission Set XML: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new MetadataUtilityException('Error processing Permission Set XML: ' + e.getMessage());
        }
    }
    
    /**
     * Process field permissions from XML and store in Field_Permission__c objects
     */
    private static void processFieldPermissions(Dom.XMLNode root, Id permissionSetId) {
        List<Field_Permission__c> fieldPermissions = new List<Field_Permission__c>();
        
        for (Dom.XMLNode child : root.getChildElements()) {
            if (child.getName() == 'fieldPermissions') {
                Field_Permission__c fp = new Field_Permission__c();
                fp.Permission_Set__c = permissionSetId;
                fp.Permission_Set_Name__c = getNodeText(root, 'label'); // Store the permission set name
                
                // Extract field permission data
                fp.Field__c = getNodeText(child, 'field');
                fp.Field_Name__c = getNodeText(child, 'field'); // Store field name separately
                fp.Editable__c = Boolean.valueOf(getNodeText(child, 'editable'));
                fp.Readable__c = Boolean.valueOf(getNodeText(child, 'readable'));
                
                System.debug('Processing field permission: ' + fp.Field__c + 
                           ' - Editable: ' + fp.Editable__c + 
                           ' - Readable: ' + fp.Readable__c);
                
                fieldPermissions.add(fp);
            }
        }
        
        if (!fieldPermissions.isEmpty()) {
            insert fieldPermissions;
            System.debug('Created ' + fieldPermissions.size() + ' field permission records');
        }
    }
    
    /**
     * Process object permissions from XML and store in Object_Permission__c objects
     */
    private static void processObjectPermissions(Dom.XMLNode root, Id permissionSetId) {
        List<Object_Permission__c> objectPermissions = new List<Object_Permission__c>();
        
        for (Dom.XMLNode child : root.getChildElements()) {
            if (child.getName() == 'objectPermissions') {
                Object_Permission__c op = new Object_Permission__c();
                op.Permission_Set__c = permissionSetId;
                op.Permission_Set_Name__c = getNodeText(root, 'label'); // Store the permission set name
                
                // Extract object permission data
                op.Object__c = getNodeText(child, 'object');
                op.Object_Name__c = getNodeText(child, 'object'); // Store object name separately
                op.Allow_Create__c = Boolean.valueOf(getNodeText(child, 'allowCreate'));
                op.Allow_Delete__c = Boolean.valueOf(getNodeText(child, 'allowDelete'));
                op.Allow_Edit__c = Boolean.valueOf(getNodeText(child, 'allowEdit'));
                op.Allow_Read__c = Boolean.valueOf(getNodeText(child, 'allowRead'));
                op.Modify_All_Records__c = Boolean.valueOf(getNodeText(child, 'modifyAllRecords'));
                op.View_All_Fields__c = Boolean.valueOf(getNodeText(child, 'viewAllFields'));
                op.View_All_Records__c = Boolean.valueOf(getNodeText(child, 'viewAllRecords'));
                
                System.debug('Processing object permission: ' + op.Object__c + 
                           ' - Create: ' + op.Allow_Create__c + 
                           ' - Read: ' + op.Allow_Read__c + 
                           ' - Edit: ' + op.Allow_Edit__c + 
                           ' - Delete: ' + op.Allow_Delete__c);
                
                objectPermissions.add(op);
            }
        }
        
        if (!objectPermissions.isEmpty()) {
            insert objectPermissions;
            System.debug('Created ' + objectPermissions.size() + ' object permission records');
        }
    }
    
    /**
     * Process tab settings from XML and store in Tab_Setting__c objects
     */
    private static void processTabSettings(Dom.XMLNode root, Id permissionSetId) {
        List<Tab_Setting__c> tabSettings = new List<Tab_Setting__c>();
        
        for (Dom.XMLNode child : root.getChildElements()) {
            if (child.getName() == 'tabSettings') {
                Tab_Setting__c ts = new Tab_Setting__c();
                ts.Permission_Set__c = permissionSetId;
                ts.Tab__c = getNodeText(child, 'tab');
                ts.Visibility__c = getNodeText(child, 'visibility');
                tabSettings.add(ts);
            }
        }
        
        if (!tabSettings.isEmpty()) {
            insert tabSettings;
            System.debug('Created ' + tabSettings.size() + ' tab setting records');
        }
    }
    
    /**
     * Process class accesses from XML and store in Class_Access__c objects
     */
    private static void processClassAccesses(Dom.XMLNode root, Id permissionSetId) {
        List<Class_Access__c> classAccesses = new List<Class_Access__c>();
        
        for (Dom.XMLNode child : root.getChildElements()) {
            if (child.getName() == 'classAccesses') {
                Class_Access__c ca = new Class_Access__c();
                ca.Permission_Set__c = permissionSetId;
                ca.Apex_Class__c = getNodeText(child, 'apexClass');
                ca.Enabled__c = Boolean.valueOf(getNodeText(child, 'enabled'));
                classAccesses.add(ca);
            }
        }
        
        if (!classAccesses.isEmpty()) {
            insert classAccesses;
            System.debug('Created ' + classAccesses.size() + ' class access records');
        }
    }
    
    /**
     * Process record type visibilities from XML and store in Record_Type_Visibility__c objects
     */
    private static void processRecordTypeVisibilities(Dom.XMLNode root, Id permissionSetId) {
        List<Record_Type_Visibility__c> recordTypeVisibilities = new List<Record_Type_Visibility__c>();
        
        for (Dom.XMLNode child : root.getChildElements()) {
            if (child.getName() == 'recordTypeVisibilities') {
                Record_Type_Visibility__c rtv = new Record_Type_Visibility__c();
                rtv.Permission_Set__c = permissionSetId;
                rtv.Record_Type__c = getNodeText(child, 'recordType');
                rtv.Visible__c = Boolean.valueOf(getNodeText(child, 'visible'));
                recordTypeVisibilities.add(rtv);
            }
        }
        
        if (!recordTypeVisibilities.isEmpty()) {
            insert recordTypeVisibilities;
            System.debug('Created ' + recordTypeVisibilities.size() + ' record type visibility records');
        }
    }
    
    /**
     * Process page accesses from XML and store in Page_Access__c objects
     */
    private static void processPageAccesses(Dom.XMLNode root, Id permissionSetId) {
        List<Page_Access__c> pageAccesses = new List<Page_Access__c>();
        
        for (Dom.XMLNode child : root.getChildElements()) {
            if (child.getName() == 'pageAccesses') {
                Page_Access__c pa = new Page_Access__c();
                pa.Permission_Set__c = permissionSetId;
                pa.Permission_Set_Name__c = getNodeText(root, 'label'); // Store the permission set name
                pa.Apex_Page__c = getNodeText(child, 'apexPage');
                pa.Enabled__c = Boolean.valueOf(getNodeText(child, 'enabled'));
                pageAccesses.add(pa);
            }
        }
        
        if (!pageAccesses.isEmpty()) {
            insert pageAccesses;
            System.debug('Created ' + pageAccesses.size() + ' page access records');
        }
    }
    
    /**
     * Process application visibilities from XML and store in Application_Visibility__c objects
     */
    private static void processApplicationVisibilities(Dom.XMLNode root, Id permissionSetId) {
        List<Application_Visibility__c> applicationVisibilities = new List<Application_Visibility__c>();
        
        for (Dom.XMLNode child : root.getChildElements()) {
            if (child.getName() == 'applicationVisibilities') {
                Application_Visibility__c av = new Application_Visibility__c();
                av.Permission_Set__c = permissionSetId;
                av.Permission_Set_Name__c = getNodeText(root, 'label'); // Store the permission set name
                av.Application__c = getNodeText(child, 'application');
                av.Visible__c = Boolean.valueOf(getNodeText(child, 'visible'));
                applicationVisibilities.add(av);
            }
        }
        
        if (!applicationVisibilities.isEmpty()) {
            insert applicationVisibilities;
            System.debug('Created ' + applicationVisibilities.size() + ' application visibility records');
        }
    }
    
    /**
     * Process user permissions from XML and store in User_Permission__c objects
     */
    private static void processUserPermissions(Dom.XMLNode root, Id permissionSetId) {
        List<User_Permission__c> userPermissions = new List<User_Permission__c>();
        
        for (Dom.XMLNode child : root.getChildElements()) {
            if (child.getName() == 'userPermissions') {
                User_Permission__c up = new User_Permission__c();
                up.Permission_Set__c = permissionSetId;
                up.Permission_Set_Name__c = getNodeText(root, 'label'); // Store the permission set name
                up.Permission_Name__c = getNodeText(child, 'name');
                up.Enabled__c = Boolean.valueOf(getNodeText(child, 'enabled'));
                userPermissions.add(up);
            }
        }
        
        if (!userPermissions.isEmpty()) {
            insert userPermissions;
            System.debug('Created ' + userPermissions.size() + ' user permission records');
        }
    }
    
    /**
     * Updates a permission set by its label using the provided XML content
     * @param permissionSetLabel The label of the permission set to update
     * @param updatedXml The updated XML content for the permission set
     */
    public static void updatePermissionSetByLabel(String permissionSetLabel, String updatedXml) {
        try {
            System.debug('=== Starting Permission Set Update by Label ===');
            System.debug('Permission Set Label: ' + permissionSetLabel);
            
            // First, try to find the existing permission set by label
            // Check if Permission_Set__c custom object exists, otherwise use standard PermissionSet
            Id existingPermissionSetId = null;
            String existingPermissionSetName = null;
            
            try {
                // Try to find in custom Permission_Set__c object first
                List<SObject> existingPermissionSets = Database.query(
                    'SELECT Id, Label__c, Name__c FROM Permission_Set__c WHERE Label__c = :permissionSetLabel LIMIT 1'
                );
                
                if (!existingPermissionSets.isEmpty()) {
                    SObject ps = existingPermissionSets[0];
                    existingPermissionSetId = (Id) ps.get('Id');
                    existingPermissionSetName = (String) ps.get('Name__c');
                    System.debug('Found existing Permission Set in custom object: ' + existingPermissionSetName + ' with ID: ' + existingPermissionSetId);
                }
            } catch (Exception e) {
                System.debug('Permission_Set__c custom object not found, trying standard PermissionSet: ' + e.getMessage());
                
                // Try to find in standard PermissionSet object
                try {
                    List<PermissionSet> standardPermissionSets = [
                        SELECT Id, Label, Name 
                        FROM PermissionSet 
                        WHERE Label = :permissionSetLabel 
                        LIMIT 1
                    ];
                    
                    if (!standardPermissionSets.isEmpty()) {
                        PermissionSet ps = standardPermissionSets[0];
                        existingPermissionSetId = ps.Id;
                        existingPermissionSetName = ps.Name;
                        System.debug('Found existing Permission Set in standard object: ' + existingPermissionSetName + ' with ID: ' + existingPermissionSetId);
                    }
                } catch (Exception e2) {
                    System.debug('Standard PermissionSet object also not accessible: ' + e2.getMessage());
                }
            }
            
            if (existingPermissionSetId == null) {
                throw new MetadataUtilityException('Permission Set with label "' + permissionSetLabel + '" not found in either custom or standard objects');
            }
            
            // Delete existing permission set data to avoid duplicates
            deleteExistingPermissionSetData(existingPermissionSetId);
            
            // Parse and process the updated XML
            Dom.Document doc = new Dom.Document();
            doc.load(updatedXml);
            Dom.XMLNode root = doc.getRootElement();
            
            // Update the master permission set record if it's a custom object
            try {
                if (existingPermissionSetId.getSObjectType().getDescribe().getName() == 'Permission_Set__c') {
                    SObject existingPermissionSet = Database.query(
                        'SELECT Id, Label__c, Description__c, User_License__c FROM Permission_Set__c WHERE Id = :existingPermissionSetId'
                    );
                    
                    existingPermissionSet.put('Label__c', getNodeText(root, 'label'));
                    existingPermissionSet.put('Description__c', getNodeText(root, 'description'));
                    existingPermissionSet.put('User_License__c', getNodeText(root, 'hasActivationRequired'));
                    
                    update existingPermissionSet;
                    System.debug('Updated master Permission Set record in custom object');
                }
            } catch (Exception e) {
                System.debug('Could not update custom Permission_Set__c record: ' + e.getMessage());
                // Continue with processing the XML even if update fails
            }
            
            // Process all child nodes dynamically
            processAllPermissionTypes(root, existingPermissionSetId, permissionSetLabel);
            
            System.debug('=== Permission Set Update Completed Successfully ===');
            
        } catch (Exception e) {
            System.debug('Error updating Permission Set: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new MetadataUtilityException('Error updating Permission Set: ' + e.getMessage());
        }
    }
    
    /**
     * Deletes existing permission set data to avoid duplicates during update
     * @param permissionSetId The ID of the permission set
     */
    private static void deleteExistingPermissionSetData(Id permissionSetId) {
        try {
            System.debug('Starting cleanup of existing permission set data for ID: ' + permissionSetId);
            
            // Delete all related permission records with proper error handling
            // Delete field permissions
            try {
                List<Field_Permission__c> fieldPermissions = [
                    SELECT Id FROM Field_Permission__c WHERE Permission_Set__c = :permissionSetId
                ];
                if (!fieldPermissions.isEmpty()) {
                    delete fieldPermissions;
                    System.debug('Deleted ' + fieldPermissions.size() + ' field permissions');
                }
            } catch (Exception e) {
                System.debug('Field_Permission__c object not found or error deleting: ' + e.getMessage());
            }
            
            // Delete object permissions
            try {
                List<Object_Permission__c> objectPermissions = [
                    SELECT Id FROM Object_Permission__c WHERE Permission_Set__c = :permissionSetId
                ];
                if (!objectPermissions.isEmpty()) {
                    delete objectPermissions;
                    System.debug('Deleted ' + objectPermissions.size() + ' object permissions');
                }
            } catch (Exception e) {
                System.debug('Object_Permission__c object not found or error deleting: ' + e.getMessage());
            }
            
            // Delete tab settings
            try {
                List<Tab_Setting__c> tabSettings = [
                    SELECT Id FROM Tab_Setting__c WHERE Permission_Set__c = :permissionSetId
                ];
                if (!tabSettings.isEmpty()) {
                    delete tabSettings;
                    System.debug('Deleted ' + tabSettings.size() + ' tab settings');
                }
            } catch (Exception e) {
                System.debug('Tab_Setting__c object not found or error deleting: ' + e.getMessage());
            }
            
            // Delete class accesses
            try {
                List<Class_Access__c> classAccesses = [
                    SELECT Id FROM Class_Access__c WHERE Permission_Set__c = :permissionSetId
                ];
                if (!classAccesses.isEmpty()) {
                    delete classAccesses;
                    System.debug('Deleted ' + classAccesses.size() + ' class accesses');
                }
            } catch (Exception e) {
                System.debug('Class_Access__c object not found or error deleting: ' + e.getMessage());
            }
            
            // Delete record type visibilities
            try {
                List<Record_Type_Visibility__c> recordTypeVisibilities = [
                    SELECT Id FROM Record_Type_Visibility__c WHERE Permission_Set__c = :permissionSetId
                ];
                if (!recordTypeVisibilities.isEmpty()) {
                    delete recordTypeVisibilities;
                    System.debug('Deleted ' + recordTypeVisibilities.size() + ' record type visibilities');
                }
            } catch (Exception e) {
                System.debug('Record_Type_Visibility__c object not found or error deleting: ' + e.getMessage());
            }
            
            // Delete page accesses
            try {
                List<Page_Access__c> pageAccesses = [
                    SELECT Id FROM Page_Access__c WHERE Permission_Set__c = :permissionSetId
                ];
                if (!pageAccesses.isEmpty()) {
                    delete pageAccesses;
                    System.debug('Deleted ' + pageAccesses.size() + ' page accesses');
                }
            } catch (Exception e) {
                System.debug('Page_Access__c object not found or error deleting: ' + e.getMessage());
            }
            
            // Delete application visibilities
            try {
                List<Application_Visibility__c> applicationVisibilities = [
                    SELECT Id FROM Application_Visibility__c WHERE Permission_Set__c = :permissionSetId
                ];
                if (!applicationVisibilities.isEmpty()) {
                    delete applicationVisibilities;
                    System.debug('Deleted ' + applicationVisibilities.size() + ' application visibilities');
                }
            } catch (Exception e) {
                System.debug('Application_Visibility__c object not found or error deleting: ' + e.getMessage());
            }
            
            // Delete user permissions
            try {
                List<User_Permission__c> userPermissions = [
                    SELECT Id FROM User_Permission__c WHERE Permission_Set__c = :permissionSetId
                ];
                if (!userPermissions.isEmpty()) {
                    delete userPermissions;
                    System.debug('Deleted ' + userPermissions.size() + ' user permissions');
                }
            } catch (Exception e) {
                System.debug('User_Permission__c object not found or error deleting: ' + e.getMessage());
            }
            
            System.debug('Successfully completed cleanup of existing permission set data');
            
        } catch (Exception e) {
            System.debug('Error during cleanup of existing permission set data: ' + e.getMessage());
            // Don't throw exception here as this is cleanup operation
            // Log the error but continue with the update process
        }
    }
    
    /**
     * Utility method to get text content of a child node
     * Handles namespace-aware XML parsing
     */
    private static String getNodeText(Dom.XMLNode parent, String childName) {
        if (parent == null) return '';
        
        for (Dom.XMLNode child : parent.getChildElements()) {
            if (child.getName() == childName) {
                return child.getText();
            }
        }
        return '';
    }
    
    /**
     * Custom exception class
     */
    public class MetadataUtilityException extends Exception {}
}