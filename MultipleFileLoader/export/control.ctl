LOAD DATA 
INFILE 'Stock.ready.doc' 
BADFILE 'Stock.ready.bad'
DISCARDFILE 'Stock.ready.dsc'

TRUNCATE 
INTO TABLE "T3R_REPORTE_STOCK_TAO"
TRUNCATE 

FIELDS TERMINATED BY ','
(
    PARTNER_ID,
    PARTNER_NAME,
    PLANTA,
    UBICACION, 
    MATERIAL,
    MATERIAL_NAME, 
    LOTE NULLIF LOTE=BLANKS,
    LIBRE_UTILIZACION NULLIF LIBRE_UTILIZACION=BLANKS,
    EN_CONTROL NULLIF EN_CONTROL=BLANKS,
    STOCK_NO_LIBRE NULLIF STOCK_NO_LIBRE=BLANKS,
    EN_TRASLADO NULLIF EN_TRASLADO=BLANKS,
    UMB
)
