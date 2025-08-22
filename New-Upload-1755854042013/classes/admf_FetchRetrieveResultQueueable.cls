public with sharing class admf_FetchRetrieveResultQueueable implements Queueable, Database.AllowsCallouts {
    String asyncId;
    String namedCredential;
    String getOrgId;

    public admf_FetchRetrieveResultQueueable(String asyncId, String namedCredential, String getOrgId) {
        this.asyncId = asyncId;
        this.namedCredential = namedCredential;
        this.getOrgId = getOrgId;
    }

    public void execute(QueueableContext context) {
        String orgId = 'a09HE000001SXwtYAG';
                System.debug('this.orgId: '+orgId);

        Map<String, String> responseMap = fetchRetrieveResult(asyncId, this.namedCredential, orgId);
        //update status to complete
        String status = responseMap.get('status');
        String fileId = responseMap.get('fileId');
        if (status != 'Pending') {
            if (status == 'Succeeded') {
				TC_Metadata_Logs__c metadataLog = [Select Id,Is_Completed__c,File_Id__c FROM TC_Metadata_Logs__c Where Developer_Org__c =: orgId];                 
                metadataLog.Is_Completed__c = true;
                metadataLog.File_Id__c=fileId;
                update metadataLog;
            }
        }
    }

    public static Map<String, String> fetchRetrieveResult(String asyncId, String namedCredential, String getOrgId) {
        Map<String, String> errorMap = new Map<String, String>();
        Map<String, String> responseMap = new Map<String, String>();

        TC_MetadataService.MetadataPort service = admf_MetadataAPI.createservice(namedCredential);
        TC_MetadataService.RetrieveResult result = service.checkRetrieveStatus(asyncId, true);
		System.debug('status: '+result.status);
        if (result.done) {
            if (result.status != 'Succeeded') {
                responseMap.put('attachmentId', '');
                responseMap.put('status', result.status);
            } else if (Schema.sObjectType.ContentVersion.isCreateable() &&
                       Schema.sObjectType.ContentVersion.fields.title.isCreateable() &&
                       Schema.sObjectType.ContentVersion.fields.versiondata.isCreateable() &&
                       Schema.sObjectType.ContentVersion.fields.PathOnClient.isCreateable()) {

                ContentVersion contentVerObj = new ContentVersion(
                    title = 'Retrieved-' + getOrgId + '.zip', 
                    versiondata = EncodingUtil.base64Decode(result.zipFile),
                    PathOnClient = 'Adminified-' + userInfo.getOrganizationId()
                );

                try {
                    insert contentVerObj;
                    List<ContentVersion> contVersList = [
                        SELECT Id, ContentDocumentId 
                        FROM ContentVersion 
                        WHERE Id = :contentVerObj.Id with SECURITY_ENFORCED
                    ];
                    responseMap.put('versionId', contentVerObj.Id);
                    responseMap.put('fileId', contVersList[0].ContentDocumentId);
                    responseMap.put('status', result.status);
                } catch (Exception ex) {
                 
                }
            }
        } else {
            responseMap.put('versionId', '');
            responseMap.put('fileId', '');
            responseMap.put('status', '');
        }
        return responseMap;
    }
}