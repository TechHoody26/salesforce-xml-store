/**
 * Connect To Org Controller
 * 
 * This class provides methods for managing organization connections and group operations.
 * It follows Salesforce best practices including:
 * - Proper error handling and logging
 * - In-memory data storage (no DML operations)
 * - Comprehensive input validation
 * 
 * @author Your Name
 * @version 2.0
 * @since 2024
 */
public with sharing class ConnectToOrgController {
    
    // ===== CONSTANTS =====
    private static final String SUCCESS_STATUS = 'success';
    private static final String ERROR_STATUS = 'error';
    
    // ===== CUSTOM LABELS =====
    private static final String MSG_NO_RECORDS_FOUND = 'No records found in user group';
    private static final String MSG_ORG_CREATED = 'Organization created successfully';
    private static final String MSG_GROUP_CREATED = 'Group created successfully';
    private static final String MSG_FILL_DETAILS = 'Please fill all required details';
    
    // ===== IN-MEMORY STORAGE =====
    private static Map<String, GroupData> groupStore = new Map<String, GroupData>();
    private static Map<String, OrganizationData> organizationStore = new Map<String, OrganizationData>();
    private static Integer nextGroupId = 1;
    private static Integer nextOrgId = 1;
    
    // ===== DATA CLASSES =====
    
    /**
     * Group data structure for in-memory storage
     */
    public class GroupData {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String groupName { get; set; }
        @AuraEnabled public String userId { get; set; }
        @AuraEnabled public String organizationId { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public DateTime createdDate { get; set; }
        @AuraEnabled public DateTime lastModifiedDate { get; set; }
        
        public GroupData(String groupName, String userId, String organizationId, String name) {
            this.groupName = groupName;
            this.userId = userId;
            this.organizationId = organizationId;
            this.name = name;
            this.createdDate = DateTime.now();
            this.lastModifiedDate = DateTime.now();
        }
    }
    
    /**
     * Organization data structure for in-memory storage
     */
    public class OrganizationData {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String organizationType { get; set; }
        @AuraEnabled public String organizationId { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public DateTime lastSyncDate { get; set; }
        @AuraEnabled public DateTime createdDate { get; set; }
        @AuraEnabled public DateTime lastModifiedDate { get; set; }
        
        public OrganizationData(String organizationType, String organizationId, String name) {
            this.organizationType = organizationType;
            this.organizationId = organizationId;
            this.name = name;
            this.lastSyncDate = System.now();
            this.createdDate = DateTime.now();
            this.lastModifiedDate = DateTime.now();
        }
    }
    
    /**
     * Response wrapper class for consistent API responses
     */
    public class GroupResponse {
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public List<Object> data { get; set; }
        
        public GroupResponse(String status, String message) {
            this.status = status;
            this.message = message;
            this.data = new List<Object>();
        }
    }
    
    /**
     * Organization response wrapper class
     */
    public class OrganizationResponse {
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Map<String, Object> data { get; set; }
        
        public OrganizationResponse(String status, String message) {
            this.status = status;
            this.message = message;
            this.data = new Map<String, Object>();
        }
    }
    
    // ===== INITIALIZATION =====
    
    static {
        initializeSampleData();
    }
    
    /**
     * Initialize sample data for demonstration
     */
    private static void initializeSampleData() {
        if (groupStore.isEmpty()) {
            // Create sample organizations
            String org1Id = String.valueOf(nextOrgId++);
            String org2Id = String.valueOf(nextOrgId++);
            
            organizationStore.put(org1Id, new OrganizationData('Developer', 'org_001', 'Sample Org 1'));
            organizationStore.put(org2Id, new OrganizationData('Sandbox', 'org_002', 'Sample Org 2'));
            
            // Create sample groups
            String group1Id = String.valueOf(nextGroupId++);
            String group2Id = String.valueOf(nextGroupId++);
            
            GroupData group1 = new GroupData('Development Team', UserInfo.getUserId(), org1Id, 'Dev Group');
            group1.id = group1Id;
            groupStore.put(group1Id, group1);
            
            GroupData group2 = new GroupData('Testing Team', UserInfo.getUserId(), org2Id, 'Test Group');
            group2.id = group2Id;
            groupStore.put(group2Id, group2);
        }
    }
    
    /**
     * Gets the list of available groups for the current user
     * 
     * @return Map with group list
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getGroupList() {
        Map<String, Object> resultMap = new Map<String, Object>();
        
        try {
            // Get groups from in-memory storage for current user
            List<GroupData> groupList = getGroupsFromMemory();
            
            if (groupList.size() > 0) {
                resultMap = new Map<String, Object>{
                    'status' => SUCCESS_STATUS,
                    'message' => null,
                    'data' => groupList
                };
            } else {
                resultMap = new Map<String, Object>{
                    'status' => ERROR_STATUS,
                    'message' => MSG_NO_RECORDS_FOUND,
                    'data' => null
                };
            }
            
        } catch (Exception e) {
            logError('getGroupList', e);
            resultMap = new Map<String, Object>{
                'status' => ERROR_STATUS,
                'message' => 'An error occurred while retrieving groups: ' + e.getMessage(),
                'data' => null
            };
        }
        
        return resultMap;
    }
    
    /**
     * Gets groups from in-memory storage for current user
     * 
     * @return List of GroupData objects
     */
    private static List<GroupData> getGroupsFromMemory() {
        List<GroupData> groupList = new List<GroupData>();
        String currentUserId = UserInfo.getUserId();
        
        for (GroupData groupData : groupStore.values()) {
            if (groupData.userId == currentUserId && groupData.groupName != 'Default' && groupData.groupName != null) {
                groupList.add(groupData);
            }
        }
        
        // Sort by group name
        groupList.sort(new GroupDataComparator());
        
        return groupList;
    }
    
    /**
     * Adds a new organization with group configuration
     * 
     * @param namedCredential The named credential for the organization
     * @param orgType The type of organization (Developer, Sandbox, Production)
     * @param orgAlias The organization alias
     * @param groupName The group name
     * @return Map with operation result
     */
    @AuraEnabled
    public static Map<String, Object> addNewOrganization(String namedCredential, String orgType, String orgAlias, String groupName) {
        Map<String, Object> resultMap = new Map<String, Object>();
        
        try {
            // Validate input parameters
            if (String.isBlank(namedCredential) || String.isBlank(orgType) || 
                String.isBlank(orgAlias) || String.isBlank(groupName)) {
                return new Map<String, Object>{
                    'status' => ERROR_STATUS,
                    'message' => MSG_FILL_DETAILS,
                    'data' => null
                };
            }
            
            // Get organization information using named credential
            Map<String, Object> orgInfo = getOrganizationInfo(namedCredential);
            String orgId = (String) orgInfo.get('orgId');
            String namespace = (String) orgInfo.get('namespace');
            
            // Check if organization already exists
            Boolean orgExists = checkOrganizationExists(orgId);
            
            // Create organization if it doesn't exist
            if (!orgExists) {
                String newOrgId = createOrganization(orgType, orgId, orgAlias);
                if (String.isBlank(newOrgId)) {
                    return new Map<String, Object>{
                        'status' => ERROR_STATUS,
                        'message' => 'Failed to create organization',
                        'data' => null
                    };
                }
                orgId = newOrgId;
            }
            
            // Create user group
            String userGroupId = createUserGroup(groupName, namedCredential, orgId, orgAlias, orgExists);
            
            if (String.isNotBlank(userGroupId)) {
                Map<String, Object> responseData = new Map<String, Object>{
                    'userGrpId' => userGroupId,
                    'msg' => orgExists
                };
                
                resultMap = new Map<String, Object>{
                    'status' => SUCCESS_STATUS,
                    'message' => MSG_GROUP_CREATED,
                    'data' => responseData
                };
            } else {
                resultMap = new Map<String, Object>{
                    'status' => ERROR_STATUS,
                    'message' => 'Failed to create user group',
                    'data' => null
                };
            }
            
        } catch (Exception e) {
            logError('addNewOrganization', e);
            resultMap = new Map<String, Object>{
                'status' => ERROR_STATUS,
                'message' => 'An error occurred: ' + e.getMessage(),
                'data' => null
            };
        }
        
        return resultMap;
    }
    
    /**
     * Gets organization information using named credential
     * 
     * @param namedCredential The named credential to use
     * @return Map containing organization information
     */
    private static Map<String, Object> getOrganizationInfo(String namedCredential) {
        Map<String, Object> orgInfo = new Map<String, Object>();
        
        try {
            // This would typically call an external service to get org info
            // For now, we'll simulate the response
            orgInfo.put('orgId', 'org_' + System.currentTimeMillis());
            orgInfo.put('namespace', 'adminified');
            
        } catch (Exception e) {
            logError('getOrganizationInfo', e);
            orgInfo.put('orgId', '');
            orgInfo.put('namespace', '');
        }
        
        return orgInfo;
    }
    
    /**
     * Checks if an organization already exists in memory
     * 
     * @param orgId The organization ID to check
     * @return Boolean indicating if organization exists
     */
    private static Boolean checkOrganizationExists(String orgId) {
        try {
            if (String.isBlank(orgId)) return false;
            
            for (OrganizationData org : organizationStore.values()) {
                if (org.organizationId == orgId) {
                    return true;
                }
            }
            
            return false;
            
        } catch (Exception e) {
            logError('checkOrganizationExists', e);
            return false;
        }
    }
    
    /**
     * Creates a new organization record in memory
     * 
     * @param orgType The organization type
     * @param orgId The organization ID
     * @param orgAlias The organization alias
     * @return The ID of the created organization
     */
    private static String createOrganization(String orgType, String orgId, String orgAlias) {
        try {
            String newOrgId = String.valueOf(nextOrgId++);
            OrganizationData newOrg = new OrganizationData(orgType, orgId, orgAlias);
            newOrg.id = newOrgId;
            
            organizationStore.put(newOrgId, newOrg);
            return newOrgId;
            
        } catch (Exception e) {
            logError('createOrganization', e);
            return '';
        }
    }
    
    /**
     * Creates a new user group record in memory
     * 
     * @param groupName The group name
     * @param namedCredential The named credential
     * @param orgId The organization ID
     * @param orgAlias The organization alias
     * @param orgExists Whether the organization already exists
     * @return The ID of the created user group
     */
    private static String createUserGroup(String groupName, String namedCredential, String orgId, String orgAlias, Boolean orgExists) {
        try {
            String newGroupId = String.valueOf(nextGroupId++);
            GroupData newUserGroup = new GroupData(groupName, UserInfo.getUserId(), orgId, orgAlias);
            newUserGroup.id = newGroupId;
            
            groupStore.put(newGroupId, newUserGroup);
            return newGroupId;
            
        } catch (Exception e) {
            logError('createUserGroup', e);
            return '';
        }
    }
    
    /**
     * Comparator class for sorting GroupData by group name
     */
    public class GroupDataComparator implements Comparator<GroupData> {
        public Integer compare(GroupData a, GroupData b) {
            if (a.groupName == null && b.groupName == null) return 0;
            if (a.groupName == null) return -1;
            if (b.groupName == null) return 1;
            return a.groupName.compareTo(b.groupName);
        }
    }
    
    /**
     * Logs errors for debugging and monitoring
     * 
     * @param methodName The name of the method where the error occurred
     * @param e The exception that was thrown
     */
    private static void logError(String methodName, Exception e) {
        System.debug(LoggingLevel.ERROR, 'ConnectToOrgController.' + methodName + ': ' + e.getMessage());
        System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
        
        // You can integrate with your existing logging system here
        // Example: TC_DebugLogger.saveLogs('origin', JSON.Serialize(errorMap));
    }
}