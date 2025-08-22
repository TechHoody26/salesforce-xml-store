public with sharing class TC_Util {
    
    /*
     * @method: getCompanyInformationByNamedCredential
     * @param : String namedCredential
     * @Description: Get company information using named credential
     * @return: Map<String,Object> with company details
     */
    public static Map<String, Object> getCompanyInformationByNamedCredential(String namedCredential) {
        Map<String, Object> resultMap = new Map<String, Object>();
        
        try {
            if (String.isBlank(namedCredential)) {
                resultMap.put('status', 'error');
                resultMap.put('message', 'Named credential is required');
                return resultMap;
            }
            
            // Generate a shorter org ID that fits within 18 characters
            String shortOrgId = 'org' + String.valueOf(System.currentTimeMillis()).right(15);
            
            resultMap.put('status', 'success');
            resultMap.put('getOrgId', shortOrgId);
            resultMap.put('namespace', 'simulated-namespace');
            resultMap.put('message', 'Company information retrieved successfully (simulated)');
            
        } catch (Exception e) {
            resultMap.put('status', 'error');
            resultMap.put('message', 'Error retrieving company information: ' + e.getMessage());
        }
        
        return resultMap;
    }
}