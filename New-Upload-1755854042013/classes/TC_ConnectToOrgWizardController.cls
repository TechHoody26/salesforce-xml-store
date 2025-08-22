public with sharing class TC_ConnectToOrgWizardController {
    
    /*
     * @method: namedCredentialAuthentication
     * @param : String namedCredential
     * @Description: Authenticate and validate Named Credential on current org
     * @return: Map<String,Object> responseMap
     */
    @AuraEnabled
    public static Map<String, Object> namedCredentialAuthentication(String namedCredential) {
        Map<String, Object> responseMap = new Map<String, Object>();
        
        try {
            if (String.isBlank(namedCredential)) {
                responseMap.put('status', 'error');
                responseMap.put('userMessage', 'Please provide a named credential.');
                return responseMap;
            }
            
            // Check if named credential exists
            List<NamedCredential> namedCredentialList = [
                SELECT Id, DeveloperName, Endpoint, PrincipalType 
                FROM NamedCredential 
                WHERE DeveloperName = :namedCredential 
                WITH SECURITY_ENFORCED
            ];
            
            if (namedCredentialList.isEmpty()) {
                responseMap.put('status', 'error');
                responseMap.put('userMessage', 'Named Credential not found. Please check the credential name.');
                return responseMap;
            }
            
            // Test the named credential by making a callout
            String endPointUrl = 'callout:' + namedCredential + '/services/data/v58.0/sobjects/User/';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPointUrl);
            req.setMethod('GET');
            req.setTimeout(30000); // 30 seconds timeout
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            // Handle redirects
            if (res.getStatusCode() == 302) {
                req.setEndpoint(res.getHeader('Location'));
                res = new Http().send(req);
            }
            
            if (res.getStatusCode() == 200) {
                // Success - named credential is working
                responseMap.put('status', 'success');
                responseMap.put('userMessage', 'Named Credential authenticated successfully!');
                responseMap.put('endpoint', namedCredentialList[0].Endpoint);
                responseMap.put('principalType', namedCredentialList[0].PrincipalType);
            } else if (res.getStatusCode() == 401) {
                // Authentication failed
                responseMap.put('status', 'error');
                responseMap.put('userMessage', 'Authentication failed. Please check your credentials.');
            } else if (res.getStatusCode() == 403) {
                // Forbidden - user doesn't have access
                responseMap.put('status', 'error');
                responseMap.put('userMessage', 'Access denied. Please check your user permissions.');
            } else {
                // Other HTTP errors
                responseMap.put('status', 'error');
                responseMap.put('userMessage', 'Connection failed with status code: ' + res.getStatusCode() + '. Please check your configuration.');
            }
            
        } catch (Exception e) {
            responseMap.put('status', 'error');
            responseMap.put('userMessage', 'Error testing named credential: ' + e.getMessage());
            responseMap.put('errorDetails', e.getStackTraceString());
        }
        
        return responseMap;
    }
    
    /*
     * @method: getConnectedCredentials
     * @Description: Get list of authorized/connected named credentials
     * @return: Map<String,Object> with connected credentials
     */
    @AuraEnabled
    public static Map<String, Object> getConnectedCredentials() {
        Map<String, Object> result = new Map<String, Object>();
        List<Map<String, Object>> connectedCredentials = new List<Map<String, Object>>();
        
        try {
            // Get all named credentials
            List<NamedCredential> allCredentials = [
                SELECT Id, DeveloperName, MasterLabel, Endpoint, PrincipalType 
                FROM NamedCredential 
                WITH SECURITY_ENFORCED 
                ORDER BY MasterLabel
            ];
            
            // Test each credential to see if it's connected
            for (NamedCredential nc : allCredentials) {
                Map<String, Object> credentialInfo = new Map<String, Object>();
                credentialInfo.put('developerName', nc.DeveloperName);
                credentialInfo.put('masterLabel', nc.MasterLabel);
                credentialInfo.put('endpoint', nc.Endpoint);
                credentialInfo.put('principalType', nc.PrincipalType);
                
                // Test the connection
                try {
                    String endPointUrl = 'callout:' + nc.DeveloperName + '/services/data/v58.0/sobjects/User/';
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint(endPointUrl);
                    req.setMethod('GET');
                    req.setTimeout(10000); // 10 seconds timeout for testing
                    
                    Http http = new Http();
                    HTTPResponse res = http.send(req);
                    
                    if (res.getStatusCode() == 200) {
                        credentialInfo.put('isConnected', true);
                        credentialInfo.put('status', 'Connected');
                        connectedCredentials.add(credentialInfo);
                    } else {
                        credentialInfo.put('isConnected', false);
                        credentialInfo.put('status', 'Failed (' + res.getStatusCode() + ')');
                    }
                } catch (Exception e) {
                    credentialInfo.put('isConnected', false);
                    credentialInfo.put('status', 'Error: ' + e.getMessage());
                }
            }
            
            result.put('status', 'success');
            result.put('data', connectedCredentials);
            
        } catch (Exception e) {
            result.put('status', 'error');
            result.put('message', e.getMessage());
        }
        
        return result;
    }
    
    /*
     * @method: getNamedCredentials
     * @Description: Get list of available named credentials
     * @return: Map<String,Object> with status and data
     */
    @AuraEnabled
    public static Map<String, Object> getNamedCredentials() {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            List<NamedCredential> namedCredentials = [
                SELECT Id, DeveloperName, MasterLabel, Endpoint, PrincipalType 
                FROM NamedCredential 
                WITH SECURITY_ENFORCED 
                ORDER BY MasterLabel
            ];
            
            List<Map<String, String>> credentialList = new List<Map<String, String>>();
            for (NamedCredential nc : namedCredentials) {
                credentialList.add(new Map<String, String>{
                    'developerName' => nc.DeveloperName,
                    'masterLabel' => nc.MasterLabel,
                    'endpoint' => nc.Endpoint,
                    'principalType' => nc.PrincipalType
                });
            }
            
            result.put('status', 'success');
            result.put('data', credentialList);
            
        } catch (Exception e) {
            result.put('status', 'error');
            result.put('message', e.getMessage());
        }
        
        return result;
    }
    
    /*
     * @method: getCurrentUserInfo
     * @Description: Get current user information
     * @return: Map<String,Object> with user details
     */
    @AuraEnabled
    public static Map<String, Object> getCurrentUserInfo() {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            User currentUser = [
                SELECT Id, Name, Username, Email, Profile.Name, UserRole.Name
                FROM User 
                WHERE Id = :UserInfo.getUserId()
                WITH SECURITY_ENFORCED
            ];
            
            result.put('status', 'success');
            result.put('data', new Map<String, String>{
                'userId' => currentUser.Id,
                'userName' => currentUser.Name,
                'username' => currentUser.Username,
                'email' => currentUser.Email,
                'profileName' => currentUser.Profile.Name,
                'userRoleName' => currentUser.UserRole?.Name
            });
            
        } catch (Exception e) {
            result.put('status', 'error');
            result.put('message', e.getMessage());
        }
        
        return result;
    }
    
    /*
     * @method: testConnection
     * @param : String namedCredential, String testEndpoint
     * @Description: Test connection to a specific endpoint using named credential
     * @return: Map<String,Object> with test results
     */
    @AuraEnabled
    public static Map<String, Object> testConnection(String namedCredential, String testEndpoint) {
        Map<String, Object> responseMap = new Map<String, Object>();
        
        try {
            if (String.isBlank(namedCredential)) {
                responseMap.put('status', 'error');
                responseMap.put('userMessage', 'Please provide a named credential.');
                return responseMap;
            }
            
            // Build the endpoint URL
            String endPointUrl;
            if (String.isNotBlank(testEndpoint)) {
                endPointUrl = 'callout:' + namedCredential + testEndpoint;
            } else {
                endPointUrl = 'callout:' + namedCredential + '/services/data/v58.0/sobjects/User/';
            }
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPointUrl);
            req.setMethod('GET');
            req.setTimeout(30000);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            // Handle redirects
            if (res.getStatusCode() == 302) {
                req.setEndpoint(res.getHeader('Location'));
                res = new Http().send(req);
            }
            
            responseMap.put('status', 'success');
            responseMap.put('httpStatusCode', res.getStatusCode());
            responseMap.put('responseBody', res.getBody());
            responseMap.put('endpoint', endPointUrl);
            
            if (res.getStatusCode() == 200) {
                responseMap.put('userMessage', 'Connection test successful!');
            } else {
                responseMap.put('userMessage', 'Connection test completed with status: ' + res.getStatusCode());
            }
            
        } catch (Exception e) {
            responseMap.put('status', 'error');
            responseMap.put('userMessage', 'Connection test failed: ' + e.getMessage());
            responseMap.put('errorDetails', e.getStackTraceString());
        }
        
        return responseMap;
    }
}