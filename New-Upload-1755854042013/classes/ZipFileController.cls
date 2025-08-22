public with sharing class ZipFileController {
    @AuraEnabled(cacheable=false)
    public static String getFileFromContentVersion(Id contentVersionId) {
        // Query the VersionData (actual file body)
        ContentVersion cv = [
            SELECT VersionData 
            FROM ContentVersion 
            WHERE Id = :contentVersionId 
            LIMIT 1
        ];

        // Encode binary into Base64 so JS can handle it
        return EncodingUtil.base64Encode(cv.VersionData);
    }
}