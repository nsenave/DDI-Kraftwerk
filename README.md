# DDI-Kraftwerk
Atelier pour enrichir l'extraction des métadonnées DDI dans Kraftwerk

## Stratégie de récupération des métadonnées

> Métadonnées = DDI

> 1 DDI = 1 mode de collecte = 1 fichier de données

## Informations qu'on veut récupérer du DDI

Groupes de variables :

- chaque variable appartient à un groupe (il y a toujours au moins un groupe : le groupe "racine" du questionnaire)

Variables "unitaires" :

- Nom
- Type

Types :

- `STRING`
- `INTEGER`
- `NUMBER`
- `BOOLEAN`
- `DATE`

Pour l'instant, pas besoin de métadonnées plus précises sur les types, exemples : valeurs min ou max pour une numérique, taille maximale d'une string, format de date -> il est standardisé.

Variables QCM :

- Nom de la QCM
- Noms des modalités de la QCM
- Types des modalité standardisé = booléen
- Libellés des modalités

Variables QCU :

- Nom
- Type standardisé = string
- Valeurs prises
- Libellés des modalités associés aux valeurs

On veut pouvoir reconnaître les QCM et les QCU.

Les modalités d'une QCM sont aussi des variables unitaires.

Une QCU est aussi une variable unitaire.

## Comment sont décrites ces informations dans le DDI

### Groupes

- Groupe de variables : 
  - `g:ResourcePackage > l:VariableScheme > l:VariableGroup`
- Nom d'un groupe : 
  - `g:ResourcePackage > l:VariableScheme > l:VariableGroup > l:VariableGroupName > r:String`

On associe une variable à son groupe via un identifiant :

- ID d'une variable dans un groupe : 
  - `g:ResourcePackage > l:VariableScheme > l:VariableGroup > r:VariableReference > r:ID`
- ID dans la définition de la variable :
  - `g:ResourcePackage > l:VariableScheme > l:Variable > r:ID`

Un groupe peut contenir des sous groupes. Le lien entre les groupes se fait via leur identifiant :

- Sous groupe d'un groupe : `g:ResourcePackage > l:VariableScheme > l:VariableGroup > l:VariableGroupReference > r:ID`

### Variables

- Liste des variables : 
  - `g:ResourcePackage > l:VariableScheme`
- Nom d'une variable : 
  - `g:ResourcePackage > l:VariableScheme > l:Variable > l:VariableName > r:String`
- Type d'une variable : 
  - `g:ResourcePackage > l:VariableScheme > l:Variable > l:VariableRepresentation > ...`

| Type | DDI | Remarque |
| --- | --- |
| `STRING` | `r:TextRepresentation` ou `r:CodeRepresentation` | cf. infos sur les QCU/listes de codes |
| `NUMBER` | `r:NumericRepresentation` ou `r:NumericRepresentationReference` | |
| `INTEGER` | `r:NumericRepresentation` ou `r:NumericRepresentationReference` | En DDI, un entier = un nombre avec 0 décimales. Si le nombre de décimales n'est pas précisé, c'est un entier. |
|`BOOLEAN` | cas particulier de string/liste de codes définit par un standard Insee `r:CodeReference/r:ID='INSEE-COMMUN-CL-Booleen-1'` | Valeurs = 1 pour "vrai", vide pour "faux". |
|`DATE` | `r:DateTimeRepresentation` ou `r:DateTimeRepresentationReference` | |

### Informations supplémentaires pour les QCM

- Définition d'une QCM :
  - `g:ResourcePackage > d:QuestionScheme > d:QuestionGrid`
- Nom de la question : 
  - `g:ResourcePackage > d:QuestionScheme > d:QuestionGrid > d:QuestionGridName > r:String`
- Libellé des modalités : 
  - `g:ResourcePackage > d:QuestionScheme > d:QuestionGrid > r:OutParameter > r:ParameterName > r:String`

### Informations supplémentaires pour les QCU

Les QCU sont liées à des listes de codes. La valeur in fine est en `STRING`.

