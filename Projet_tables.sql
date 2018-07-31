--########################################################################################################
--#																TABLES																#
--########################################################################################################
CREATE TABLE AEROPORT
(CodeArpt VARCHAR(4) CONSTRAINT pk_Aeroport PRIMARY KEY,
 Ville VARCHAR2(20) NOT NULL,
 Province VARCHAR(3) NOT NULL);

CREATE TABLE APPAREIL
(
CodeType VARCHAR2(10) NOT NULL,
NbrePlaceMax NUMBER(4) NOT NULL,
Fabricant VARCHAR2(10) NOT NULL,
CONSTRAINT pk_Appareil PRIMARY KEY (CodeType)
);

CREATE TABLE VOL
(NumVol VARCHAR2(10) NOT NULL,
 CodeDep VARCHAR2(4) NOT NULL,
 CodeArr VARCHAR2(4) NOT NULL,
 HeureMinMDep NUMBER(4) NOT NULL,
 HeureMinArr NUMBER(4) NOT NULL,
 JourArr NUMBER(1) CONSTRAINT c_JourArr CHECK (JourArr IN (0,1)),
 NbrePlacesDisponibles NUMBER(4) NOT NULL,
 CONSTRAINT pk_Vol PRIMARY KEY (NumVol),
 CONSTRAINT fk_Vol_A FOREIGN KEY (CodeDep) REFERENCES AEROPORT(CodeArpt),
 CONSTRAINT fk_Vol_B FOREIGN KEY (CodeArr) REFERENCES AEROPORT(CodeArpt)
 );

CREATE TABLE AVION
(
NumAvion VARCHAR(10) NOT NULL,
CodeType VARCHAR2(10) NOT NULL,
AnneeService NUMBER(4) NOT NULL,
NbreHeures NUMBER(8),
CONSTRAINT pk_Avion PRIMARY KEY (NumAvion),
CONSTRAINT fk_Avion_A FOREIGN KEY (CodeType) REFERENCES APPAREIL(CodeType)
);

CREATE TABLE AFFECTATION
(NumVol VARCHAR2(10) NOT NULL,
 NumAvion VARCHAR2(10) NOT NULL,
 NbrePassagers NUMBER(4),
 CONSTRAINT pk_Affectation PRIMARY KEY (NumVol,NumAvion),
 CONSTRAINT fk_Affectation_A FOREIGN KEY (NumVol) REFERENCES VOL(NumVol),
 CONSTRAINT fk_Affectation_B FOREIGN KEY (NumAvion) REFERENCES AVION(NumAvion)
 );
CREATE TABLE TRAJET
(
NumVol VARCHAR2(10),
DateVol DATE,
CONSTRAINT pk_Trajet PRIMARY KEY (NumVol,DateVol),
CONSTRAINT fk_Trajet_A FOREIGN KEY (NumVol) REFERENCES VOL(NumVol)
);
CREATE TABLE RESERVATION 
(
NumVol VARCHAR2(10) NOT NULL,
DateVol DATE NOT NULL,
NumPlace NUMBER(4) NOT NULL,
NomClient  VARCHAR2(30) NOT NULL,
CONSTRAINT pk_Reservation PRIMARY KEY (NumVol,DateVol,NumPlace),
CONSTRAINT fk_Reservation_A FOREIGN KEY (NumVol,DateVol) REFERENCES TRAJET(NumVol,DateVol)
);
