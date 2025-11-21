# Inizio osservando le tabelle e le relative colonne
SELECT 
    *
FROM
    banca.cliente;
SELECT 
    *
FROM
    banca.conto;
SELECT 
    *
FROM
    banca.tipo_conto;
SELECT 
    *
FROM
    banca.tipo_transazione;
SELECT 
    *
FROM
    banca.transazioni;

# INDICATORI DI BASE
# Calcolo l'eta in modo dinamico considerando la data odierna
CREATE TEMPORARY TABLE tmp_indicatori_base AS
SELECT 
    id_cliente,
    TIMESTAMPDIFF(YEAR,
        data_nascita,
        CURDATE()) AS eta_cliente
FROM
    banca.cliente;
    
/*  INDICATORI SULLE TRANSAZIONI
- Numero di transazioni in uscita su tutti i conti.
- Numero di transazioni in entrata su tutti i conti.
- Importo totale transato in uscita su tutti i conti.
- Importo totale transato in entrata su tutti i conti.
*/

CREATE TEMPORARY TABLE tmp_indicatori_transazioni AS
SELECT 
	c.id_cliente,
    COUNT(CASE WHEN tt.segno = "+" THEN 1 END) AS num_transazioni_entrata,
    COUNT(CASE WHEN tt.segno = "-" THEN 1 END) AS num_transazioni_uscita,
    ROUND(SUM(CASE WHEN tt.segno = "+" THEN t.importo ELSE 0 END),2) as tot_entrate,
	ROUND(SUM(CASE WHEN tt.segno = "-" THEN t.importo ELSE 0 END),2) as tot_uscite
FROM banca.cliente c
	LEFT JOIN banca.conto co ON c.id_cliente = co.id_cliente
    LEFT JOIN banca.transazioni t ON co.id_conto = t.id_conto
    LEFT JOIN banca.tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
GROUP BY
c.id_cliente;

/*  INDICATORI SUI CONTI
- Numero totale di conti posseduti.
- Numero di conti posseduti per tipologia (un indicatore per ogni tipo di conto).
*/

CREATE TEMPORARY TABLE tmp_indicatori_conti AS
SELECT
	c.id_cliente,
    COUNT(co.id_conto) AS qta_conti,
    COUNT(CASE WHEN tc.desc_tipo_conto = 'Conto Base' THEN 1 END) AS num_ContoBase,
	COUNT(CASE WHEN tc.desc_tipo_conto = 'Conto Business' THEN 1 END) AS num_ContoBusiness,
	COUNT(CASE WHEN tc.desc_tipo_conto = 'Conto Privati' THEN 1 END) AS num_ContoPrivati,
    COUNT(CASE WHEN tc.desc_tipo_conto = 'Conto Famiglie' THEN 1 END) AS num_ContoFamiglie
FROM banca.cliente c
	LEFT JOIN banca.conto co ON c.id_cliente = co.id_cliente
    LEFT JOIN banca.tipo_conto tc ON co.id_tipo_conto = tc.id_tipo_conto
GROUP BY
	c.id_cliente;

/*  INDICATORI SU TRANSAZIONI PER TIPO DI CONTO
- Numero di transazioni in uscita per tipologia di conto (un indicatore per tipo di conto).
- Numero di transazioni in entrata per tipologia di conto (un indicatore per tipo di conto).
- Importo transato in uscita per tipologia di conto (un indicatore per tipo di conto).
- Importo transato in entrata per tipologia di conto (un indicatore per tipo di conto).
*/

