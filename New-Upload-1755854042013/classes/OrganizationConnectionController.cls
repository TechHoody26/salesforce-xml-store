public with sharing class OrganizationConnectionController {
    
    /*
     * @method: validateNamedCredential
     * @param : String namedCredential
     * @Description: Validates if a named credential exists and is accessible
     * @return: Map containing validation result
     */
    @AuraEnabled
    public static Map<String, Object> validateNamedCredential(String namedCredential) {
        Map<String, Object> resultMap = new Map<String, Object>();
        
        try {
            // Input validation
            if (String.isBlank(namedCredential)) {
                resultMap.put('status', 'error');
                resultMap.put('message', 'Named credential cannot be blank');
                return resultMap;
            }
            
            // Trim whitespace
            namedCredential = namedCredential.trim();
            
            // Check if named credential exists
            List<NamedCredential> credentials = [
                SELECT Id, MasterLabel, DeveloperName, Endpoint, PrincipalType
                FROM NamedCredential
                WHERE DeveloperName = :namedCredential
                LIMIT 1
            ];
            
            if (credentials.isEmpty()) {
                // Check if there are any named credentials at all
                List<NamedCredential> allCredentials = [
                    SELECT DeveloperName, MasterLabel
                    FROM NamedCredential
                    ORDER BY MasterLabel
                    LIMIT 10
                ];
                
                String availableCredentials = '';
                if (!allCredentials.isEmpty()) {
                    List<String> credentialNames = new List<String>();
                    for (NamedCredential cred : allCredentials) {
                        credentialNames.add(cred.MasterLabel);
                    }
                    availableCredentials = ' Available credentials: ' + String.join(credentialNames, ', ');
                }
                
                resultMap.put('status', 'error');
                resultMap.put('message', 'Named credential "' + namedCredential + '" not found.' + availableCredentials);
            } else {
                NamedCredential cred = credentials[0];
                resultMap.put('status', 'success');
                resultMap.put('message', 'Named credential "' + cred.MasterLabel + '" validated successfully');
                resultMap.put('credential', cred);
                
                // Additional validation checks
                if (String.isBlank(cred.Endpoint)) {
                    resultMap.put('warning', 'Named credential endpoint is not configured');
                }
            }
        } catch (Exception e) {
            System.debug('Error in validateNamedCredential: ' + e.getMessage() + '\n' + e.getStackTraceString());
            resultMap.put('status', 'error');
            resultMap.put('message', 'Error validating named credential: ' + e.getMessage());
        }
        
        return resultMap;
    }
    
    /*
     * @method: getAvailableNamedCredentials
     * @Description: Gets all available named credentials
     * @return: List of named credential options
     */
    @AuraEnabled
    public static List<Map<String, String>> getAvailableNamedCredentials() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        
        try {
            List<NamedCredential> credentials = [
                SELECT Id, MasterLabel, DeveloperName
                FROM NamedCredential
                ORDER BY MasterLabel
            ];
            
            for (NamedCredential cred : credentials) {
                Map<String, String> option = new Map<String, String>();
                option.put('label', cred.MasterLabel);
                option.put('value', cred.DeveloperName);
                options.add(option);
            }
        } catch (Exception e) {
            System.debug('Error getting named credentials: ' + e.getMessage());
        }
        
        return options;
    }
    
    /*
     * @method: testNamedCredentials
     * @Description: Test method to debug named credential issues
     * @return: Map containing debug information
     */
    @AuraEnabled
    public static Map<String, Object> testNamedCredentials() {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            List<NamedCredential> allCredentials = [
                SELECT Id, MasterLabel, DeveloperName, Endpoint, PrincipalType
                FROM NamedCredential
                ORDER BY MasterLabel
            ];
            
            result.put('totalCount', allCredentials.size());
            result.put('credentials', allCredentials);
            result.put('status', 'success');
            
            if (allCredentials.isEmpty()) {
                result.put('message', 'No named credentials found in this org');
            } else {
                result.put('message', 'Found ' + allCredentials.size() + ' named credentials');
            }
            
        } catch (Exception e) {
            result.put('status', 'error');
            result.put('message', 'Error testing named credentials: ' + e.getMessage());
            result.put('stackTrace', e.getStackTraceString());
        }
        
        return result;
    }
}