//Classement des clients par nombre d occupations

select CLI_ID,count(CLI_ID) NbOccupation
from TJ_CHB_PLN_CLI
where CHB_PLN_CLI_OCCUPE=1
group by CLI_ID
order by NbOccupation asc;

//Classement des clients par montant sépensé dans l hôtel

select CLI_ID,sum(LIF_MONTANT) MontantTotal
from T_FACTURE F,T_LIGNE_FACTURE LF
where F.FAC_ID=LF.FAC_ID
group by CLI_ID
order by MontantTotal;

//Classement des occupation par mois

select strftime('%m',PLN_JOUR) Mois,sum(CHB_PLN_CLI_OCCUPE) Occupation
from TJ_CHB_PLN_CLI
group by strftime('%m',PLN_JOUR);

//Classement des occupation par trimestre

//Montant TTC de chaque ligne facture (avec remise)

select LIF_ID,LIF_MONTANT-LIF_REMISE_MONTANT+((LIF_MONTANT/100)*LIF_TAUX_TVA)-((LIF_MONTANT/100)*LIF_REMISE_POURCENT)
from T_LIGNE_FACTURE
group by LIF_ID

//Tarif moyen des chambres par années croissantes

select strftime('%Y',TRF_DATE_DEBUT) Annee,sum(TRF_CHB_PRIX)/count(CHB_ID) TarifMoyenChambre
from TJ_TRF_CHB TC
group by strftime('%Y',TRF_DATE_DEBUT);

//Tarif moyen des chambres par étage et années croissantes

select strftime('%Y',TRF_DATE_DEBUT) Annee,CHB_ETAGE,sum(TRF_CHB_PRIX)/count(TC.CHB_ID) TarifMoyenChambre
from TJ_TRF_CHB TC,T_CHAMBRE C
where TC.CHB_ID=C.CHB_ID
group by strftime('%Y',TRF_DATE_DEBUT),CHB_ETAGE;

//Chambre la plus cher et en quel année

select CHB_ID,strftime('%Y',TRF_DATE_DEBUT),max(TRF_CHB_PRIX)
from TJ_TRF_CHB;

//Chambre réservées mais pas occupées

select CHB_ID
from TJ_CHB_PLN_CLI
where CHB_PLN_CLI_OCCUPE = 0 and CHB_PLN_CLI_RESERVE = 1;

//Taux résa par chambres

select CHB_ID,100.0*sum(CHB_PLN_CLI_RESERVE)/sum(CHB_PLN_CLI_OCCUPE) Taux
from TJ_CHB_PLN_CLI
group by CHB_ID;

//Facture réglées avant leur édition

select FAC_ID,FAC_DATE,FAC_PMT_DATE
from T_FACTURE
where strftime(FAC_DATE)>strftime(FAC_PMT_DATE) and strftime('%Y',FAC_PMT_DATE)<>0;

//Par qui ont été payées ces facture réglées en avance 

select FAC_ID,CLI_NOM,CLI_PRENOM,FAC_DATE,FAC_PMT_DATE
from T_FACTURE F,T_CLIENT C
where F.CLI_ID=C.CLI_ID and strftime(FAC_DATE)>strftime(FAC_PMT_DATE) and strftime('%Y',FAC_PMT_DATE)<>0;

//Classement des modes de paiement (par le mode et le montant total généré)

select MP.PMT_CODE ,PMT_LIBELLE,sum(LIF_MONTANT) TotalMontant
from T_MODE_PAIEMENT MP,T_FACTURE F, T_LIGNE_FACTURE LF
where MP.PMT_CODE=F.PMT_CODE and F.FAC_ID=LF.FAC_ID
group by MP.PMT_CODE
order by TotalMontant;

//Vous vous créez en tant que client de l hôtel 

INSERT INTO T_CLIENT (CLI_ID,TIT_CODE,CLI_NOM,CLI_PRENOM)
VALUES((select max(CLI_ID)+1 
		from T_CLIENT),
		'M.',
		'BOURGUIGNON',
		'Kévin');

//Moyens de communication

