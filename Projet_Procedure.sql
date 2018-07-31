--########################################################################################################
--#									             PROCEDURES TABLE AFFECTATION		 	   							#
--########################################################################################################


--####################################
-- PROCEDURE AJOUTER UNE AFFECTATION
--####################################
CREATE OR REPLACE 
PROCEDURE p_add_affectation(Num_vo IN AFFECTATION.NumVol%TYPE, 
			    Num_Avion IN AFFECTATION.NumAvion%TYPE, 
			    NbrePass IN AFFECTATION.NbrePassagers%TYPE) AS

numeroVo AFFECTATION.NumVol%TYPE;
numeroAv AFFECTATION.NumAvion%TYPE;

BEGIN 
--PERMET DE VERIFIER SI LE VOL ET LE NUMERO D"AVION EXISTE (RAISE NO_DATA_FOUND SINON): CONTRAINTE DE CLE ETRANGERE
SELECT NumVol into numeroVo FROM VOL WHERE UPPER(VOL.NumVol) = UPPER(Num_vo);
SELECT NumAvion into numeroAv FROM AVION WHERE UPPER(AVION.NumAvion) = UPPER(Num_Avion);

--INSERTION
INSERT INTO AFFECTATION values (UPPER(Num_vo), UPPER(Num_Avion), NbrePass );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
	  RAISE_APPLICATION_ERROR(-20001, 'Erreur de cle secondaire ! Ce numero de Vol ou Numero d''avion n''existe pas');

END;
/

--########################################
-- PROCEDURE SUPPRIMER UNE AFFECTATION
--#########################################
CREATE OR REPLACE PROCEDURE p_del_affectation(Num_vo IN AFFECTATION.NumVol%TYPE, 
			    		      Num_Avion IN AFFECTATION.NumAvion%TYPE) AS

numeroVo AFFECTATION.NumVol%TYPE;
numeroAv AFFECTATION.NumAvion%TYPE;

BEGIN 
--PERMET DE VERIFIER SI L"AFFECTATION EXISTE (RAISE NO_DATA_FOUND SINON)
SELECT NumVol, NumAvion into numeroVo , numeroAv FROM AFFECTATION WHERE UPPER(AFFECTATION.NumVol) = UPPER(Num_vo) AND UPPER(AFFECTATION.NumAvion) = UPPER(Num_Avion);

DELETE FROM AFFECTATION WHERE UPPER(AFFECTATION.NumVol) = UPPER(Num_vo) AND UPPER(AFFECTATION.NumAvion) = UPPER(Num_Avion);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
	  RAISE_APPLICATION_ERROR(-20001, 'Les données(Numero de vol ou Numero d''avion) de l''affectation entree, n''existe pas');
END;
/

--###################################
-- PROCEDURE MODIFIER AFFECTATION
--###################################
CREATE OR REPLACE PROCEDURE p_updt_affectation(Num_vo IN AFFECTATION.NumVol%TYPE, 
			    		       Num_Avion IN AFFECTATION.NumAvion%TYPE,
					       newVol IN AFFECTATION.NumVol%TYPE, 
			    		       newAvion IN AFFECTATION.NumAvion%TYPE,
					       newPassaG IN AFFECTATION.NbrePassagers%TYPE) AS

FOREING_KEY_ERROR EXCEPTION;

BEGIN 

UPDATE AFFECTATION
SET NumVol = UPPER(newVol), NumAvion = UPPER(newAvion), NbrePassagers = newPassaG
WHERE UPPER(NumVol) = UPPER(Num_vo) AND UPPER(NumAvion) = UPPER(Num_Avion);

IF SQL%ROWCOUNT = 0 THEN
    RAISE FOREING_KEY_ERROR;
END IF;
    
EXCEPTION
   WHEN FOREING_KEY_ERROR THEN
     RAISE_APPLICATION_ERROR(-20001,'FOREIGN KEY ERROR: Impossible de faire la modification, le Numero de vol ou d''affectation n''existe pas dans la base de donnees ') ;
  ROLLBACK;
END;
/

--##############################################################
-- PROCEDURE Verifie Existence d'affectation AVANT MODIFICATION
--##############################################################

