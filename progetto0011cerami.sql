-- Progetto 0011 di Cerami Cristian, Matricola: 324075

DROP SCHEMA IF EXISTS ordinazioni_postali CASCADE;
CREATE SCHEMA ordinazioni_postali;
SET search_path TO ordinazioni_postali;


CREATE TABLE prodotto(
	numero_p INT PRIMARY KEY, 
	nome_p VARCHAR UNIQUE, 
	quant_giaz INT NOT NULL, 
	prezzo NUMERIC, 
	liv_riordino INT
);

CREATE TABLE codice_CAP(
	CAP VARCHAR PRIMARY KEY, 
	citta VARCHAR NOT NULL
);

-- Avendo le chiavi primarie già elencate dalla prof non ho potuto effettuare la scelta di avere come chiave primaria 
-- la coppia CAP-citta in quanto le città in Italia possono avere uno stesso CAP e quindi sarebbe bene specificare la
-- città di appartenenza ed è per questo motivo che ho messo citta NOT NULL e non l'ho messa UNIQUE in quanto esistono
-- più città che hanno lo stesso nome ma, perfortuna, CAP diverso. In caso contrario si sarebbe dovuta aggiungere anche
-- la colonna 'regione'

CREATE TABLE cliente(
	numero_c INT PRIMARY KEY,
	nome_c VARCHAR NOT NULL,
	via VARCHAR NOT NULL,
	CAP VARCHAR REFERENCES codice_CAP(CAP),
	telefono VARCHAR
);

-- telefono per me può non essere UNIQUE in quanto se il cliente fa parte di un'azienda allora come telefono lascierà il numero
-- dell'azienda e non il proprio. E allo stesso tempo ci potrebbero essere più clienti dipendendti della stessa azienda
-- telefono può essere NULL in quanto solitamente viene usato solo in caso di problemi e quindi il suo inserimento è facoltativo
-- via non può essere NULL perchè bisogna sapere dove vogliamo consegnare il pacco e non è UNIQUE in quanto più città hanno 
-- una stessa via
-- nome_c non può essere NULL in quanto quando un prodotto deve essere consegnato si deve sapere chi è che lo può ritirare
-- o in caso di una ditta si deve sapere chi è l'impiegato che ha comprato un determinato oggetto

CREATE TABLE impiegato(
	numero_i INT PRIMARY KEY,
	nome_i VARCHAR,
	CAP VARCHAR REFERENCES codice_CAP(CAP),
	dta_assunzione DATE NOT NULL
);

-- nome impiegato può essere NULL in quanto è quasi inutile saperlo essendo l'unica cosa importante il suo numero identificativo
-- dta_assunzione è NOT NULL in quanto per essere dipendente si deve avere per forza una data di assunzione

CREATE TABLE ordinazione(
	numero_o INT PRIMARY KEY,
	numero_c INT NOT NULL REFERENCES cliente(numero_c) ON UPDATE CASCADE ON DELETE RESTRICT,
	numero_i INT NOT NULL REFERENCES impiegato(numero_i) ON UPDATE CASCADE ON DELETE RESTRICT,
	data_ordine DATE NOT NULL,
	data_consegna DATE
);

-- Se un cliente ha effettuato un ordine allora deve essere impossibile eliminare quel cliente o comunque prima deve essere
-- cancellato l'ordine
-- Se un impiegato viene eliminato e c'è un ordine attivo fatto da lui si deve prima passare il numero ordine a un'altro 
-- impiegato in quanto è preferibile far continuare l'ordine e far guadagnare soldi al negozio
-- data_ordine è NOT NULL in quanto se esiste l'ordine deve esistere per forza anche la data di creazione dell'ordine
-- data_consegna può essere NULL in caso si verifichino problemi nella spedizione e non si sappia quando arriverà

CREATE TABLE dettaglio(
	numero_o INT REFERENCES ordinazione(numero_o) ON UPDATE CASCADE ON DELETE CASCADE, 
	numero_p INT REFERENCES prodotto(numero_p) ON UPDATE CASCADE ON DELETE RESTRICT,
	quantita INT NOT NULL,
	PRIMARY KEY(numero_o, numero_p)
);


-- Se un prodotto è presente in un'ordine allora deve essere impossibile eliminare quel prodotto. 
-- quantita è NOT NULL in quanto se si fa un'ordine si sa per forza quanti determinati pezzi di un prodotto sono stati venduti
-- e non più presenti in magazzino 