INSERT INTO T_ADRESSE(ADR_ID,CLI_ID,ADR_LIGNE1,ADR_LIGNE2,ADR_LIGNE3,ADR_LIGNE4,ADR_CP,ADR_VILLE)
VALUES((select max(ADR_ID)+1 
		from T_ADRESSE),
		(select CLI_ID 
		from T_CLIENT 
		where CLI_NOM = 'BOURGUIGNON' and CLI_PRENOM = 'Kévin'),
		'3 rue de hgrygy',
		' ',
		' ',
		' ',
		'67222',
		'Strasbourg');

INSERT INTO T_TELEPHONE (TEL_ID,CLI_ID,TYP_CODE,TEL_NUMERO,TEL_LOCALISATION)
VALUES((select max(TEL_ID)+1 
		from T_TELEPHONE),
		(select CLI_ID 
		from T_CLIENT 
		where CLI_NOM = 'BOURGUIGNON' and CLI_PRENOM = 'Kévin'),
		'TEL',
		'06-06-06-06-06',
		' ');

//Vous créez une nouvelle chambre à la date du jour 

INSERT INTO T_CHAMBRE(CHB_ID,CHB_NUMERO,CHB_ETAGE,CHB_BAIN,CHB_DOUCHE,CHB_WC,CHB_COUCHAGE,CHB_POSTE_TEL)
VALUES((select max(CHB_ID)+1 
		from T_CHAMBRE),
		(select max(CHB_NUMERO)+1 
		from T_CHAMBRE),
		'3e',
		1,
		1,
		1,
		3,
		121);

INSERT INTO T_PLANNING(PLN_JOUR)
VALUES("2017-5-11");

//Vous serez 3 occupant et souhaitez le maximum de confort pour cette chambre dont le prix est 
//30% superieur a la chambre la plus cher

INSERT INTO T_TARIF
VALUES("2017-05-11",20.6,50);

INSERT INTO TJ_TRF_CHB
VALUES("2017-05-11",21,(select (max(TRF_CHB_PRIX)/100)*130
from TJ_TRF_CHB)); 

INSERT INTO TJ_CHB_PLN_CLI
VALUES((select max(CHB_ID) 
		from T_CHAMBRE),
		(select TRF_DATE_DEBUT 
		from TJ_TRF_CHB 
		where CHB_ID=(select max(CHB_ID) 
					from T_CHAMBRE)),
		(select max(CLI_ID) 
		from T_CLIENT),
		3,
		1,
		1);
		
//Le réglement de votre facture sera éffectuer par CB

INSERT INTO T_FACTURE
VALUES((select max(FAC_ID)+1 
		from T_FACTURE),
		(select max(CLI_ID) 
		from T_CLIENT),
		'CB',
		(select TRF_DATE_DEBUT 
		from TJ_TRF_CHB 
		where CHB_ID=(select max(CHB_ID) 
					from T_CHAMBRE)),
		(select TRF_DATE_DEBUT 
		from TJ_TRF_CHB 
		where CHB_ID=(select max(CHB_ID) 
					from T_CHAMBRE)));
					
INSERT INTO T_LIGNE_FACTURE
VALUES((select max(LIF_ID)+1 
		from T_LIGNE_FACTURE),
		(select max(FAC_ID) 
		from T_FACTURE),
		1,
		0,
		0,
		(select TRF_CHB_PRIX 
		from TJ_TRF_CHB 
		where CHB_ID = (select max(CHB_ID)
						from T_CHAMBRE)),20.6);
						
//une seconde facture éditée car le tarif a changé : rabais de 10 %

Update T_LIGNE_FACTURE
Set LIF_REMISE_POURCENT= 10
Where FAC_ID = (select max(FAC_ID) from T_FACTURE) ;

select LIF_ID,LIF_MONTANT-LIF_REMISE_MONTANT+((LIF_MONTANT/100)*LIF_TAUX_TVA)-((LIF_MONTANT/100)*LIF_REMISE_POURCENT)
from T_LIGNE_FACTURE
where LIF_ID = (select max(LIF_ID) from T_LIGNE_FACTURE);