#Creiamo le 4 colonne per ogni tipologia di conto, in totale avremo quindi 16 nuove colonne
CREATE TEMPORARY TABLE tmp_indicatoritransazoni_per_tipo_conto AS
SELECT
	c.id_cliente,
    COUNT(CASE WHEN tc.desc_tipo_conto = 'Conto Base' AND tt.segno = '-' THEN 1 END) AS num_trans_uscita_ContoBase,
	COUNT(CASE WHEN tc.desc_tipo_conto = 'Conto Base' AND tt.segno = '+' THEN 1 END) AS num_trans_entrata_ContoBase,
	ROUND(SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Base' AND tt.segno = '-' THEN t.importo ELSE 0 END),2) AS totale_trans_uscita_ContoBase,
	ROUND(SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Base' AND tt.segno = '+' THEN t.importo ELSE 0 END),2) AS totale_trans_entrata_ContoBase,
    COUNT(CASE WHEN tc.desc_tipo_conto = 'Conto Business' AND tt.segno = '-' THEN 1 END) AS num_trans_uscita_ContoBusiness,
	COUNT(CASE WHEN tc.desc_tipo_conto = 'Conto Business' AND tt.segno = '+' THEN 1 END) AS num_trans_entrata_ContoBusiness,
	ROUND(SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Business' AND tt.segno = '-' THEN t.importo ELSE 0 END),2) AS totale_trans_uscita_ContoBusiness,
	ROUND(SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Business' AND tt.segno = '+' THEN t.importo ELSE 0 END),2) AS totale_trans_entrata_ContoBusiness,
	COUNT(CASE WHEN tc.desc_tipo_conto = 'Conto Privati' AND tt.segno = '-' THEN 1 END) AS num_trans_uscita_ContoPrivati,
	COUNT(CASE WHEN tc.desc_tipo_conto = 'Conto Privati' AND tt.segno = '+' THEN 1 END) AS num_trans_entrata_ContoPrivati,
	ROUND(SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Privati' AND tt.segno = '-' THEN t.importo ELSE 0 END),2) AS totale_trans_uscita_ContoPrivati,
	ROUND(SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Privati' AND tt.segno = '+' THEN t.importo ELSE 0 END),2) AS totale_trans_entrata_ContoPrivati,
	COUNT(CASE WHEN tc.desc_tipo_conto = 'Conto Famiglie' AND tt.segno = '-' THEN 1 END) AS num_trans_uscita_ContoFamiglie,
	COUNT(CASE WHEN tc.desc_tipo_conto = 'Conto Famiglie' AND tt.segno = '+' THEN 1 END) AS num_trans_entrata_ContoFamiglie,
	ROUND(SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Famiglie' AND tt.segno = '-' THEN t.importo ELSE 0 END),2) AS totale_trans_uscita_ContoFamiglie,
	ROUND(SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Famiglie' AND tt.segno = '+' THEN t.importo ELSE 0 END),2) AS totale_trans_entrata_ContoFamiglie
    FROM banca.cliente c
	LEFT JOIN banca.conto co ON c.id_cliente = co.id_cliente
    LEFT JOIN banca.transazioni t ON co.id_conto = t.id_conto
    LEFT JOIN banca.tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
    LEFT JOIN banca.tipo_conto tc ON co.id_tipo_conto = tc.id_tipo_conto
GROUP BY
	c.id_cliente;

CREATE TABLE tabella_denormalizzata AS SELECT t1.*,
    t2.num_transazioni_entrata,
    t2.num_transazioni_uscita,
    t2.tot_entrate,
    t2.tot_uscite,
    t3.qta_conti,
    t3.num_ContoBase,
    t3.num_ContoBusiness,
    t3.num_ContoPrivati,
    t3.num_ContoFamiglie,
    t4.num_trans_uscita_ContoBase,
    t4.num_trans_entrata_ContoBase,
    t4.totale_trans_uscita_ContoBase,
    t4.totale_trans_entrata_ContoBase,
    t4.num_trans_uscita_ContoBusiness,
    t4.num_trans_entrata_ContoBusiness,
    t4.totale_trans_uscita_ContoBusiness,
    t4.totale_trans_entrata_ContoBusiness,
    t4.num_trans_uscita_ContoPrivati,
    t4.num_trans_entrata_ContoPrivati,
    t4.totale_trans_uscita_ContoPrivati,
    t4.totale_trans_entrata_ContoPrivati,
    t4.num_trans_uscita_ContoFamiglie,
    t4.num_trans_entrata_ContoFamiglie,
    t4.totale_trans_uscita_ContoFamiglie,
    t4.totale_trans_entrata_ContoFamiglie FROM
    tmp_indicatori_base t1
        LEFT JOIN
    tmp_indicatori_transazioni t2 ON t1.id_cliente = t2.id_cliente
        LEFT JOIN
    tmp_indicatori_conti t3 ON t1.id_cliente = t3.id_cliente
        LEFT JOIN
    tmp_indicatoritransazoni_per_tipo_conto t4 ON t1.id_cliente = t4.id_cliente;
    
#Visualizzo tabella finale
SELECT 
    *
FROM
    tabella_denormalizzata;