CREATE OR REPLACE PROCEDURE p_check_affectation(Num_vo IN AFFECTATION.NumVol%TYPE, 
			    		      Num_Avion IN AFFECTATION.NumAvion%TYPE) AS

numeroVo AFFECTATION.NumVol%TYPE;
numeroAv AFFECTATION.NumAvion%TYPE;

BEGIN 

SELECT NumVol, NumAvion into numeroVo , numeroAv FROM AFFECTATION WHERE UPPER(AFFECTATION.NumVol) = UPPER(Num_vo) AND UPPER(AFFECTATION.NumAvion) = UPPER(Num_Avion);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RAISE_APPLICATION_ERROR(-20001,'Les données de l''affectation entree, n''existe pas, Impossible de mettre a jour !') ;

END;
/

--########################################################################################################
--#									             PROCEDURES TABLE VOL		 	   										#
--########################################################################################################


--##########################
-- PROCEDURE AJOUTER UN VOL
--##########################
CREATE OR REPLACE PROCEDURE p_add_vol(Nvol IN VOL.NumVol%TYPE, 
			    		 Depart IN VOL.CodeDep%TYPE, 
			    		 Arriv IN VOL.CodeArr%TYPE,
			    		 HeurDepart IN VOL.HeureMinMDep%TYPE,
			    		 HeurArriv IN VOL.HeureMinArr%TYPE,
			    		 JArr IN VOL.JourArr%TYPE,
			    		 NbrePlace IN VOL.NbrePlacesDisponibles%TYPE) AS	

Ville1 AEROPORT.CodeArpt%TYPE;
Ville2 AEROPORT.CodeArpt%TYPE;

BEGIN 
--VERIFICATION DE LA PRESENCE DES CODES AEROPORT
SELECT CodeArpt INTO Ville1 FROM AEROPORT WHERE UPPER(CodeArpt) = UPPER(Depart);
SELECT CodeArpt INTO Ville2 FROM AEROPORT WHERE UPPER(CodeArpt) = UPPER(Arriv);
--INSERTION
INSERT INTO VOL values (UPPER(Nvol), UPPER(Depart), UPPER(Arriv), HeurDepart, HeurArriv, JArr, NbrePlace);

EXCEPTION
WHEN NO_DATA_FOUND THEN
 RAISE_APPLICATION_ERROR(-20001,'Un des codes Aeroport N''existe pas!') ;

END;
/

--############################
-- PROCEDURE SUPPRIMER UN VOL
--############################
CREATE OR REPLACE 
PROCEDURE p_del_vol(Nvol IN VOL.NumVol%TYPE) AS

BEGIN
--UNE AUTRE PROCEDURE VERIFIE LA PRESENCE DU VOL AVANT LA SUPPRESSION
--ON SUPPRIME AUSSI TOUS LES TUPLES CONTENANT ENTREE DANS LES AUTRES TABLES COMME CLE ETRANGERE

EXECUTE IMMEDIATE 'DELETE FROM AFFECTATION WHERE UPPER(AFFECTATION.NumVol) = :num' USING UPPER(Nvol);

EXECUTE IMMEDIATE 'ALTER TABLE RESERVATION DISABLE CONSTRAINT FK_RESERVATION_A'; 
DELETE FROM TRAJET WHERE UPPER(TRAJET.NumVol) = UPPER(Nvol);

EXECUTE IMMEDIATE 'ALTER TRIGGER T_ANNULATION_RESERVATION DISABLE'; 
EXECUTE IMMEDIATE 'DELETE FROM RESERVATION WHERE UPPER(RESERVATION.NumVol) = :num' USING UPPER(Nvol);         
EXECUTE IMMEDIATE 'ALTER TRIGGER T_ANNULATION_RESERVATION ENABLE'; 

EXECUTE IMMEDIATE 'ALTER TABLE RESERVATION ENABLE CONSTRAINT FK_RESERVATION_A';

DELETE FROM VOL WHERE UPPER(VOL.NumVol) = UPPER(Nvol); 

END;
/

