public with sharing class admf_MetadataAPI {
    private static final Integer METADATA_API_VERSION = Integer.valueOf(new TC_MetadataService.MetadataPort().endpoint_x.substringAfterLast('/'));
    public static TC_MetadataService.PackageTypeMembers packageType = null;
    public static Map<String, String> errorMap = new Map<String, String>();
    
    @AuraEnabled(cacheable=true)
    public static TC_MetadataService.PackageTypeMembers getPackageTypeMembers(String metadataType, List<String> packageTypeMembers) {
        packageType = new TC_MetadataService.PackageTypeMembers();
        packageType.name = metadataType;
        packageType.members = new List<String>();
        for (String packageTypeMember : packageTypeMembers) {
            packageType.members.add(packageTypeMember);
        }
        return packageType;
    }

    public static TC_MetadataService.MetadataPort createService(String namedCredential) {
        TC_MetadataService.MetadataPort service = new TC_MetadataService.MetadataPort();
        service.SessionHeader = new TC_MetadataService.SessionHeader_element();
        service.endpoint_x = 'callout:' + namedCredential + '/services/Soap/m/41.0';
        service.SessionHeader.sessionId = '{!$Credential.OAuthToken}';
        return service;
    }

    @AuraEnabled
    public static Map<String, String> retrieveMetadata(String namedCredential, String orgId){
        Map<String, String> responseMap = new Map<String, String>();
        
        try {
            // Create a queueable job for metadata retrieval
            admf_QueueableController obj = new admf_QueueableController(orgId, namedCredential);
            Id jobId = System.enqueueJob(obj);
            
            // Create a content version for file tracking
           // String contentVerId = insertContentVer(orgId);
            
            responseMap.put('jobId', jobId);
           // responseMap.put('fileId', contentVerId);
            responseMap.put('status', 'queued');
            responseMap.put('message', 'Metadata retrieval job queued successfully');
            
        } catch (Exception e) {
            responseMap.put('error', e.getMessage());
            responseMap.put('status', 'error');
            responseMap.put('message', 'Failed to queue metadata retrieval job');
        }
        
        return responseMap;
    }

    public static String insertContentVer(String orgId) {
        try {
            ContentVersion contentVerObj = new ContentVersion(
                title = 'Adminified-' + orgId + '.zip', 
                versiondata = EncodingUtil.base64Decode('This is metadata file'), 
                PathOnClient = 'temp-' + orgId
            );
            
            insert contentVerObj;
            return contentVerObj.Id;
            
        } catch (Exception ex) {
            System.debug('Error creating content version: ' + ex.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static String checkJobStatus(String jobId) {
        String asynchJobStatus;
        List<AsyncApexJob> asynchJobObj;
        if (Schema.sObjectType.AsyncApexJob.fields.Id.isAccessible() && Schema.sObjectType.AsyncApexJob.fields.Status.isAccessible() && Schema.sObjectType.AsyncApexJob.fields.ExtendedStatus.isAccessible()) {
            asynchJobObj = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE Id = :jobId];
        }
        if (asynchJobObj.size() > 0) {
            asynchJobStatus = asynchJobObj[0].Status;
            if (asynchJobStatus == 'Failed') {
                Map<String, Object> errorMap = new Map<String, Object>{ 'status' => 'error', 'userMessage' => asynchJobObj[0].ExtendedStatus };
                   // TC_DebugLogger.saveLogs('origin', JSON.Serialize(errorMap));
            }
        }
        return asynchJobStatus;
    }
    
    @AuraEnabled
    public static String getAsyncId() {
        String asyncId;
        List<TC_Metadata_Logs__c> logs;
        if (Schema.sObjectType.TC_Metadata_Logs__c.fields.Async_Id__c.isAccessible()) {
            logs = [SELECT Async_Id__c FROM TC_Metadata_Logs__c WHERE Is_Completed__c = false AND Is_Completed__c = false Order By CreatedDate Desc];
        }
        if (logs.size() > 0) {
            asyncId = logs[0].Async_Id__c;
        }
        return asyncId;
    }
    
    @AuraEnabled
    public static Map<String, Object> checkStatus(String asyncId, String namedCredential, String orgId) {
        //String getOrgId = '';
    /*    Map<String, Object> resultObj = TC_Util.getCompanyInformationByNamedCredential(namedCredential);
        if (resultObj.get('status') == 'success') {
            getOrgId = resultObj.get('getOrgId') + '';
        }*/
        admf_FetchRetrieveResultQueueable obj = new admf_FetchRetrieveResultQueueable(asyncId, namedCredential, orgId);
        Id jobId = System.enqueueJob(obj);
        Map<String, Object> responseMap = new Map<String, Object>();
        List<TC_Metadata_Logs__c> metadataLogs;
        if (Schema.sObjectType.TC_Metadata_Logs__c.fields.Async_Id__c.isAccessible() && Schema.sObjectType.TC_Metadata_Logs__c.fields.Is_Completed__c.isAccessible()) {
            metadataLogs = [SELECT Async_Id__c, Is_Completed__c FROM TC_Metadata_Logs__c WHERE Async_Id__c = :asyncId LIMIT 1];
        }
        if (metadataLogs.size() > 0) {
            responseMap = new Map<String, String>{ 'status' => metadataLogs[0].Is_Completed__c + '', 'tempId' => ''};
                }
        return responseMap;
    }
}