- Définition d'une liste de codes : 
  - `g:ResourcePackage > l:CodeListScheme`
- Valeurs d'une liste de codes : 
  - `g:ResourcePackage > l:CodeListScheme > l:CodeList > l:Code > r:Value`
- Libellés d'une liste de code : (voir plus bas pour le lien valeur-libellé)
  - `g:ResourcePackage > l:CategoryScheme > l:Category > r:Label > r:Content`

Une liste de codes est associée à une variable QCU via un identifiant :

- ID d'une liste de codes dans une variable : 
  - `g:ResourcePackage > l:VariableScheme > l:VariableRepresentation > l:VariableRepresentation > r:CodeRepresentation > r:CodeListReference > r:ID`
- ID d'une liste de codes dans la définition de la liste de codes : 
  - `g:ResourcePackage > l:CodeListScheme > l:CodeList > r:ID`

Une valeur d'une liste des codes est associée à un libellé via un identifiant :

- ID d'une valeur dans une liste de codes :
  - `g:ResourcePackage > l:CodeListScheme > l:CodeList > l:Code > r:CategoryReference > r:ID`
- ID d'une valeur dans le libellé correspondant :
  - `g:ResourcePackage > l:CategoryScheme > l:Category > r:ID`

## Implémentation de la récupération des métadonnées

`fichier DDI > script XSLT > fichier variables.xml`

Spécifications de l'output "`variables.xml`" (pseudo-code xml) :

```
<VariablesGroups>
   <Group id= name= parent=> *
        <Variable> *
            <Name>
            <Format>
        <Variable> *
            <Name>
			<QCM>
			<Format>
			<Label>
        <Variable> *
            <Name>
            <Format>
            <Values>
                <Value label=> *

* = la balise peut s'itérer plusieurs fois
```

- `VariableGroups` : racine du document.

### Groupes

- `Group` : groupe de variables.

  - `id` : toujours présent, id du groupe dans le DDI.
  - `name` : toujours présent, nom du groupe. _Nota bene :_ Le nom du groupe "racine" varie d'une enquête à l'autre (pas de standardisation dans les DDI).
  - `parent` : présent sauf pour le groupe "racine" (on reconnaît le groupe "racine" comme étant celui qui n'a pas de parent), nom du groupe parent.

- `Variable` : balise contenant les informations d'une variable "unitaire".

### Variables "unitaires"

- `Name` : nom de la variable.
- `Format` : type de la variable, valeurs possibles : `STRING`, `NUMBER`, `INTEGER`, `BOOLEAN`, `DATE`, `UNKNOWN`

### Variables QCM

> 1 question à choix multiples à K modalités => K variables unitaires

On reconnaît une QCM par la présence de la balise `QCM`.

- `Name` : nom de la variable, qui est une des modalités de la QCM.
- `Format` = `BOOLEAN`
- `QCM` : nom de la QCM.
- `Label` : libellé de la modalité de la QCM.

### Variables QCU

> 1 question à choix unique à K modalités => 1 variable unitaire (qui peut prendre K valeurs différentes en cas de réponse)

On reconnaît une QCM par la présence de la balise `Values`.

- `Name` : nom de la variable QCU.
- `Format` = `STRING`
- `Values` : valeurs des différentes modalités de la QCU.

Modalités d'une QCU :

- `Value` : valeur de la modalité.
  - `label` : libellé de la modalité.


## Apartés

### Autres formes de QCM / QCU

- QCM "ordonnées", exemple "Classez les propositions par ordre de préférence"
- QCM / QCU avec un champ libre, exemple "Autre, veuillez préciser"  

-> Concepts pas encore implémentés dans Métallica.

### Validation de données 

Actuellement : peu

Validations sur les valeurs des variables :

- string : longueur min / longueur max / pattern
- numériques : valeur min, valeur max
- date : format standardisé, intervalle de dates acceptables

Technos pour faire de la validation :

| Format de données | techno |
| `LUNATIC_XML` | XSD |
| `LUNATIC_JSON` | ? |
| `XFORMS` | XSD |
| `PAPER` | ? |