--###############################
--PROCEDURE POUR MODIFIER UN VOL
--###############################
CREATE OR REPLACE 
PROCEDURE p_updt_vol(
						 Nvol IN VOL.NumVol%TYPE,
						 NewNvol IN VOL.NumVol%TYPE, 
			    		 NewDepart IN VOL.CodeDep%TYPE, 
			    		 NewArriv IN VOL.CodeArr%TYPE,
			    		 NewHeurDepart IN VOL.HeureMinMDep%TYPE,
			    		 NewHeurArriv IN VOL.HeureMinArr%TYPE,
			    		 NewJArr IN VOL.JourArr%TYPE,
			    		 NewNbrePlace IN VOL.NbrePlacesDisponibles%TYPE) AS	

Ville1 AEROPORT.CodeArpt%TYPE;
Ville2 AEROPORT.CodeArpt%TYPE;

BEGIN
--UNE AUTRE PROCEDURE VERIFIE LA PRESENCE DU VOL AVANT LA MODIFICATION

--VERIFICATION DE LA PRESENCE DES CODES AEROPORT
SELECT CodeArpt INTO Ville1 FROM AEROPORT WHERE UPPER(CodeArpt) = UPPER(NewDepart);
SELECT CodeArpt INTO Ville2 FROM AEROPORT WHERE UPPER(CodeArpt) = UPPER(NewArriv);

--MET A JOUR Le VOL et MET A JOUR les tuples des tables qui ont la clé primaire de la table VOL comme clé secondaire

EXECUTE IMMEDIATE 'ALTER TABLE VOL DISABLE PRIMARY KEY CASCADE';
	UPDATE VOL
	SET NumVol = UPPER(NewNVol), CodeDep = UPPER(NewDepart), CodeArr = UPPER(NewArriv), HeureMinMDep = NewHeurDepart, HeureMinArr = NewHeurArriv, JourArr = NewJArr, NbrePlacesDisponibles = NewNbrePlace
	WHERE UPPER(NumVol) = UPPER(Nvol);

EXECUTE IMMEDIATE 'ALTER TABLE RESERVATION  DISABLE CONSTRAINT FK_RESERVATION_A ';
EXECUTE IMMEDIATE 'ALTER TABLE TRAJET  DISABLE CONSTRAINT FK_TRAJET_A';
EXECUTE IMMEDIATE 'ALTER TABLE AFFECTATION  DISABLE CONSTRAINT FK_AFFECTATION_A';

EXECUTE IMMEDIATE 'UPDATE TRAJET SET NumVol = :text1 WHERE TRAJET.NumVol = : text2' USING UPPER(NewNvol), UPPER(Nvol) ;
EXECUTE IMMEDIATE 'UPDATE RESERVATION SET NumVol = :text1 WHERE RESERVATION.NumVol = : text2' USING UPPER(NewNvol), UPPER(Nvol) ;

EXECUTE IMMEDIATE 'UPDATE AFFECTATION SET NumVol = :text1 WHERE AFFECTATION.NumVol = : text2' USING UPPER(NewNvol), UPPER(Nvol) ;
EXECUTE IMMEDIATE 'ALTER TABLE RESERVATION ENABLE CONSTRAINT FK_RESERVATION_A'; 
                 
EXECUTE IMMEDIATE 'ALTER TABLE VOL ENABLE VALIDATE PRIMARY KEY'; 

EXECUTE IMMEDIATE 'ALTER TABLE TRAJET  ENABLE CONSTRAINT FK_TRAJET_A';
EXECUTE IMMEDIATE 'ALTER TABLE AFFECTATION  ENABLE CONSTRAINT FK_AFFECTATION_A';
EXCEPTION
WHEN NO_DATA_FOUND THEN
 RAISE_APPLICATION_ERROR(-20001,'Un des codes Aeroport N''existe pas!') ;
END;

/

--########################################################################
-- PROCEDURE Verifie Existence d'un VOL AVANT MODIFICATION Ou SUPPRESSION
--########################################################################
CREATE OR REPLACE PROCEDURE p_check_vol(Nvol IN VOL.NumVol%TYPE) AS

numeroVo VOL.NumVol%TYPE;

BEGIN 

SELECT NumVol INTO numeroVo FROM VOL WHERE UPPER(VOL.NumVol) = UPPER(Nvol) ;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RAISE_APPLICATION_ERROR(-20001,'Ce Vol n''existe malheuresement pas!!!') ;

