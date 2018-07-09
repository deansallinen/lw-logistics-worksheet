SELECT * FROM (

-- Quotes
SELECT
	quote.date AS doc_date,
    quote.type AS doc_type, 
    status.status_name AS doc_status,
    quote.document_number AS doc_num, 
    quote.element_name AS doc_name,
    venue.display_string AS doc_location,
    am.display_string AS account_manager,
    method.method_name AS method,
    quote.notes AS doc_notes

FROM (
    -- Load In
    SELECT id,
        load_in_date,
        load_in_date AS date,
        'Load In' AS type, 
        document_number, 
        element_name, 
        status_id, 
        person_responsible_id,
        shipping_method_id AS method_id, 
        venue_id, 
        is_deleted, 
        notes, 
        show_start 

    FROM st_prj_project_element

    WHERE location_id = '2f49c62c-b139-11df-b8d5-00e08175e43e' -- Vancouver
    AND def_id = '9bfb850c-b117-11df-b8d5-00e08175e43e' -- Quote
    AND shipping_method_id != 'c2b7762c-aee9-11df-b8d5-00e08175e43e' -- By Client


UNION ALL 

    -- Load Out
    SELECT id, 
        load_out_date,
        load_out_date AS date,
        'Load Out' AS type, 
        document_number, 
        element_name, 
        status_id, 
        person_responsible_id, 
        return_method_id AS method_id,
        venue_id, 
        is_deleted, 
        notes, 
        show_start 

    FROM st_prj_project_element

    WHERE location_id = '2f49c62c-b139-11df-b8d5-00e08175e43e' -- Vancouver
    AND def_id = '9bfb850c-b117-11df-b8d5-00e08175e43e' -- Quote
    AND return_method_id != 'c2b7762c-aee9-11df-b8d5-00e08175e43e' -- By Client
) AS quote

LEFT JOIN st_biz_status_option AS status ON (status.id = quote.status_id)
LEFT JOIN st_biz_shipping_method AS method ON (method.id = quote.method_id)
LEFT JOIN st_biz_managed_resource AS am ON (am.id = quote.person_responsible_id)
LEFT JOIN st_biz_managed_resource AS venue ON (venue.id = quote.venue_id)

WHERE quote.is_deleted = 0

AND (status.id != '78a1508c-aee7-11df-b8d5-00e08175e43e' -- Cancelled
	AND status.id != '8b47ca2c-aee7-11df-b8d5-00e08175e43e') -- Closed

UNION ALL 

-- RPOs
SELECT 
    rpo.date AS doc_date,
    rpo.type AS doc_type,
    "" AS doc_status,
    rpo.document_number AS doc_num,
    rpo.element_name AS doc_name,
    vendor.display_string AS doc_location,
    am.display_string AS account_manager,
    method.method_name AS method,
    rpo.notes AS doc_notes

FROM (
    -- Pick Up
    SELECT id, 
        planned_start_date,
        planned_start_date AS date,
        'PUP' AS type, 
        document_number, 
        element_name, 
        -- status_id,
        shipping_method_id AS method_id, 
        person_responsible_id, 
        vendor_id, 
        is_deleted, 
        notes
        -- show_start 
    FROM st_prj_project_element

    WHERE location_id = '2f49c62c-b139-11df-b8d5-00e08175e43e' -- Vancouver
    
    AND def_id = 'c2eaed0c-b0bc-11df-b8d5-00e08175e43e' -- RPO

UNION ALL 
    
    -- Drop Off
    SELECT id, 
        planned_end_date,
        planned_end_date AS date,
        'DOFF' AS type, 
        document_number, 
        element_name, 
        -- status_id, 
        null AS method_id,
        person_responsible_id, 
        vendor_id, 
        is_deleted, 
        notes
        -- show_start 
    FROM st_prj_project_element

    WHERE location_id = '2f49c62c-b139-11df-b8d5-00e08175e43e' -- Vancouver
    
    AND def_id = 'c2eaed0c-b0bc-11df-b8d5-00e08175e43e' -- RPO
) AS rpo

LEFT JOIN st_biz_managed_resource AS am ON (am.id = rpo.person_responsible_id)
LEFT JOIN st_biz_managed_resource AS vendor ON (vendor.id = rpo.vendor_id)
LEFT JOIN st_biz_shipping_method AS method ON (method.id = rpo.method_id)

WHERE rpo.is_deleted = 0

) AS main

WHERE main.doc_date > $P{START_DATE} AND main.doc_date <= DATE_ADD($P{END_DATE}, INTERVAL 1 DAY) 

ORDER BY main.doc_date ASC
    
;