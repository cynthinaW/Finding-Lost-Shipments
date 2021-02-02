SELECT       EF.shipment_id                                                 "SHIPMENT_ID", 
             EWT.work_type                                               "WORK_TYPE",
             S.authorized                                                 "AUTHORIZED",
             sgs.picking_completed_date         "PICKING_COMPLETED_DATE",
             To_char(PSL.expected_delivery_date, 'MM/DD/YY')             "EXPECTED_DELIVERY_DATE",
             S.is_drop_ship ,
             S.is_cancelled ,
             S.is_hold ,
             S.is_temp_hold ,
             O.is_cancelled , 
             O.is_hold ,
             O.is_temp_hold,
--- SKU orders from smallest to largest
            string_agg(sk.sku::VARCHAR ||'-'||osh.quantity::VARCHAR,','order by sk.sku::VARCHAR ASC)  "SKU-QUANTITY"
               
FROM   exporting_work_type EWT, 
       exporting_flags EF 
       INNER JOIN shipment S 
               ON EF.shipment_id = S.shipment_id 
       LEFT JOIN orders O 
              ON S.order_id = O.order_id 
       LEFT JOIN proship_shipment_lookup PSL 
              ON EF.shipment_id = PSL.shipment_id 
       JOIN   order_shipment osh
              ON  osh.shipment_id=s.shipment_id
       JOIN order_sku osk
              ON  osh.order_sku_id=osk.order_sku_id
       JOIN   sku sk
               ON sk.sku=osk.sku
       LEFT JOIN  sg_shipment_state sgs 
               ON s.shipment_id = sgs.shipment_id
WHERE  EF.work_type_id = EWT.id 
---Only Grab the shipments from Brooklyn warehouse
       AND ef.work_type_id  IN (39,41,40,38,26,27,32,24,25,28,1,30,31,22,29,12,33,46)
       AND s.shipped_date is null 
       AND O.date_created > ( localtimestamp - ( 365 
                                                 || ' days' ) :: interval ) 
---Limit the research date only within 2020                                               
       AND s.authorized::Date>= '01/01/2020' 
       AND s.authorized::Date<= '12/31/2020'    
Group by 1,2,3,4,5,6,7,8,9,10,11,12
HAVING string_agg(sk.sku::VARCHAR ||'-'||osh.quantity::VARCHAR,','order by sk.sku::VARCHAR ASC) IN ('457800000000-1,471700000001-1,489040000001-2,496440000000-1,497490000000-2,524050000001-2,527340000000-1')
       ; 
