insert into dbo.atbl_Integrations_Setup_Endpoints
(
    System,
	Name,
	Description,
	EndpointConfig,
	Query,
	Mapping,
	Comments
)
values
(
    'CDF (ProArc) NOAFULLA',
	'All Documents',
	'Query to retrieve document profiles for NOAFULLA from ProArc via CDF',
	'{    
    "QueryUri": "https://esa.api.akersolutions.com/dataops/cdf/akerbp/graphql",
    "TokenUri": "https://login.microsoftonline.com/26b749f6-8c72-44e3-bbde-ae3de07b4206/oauth2/v2.0/token",                
    "Project": "integral",
    "Cluster": "westeurope-1",
    "ITGSchemaName" : "noafulla_proarc",
    "SECRET_REF":"CDF_PROD"
}',
	'query Documents {
    Document(first: 5000, offset: 0) {
        actual_received
        akerbp_distr
        areas {          
            value
        }
        chapter_in_user_manual
        created
        created_by
        deliver_to_site
        dfo_lci
        discipline
        distributionflags {
            value
        }
        document_number
        document_group
        document_type {
            value
        }
        
        facility_code
        first_due_date
        forecast
        id
        include_in_asbuilt
        include_in_mrb
        include_in_um
        inheritance_code
        interface
        isDeleted
        mdr_change
        modified_date
        native_format
        next_plan_date
        next_revision_reason
        originator
        owner
        pa_revision_id
        package {
            value
        }
        pem_interface
        plan_return_date
        proarc_document_primary_key
        proarc_project_code
        project_desc
        project_number
        returned_date
        safety_critical
        sas_interface
        sequence_number
        sheet_number
        status
        status_date
        subcontractors {
            value
        }
        submitted_retained
        supersedes
        superseded_by
        supplier
        supplier_document_number
        systems {
            value
        }
        title
        voided
    }
}',
	'{
    "mappingRules": [
        {
            "property": "areas",
            "rule": "concatenate",
            "type": "list",
            "value": "value",
            "splitchar": "|"
        },
        {
            "property": "systems",
            "rule": "concatenate",
            "type": "list",
            "value": "value",
            "splitchar": "|"
        },
        {
            "property": "subcontractors",
            "rule": "concatenate",
            "type": "list",
            "value": "value",
            "splitchar": "|"
        },
        {
            "property": "distributionflags",
            "rule": "concatenate",
            "type": "list",
            "value": "value",
            "splitchar": "|"
        },
        {
            "property": "created",
            "rule": "rename",
            "dbfield": "proarc_created"
        },
        {
            "property": "created_by",
            "rule": "rename",
            "dbfield": "proarc_created_by"
        }
    ]
}',
	NULL
),(
    'CDF (ProArc) NOAFULLA',
	'All Revision Files',
	'Query to retrieve revision files for NOAFULLA  from ProArc via CDF',
	'{
    "QueryUri": "https://esa.api.akersolutions.com/dataops/cdf/akerbp/graphql",
    "TokenUri": "https://login.microsoftonline.com/26b749f6-8c72-44e3-bbde-ae3de07b4206/oauth2/v2.0/token",                
    "Project": "integral",
    "Cluster": "westeurope-1",
    "ITGSchemaName" : "noafulla_proarc",
    "SECRET_REF":"CDF_PROD"
}
 ',
	'query QueryFiles {    
    File(first: 5000, offset: 0) {        
        cdf_file_id        
        cdf_file_url        
        document_number        
        file_comment        
        file_imported_date        
        file_modified_date        
        file_modified_time        
        file_sequence_number        
        file_size        
        file_status        
        file_status_date        
        file_type        
        filename        
        id        
        isDeleted        
        original_filename        
        proarc_document_primary_key        
        proarc_file_checksum        
        proarc_file_primary_key        
        proarc_file_url        
        proarc_project_id        
        proarc_revision_id        
        revision    
    }
}',
	NULL,
	NULL
),(
    'CDF (ProArc) NOAFULLA',
	'All Revisions',
	'Query to retrieve document revisions for NOAFULLA  from ProArc via CDF',
	'{
    "QueryUri": "https://esa.api.akersolutions.com/dataops/cdf/akerbp/graphql",
    "TokenUri": "https://login.microsoftonline.com/26b749f6-8c72-44e3-bbde-ae3de07b4206/oauth2/v2.0/token",                
    "Project": "integral",
    "Cluster": "westeurope-1",
    "ITGSchemaName" : "noafulla_proarc",
    "SECRET_REF":"CDF_PROD"
}
 ',
	'query Revisions {    
    Revision(first: 5000, offset: 0) {
        additional_info
        closed
        document_number
        files_exists
        generated_primary_key
        id
        initiated
        isDeleted
        issue_status
        issue_status_description
        proarc_document_primary_key
        proarc_project_code
        proarc_revision_id
        revision
        revision_sequence_number
        status
        status_date
    }
}',
	NULL,
	NULL
),(
    'CDF (ProArc) NOAFULLA',
	'Download Files',
	'Download files for NOAFULLA from ProArc via CFD',
	'{
    "QueryUri": "https://esa.api.akersolutions.com/dataops/cdf/akerbp/graphql",
    "TokenUri": "https://login.microsoftonline.com/26b749f6-8c72-44e3-bbde-ae3de07b4206/oauth2/v2.0/token",                
    "CogniteFilesUri": "https://esa.api.akersolutions.com/dataops/cdf/akerbp/projects/integral/files/",
    "DownloadEndpoint": "https://esa.api.akersolutions.com/dataops/cdf/akerbp/projects/integral/files/downloadlink",
    "Project": "integral",
    "Cluster": "westeurope-1",
    "ITGSchemaName" : "noafulla_proarc",
    "SECRET_REF":"CDF_PROD"
}',
	NULL,
	NULL,
	NULL
)
