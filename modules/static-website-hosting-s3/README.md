# Static website hosting s3 module
This module creates multiple s3 buckets and related bucket policies for hosting a static website.

## Variables
`project_name`(required) - The name for the project.  
`environment` (required) - Environment for the project.  
`domain_name` (required) - The domain name of the hosted website.  
`hosting_index_document` (optional) - The name of the index document, default is `index.html`.  
`hosting_error_document` (optional) - The name of the error document, default is `404.html`. 


## Outputs
`website_endpoint` - The dns name of the s3-hosted website.   