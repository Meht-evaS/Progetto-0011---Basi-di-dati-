
# LABORATORIO DI BASI DI DATI: PROGETTO 0011

Progetto d'esame, in linguaggio SQL, per la materia Basi di Dati e Sistemi Informativi con Laboratorio (A.A. 2021/2022).

##  :pencil: Sommario
* [Obiettivo](#obiettivo)
* [Problema](#problema)
* [Ambiente di lavoro](#ambiente-di-lavoro)
* [Setup](#setup)

## :dart: Obiettivo <a name="obiettivo"/>
L'obiettivo di questo progetto è la risoluzione di una serie di esercizi che è possibile leggere all'interno del file [progetto0011.pdf](progetto0011.pdf). In generale ci viene chiesto di creare e popolare uno schema relazionale, nominato "*ordinazioni_postali*", tramite script SQL, che vada a rispettare una serie di vincoli e su cui possano poi essere eseguite delle specifiche query.

## :question: Problema <a name="problema"/>
Possiamo sintetizzare le richieste degli esercizi come:
- Creare lo schema definendo e commentando i vincoli per il popolamento delle varie tabelle
- Popolare lo schema affinchè ogni query da eseguire restituisca almeno un risultato
- Eseguire delle query
- Creare un trigger per l'aggiornamento automatico di alcuni valori quando viene eseguita una specifica azione 

## :computer: Ambiente di lavoro <a name="ambiente-di-lavoro"/>
Il progetto è stato realizzato su Windows ed in particolare tramite il terminale **psql (PostgreSQL Shell)** che è possibile installare al [seguente link](https://www.postgresql.org/download/).

## :gear: Setup <a name="setup"/>
Per eseguire questo progetto, dopo aver scaricato il terminale **[psql (PostgreSQL Shell)](https://www.postgresql.org/download/)**, ti basterà:
1. Creare la cartella `ProgettoEsame0011` all'interno della directory `C:` 
2. Scaricare i file di questo progetto all'inerno della cartella creata al punto precedente
3. Aprire il terminale `psql` ed eseguire il seguente comando:
```sql
\i C://ProgettoEsame0011/progetto0011cerami.sql 
```
