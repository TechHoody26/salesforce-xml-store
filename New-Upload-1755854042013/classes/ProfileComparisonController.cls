public with sharing class ProfileComparisonController {
    
    @AuraEnabled(cacheable=true)
    public static List<OrganizationWrapper> getOrganizations() {
        try {
            List<OrganizationWrapper> orgs = new List<OrganizationWrapper>();
            
            // Get current org information
            Organization org = [SELECT Id, Name, CreatedDate FROM Organization LIMIT 1];
            
            // Add current org
            orgs.add(new OrganizationWrapper(
                org.Name, 
                org.Id, 
                'Current Organization',
                'current'
            ));
            
            // Add sample connected orgs (in real implementation, you would query connected orgs)
            // For demonstration, we'll add some sample orgs
            orgs.add(new OrganizationWrapper(
                'Production Org', 
                '00DHE000001m4S9', 
                'Production Environment',
                'connected'
            ));
            
            orgs.add(new OrganizationWrapper(
                'Sandbox Org', 
                '00D9876543210987', 
                'Sandbox Environment',
                'connected'
            ));
            
            return orgs;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading organizations: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ProfileWrapper> getProfiles(String orgId) {
        try {
            List<ProfileWrapper> profiles = new List<ProfileWrapper>();
            
            // Check if this is the current org or a connected org
            Organization currentOrg = [SELECT Id FROM Organization LIMIT 1];
            
            if (orgId == currentOrg.Id) {
                // Use SOQL for current org
                profiles = getProfilesFromCurrentOrg();
            } else {
                // Use Tooling API for connected orgs
                profiles = getProfilesFromConnectedOrg(orgId);
            }
            
            return profiles;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading profiles: ' + e.getMessage());
        }
    }
    
    // Method to get profiles from current org using SOQL
    private static List<ProfileWrapper> getProfilesFromCurrentOrg() {
        List<ProfileWrapper> profiles = new List<ProfileWrapper>();
        
        List<Profile> profileList = [
            SELECT Id, Name, UserLicense.Name, Description, LastModifiedDate, UserType
            FROM Profile 
            ORDER BY Name
        ];
        
        for (Profile prof : profileList) {
            profiles.add(new ProfileWrapper(
                prof.Name,
                prof.Id,
                prof.UserLicense.Name,
                prof.Description != null ? prof.Description : '',
                prof.LastModifiedDate.format(),
                prof.UserType
            ));
        }
        
        return profiles;
    }
    
    // Method to get profiles from connected org using Tooling API
    private static List<ProfileWrapper> getProfilesFromConnectedOrg(String orgId) {
        List<ProfileWrapper> profiles = new List<ProfileWrapper>();
        
        try {
            // Get the connected org's session ID and instance URL
            // In a real implementation, you would store these securely
            String sessionId = getConnectedOrgSessionId(orgId);
            String instanceUrl = getConnectedOrgInstanceUrl(orgId);
            
            if (String.isBlank(sessionId) || String.isBlank(instanceUrl)) {
                throw new AuraHandledException('Unable to connect to the specified organization');
            }
            
            // Make Tooling API call to get profiles
            String endpoint = instanceUrl + '/services/data/v58.0/tooling/query?q=SELECT+Id,Name,UserLicense.Name,Description,LastModifiedDate,UserType+FROM+Profile+ORDER+BY+Name';
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + sessionId);
            req.setHeader('Content-Type', 'application/json');
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                // Parse the JSON response
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> records = (List<Object>) responseMap.get('records');
                
                for (Object recordObj : records) {
                    Map<String, Object> record = (Map<String, Object>) recordObj;
                    
                    // Extract profile data
                    String name = (String) record.get('Name');
                    String id = (String) record.get('Id');
                    String description = (String) record.get('Description');
                    String userType = (String) record.get('UserType');
                    String lastModifiedDate = (String) record.get('LastModifiedDate');
                    
                    // Extract UserLicense info
                    String userLicense = 'Unknown';
                    if (record.containsKey('UserLicense')) {
                        Map<String, Object> licenseInfo = (Map<String, Object>) record.get('UserLicense');
                        userLicense = (String) licenseInfo.get('Name');
                    }
                    
                    profiles.add(new ProfileWrapper(
                        name,
                        id,
                        userLicense,
                        description != null ? description : '',
                        lastModifiedDate,
                        userType
                    ));
                }
            } else {
                throw new AuraHandledException('Failed to fetch profiles from connected org. Status: ' + res.getStatusCode() + ' Body: ' + res.getBody());
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching profiles from connected org: ' + e.getMessage());
        }
        
        return profiles;
    }
    
    // Method to get session ID for connected org (placeholder implementation)
    private static String getConnectedOrgSessionId(String orgId) {
        // In a real implementation, you would:
        // 1. Store connected org credentials securely (Custom Settings, Named Credentials, etc.)
        // 2. Use Named Credentials for authentication
        // 3. Or implement OAuth flow for connected orgs
        
        // For demonstration, returning a placeholder
        // You would need to implement proper authentication for each connected org
        return null;
    }
    
    // Method to get instance URL for connected org (placeholder implementation)
    private static String getConnectedOrgInstanceUrl(String orgId) {
        // In a real implementation, you would store the instance URL for each connected org
        // For demonstration, returning a placeholder
        return null;
    }
    
    // Alternative method using Named Credentials (recommended approach)
    @AuraEnabled(cacheable=true)
    public static List<ProfileWrapper> getProfilesFromNamedCredential(String namedCredential) {
        List<ProfileWrapper> profiles = new List<ProfileWrapper>();
        
        try {
            // Use Named Credentials for secure authentication
            String endpoint = 'callout:' + namedCredential + '/services/data/v58.0/tooling/query?q=SELECT+Id,Name,UserLicense.Name,Description,LastModifiedDate,UserType+FROM+Profile+ORDER+BY+Name';
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                // Parse the JSON response
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> records = (List<Object>) responseMap.get('records');
                
                for (Object recordObj : records) {
                    Map<String, Object> record = (Map<String, Object>) recordObj;
                    
                    // Extract profile data
                    String name = (String) record.get('Name');
                    String id = (String) record.get('Id');
                    String description = (String) record.get('Description');
                    String userType = (String) record.get('UserType');
                    String lastModifiedDate = (String) record.get('LastModifiedDate');
                    
                    // Extract UserLicense info
                    String userLicense = 'Unknown';
                    if (record.containsKey('UserLicense')) {
                        Map<String, Object> licenseInfo = (Map<String, Object>) record.get('UserLicense');
                        userLicense = (String) licenseInfo.get('Name');
                    }
                    
                    profiles.add(new ProfileWrapper(
                        name,
                        id,
                        userLicense,
                        description != null ? description : '',
                        lastModifiedDate,
                        userType
                    ));
                }
            } else {
                throw new AuraHandledException('Failed to fetch profiles. Status: ' + res.getStatusCode() + ' Body: ' + res.getBody());
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching profiles: ' + e.getMessage());
        }
        
        return profiles;
    }
    
    // Method using Metadata API to fetch profiles (alternative approach)
    @AuraEnabled(cacheable=true)
    public static List<ProfileWrapper> getProfilesFromMetadataAPI(String namedCredential) {
        List<ProfileWrapper> profiles = new List<ProfileWrapper>();
        
        try {
            // Use Metadata API to list all profiles
            String endpoint = 'callout:' + namedCredential + '/services/Soap/m/58.0';
            
            // SOAP envelope for Metadata API listMetadata call
            String soapEnvelope = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:met="http://soap.sforce.com/2006/04/metadata">' +
                '<soapenv:Header>' +
                '<met:SessionHeader>' +
                '<met:sessionId>{!$Credential.OAuthToken}</met:sessionId>' +
                '</met:SessionHeader>' +
                '</soapenv:Header>' +
                '<soapenv:Body>' +
                '<met:listMetadata>' +
                '<met:queries>' +
                '<met:ListMetadataQuery>' +
                '<met:type>Profile</met:type>' +
                '</met:ListMetadataQuery>' +
                '</met:queries>' +
                '</met:listMetadata>' +
                '</soapenv:Body>' +
                '</soapenv:Envelope>';
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'text/xml; charset=UTF-8');
            req.setHeader('SOAPAction', '""');
            req.setBody(soapEnvelope);
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                // Parse the SOAP response to extract profile names
                // Note: This is a simplified parsing - in production, use proper XML parsing
                String responseBody = res.getBody();
                
                // Extract profile names from the response
                // This is a basic regex approach - for production, use proper XML parsing
                Pattern profilePattern = Pattern.compile('<met:fullName>(.*?)</met:fullName>');
                Matcher matcher = profilePattern.matcher(responseBody);
                
                while (matcher.find()) {
                    String profileName = matcher.group(1);
                    
                    // Create a basic profile wrapper (Metadata API doesn't provide all details)
                    profiles.add(new ProfileWrapper(
                        profileName,
                        '', // Metadata API doesn't provide Id
                        'Unknown', // Metadata API doesn't provide license info
                        '', // Metadata API doesn't provide description
                        '', // Metadata API doesn't provide last modified date
                        'Unknown' // Metadata API doesn't provide user type
                    ));
                }
            } else {
                throw new AuraHandledException('Failed to fetch profiles via Metadata API. Status: ' + res.getStatusCode() + ' Body: ' + res.getBody());
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching profiles via Metadata API: ' + e.getMessage());
        }
        
        return profiles;
    }
    
    // Method to get profiles using REST API (another alternative)
    @AuraEnabled(cacheable=true)
    public static List<ProfileWrapper> getProfilesFromRESTAPI(String namedCredential) {
        List<ProfileWrapper> profiles = new List<ProfileWrapper>();
        
        try {
            // Use REST API to query profiles
            String endpoint = 'callout:' + namedCredential + '/services/data/v58.0/query?q=SELECT+Id,Name,UserLicense.Name,Description,LastModifiedDate,UserType+FROM+Profile+ORDER+BY+Name';
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                // Parse the JSON response
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> records = (List<Object>) responseMap.get('records');
                
                for (Object recordObj : records) {
                    Map<String, Object> record = (Map<String, Object>) recordObj;
                    
                    // Extract profile data
                    String name = (String) record.get('Name');
                    String id = (String) record.get('Id');
                    String description = (String) record.get('Description');
                    String userType = (String) record.get('UserType');
                    String lastModifiedDate = (String) record.get('LastModifiedDate');
                    
                    // Extract UserLicense info
                    String userLicense = 'Unknown';
                    if (record.containsKey('UserLicense')) {
                        Map<String, Object> licenseInfo = (Map<String, Object>) record.get('UserLicense');
                        userLicense = (String) licenseInfo.get('Name');
                    }
                    
                    profiles.add(new ProfileWrapper(
                        name,
                        id,
                        userLicense,
                        description != null ? description : '',
                        lastModifiedDate,
                        userType
                    ));
                }
            } else {
                throw new AuraHandledException('Failed to fetch profiles via REST API. Status: ' + res.getStatusCode() + ' Body: ' + res.getBody());
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching profiles via REST API: ' + e.getMessage());
        }
        
        return profiles;
    }
    
    // Method to get all profiles from multiple orgs
    @AuraEnabled(cacheable=true)
    public static Map<String, List<ProfileWrapper>> getAllProfilesFromMultipleOrgs() {
        Map<String, List<ProfileWrapper>> orgProfiles = new Map<String, List<ProfileWrapper>>();
        
        try {
            // Get current org profiles
            List<ProfileWrapper> currentOrgProfiles = getProfilesFromCurrentOrg();
            orgProfiles.put('Current Org', currentOrgProfiles);
            
            // Get profiles from connected orgs using Named Credentials
            // You would need to set up Named Credentials for each connected org
            List<String> namedCredentials = new List<String>{
                'Production_Org_Credential',
                'Sandbox_Org_Credential'
            };
            
            for (String credential : namedCredentials) {
                try {
                    List<ProfileWrapper> profiles = getProfilesFromRESTAPI(credential);
                    orgProfiles.put(credential, profiles);
                } catch (Exception e) {
                    // Log error but continue with other orgs
                    System.debug('Error fetching profiles from ' + credential + ': ' + e.getMessage());
                    orgProfiles.put(credential, new List<ProfileWrapper>());
                }
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching profiles from multiple orgs: ' + e.getMessage());
        }
        
        return orgProfiles;
    }
    
    @AuraEnabled(cacheable=true)
    public static ProfileDetailsWrapper getProfileDetails(String profileId) {
        try {
            ProfileDetailsWrapper details = new ProfileDetailsWrapper();
            
            // Query the specific profile details
            List<Profile> profileList = [
                SELECT Id, Name, Description, UserLicense.Name, UserType, LastModifiedDate
                FROM Profile 
                WHERE Id = :profileId
                LIMIT 1
            ];
            
            if (!profileList.isEmpty()) {
                Profile prof = profileList[0];
                details.description = prof.Description != null ? prof.Description : prof.Name;
                // Fix the logic: Standard profiles have UserType = 'Standard', Custom profiles have UserType = 'PowerPartner' or other values
                details.isCustom = prof.UserType != 'Standard';
                details.applications = new List<ApplicationVisibility>();
                
                // Query application permissions for this profile
                List<SetupEntityAccess> appAccess = [
                    SELECT SetupEntityId, ParentId, SetupEntityType
                    FROM SetupEntityAccess 
                    WHERE ParentId = :profileId 
                    AND SetupEntityType = 'TabSet'
                ];
                
                // Add common applications
                details.applications.add(new ApplicationVisibility('Force.com', true, true));
                details.applications.add(new ApplicationVisibility('App Launcher', true, true));
                
                // Add dynamic applications based on profile access
                for (SetupEntityAccess access : appAccess) {
                    details.applications.add(new ApplicationVisibility('Custom App: ' + access.SetupEntityId, true, false));
                }
            }
            
            return details;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading profile details: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<PermissionWrapper> getProfilePermissions(String profileId) {
        try {
            List<PermissionWrapper> permissions = new List<PermissionWrapper>();
            
            // Query profile permissions using PermissionSet
            List<PermissionSet> permissionSets = [
                SELECT Id, Name, Profile.Name, 
                       PermissionsViewAllData, PermissionsModifyAllData, PermissionsCustomizeApplication,
                       PermissionsViewSetup, PermissionsManageUsers, PermissionsManageRoles,
                       PermissionsManageSharing, PermissionsRunFlow, PermissionsViewContent,
                       PermissionsCreateCustomizeDashboards, PermissionsCreateCustomizeReports
                FROM PermissionSet 
                WHERE Profile.Id = :profileId
            ];
            
            if (!permissionSets.isEmpty()) {
                PermissionSet ps = permissionSets[0];
                
                // Add common permissions
                permissions.add(new PermissionWrapper('View All Data', ps.PermissionsViewAllData));
                permissions.add(new PermissionWrapper('Modify All Data', ps.PermissionsModifyAllData));
                permissions.add(new PermissionWrapper('Customize Application', ps.PermissionsCustomizeApplication));
                permissions.add(new PermissionWrapper('View Setup and Configuration', ps.PermissionsViewSetup));
                permissions.add(new PermissionWrapper('Manage Users', ps.PermissionsManageUsers));
                permissions.add(new PermissionWrapper('Manage Roles', ps.PermissionsManageRoles));
                permissions.add(new PermissionWrapper('Manage Sharing', ps.PermissionsManageSharing));
                permissions.add(new PermissionWrapper('Run Flow', ps.PermissionsRunFlow));
                permissions.add(new PermissionWrapper('View Content', ps.PermissionsViewContent));
                permissions.add(new PermissionWrapper('Create Customize Dashboards', ps.PermissionsCreateCustomizeDashboards));
                permissions.add(new PermissionWrapper('Create Customize Reports', ps.PermissionsCreateCustomizeReports));
            }
            
            return permissions;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading permissions: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ComparisonItemWrapper> getProfileComparison(List<String> profileIds) {
        try {
            List<ComparisonItemWrapper> comparisonData = new List<ComparisonItemWrapper>();
            
            if (profileIds == null || profileIds.isEmpty()) {
                return comparisonData;
            }
            
            // Query the profiles to compare
            List<Profile> profiles = [
                SELECT Id, Name, Description, UserLicense.Name, UserType
                FROM Profile 
                WHERE Id IN :profileIds
                ORDER BY Name
            ];
            
            if (profiles.isEmpty()) {
                return comparisonData;
            }
            
            // Prepare text values for basic profile info
            List<String> names = new List<String>();
            List<String> licenses = new List<String>();
            List<String> descriptions = new List<String>();
            List<String> customFlags = new List<String>();
            
            for (Profile prof : profiles) {
                names.add(prof.Name);
                licenses.add(prof.UserLicense.Name);
                descriptions.add(prof.Description != null ? prof.Description : prof.Name);
                customFlags.add(prof.UserType != 'Standard' ? 'Yes' : 'No');
            }
            
            // Add basic profile information
            comparisonData.add(new ComparisonItemWrapper('Name', names, null, false));
            comparisonData.add(new ComparisonItemWrapper('User License', licenses, null, true));
            comparisonData.add(new ComparisonItemWrapper('Description', descriptions, null, true));
            comparisonData.add(new ComparisonItemWrapper('Custom Profile', customFlags, null, false));
            
                         // Query permissions for comparison
             List<PermissionSet> permissionSets = [
                 SELECT Profile.Id, Profile.Name,
                        PermissionsViewAllData, PermissionsModifyAllData, PermissionsCustomizeApplication,
                        PermissionsViewSetup, PermissionsManageUsers, PermissionsManageRoles,
                        PermissionsManageSharing, PermissionsRunFlow, PermissionsViewContent,
                        PermissionsCreateCustomizeDashboards, PermissionsCreateCustomizeReports
                 FROM PermissionSet 
                 WHERE Profile.Id IN :profileIds
             ];
            
            // Create a map for easy lookup
            Map<String, PermissionSet> profileToPermissionSet = new Map<String, PermissionSet>();
            for (PermissionSet ps : permissionSets) {
                profileToPermissionSet.put(ps.Profile.Id, ps);
            }
            
                         // Define permissions to compare
             Map<String, String> permissionFields = new Map<String, String>{
                 'View All Data' => 'PermissionsViewAllData',
                 'Modify All Data' => 'PermissionsModifyAllData',
                 'Customize Application' => 'PermissionsCustomizeApplication',
                 'View Setup and Configuration' => 'PermissionsViewSetup',
                 'Manage Users' => 'PermissionsManageUsers',
                 'Manage Roles' => 'PermissionsManageRoles',
                 'Manage Sharing' => 'PermissionsManageSharing',
                 'Run Flow' => 'PermissionsRunFlow',
                 'View Content' => 'PermissionsViewContent',
                 'Create Customize Dashboards' => 'PermissionsCreateCustomizeDashboards',
                 'Create Customize Reports' => 'PermissionsCreateCustomizeReports'
             };
            
            // Compare each permission
            for (String permissionName : permissionFields.keySet()) {
                String fieldName = permissionFields.get(permissionName);
                List<Boolean> permissionValues = new List<Boolean>();
                Boolean hasDifference = false;
                Boolean firstValue = null;
                
                for (Profile prof : profiles) {
                    PermissionSet ps = profileToPermissionSet.get(prof.Id);
                    Boolean value = false;
                    
                    if (ps != null) {
                        value = (Boolean)ps.get(fieldName);
                    }
                    
                    permissionValues.add(value);
                    
                    if (firstValue == null) {
                        firstValue = value;
                    } else if (firstValue != value) {
                        hasDifference = true;
                    }
                }
                
                comparisonData.add(new ComparisonItemWrapper(permissionName, null, permissionValues, hasDifference));
            }
            
            return comparisonData;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading comparison data: ' + e.getMessage());
        }
    }
    
    // Wrapper classes for data transfer
    public class OrganizationWrapper {
        @AuraEnabled public String Name;
        @AuraEnabled public String Id;
        @AuraEnabled public String Description;
        @AuraEnabled public String Type; // 'current' or 'connected'
        
        public OrganizationWrapper(String name, String id, String description, String type) {
            this.Name = name;
            this.Id = id;
            this.Description = description;
            this.Type = type;
        }
    }
    
    public class ProfileWrapper {
        @AuraEnabled public String Name;
        @AuraEnabled public String Id;
        @AuraEnabled public String UserLicense;
        @AuraEnabled public String Description;
        @AuraEnabled public String LastModifiedDate;
        @AuraEnabled public String UserType;
        
        public ProfileWrapper(String name, String id, String userLicense, String description, String lastModifiedDate, String userType) {
            this.Name = name;
            this.Id = id;
            this.UserLicense = userLicense;
            this.Description = description;
            this.LastModifiedDate = lastModifiedDate;
            this.UserType = userType;
        }
    }
    
    public class ProfileDetailsWrapper {
        @AuraEnabled public String description;
        @AuraEnabled public Boolean isCustom;
        @AuraEnabled public List<ApplicationVisibility> applications;
    }
    
    public class ApplicationVisibility {
        @AuraEnabled public String ApplicationName;
        @AuraEnabled public Boolean Visible;
        @AuraEnabled public Boolean IsDefault;
        
        public ApplicationVisibility(String applicationName, Boolean visible, Boolean isDefault) {
            this.ApplicationName = applicationName;
            this.Visible = visible;
            this.IsDefault = isDefault;
        }
    }
    
    public class PermissionWrapper {
        @AuraEnabled public String PermissionName;
        @AuraEnabled public Boolean IsGranted;
        
        public PermissionWrapper(String permissionName, Boolean isGranted) {
            this.PermissionName = permissionName;
            this.IsGranted = isGranted;
        }
    }
    
    public class ComparisonItemWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public List<String> textValues;
        @AuraEnabled public List<Boolean> values;
        @AuraEnabled public Boolean hasDifference;
        
        public ComparisonItemWrapper(String name, List<String> textValues, List<Boolean> values, Boolean hasDifference) {
            this.name = name;
            this.textValues = textValues;
            this.values = values;
            this.hasDifference = hasDifference;
        }
    }

    // New methods for detailed profile view

    @AuraEnabled(cacheable=true)
    public static List<TabVisibilityWrapper> getProfileTabVisibilities(String profileId) {
        try {
            List<TabVisibilityWrapper> tabVisibilities = new List<TabVisibilityWrapper>();
            
            // Mock data for tab visibilities - in real implementation, query SetupEntityAccess
            tabVisibilities.add(new TabVisibilityWrapper('Accounts', true));
            tabVisibilities.add(new TabVisibilityWrapper('Contacts', true));
            tabVisibilities.add(new TabVisibilityWrapper('Cases', true));
            tabVisibilities.add(new TabVisibilityWrapper('Opportunities', true));
            tabVisibilities.add(new TabVisibilityWrapper('Leads', true));
            tabVisibilities.add(new TabVisibilityWrapper('Campaigns', true));
            tabVisibilities.add(new TabVisibilityWrapper('Dashboards', true));
            tabVisibilities.add(new TabVisibilityWrapper('Reports', true));
            tabVisibilities.add(new TabVisibilityWrapper('Setup', true));
            tabVisibilities.add(new TabVisibilityWrapper('App Launcher', true));
            
            return tabVisibilities;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading tab visibilities: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ApplicationVisibility> getProfileApplicationVisibilities(String profileId) {
        try {
            List<ApplicationVisibility> appVisibilities = new List<ApplicationVisibility>();
            
            // Mock data for application visibilities
            appVisibilities.add(new ApplicationVisibility('Force.com', true, false));
            appVisibilities.add(new ApplicationVisibility('Community', true, false));
            appVisibilities.add(new ApplicationVisibility('Automation', true, false));
            appVisibilities.add(new ApplicationVisibility('Sales Console', true, false));
            appVisibilities.add(new ApplicationVisibility('Consumer Goods', true, false));
            appVisibilities.add(new ApplicationVisibility('Digital Experiences', true, false));
            appVisibilities.add(new ApplicationVisibility('All Tabs', true, false));
            appVisibilities.add(new ApplicationVisibility('Content', true, false));
            appVisibilities.add(new ApplicationVisibility('Service Console', true, false));
            appVisibilities.add(new ApplicationVisibility('Service', true, false));
            appVisibilities.add(new ApplicationVisibility('Sales', true, false));
            appVisibilities.add(new ApplicationVisibility('Approvals', true, false));
            appVisibilities.add(new ApplicationVisibility('Business Rules Engine', true, false));
            appVisibilities.add(new ApplicationVisibility('Sales Cloud Mobile', true, false));
            appVisibilities.add(new ApplicationVisibility('Site.com', true, false));
            appVisibilities.add(new ApplicationVisibility('App Launcher', true, true));
            appVisibilities.add(new ApplicationVisibility('Lightning Bolt', false, false));
            appVisibilities.add(new ApplicationVisibility('Lightning Sales', false, false));
            appVisibilities.add(new ApplicationVisibility('Platform', false, false));
            
            return appVisibilities;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading application visibilities: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<LayoutAssignmentWrapper> getProfileLayoutAssignments(String profileId) {
        try {
            List<LayoutAssignmentWrapper> layoutAssignments = new List<LayoutAssignmentWrapper>();
            
            // Mock data for layout assignments
            layoutAssignments.add(new LayoutAssignmentWrapper('Account Layout', 'Account'));
            layoutAssignments.add(new LayoutAssignmentWrapper('Contact Layout', 'Contact'));
            layoutAssignments.add(new LayoutAssignmentWrapper('Case Layout', 'Case'));
            layoutAssignments.add(new LayoutAssignmentWrapper('Opportunity Layout', 'Opportunity'));
            layoutAssignments.add(new LayoutAssignmentWrapper('Lead Layout', 'Lead'));
            
            return layoutAssignments;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading layout assignments: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<RecordTypeVisibilityWrapper> getProfileRecordTypeVisibilities(String profileId) {
        try {
            List<RecordTypeVisibilityWrapper> recordTypeVisibilities = new List<RecordTypeVisibilityWrapper>();
            
            // Mock data for record type visibilities
            recordTypeVisibilities.add(new RecordTypeVisibilityWrapper('Customer', 'Account'));
            recordTypeVisibilities.add(new RecordTypeVisibilityWrapper('Partner', 'Account'));
            recordTypeVisibilities.add(new RecordTypeVisibilityWrapper('Prospect', 'Contact'));
            recordTypeVisibilities.add(new RecordTypeVisibilityWrapper('Customer', 'Contact'));
            
            return recordTypeVisibilities;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading record type visibilities: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<PermissionWrapper> getProfileCustomPermissions(String profileId) {
        try {
            List<PermissionWrapper> customPermissions = new List<PermissionWrapper>();
            
            // Mock data for custom permissions
            customPermissions.add(new PermissionWrapper('Custom Permission 1', true));
            customPermissions.add(new PermissionWrapper('Custom Permission 2', false));
            customPermissions.add(new PermissionWrapper('Custom Permission 3', true));
            
            return customPermissions;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading custom permissions: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ApexPageWrapper> getProfileApexPages(String profileId) {
        try {
            List<ApexPageWrapper> apexPages = new List<ApexPageWrapper>();
            
            // Mock data for apex pages
            apexPages.add(new ApexPageWrapper('CustomPage1', true));
            apexPages.add(new ApexPageWrapper('CustomPage2', false));
            apexPages.add(new ApexPageWrapper('CustomPage3', true));
            
            return apexPages;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading apex pages: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ClassAccessWrapper> getProfileClassAccesses(String profileId) {
        try {
            List<ClassAccessWrapper> classAccesses = new List<ClassAccessWrapper>();
            
            // Mock data for class accesses
            classAccesses.add(new ClassAccessWrapper('CustomClass1', true));
            classAccesses.add(new ClassAccessWrapper('CustomClass2', false));
            classAccesses.add(new ClassAccessWrapper('CustomClass3', true));
            
            return classAccesses;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading class accesses: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ExternalDataSourceWrapper> getProfileExternalDataSources(String profileId) {
        try {
            List<ExternalDataSourceWrapper> externalDataSources = new List<ExternalDataSourceWrapper>();
            
            // Mock data for external data sources
            externalDataSources.add(new ExternalDataSourceWrapper('ExternalDataSource1', true));
            externalDataSources.add(new ExternalDataSourceWrapper('ExternalDataSource2', false));
            externalDataSources.add(new ExternalDataSourceWrapper('ExternalDataSource3', true));
            
            return externalDataSources;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading external data sources: ' + e.getMessage());
        }
    }

    // Additional wrapper classes for detailed profile view
    public class TabVisibilityWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public Boolean visible;
        
        public TabVisibilityWrapper(String name, Boolean visible) {
            this.name = name;
            this.visible = visible;
        }
    }

    public class LayoutAssignmentWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public String type;
        
        public LayoutAssignmentWrapper(String name, String type) {
            this.name = name;
            this.type = type;
        }
    }

    public class RecordTypeVisibilityWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public String objectName;
        
        public RecordTypeVisibilityWrapper(String name, String objectName) {
            this.name = name;
            this.objectName = objectName;   
        }
    }

    public class ApexPageWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public Boolean enabled;
        
        public ApexPageWrapper(String name, Boolean enabled) {
            this.name = name;
            this.enabled = enabled;
        }
    }

    public class ClassAccessWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public Boolean enabled;
        
        public ClassAccessWrapper(String name, Boolean enabled) {
            this.name = name;
            this.enabled = enabled;
        }
    }

    public class ExternalDataSourceWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public Boolean enabled;
        
        public ExternalDataSourceWrapper(String name, Boolean enabled) {
            this.name = name;
            this.enabled = enabled;
        }
    }
}