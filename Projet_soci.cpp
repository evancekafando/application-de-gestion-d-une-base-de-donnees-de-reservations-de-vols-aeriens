/*Le code est organisé en plusieurs cas. selon le choix de l'utilisateur
il entre dans un cas pour faire des operations. L'approche prise pour traiter les operations,
pour chaque cas utilisateur est demandé à entrer certaines informations et un appel de procedure est 
effectuer dans la base et le resultat est retourné
Exemple : procedure p_add_reserv procedure p_add_reserv = (sql.prepare << "$Requette") p_add_reserv.execute(1);*/

#include <iostream>
#include <string>
#include <iomanip>
#include <exception>
#include <algorithm>
#include <ctime>

#include <soci.h>
#include <oracle/soci-oracle.h>

using namespace soci;
using namespace std;

//main
int main()
{

 char continuer; // condition de sortie du programme

 do
    
   {
    try
    {
      session sql(oracle, "service=XE user=xxxx password=xxxx"); // connection a la base de donnees
          	system("clear");
        int choix_menu_principal;
	do 
	{ // *MENU PRINCIPAL
		cout << "*** MENU PRINCIPAL***" << endl; 
		cout << "(1) Menu utilisateur" << endl; 
		cout << "(2) Menu administrateur" << endl; 
		cout << "(3) Quitter" << endl;
		cout << "Choix ? : " ;
		cin >> choix_menu_principal; 

		if ( choix_menu_principal != 1 && choix_menu_principal != 2 && choix_menu_principal != 3 )
		{ 
		cout << endl << " Choix incorrect " << endl;

		}
	} while (choix_menu_principal != 1 && choix_menu_principal != 2 && choix_menu_principal != 3);
   

     switch (choix_menu_principal)
     {
    
      case 1:  // ** MENU UTILISATEUR**
    	  
    	    int choix_menu_utilisateur;
    	   do 
    	    {	 system("clear");
		 cout << "*** MENU UTILISATEUR***" << endl; 
		 cout << "(1) Afficher la liste des vols disponibles entre deux villes à une date donnée" << endl; 
		 cout << "(2) Ajouter/Supprimer/Modifier une réservation" << endl; 
		 cout << "(3) Quitter" << endl;
	         cout << "Choix ? : " ;
		 cin >> choix_menu_utilisateur; 

		 if ( choix_menu_utilisateur != 1 && choix_menu_utilisateur != 2 && choix_menu_utilisateur != 3 )
			 { cout << endl << " Choix incorrect " << endl;}

    	    } while (choix_menu_utilisateur != 1 && choix_menu_utilisateur != 2 && choix_menu_utilisateur != 3);
    	   

    	     switch (choix_menu_utilisateur)
    	  { 
		
	      	system("clear");
	      	
    	      //(1)Choix 1-1 Afficher la liste des vols disponibles entre deux villes à une date donnée
    	      case 1: 
    	    	 { string ville_A,ville_B, la_date;
    	    	  cout << "Nom de la premiere ville : ";
    	    	  cin >> ville_A;
    	    	  cout << "Nom de la deuxieme ville : ";
    	    	  cin >> ville_B;
    	    	  cout << "Date du vol (au format YYYY-MM-JJ) : ";
    	    	  cin >> la_date;
    	    	  
              //REQUETE SQL POUR ALLER RECHERCHER LA LISTE DES VOLS DISPONIBLES
    	    	  rowset<row> rs = (sql.prepare << "SELECT Vol.NumVol, CodeDep, CodeArr,TO_CHAR(DateVol, 'YYYY-MM-DD') FROM VOL,(SELECT CodeArpt as Cod1 FROM AEROPORT WHERE UPPER(Ville) = UPPER(:vil1))a,(SELECT CodeArpt as Cod2 FROM AEROPORT WHERE UPPER(Ville) = UPPER(:vil2))b,(SELECT NumVol, DateVol FROM TRAJET WHERE TRUNC(TRAJET.DateVol - TO_DATE(:la_dat, 'yyyy-mm-dd' ) )  = 0)c WHERE (Vol.CodeDep = a.Cod1) AND  (Vol.CodeArr = b.Cod2) AND (c.NumVol = Vol.NumVol )", use(ville_A, "vil1"), use(ville_B, "vil2"), use(la_date,"la_dat"));
    	    	  // iteration through the resultset:
    	    	  cout << endl << endl;
    	    	  cout << "*===================================*" << endl;
		 		  cout << " 		Resultat		" << endl;
		        cout << "*===================================*" << endl << endl;

    	    	  for (rowset<row>::const_iterator it = rs.begin(); it != rs.end(); ++it)
    	    	  {	 
    	    	      row const& ligne = *it;
    	    	      // dynamic data extraction from each row:
    	    	      cout << "Numero de Vol : " << ligne.get<std::string>(0) << endl
    	    	           << "Code Aeroport Depart : " << ligne.get<std::string>(1) << "	" << ville_A << endl
    	    	           << "Code Aeroport Arrive : " << ligne.get<std::string>(2) << "	" << ville_B << endl
    	    	           << "Date et Heure de Depart : " << ligne.get<std::string>(3) << endl << endl;
    	    	  }
		}
    	          break;
    	          
    	    // "(2) Ajouter/Supprimer/Modifier une réservation"
    	      case 2:	    	  
    	    	   int choix_reservation;
    	      	   do 
    	      	    {
    	      	   //**MENU PRINCIPALE
				 cout << "*** MENU RESERVATION***" << endl; 
				 cout << "(1) Ajouter une reservation" << endl; 
				 cout << "(2) Supprimer une reservation" << endl; 
				 cout << "(3) Modifier une reservation" << endl; 
				 cout << "(4) Quitter" << endl;
					   cout << "Choix ? : " ;
				 cin >> choix_reservation; 
				 if ( choix_reservation != 1 && choix_reservation != 2 && choix_reservation != 3 )
					 {cout << endl << " Choix incorrect " << endl;}

		 	      	    } while (choix_reservation != 1 && choix_reservation != 2 && choix_reservation != 3);
		 	      	   
		 	      	     switch (choix_reservation)
		 	      	   { 
		 	      	      //(1) Ajouter une reservation
		 	      	      case 1: 
			   
                             {
			        string Num_vol, Date_vol, Nom_client;
				int Num_place;
				cout << "Quel est votre numero de vol: ";
				cin >> Num_vol;
				cout << "Quel est votre numero de place: ";
				cin >> Num_place;
				cin.ignore();
				cout << "Votre nom : ";
				getline(cin,Nom_client);
				cout << "Quel est votre date de depart (au format YYYY-MM-JJ) : ";
				getline(cin,Date_vol);
				
				procedure p_add_reserv = (sql.prepare << "p_add_reservation(:Num_vo, :Date_vo, :Num_plac, :Nom_clien)",
					use(Num_vol, "Num_vo"), use(Date_vol, "Date_vo"), use(Num_place, "Num_plac"), use(Nom_client, "Nom_clien"));

				p_add_reserv.execute(1);
 				cout << endl << "!!!!Reservation faite avec succes!!!!"<< endl;

 			     }  
				
			 	      
    	      	    	       break;
    	      	      // (2) Supprimer une reservation
    	      	      case 2:  
			     {
				string Num_vol, Date_vol;
			        int Num_place;
				cout << "Entrer votre numero de vol a supprimer : ";
				cin >> Num_vol;
				cout << "Entrer le numero de place : ";
				cin >> Num_place;
				cin.ignore();
				cout << "Entrer la date de depart (au format YYYY-MM-JJ) : ";
				getline(cin,Date_vol);
				// Verifie que la reservation exite avant d'essayer de la supprimer
				procedure p_check_reserv = (sql.prepare << "p_check_reservation(:Num_vo, :Date_vo, :Num_plac)",
					use(Num_vol, "Num_vo"), use(Date_vol, "Date_vo"), use(Num_place, "Num_plac") );

				p_check_reserv.execute(1);

				procedure p_del_reserv = (sql.prepare << "p_del_reservation(:Num_vo, :Date_vo, :Num_plac)",
					use(Num_vol, "Num_vo"), use(Date_vol, "Date_vo"), use(Num_place, "Num_plac") );

				p_del_reserv.execute(1);

				cout << "!!!!Merci, votre reservation a ete annule avec succes!!!!"<< endl;
			      }

    	      	    	     break;
    	      	    	// (3) Modifier une reservation
    	      	      case 3:
		   	  {
		   	 
		   	 
				string Num_vol, Date_vol, new_NumVol, new_DateVol, new_Nom;
				int Num_place, new_NumPlace;
				cout << "Entrez votre numero de vol que vous voulez modifier : ";
				cin >> Num_vol;
				cin.ignore();
				cout << "Entrez la date de depart (au format YYYY-MM-JJ) : ";
				getline(cin,Date_vol);
				cout << "Entrez votre numero de place : ";
				cin >> Num_place;
				
				// Verifie que la reservation exite avant d'essayer de la modifier
				procedure p_check_reserv = (sql.prepare << "p_check_reservation(:Num_vo, :Date_vo, :Num_plac)",
					use(Num_vol, "Num_vo"), use(Date_vol, "Date_vo"), use(Num_place, "Num_plac") );

				p_check_reserv.execute(1);
                                cout << "Merci!, votre resevation a ete trouve!" << endl;
				cout << "***Apporter vos modifications***" << endl;

				cout << "Quel est votre nouveau numero de vol: ";
				cin >> new_NumVol;
				cin.ignore();
				cout << "Quel est votre nouvelle date de depart (au format YYYY-MM-JJ) : " ;
				getline(cin,new_DateVol);
				cout << "Quel est votre nouveau numero de place: " ;
				cin >> new_NumPlace;
				cout << "Nouveau nom : " ;
				cin.ignore();
				getline(cin,new_Nom);

				procedure p_updt_reserv = (sql.prepare << "p_updt_reservation(:Num_vo, :Date_vo, :Num_plac, :new_Num, :new_date, :new_place, :new_name)",
					use(Num_vol, "Num_vo"), use(Date_vol, "Date_vo"), use(Num_place, "Num_plac"), use(new_NumVol, "new_Num"), use(new_DateVol, "new_date"), use(new_NumPlace, "new_place"), use(new_Nom, "new_name") );

				p_updt_reserv.execute(1);

				cout << "Merci, votre reservation a ete mise a jour avec succes"<< endl;
			      }
      	      	    	      break;
    	      	    	      
    	      	    	 //(3) Quitter
    	      	      case 4:
			   return 0;
    	      	    	      break;       	
		   }  

    	    	   break;

    	    	 //(3) Quitte   	      
	     case 3:
		 return 0;
		  break;
    	  }  
    	
    	    break;
    	    
    	    // ** MENU ADMINISTRATION**    
      case 2 :
    	  
    	    int choix_menu_admin;
    	    	   do 
    	    	    { 	 system("clear");
			 cout << "*** MENU ADMINISTRATEUR***" << endl; 
			 cout << "(1) Ajouter/Supprimer/Modifier une affectation" << endl; 
			 cout << "(2) Ajouter/Supprimer/Modifier un vol" << endl; 
			 cout << "(3) Ajouter/Supprimer/Modifier un avion" << endl; 
			 cout << "(4) Ajouter/Supprimer/Modifier un appareil" << endl; 
			 cout << "(5) Quitter" << endl;
		         cout << "Choix ? : " ;
 
			 cin >> choix_menu_admin; 

			 if ( choix_menu_admin != 1 && choix_menu_admin != 2 && choix_menu_admin != 3 && choix_menu_admin != 4 && choix_menu_admin != 5)
			 { cout << endl << " Choix incorrect " << endl; }

    	    	    } while (choix_menu_admin != 1 && choix_menu_admin != 2 && choix_menu_admin != 3 && choix_menu_admin != 4 && choix_menu_admin != 5);
    	    	   

    	    	   switch (choix_menu_admin)
    	    	  {
    	    	      case 1:
		           int choix_affectation;
			   do 
		 	      {
				 cout << "*** MENU AFFECTION***" << endl; 
				 cout << "(1) Ajouter une affectation" << endl; 
				 cout << "(2) Supprimer une affectation" << endl; 
				 cout << "(3) Modifier une affectation" << endl; 
				 cout << "(4) Quitter" << endl; 
				 cout << "Choix ? : " ;

				 cin >> choix_affectation; 
	
				   if ( choix_affectation != 1 && choix_affectation != 2 && choix_affectation != 3 && choix_affectation != 4 )
			            {cout << endl << " Choix incorrect " << endl;}

				} while (choix_affectation != 1 && choix_affectation != 2 && choix_affectation != 3 && choix_affectation != 4);
			   

			 switch (choix_affectation)
		         { 
			  //(1) Ajouter une affectation
			  case 1: 
			      {
			        string Num_Avion, Num_vol;
				int NbrePass;
				cout << endl << "!!!!AJOUT AFEECTATION!!!!" << endl;
				cout << "Veuillez entrer le numero de vol : ";
				cin >> Num_vol;
				cout << "Veuillez entrer le numero d'avion: ";
				cin >> Num_Avion;
				cout << "Veuillez entrer le nombre de passagers : ";
				cin >> NbrePass;

				
				procedure p_add_affect= (sql.prepare << "p_add_affectation(:Vol, :Avion, :PassaG)",
					use(Num_vol, "Vol"), use(Num_Avion, "Avion"), use(NbrePass, "PassaG"));

				p_add_affect.execute(1);

 				cout << endl << "!!!!Affectation ajouter avec succes!!!!"<< endl;

 			     }  
					   break;
			  // (2) Supprimer une affectation
			  case 2:
			       { string Num_Avion,Num_vol;
				cout << " !!!!!!SUPPRESSION AFFECTATION!!!" << endl;
				cout << "Veuillez entrer le numero de vol: ";
				cin >> Num_vol;
				cout << "Veuillez entrer le numero d'avion: ";
				cin >> Num_Avion;
				
				procedure p_del_affect= (sql.prepare << "p_del_affectation(:Vol, :Avion)",
					use(Num_vol, "Vol"), use(Num_Avion, "Avion"));

				p_del_affect.execute(1);

 				cout << "!!!!!Affectation trouver et supprimer avec succes!!!!!"<< endl;	   
			       }
					 break;
				// (3) Modifier une affectation
			  case 3:
 				{ 
				string Num_vol, Num_Avion, newVol, newAvion;
				int newPassaG;
				cout << "!!! MODIFICATION AFFECTATION!!!" << endl;
				cout << "Veuillez entrer le numero de vol a modifier: ";
				cin >> Num_vol;
				cout << "Veuillez entrer le numero d'avion a modifier: ";
				cin >> Num_Avion;

				procedure p_check_affect= (sql.prepare << "p_check_affectation(:Vol, :Avion)",
					use(Num_vol, "Vol"), use(Num_Avion, "Avion"));

				p_check_affect.execute(1);

				cout << "!!!!Affectation trouver!!!!"<< endl;
				cout << "Veuillez entrer le nouveau numero de vol: ";
				cin >> newVol;
				cout << "Veuillez entrer le nouveau numero d'avion : ";
				cin >> newAvion;
				cout << "Veuillez entrer le nouveau nombre de passagers : ";
				cin >> newPassaG;
				procedure p_updt_affect= (sql.prepare << "p_updt_affectation(:Vol, :Avion, :NVol, :NAvion, :NPassaG)",
					use(Num_vol, "Vol"), use(Num_Avion, "Avion"),use(newVol, "NVol"), use(newAvion, "NAvion"),use(newPassaG, "NPassaG"));

				p_updt_affect.execute(1);

 				cout << endl << "!!!!!!Affectation modifier avec succes!!!!!!!"<< endl;	   
			       }
					  break;
					  
				 //(4) Quitter
			  case 4:
 				return 0;
			        break;
			  }  
			 break;
				 

    	    	      case 2:
			  int choix_vol;
			   do 
			     {
		 		 cout << "*** MENU VOL***" << endl; 
				 cout << "(1) Ajouter une vol" << endl; 
				 cout << "(2) Supprimer une vol" << endl; 
				 cout << "(3) Modifier une vol" << endl; 
				 cout << "(4) Quitter" << endl; 
			  	 cout << "Choix ? : " ;

				 cin >> choix_vol;
			   	if ( choix_vol != 1 && choix_vol != 2 && choix_vol != 3 && choix_vol != 4 )
					 { cout << endl << " Choix incorrect " << endl;}
			    } while (choix_vol != 1 && choix_vol != 2 && choix_vol != 3 && choix_vol != 4);
			  switch (choix_vol)
			  { 
			  //(1) Ajouter un vol
			  case 1: 
			       { 
				string Nvol, Depart, Arriv;
				int HeurDepart,HeurArriv,JArr, NbrePlace;
				cout << "!!!! AJOUT VOL !!!!!!" << endl;
				cout << "Veuillez entrer le numero de vol : ";
				cin >> Nvol;
				cout << "Veuillez entrer le code de la ville de Depart: ";
				cin >> Depart;
				cout << "Veuillez entrer le code de la ville d'Arrivee: ";
				cin >> Arriv;
				cout << "Veuillez entrer l'heure de depart: ";
				cin >> HeurDepart;
				cout << "Veuillez entrer l'heure d'arrivee: ";
				cin >> HeurArriv;
				cout << "le vol arrive t-il le meme jour? 0 si Oui et 1 si Arrive  le lendemain: ";
				cin >> JArr;
				cout << "Quel est le nombre de place disponible: ";
				cin >> NbrePlace;
				

				procedure p_add_Levol = (sql.prepare << "p_add_vol(:Vol, :Dep, :Arr, :hDep, :hArr, :JAr, :NbrPlac)",
					use(Nvol, "Vol"), use(Depart, "Dep"), use(Arriv, "Arr"), use(HeurDepart, "hDep"),
					use(HeurArriv, "hArr"), use(JArr, "JAr"),  use(NbrePlace, "NbrPlac"));

				p_add_Levol.execute(1);

 				cout << endl << "!!!!!Vol ajouter avec succes!!!!!"<< endl;
 				}
					   break;
			  // (2) Supprimer un vol
			  case 2:
				{
				string Nvol;
				cout << "!!!!!!SUPPRESION DE VOL!!!!!!" << endl;
				cout << "Veuillez entrer le numero de vol que vous voulez supprimer: ";
				cin >> Nvol;

				//Verifie que le numero de vol existe
				procedure p_check_Levol = (sql.prepare << "p_check_vol(:Vol)",use(Nvol, "Vol"));
				p_check_Levol.execute(1);
				
				//Effectue la suppression
				procedure p_del_Levol = (sql.prepare << "p_del_vol(:Vol)",use(Nvol, "Vol"));
				p_del_Levol.execute(1);

 				cout << endl << "!!!!!Vol supprimer avec succes!!!!!"<< endl;
				cout << "!!Des entrees ont pu etre supprimer dans les tables AFFECTATION, RESERVATION, TRAJET" << endl;
				}				  
					 break;
				// (3) Modifier un vol
			  case 3:
 				{
				string Nvol, NewNvol, NewDepart, NewArriv;
				int NewHeurDepart,NewHeurArriv,NewJArr, NewNbrePlace;
				cout << "Veuillez entrer le numero de vol que vous voulez modifier: ";
				cin >> Nvol;

				//Verifie que le numero de vol existe
				procedure p_check_Levol = (sql.prepare << "p_check_vol(:Vol)",use(Nvol, "Vol"));
				p_check_Levol.execute(1);
				cout << endl << "Cool! Numero de vol trouver!!!" << endl;

				//Electure nouvelle donnees
				cout << "!!!MODIFICATION DE VOL!!!" << endl;
				cout << "Veuillez entrer un nouveau numero de vol : ";
				cin >> NewNvol;
				cout << "Veuillez entrer un nouveau code de la ville de Depart: ";
				cin >> NewDepart;
				cout << "Veuillez entrer un nouveau code de la ville d'Arrivee: ";
				cin >> NewArriv;
				cout << "Veuillez entrer une nouvelle heure de depart: ";
				cin >> NewHeurDepart;
				cout << "Veuillez entrer une nouvelle heure d'arrivee: ";
				cin >> NewHeurArriv;
				cout << "le vol arrive t-il le meme jour? 0 si Oui et 1 si Arrive  le lendemain: ";
				cin >> NewJArr;
				cout << "Quel est le nombre de place disponible: ";
				cin >> NewNbrePlace;
			

				procedure p_updt_Levol = (sql.prepare << "p_updt_vol(:OldVol, :Vol, :Dep, :Arr, :hDep, :hArr, :JAr, :NbrPlac)",
					use(Nvol, "OldVol"),use(NewNvol, "Vol"), use(NewDepart, "Dep"), use(NewArriv, "Arr"),
					use(NewHeurDepart, "hDep"),use(NewHeurArriv, "hArr"), use(NewJArr, "JAr"),  use(NewNbrePlace, "NbrPlac"));

				p_updt_Levol.execute(1);

 				cout << endl << "!!!!Vol a ete modifier  avec succes!!!!"<< endl;
				cout << "Les tables AFFECTATION, TRAJET, RESERVATION, ont pu etre affecte par cette modification" << endl;

				}
				 break;
					  
				 //(4) Quitter
			  case 4:
 				return 0;
				 break;
			  }     	    	    	  
		      break;
					   
    	    	      case 3:
    	    	    	  int choix_avion;
			   do 
				{
				 cout << "*** MENU AVION***" << endl; 
				 cout << "(1) Ajouter un avion" << endl; 
				 cout << "(2) Supprimer un avion" << endl; 
				 cout << "(3) Modifier un avion" << endl; 
				 cout << "(4) Quitter" << endl; 
			  	 cout << "Choix ? : " ;

				 cin >> choix_avion; 

				 if ( choix_avion != 1 && choix_avion != 2 && choix_avion != 3 && choix_avion != 4)
				 { cout << endl << " Choix incorrect " << endl; }
				} while (choix_avion != 1 && choix_avion != 2 && choix_avion != 3  && choix_avion != 4);
						   

			 switch (choix_avion)
			  { 
			  //(1) Ajouter un Avion
			  case 1: 
			     {
				string NAvion, Ctype;
				int Annee, NbreHeure;
				cout << "!!!!AJOUT AVION!!!!" << endl;
				cout << "Veuillez entrer le numero de l'avion : ";
				cin >> NAvion;
				cout << "Veuillez entrer le code type de l'avion: ";
				cin >> Ctype;
				cout << "Veuillez entrer son annee de service: ";
				cin >> Annee;
				cout << "Veuillez entrer le nombre d'heures de vol (Elle sera automatiquement mise a jour par la suite): ";
				cin >> NbreHeure;			

				procedure p_add_LAvion = (sql.prepare << "p_add_Avion(:Avion, :Code, :Ann, :Nbre)",
					use(NAvion, "Avion"), use(Ctype,"Code"), use(Annee, "Ann"), use(NbreHeure, "Nbre"));

				p_add_LAvion.execute(1);

 				cout << endl << "!!!!Avion ajouter avec succes!!!"<< endl;

			    }
					   break;
			  // (2) Supprimer un Avion
			  case 2:
			     {
				string NAvion;
				cout << "!!!! SUPPRESSION D'AVION!!!!" << endl;
				cout << "Veuillez entrer le numero de l'avion que vous voulez supprimer: ";
				cin >> NAvion;

				//Verifie que le numero de l'avion existe

				procedure p_check_LAvion = (sql.prepare << "p_check_Avion(:Avion)",use(NAvion, "Avion"));
				p_check_LAvion.execute(1);
				
				//Supprime l'avion
				procedure p_del_LAvion = (sql.prepare << "p_del_Avion(:Avion)",use(NAvion, "Avion"));

				p_del_LAvion.execute(1);

 				cout << endl << "!!!!!!Avion trouver et supprimer!!!!"<< endl;

			     }	 
				 break;
				// (3) Modifier un Avion
			  case 3:
				{
				string NAvion, NewCtype, NewNAvion;
				int NewAnnee, NewNbreHeure;
				cout << "!!!!!!MODIFICATION AVION!!!!!" << endl;
				cout << "Veuillez entrer le numero de l'avion que vous voulez modifier: " ;
				cin >> NAvion;

				//Verifie que le numero de l'avion existe

				procedure p_check_LAvion = (sql.prepare << "p_check_Avion(:Avion)",use(NAvion, "Avion"));
				p_check_LAvion.execute(1);

				cout << "Avion Trouver!!!!" << endl << endl;

				cout << "Veuillez entrer le nouveau numero de l'avion que vous voulez modifier: " ;
				cin >> NewNAvion;
				cout << "Veuillez entrer le nouveau code type de l'avion: ";
				cin >> NewCtype;
				cout << "Veuillez entrer son annee de service: ";
				cin >> NewAnnee;
				cout << "Veuillez entrer le nouveau nombre d'heures de vol (Elle sera automatiquement mise a jour par la suite): ";
				cin >> NewNbreHeure;
				
				procedure p_updt_LAvion = (sql.prepare << "p_updt_Avion(:OldAvion,:Avion, :Code, :Ann, :Nbre)",
						use(NAvion, "OldAvion"),use(NewNAvion, "Avion"), use(NewCtype, "Code"),
						use(NewAnnee, "Ann"), use(NewNbreHeure, "Nbre"));

				p_updt_LAvion.execute(1);

 				cout <<endl<< "!!!!!Modification faite avec succes!!!!"<< endl;

				}
 
				break;
					  
				 //(3) Quitter
			  case 4:
 				return 0;
				break;
			  }    	    	    	  
		    break;
					    
    	    	      case 4:
    	    	    	  int choix_appareil;
			   do 
			    {
				 cout << "*** MENU APPAREIL***" << endl; 
				 cout << "(1) Ajouter un appareil" << endl; 
				 cout << "(2) Supprimer un appareil" << endl;  
				 cout << "(3) Modifier un appareil" << endl; 
				 cout << "(4) Quitter" << endl;
				 cout << "Choix ? : " ;
 
				 cin >> choix_appareil; 
				 if ( choix_appareil != 1 && choix_appareil != 2 && choix_appareil != 3 && choix_appareil != 4 )
				 { cout << endl << " Choix incorrect " << endl;}
			   } while (choix_appareil != 1 && choix_appareil != 2 && choix_appareil != 3 && choix_appareil != 4);
		
 		         switch (choix_appareil)
			  { 
			  //(1) Ajouter une Appareil
			  case 1 : 
				  {
				string Ctype, Fab;
				int PlaceMax;
				cout << "!!!AJOUT APPAREIL!!!!" << endl;
				cout << "Veuillez entrer le code type de l'avion : ";
				cin >> Ctype;
				cout << "Veuillez entrer le nombre max de place de l'avion: ";
				cin >> PlaceMax;
				cout << "Veuillez entrer le nom du fabricant: ";
				cin >> Fab;
								
				procedure p_add_Appareil = (sql.prepare << "p_add_App(:CodeT, :PMax, :Fabr)",
						use(Ctype, "CodeT"), use(PlaceMax, "PMax"), use(Fab, "Fabr"));

				p_add_Appareil.execute(1);

 				cout << endl << "!!!!Appareil ajouter avec succes!!!!!"<< endl;	  
				  }
				break;
			  // (2) Supprimer une Appareil
			  case 2 :
				{
				string Ctype;
				cout << "!!!!!SUPPRESSION APPAREIL!!!!" <<endl;
				cout << "Veuillez entrer le code type de l'avion que vous voulez supprimer : ";
				cin >> Ctype;

				procedure p_check_Appareil = (sql.prepare << "p_check_App(:Code)",use(Ctype, "Code"));
				p_check_Appareil.execute(1);

				procedure p_del_Appareil = (sql.prepare << "p_del_App(:Code)",use(Ctype, "Code"));
				p_del_Appareil.execute(1);

 				cout << endl << "!!!!Appareil trouver et supprimer avec succes!!!!!"<< endl;	
				}
				
				break;
				// (3) Modifier une Appareil
			  case 3 :
			  	{
				//
				string Ctype, NewCtype, NewFab;
				int NewPlaceMax;
				cout << "!!!MODIFICATION APPAREIL!!!!" << endl;
				cout << "Veuillez entrer le code type de l'avion que vous souhaitez modifier: ";
				cin >> Ctype;

				//Verifie que l'appareil existe
				procedure p_check_Appareil = (sql.prepare << "p_check_App(:App)",use(Ctype, "App"));
				p_check_Appareil.execute(1);
				
				cout << "Avion trouve!! " << endl;

				cout << "Veuillez entrer le nouveau code type de l'avion : ";
				cin >> NewCtype;

				cout << "Veuillez entrer le nombre Max de place: ";
				cin >> NewPlaceMax;
				cout << "Veuillez entrer le nom du nouveau fabricant: ";
				cin >> NewFab;
								
				procedure p_updt_Appareil = (sql.prepare << "p_updt_App(:OldCodeT, :CodeT, :PMax, :Fabr)",
						use(Ctype, "OldCodeT"),use(NewCtype, "CodeT"), use(NewPlaceMax, "PMax"),
						use(NewFab, "Fabr"));
				p_updt_Appareil.execute(1);

 				cout << "!!!!!Appareil modifier avec succes!!!!"<< endl;	
				
				}
				break;
					  
				 //(3) Quitter
			  case 4 :
 				return 0;
				break;
			  }       	    	    	  
    	    	       break;
    	    	       
    	    	       // QUITTER
    	     case 5:
		 return 0;
    	    	 break;
    	    	  }  
             break;
    	
    	 //(5) Quitter
      case 3:
        return 0;
	break;  	      
  }
}  
 catch (oracle_soci_error const & e)
    {
        cerr << "Oracle error: " << e.err_num_
            << " " << e.what() << endl;
    }
    catch (exception const &e)
    {
        cerr << "Error: " << e.what() << '\n';
    }
cout << endl << endl << "Voulez vous faire d'autres operations?" << endl;
cout << "Entrer 'O' pour Oui ou tout autre caractere pour quitter : " ;
cin >> continuer;
}while (continuer == 'O' || continuer == 'o'); 

return 0;
}
//FIn

