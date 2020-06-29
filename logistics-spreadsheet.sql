SELECT
    *
FROM
    (
        -- Quotes
        SELECT
            quote.id AS doc_id,
            quote.date AS doc_date,
            quote.type AS doc_type,
            status.status_name AS doc_status,
            quote.document_number AS doc_num,
            quote.element_name AS doc_name,
            quote.location_id AS location_id,
            venue.display_string AS doc_location,
            am.display_string AS account_manager,
            method.method_name AS method,
            method.id AS method_id,
            quote.notes AS doc_notes,
            findoc.center_addr_string AS onsite_details,
            '24a2d590-2fb8-11e9-9163-4676808eeebb' AS pdf_report_type
        FROM
            (
                -- Load In
                SELECT
                    id,
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
                    location_id,
                    show_start
                FROM
                    st_prj_project_element
                WHERE
                    def_id = '9bfb850c-b117-11df-b8d5-00e08175e43e' -- Quote
                UNION
                ALL -- Load Out
                SELECT
                    id,
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
                    location_id,
                    show_start
                FROM
                    st_prj_project_element
                WHERE
                    def_id = '9bfb850c-b117-11df-b8d5-00e08175e43e' -- Quote
            ) AS quote
            LEFT JOIN st_biz_status_option AS status ON (status.id = quote.status_id)
            LEFT JOIN st_biz_shipping_method AS method ON (method.id = quote.method_id)
            LEFT JOIN st_biz_managed_resource AS am ON (am.id = quote.person_responsible_id)
            LEFT JOIN st_biz_managed_resource AS venue ON (venue.id = quote.venue_id)
            LEFT JOIN st_fin_document AS findoc ON (quote.id = findoc.id)
        WHERE
            quote.is_deleted = 0
            AND (
                status.id != '78a1508c-aee7-11df-b8d5-00e08175e43e' -- Cancelled
                AND status.id != '8b47ca2c-aee7-11df-b8d5-00e08175e43e'
            ) -- Closed
        UNION
        ALL -- RPOs
        SELECT
            rpo.id AS doc_id,
            rpo.date AS doc_date,
            rpo.type AS doc_type,
            "" AS doc_status,
            rpo.document_number AS doc_num,
            rpo.element_name AS doc_name,
            rpo.location_id AS location_id,
            vendor.display_string AS doc_location,
            am.display_string AS account_manager,
            method.method_name AS method,
            method.id AS method_id,
            rpo.notes AS doc_notes,
            "" AS onsite_details,
            "7bcf4f50-b5fc-11e8-b74c-0030489e8f64" AS pdf_report_type
        FROM
            (
                -- Pick Up
                SELECT
                    id,
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
                    location_id,
                    notes -- show_start 
                FROM
                    st_prj_project_element
                WHERE
                    def_id = 'c2eaed0c-b0bc-11df-b8d5-00e08175e43e' -- RPO
                UNION
                ALL -- Drop Off
                SELECT
                    id,
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
                    location_id,
                    notes -- show_start 
                FROM
                    st_prj_project_element
                WHERE
                    def_id = 'c2eaed0c-b0bc-11df-b8d5-00e08175e43e' -- RPO
            ) AS rpo
            LEFT JOIN st_biz_managed_resource AS am ON (am.id = rpo.person_responsible_id)
            LEFT JOIN st_biz_managed_resource AS vendor ON (vendor.id = rpo.vendor_id)
            LEFT JOIN st_biz_shipping_method AS method ON (method.id = rpo.method_id)
        WHERE
            rpo.is_deleted = 0
        UNION
        ALL
        SELECT
            sales.id AS doc_id,
            sales.planned_start_date AS doc_date,
            "SALE" AS doc_type,
            status.status_name AS doc_status,
            sales.document_number AS doc_num,
            sales.element_name AS doc_name,
            sales.location_id AS location_id,
            venue.display_string AS doc_location,
            am.display_string AS account_manager,
            method.method_name AS method,
            method.id AS method_id,
            sales.notes AS doc_notes,
            "" AS onsite_details,
            "7bcf4f50-b5fc-11e8-b74c-0030489e8f64" AS pdf_report_type
        FROM
            st_prj_project_element AS sales
            LEFT JOIN st_biz_status_option AS status ON (status.id = sales.status_id)
            LEFT JOIN st_biz_managed_resource AS am ON (am.id = sales.person_responsible_id)
            LEFT JOIN st_biz_managed_resource AS venue ON (venue.id = sales.venue_id)
            LEFT JOIN st_biz_shipping_method AS method ON (method.id = sales.shipping_method_id)
        WHERE
            sales.def_id = '6f36f740-a565-11e3-a128-00259000d29a' -- sales
            AND sales.is_deleted = 0
            AND (
                status.id != '78a1508c-aee7-11df-b8d5-00e08175e43e' -- Cancelled
                AND status.id != '8b47ca2c-aee7-11df-b8d5-00e08175e43e'
            ) -- Closed
    ) AS main
WHERE
    main.method_id IN (
        'd6093248-3592-11e1-99fd-00e08175e43e',
        -- Action Movers
        'f29c2cb0-6058-11e8-bc06-0030489e8f64',
        -- Day and Ross
        '88037050-605a-11e8-bc06-0030489e8f64',
        -- Loungeworks
        '6b774ba0-605f-11e8-bc06-0030489e8f64',
        -- Loungeworks Warehouse Courier
        '0ee30788-3593-11e1-99fd-00e08175e43e',
        -- Other
        'cf3a44e0-5ec9-11e8-bc06-0030489e8f64',
        -- Outside Carrier
        '09e14a88-3593-11e1-99fd-00e08175e43e' -- See Notes
    )
    AND main.location_id = '2f49c62c-b139-11df-b8d5-00e08175e43e' -- Vancouver
    -- AND main.doc_date > $ P { START_DATE }
    -- AND main.doc_date <= DATE_ADD($ P { END_DATE }, INTERVAL 1 DAY)
ORDER BY
    main.doc_date ASC;