\copy prodotto from C://ProgettoEsame0011/prodotto.txt
\copy codice_CAP from C://ProgettoEsame0011/codice_CAP.txt
\copy cliente from C://ProgettoEsame0011/cliente.txt
\copy impiegato from C://ProgettoEsame0011/impiegato.txt
\copy ordinazione from C://ProgettoEsame0011/ordinazione.txt
\copy dettaglio from C://ProgettoEsame0011/dettaglio.txt



-- (1) I nomi dei prodotti che hanno costo inferiore a 100 euro
	SELECT nome_p AS nome_prodotto from prodotto where prezzo < 100;

-- (2) Le coppie di clienti (codice cliente) che risiedono nella stessa citta ed hanno lo stesso nome.
	
	SELECT DISTINCT c1.nome_c AS nome_cliente_1, c2.nome_c AS nome_cliente_2 from cliente as c1 natural join codice_CAP as cap1, cliente as c2 natural join codice_CAP as cap2 where c1.nome_c = c2.nome_c and cap1.citta = cap2.citta and c1.numero_c != c2.numero_c;

-- (3) I nomi dei clienti residenti a Perugia (CAP 06123) che non hanno effettuato alcun ordine.
	SELECT nome_c AS nome_cliente from cliente natural left join ordinazione natural join codice_CAP where numero_o IS NULL and codice_CAP.citta = 'Perugia';

-- (4) I clienti che hanno ordinato tutti i prodotti di costo inferiore a 10 euro.
-- equivale a...
-- Per ogni prodotto di costo inferiore a 10 euro, esiste uno stesso cliente che lo ha comprato
-- equivale a...
-- Non esiste un prodotto di costo inferiore a 10 euro che non è stato acquistato da uno stesso cliente
-- equivale a...
-- Il numero di prodotti diversi tra loro e di costo inferiore a 10 euro acquistati da una stessa persona è uguale al numero 
-- di oggetti diversi di costo inferiore a 10 euro presenti nella BD

	SELECT nome_c FROM cliente AS x WHERE NOT EXISTS 
	(SELECT * FROM prodotto AS y WHERE y.prezzo < 10 AND NOT EXISTS 
	(SELECT * FROM ordinazione AS z natural join dettaglio AS z2 
	WHERE z.numero_c = x.numero_c AND z2.numero_p = y.numero_p));


-- Esercizio 3
-- Dopo aver aggiunto l'attributo numordinazioni nella relazione impiegato, si definisca un trigger per l'aggiornamento 
-- automatico del numero di ordinazioni processate da ogni impiegato.
	ALTER TABLE impiegato ADD COLUMN num_ordinazioni INT DEFAULT 0; 
	UPDATE impiegato SET num_ordinazioni = (SELECT COUNT(DISTINCT ordinazione.numero_o) from impiegato as i1 natural join ordinazione where i1.numero_i = impiegato.numero_i GROUP BY numero_i);

	CREATE OR REPLACE FUNCTION aggiorna_numero_ordinazioni() 
	RETURNS TRIGGER AS $BODY$
	BEGIN
		IF TG_OP = 'INSERT' THEN
			UPDATE impiegato SET num_ordinazioni = num_ordinazioni + 1 where numero_i = NEW.numero_i;
			RETURN NEW;
		END IF;

		IF TG_OP = 'DELETE' THEN
			UPDATE impiegato SET num_ordinazioni = num_ordinazioni - 1 where numero_i = OLD.numero_i;
			RETURN OLD;
		END IF;

		IF TG_OP = 'UPDATE' THEN
			UPDATE impiegato SET num_ordinazioni = num_ordinazioni - 1 where numero_i = OLD.numero_i;
			UPDATE impiegato SET num_ordinazioni = num_ordinazioni + 1 where numero_i = NEW.numero_i;
			RETURN NEW;
		END IF;
	END;
	$BODY$
	LANGUAGE PLPGSQL;


	CREATE TRIGGER aggiorna_numero_ordinazioni
	AFTER INSERT OR UPDATE OR DELETE
	ON ordinazione
	FOR EACH ROW
	EXECUTE PROCEDURE aggiorna_numero_ordinazioni();


-- Progetto 0011 di Cerami Cristian, Matricola: 324075

-- Dentro terminale psql eseguire: -- \i C://ProgettoEsame0011/progetto0011cerami.sql