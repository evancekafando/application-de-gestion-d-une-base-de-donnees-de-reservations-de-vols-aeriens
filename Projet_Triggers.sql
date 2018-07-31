--########################################################################################################
--#																TRIGGERS																#
--########################################################################################################

--TRIGGER VERIFIE SI Nbre de Place Disponible avant toute insertion (Reservation)

CREATE OR REPLACE TRIGGER T_Nouvelle_reservation
before INSERT ON RESERVATION
for each row 

declare 
  place_null EXCEPTION;
  Nbre VOL.NbrePlacesDisponibles%TYPE;
begin
    SELECT NVL(NbrePlacesDisponibles,0) INTO Nbre FROM VOL WHERE (UPPER(:new.NumVol) = UPPER(VOL.NumVol));
    if (Nbre = 0) THEN
       RAISE place_null;
    end if;
EXCEPTION
  WHEN place_null THEN
    raise_application_error(-20001, 'IMPOSSIBLE DE FAIRE UNE RESERVATION, LE VOL EST COMPLET');
end;
/

--##############################################################
--TRIGGER DECREMENTE LE NOMBRE DE PLACE APRES CHAQUE RESERVATION
--##############################################################
CREATE OR REPLACE TRIGGER T_after_Nouvelle_reservation
after INSERT ON RESERVATION
for each row 
declare 

begin
UPDATE VOL SET VOL.NbrePlacesDisponibles = (VOL.NbrePlacesDisponibles-1) WHERE UPPER(VOL.NumVol) = UPPER(:new.NumVol);
end;
/

--############################################################################
--TRIGGER INCREMENTE LE NOMBRE DE PLACE APRES CHAQUE ANNULATION DE RESERVATION
--############################################################################
CREATE OR REPLACE TRIGGER T_annulation_reservation
before DELETE ON RESERVATION
for each row 
declare 
--Numero VOL.NumVol%TYPE;
begin

--SELECT NumVol into Numero FROM VOL WHERE UPPER(VOL.NumVol) = UPPER(:old.NumVol);
--if NUMERO IS NOT NULL THEN
 EXECUTE IMMEDIATE 'UPDATE VOL SET VOL.NbrePlacesDisponibles = (VOL.NbrePlacesDisponibles+1) WHERE UPPER(VOL.NumVol) = :num' USING UPPER(:old.NumVol);
--end if;
end;
/

--###############################################################
-- TRIGGER QUI MET A JOUR LW NBRES DHEURES AVION CHAQUE 24 HEURES
--###############################################################
--IMPOSSIBLE D"EXECUTER DROIT D'ACCES INDISPONIBLE 
--
BEGIN
    DBMS_SCHEDULER.CREATE_JOB(job_name => 'UpdateNbrHeure',
                              job_type => 'PLSQL_BLOCK',
                              job_action => '
DECLARE
CURSOR c IS
SELECT VOL.NumVol, (HeureMinArr + 24*JourArr - HeureMinMDep) AS DureeVol , NumAvion
 FROM VOL, AFFECTATION, (SELECT DISTINCT Numvol FROM TRAJET WHERE  DateVol > (SYSDATE-1))d 
WHERE d.NumVol =   VOL.NumVol AND d.NumVol = AFFECTATION.NumVol;
c_rec c%ROWTYPE ;

BEGIN 

OPEN c;
        
 FOR c_rec IN c Loop
	EXIT WHEN c%NOTFOUND;
	 UPDATE AVION
	 SET NbreHeures = c_rec.DureeVol WHERE NumAvion =  c_rec.NumAvion ;                                   
End loop ;
    
CLOSE c;		
	END;',
                              start_date => systimestamp,
                              repeat_interval => 'FREQ=DAILY;INTERVAL=1;BYHOUR=0;BYMINUTE=0;',
                              enabled => TRUE);
END;
/

--########################################################################################################
--TRIGGER "BEFORE DELETE AVION" supprime dans la table AFFECTATION les tuples contenant le numero d'un avion avant la suppression de cet Avion
--########################################################################################################

CREATE OR REPLACE TRIGGER T_delete_Avion
before DELETE ON AVION
for each row 

declare 
  
begin

DELETE FROM AFFECTATION WHERE UPPER(AFFECTATION.NumAvion) = UPPER(:old.NumAvion);
  
end;
/

--########################################################################################################
--TRIGGER "BEFORE DELETE APPREIL" supprime dans la table AVION les tuples contenant le CodeType d'un appareil avant la suppression de cet appareil
--########################################################################################################
CREATE OR REPLACE TRIGGER T_delete_Appareil
before DELETE ON APPAREIL
for each row 

declare 
  
begin

DELETE FROM AVION WHERE UPPER(AVION.CodeType) = UPPER(:old.CodeType);
  
end;
/

--########################################################################################################