END;
/

--########################################################################################################
--#									      PROCEDURES TABLE RESERVATION		 	   										#
--########################################################################################################

--###################################
-- PROCEDURE AJOUTER UNE RESERVATION
--###################################
CREATE OR REPLACE 
PROCEDURE p_add_reservation(Num_vo IN RESERVATION.NumVol%TYPE, Date_vo IN VARCHAR, Num_plac IN RESERVATION.NumPlace%TYPE, Nom_clien IN RESERVATION.NomClient%TYPE) AS

numero TRAJET.NumVol%TYPE;
datev TRAJET.DateVol%TYPE;
BEGIN 

  SELECT NumVol,DateVol into numero,datev FROM TRAJET WHERE UPPER(TRAJET.NumVol) = UPPER(Num_vo) AND TRAJET.DateVol = TO_DATE(Date_vo, 'yyyy/mm/dd');

	INSERT INTO RESERVATION values (UPPER(Num_vo), TO_DATE(Date_vo, 'yyyy/mm/dd'), Num_plac, UPPER(Nom_clien));

EXCEPTION
   WHEN NO_DATA_FOUND THEN
	  RAISE_APPLICATION_ERROR(-20001, 'Ce Vol n''existe pas');

END;
/

--#####################################
-- PROCEDURE SUPPRIMER UNE RESERVATION
--#####################################
CREATE OR REPLACE PROCEDURE p_del_reservation(Num_vo IN RESERVATION.NumVol%TYPE, Date_vo IN VARCHAR, Num_plac IN RESERVATION.NumPlace%TYPE) AS

BEGIN 

DELETE FROM RESERVATION WHERE UPPER(NumVol) = UPPER(Num_vo) AND DateVol = TO_DATE(Date_vo, 'yyyy/mm/dd') AND NumPlace = Num_plac;


EXCEPTION
   WHEN NO_DATA_FOUND THEN
	  RAISE_APPLICATION_ERROR(-20001, 'Impossible de supprimer la reservation, les donnees entrées ne corespondent pas à aucune reservation');

END;
/

--####################################
-- PROCEDURE MODIFIER UNE RESERVATION
--####################################
CREATE OR REPLACE PROCEDURE p_updt_reservation(Num_vo IN RESERVATION.NumVol%TYPE,
						Date_vo IN VARCHAR,
	 					Num_plac IN RESERVATION.NumPlace%TYPE,
						new_NumVol IN RESERVATION.NumVol%TYPE,
						new_DateVol IN VARCHAR,
						new_NumPlace IN RESERVATION.NumPlace%TYPE, 
						new_Nom IN RESERVATION.NomClient%TYPE) AS

BEGIN 
-- ON A UNE AUTRE PRODEDURE QUI VERIFIE QUE LES NOUVELLES DONNEES DE RESERVATION SONT VALIDES AVANT LA MODIFICATION 
UPDATE RESERVATION
SET NumVol = UPPER(new_NumVol), DateVol = TO_DATE(new_DateVol, 'yyyy/mm/dd'), NumPlace = new_NumPlace, NomClient = UPPER(new_Nom)
WHERE UPPER(NumVol) = UPPER(Num_vo) AND DateVol = TO_DATE(Date_vo, 'yyyy/mm/dd') AND NumPlace = Num_plac;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
	  RAISE_APPLICATION_ERROR(-20001, 'Ce trajet n''existe pas dans la base de donnees');
END;
/

--#################################################
-- PROCEDURE Verifie RESERVATION AVANT MODIFICATION
--#################################################
CREATE OR REPLACE 
PROCEDURE p_check_reservation(Num_vo IN RESERVATION.NumVol%TYPE,
						Date_vo IN VARCHAR,
	 					Num_plac IN RESERVATION.NumPlace%TYPE ) AS

numero RESERVATION.NumVol%TYPE;

BEGIN 

 SELECT NumVol into numero FROM RESERVATION 
 WHERE NumVol = UPPER(Num_vo) AND DateVol = TO_DATE(Date_vo, 'yyyy/mm/dd') AND NumPlace = Num_plac;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RAISE_APPLICATION_ERROR(-20001,'Les parametres entrees sont incorrectes, aucune reservation ne correspond !') ;

