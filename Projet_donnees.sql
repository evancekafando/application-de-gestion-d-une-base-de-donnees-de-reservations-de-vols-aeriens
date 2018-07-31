--########################################################################################################
--#													EXEMPLES DE DONNEES															#
--########################################################################################################

insert into AEROPORT values ('YBG', 'BAGOTVILLE', 'QC');
insert into AEROPORT values ('YYC', 'CALGARY', 'AB');
insert into AEROPORT values ('YYG', 'CHARLOTTETOWN', 'PE');
insert into AEROPORT values ('YQM', 'MONCTON', 'NB');

insert into APPAREIL values ( 'A300', 500, 'Airbus');
insert into APPAREIL values ( 'CRJ100', 400, 'Bombardier');
insert into APPAREIL values ( 'MD-90', 300, 'Boeing');

insert into VOL values ('AC8989','YQM','YBG', 12, 23, 0, 100 );
insert into VOL values ('AC7470','YYC', 'YYG', 01, 11, 0, 120 );
insert into VOL values ('AC669', 'YBG', 'YQM', 01, 02, 1, 50 );

insert into AVION values ( 'AA89700', 'A300', 2007, 01);
insert into AVION values ( 'AB200010', 'CRJ100', 2010, 204);
insert into AVION values ( '110000', 'MD-90', 2015, 350);

insert into TRAJET values ('AC8989',TO_DATE('2015-04-07' ,  'yyyy/mm/dd'));
insert into TRAJET values ('AC7470',TO_DATE('2015-04-07' ,  'yyyy/mm/dd'));
insert into TRAJET values ('AC669', TO_DATE('2015-04-09' ,  'yyyy/mm/dd'));
insert into TRAJET values ('AC8989',TO_DATE('2015-04-09' ,  'yyyy/mm/dd'));

insert into AFFECTATION values ( 'AC8989', 'AA89700', 10);
insert into AFFECTATION values ( 'AC7470', 'AB200010', 0);
insert into AFFECTATION values ( 'AC8989', '110000', 200);

insert into RESERVATION values ( 'AC7470', TO_DATE('2015-04-07' ,  'yyyy/mm/dd'), 10, 'EVANCE KAFANDO');
insert into RESERVATION values ( 'AC7470', TO_DATE('2015-04-07' ,  'yyyy/mm/dd'), 105, 'EVA KAF');
insert into RESERVATION values ( 'AC8989', TO_DATE('2015-04-07' ,  'yyyy/mm/dd'), 5, 'EVAN KAFA');