END;
/

--########################################################################################################
--#									           PROCEDURES TABLE AVION		 	   										#
--########################################################################################################

--###########################
-- PROCEDURE AJOUTER UN AVION
--###########################
CREATE OR REPLACE 
PROCEDURE p_add_Avion(NAvion IN AVION.NUmAvion%TYPE, 
			    		 Ctype IN AVION.CodeType%TYPE, 
			    		 Annee IN AVION.AnneeService%TYPE,
			    		 NbreHeure IN AVION.NbreHeures%TYPE) AS	

Code APPAREIL.CodeType%TYPE;

BEGIN 
SELECT CodeType INTO Code FROM APPAREIL WHERE UPPER(CodeType) = UPPER(Ctype);

--INSERTION
INSERT INTO AVION values (UPPER(NAvion), UPPER(Ctype), Annee, NbreHeure);

EXCEPTION
 WHEN NO_DATA_FOUND THEN
 RAISE_APPLICATION_ERROR(-20001,'Le CodeType de l''appareil n''existe pas dans la table APPAREIL !') ;
END;
/

--#############################
-- PROCEDURE SUPPRIMER UN AVION
--#############################
CREATE OR REPLACE 
PROCEDURE p_del_Avion(NAvion IN AVION.NUmAvion%TYPE) AS

BEGIN
--UNE AUTRE PROCEDURE VERIFIE LA PRESENCE DE L'AVION AVANT LA SUPPRESSION
--UN TRIGGER A ETE PROGRAMMER POUR SUPPRIMER TOUS LES TUPLES CONTENANT L'ENTREE DANS LES AUTRES TABLES COMME CLE ETRANGERE

DELETE FROM AVION WHERE UPPER(AVION.NUmAvion) = UPPER(NAvion); 

END;
/

--#############################
-- PROCEDURE MODIFIER UN AVION
--#############################
CREATE OR REPLACE 
PROCEDURE p_updt_Avion(NAvion IN AVION.NumAvion%TYPE, 
						 NewNAvion IN AVION.NumAvion%TYPE,
			    		 NewCtype IN AVION.CodeType%TYPE, 
			    		 NewAnnee IN AVION.AnneeService%TYPE,
			    		 NewNbreHeure IN AVION.NbreHeures%TYPE) AS	

ACodeType AVION.CodeType%TYPE;

BEGIN
--UNE AUTRE PROCEDURE VERIFIE LA PRESENCE DE L'AVION AVANT LA MODIFICATION

--VERIFICATION DE LA PRESENCE DES CODES AEROPORT
SELECT CodeType INTO ACodeType FROM APPAREIL WHERE UPPER(CodeType) = UPPER(NewCtype);

--MET A JOUR L'AVION et MET A JOUR les tuples des tables qui ont la clé primaire de la table AVION comme clé secondaire
EXECUTE IMMEDIATE 'ALTER TABLE AVION DISABLE PRIMARY KEY CASCADE';
	
	UPDATE AVION
	SET NumAvion = UPPER(NewNAvion), CodeType = UPPER(NewCtype), AnneeService = NewAnnee, NbreHeures = NewNbreHeure
	WHERE UPPER(NumAvion) = UPPER(NAvion);

EXECUTE IMMEDIATE 'UPDATE AFFECTATION SET NumAvion = :text1 WHERE AFFECTATION.NumAvion = :text2' USING UPPER(NewNAvion), UPPER(NAvion) ;
                 
EXECUTE IMMEDIATE 'ALTER TABLE AVION ENABLE VALIDATE PRIMARY KEY'; 

EXECUTE IMMEDIATE 'ALTER TABLE AFFECTATION  ENABLE CONSTRAINT FK_AFFECTATION_B';

EXCEPTION
WHEN NO_DATA_FOUND THEN
 RAISE_APPLICATION_ERROR(-20001,'Le CodeType de l''appareil n''existe pas dans la table APPAREIL !') ;
END;
/

--##########################################################################
-- PROCEDURE Verifie Existence d'un AVION AVANT MODIFICATION Ou SUPPRESSION
--##########################################################################
CREATE OR REPLACE PROCEDURE p_check_Avion(NAvion IN AVION.NUmAvion%TYPE) AS

numeroAvion AVION.NUmAvion%TYPE;

BEGIN 

SELECT NAvion INTO numeroAvion FROM AVION WHERE UPPER(AVION.NUmAvion) = UPPER(NAvion) ;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RAISE_APPLICATION_ERROR(-20001,'Cet Avion n''existe malheuresement pas!!!') ;

END;
/

--########################################################################################################
--#									      PROCEDURES TABLE RESERVATION		 	   										#
--########################################################################################################

--##############################
-- PROCEDURE AJOUTER UN APPAREIL
--##############################
CREATE OR REPLACE 
PROCEDURE p_add_App(Ctype IN APPAREIL.CodeType%TYPE, 
			    		 PlaceMax IN APPAREIL.NbrePlaceMax%TYPE, 
			    		 Fab IN APPAREIL.Fabricant%TYPE) AS	

BEGIN 

--INSERTION
INSERT INTO APPAREIL values (UPPER(Ctype), PlaceMax, UPPER(Fab));

END;
/

--################################
-- PROCEDURE SUPPRIMER UN APPAREIL
--################################
CREATE OR REPLACE 
PROCEDURE p_del_App(Ctype IN APPAREIL.CodeType%TYPE) AS

BEGIN
--UNE AUTRE PROCEDURE VERIFIE LA PRESENCE DE L'APPAREIL AVANT LA SUPPRESSION
--UN TRIGGER A ETE PROGRAMMER POUR SUPPRIMER TOUS LES TUPLES CONTENANT L'ENTREE DANS LES AUTRES TABLES COMME CLE ETRANGERE

DELETE FROM APPAREIL WHERE UPPER(APPAREIL.CodeType) = UPPER(Ctype); 

END;
/

--###############################
-- PROCEDURE MODIFIER UN APPAREIL
--###############################
CREATE OR REPLACE 
PROCEDURE p_updt_App(Ctype IN APPAREIL.CodeType%TYPE, 
							NewCtype IN APPAREIL.CodeType%TYPE, 
			    		 	NewPlaceMax IN APPAREIL.NbrePlaceMax%TYPE, 
			    		 	NewFab IN APPAREIL.Fabricant%TYPE) AS	

BEGIN
--UNE AUTRE PROCEDURE VERIFIE LA PRESENCE DE L'APPAREIL AVANT LA MODIFICATION

--MET A JOUR L'APPAREIL et MET A JOUR les tuples des tables qui ont la clé primaire de la table APPAREIL comme clé secondaire

    EXECUTE IMMEDIATE 'ALTER TABLE APPAREIL DISABLE PRIMARY KEY CASCADE';
	 
	 UPDATE APPAREIL SET CodeType = UPPER(NewCtype), NbrePlaceMax = NewPlaceMax, Fabricant = UPPER(NewFab) WHERE UPPER(CodeType) = UPPER(Ctype);
	 
    EXECUTE IMMEDIATE 'UPDATE AVION SET CodeType = :var1 WHERE AVION.CodeType = :var2 'USING  UPPER(NewCtype), UPPER(Ctype) ;
                       
    EXECUTE IMMEDIATE 'ALTER TABLE APPAREIL ENABLE VALIDATE PRIMARY KEY';
    
	 EXECUTE IMMEDIATE 'ALTER TABLE AVION  ENABLE CONSTRAINT FK_AVION_A';

END;
/

--############################################################################
-- PROCEDURE Verifie Existence d'un APPAREIL AVANT MODIFICATION Ou SUPPRESSION
--############################################################################
CREATE OR REPLACE PROCEDURE p_check_App(Ctype IN APPAREIL.CodeType%TYPE) AS

CodeAv APPAREIL.CodeType%TYPE;

BEGIN 

SELECT CodeType INTO CodeAv FROM APPAREIL WHERE UPPER(APPAREIL.CodeType) = UPPER(Ctype) ;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RAISE_APPLICATION_ERROR(-20001,'Cet Appareil n''existe malheuresement pas!!!') ;

END;
/

