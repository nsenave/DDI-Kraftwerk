# DDI-Kraftwerk
Atelier pour enrichir l'extraction des métadonnées DDI dans Kraftwerk

## Stratégie de récupération des métadonnées

> Métadonnées = DDI

> 1 DDI = 1 mode de collecte = 1 fichier de données

**Informations qu'on veut récupérer du DDI :**

Groupes de variables :

- chaque variable appartient à un groupe (il y a toujours au moins un groupe : le groupe "racine" du questionnaire)

Variables "unitaires" :

- Nom
- Type

Types :

- string
- integer
- number
- boolean
- date

NB : a priori, pas besoin de métadonnées plus précises sur les types, exemples : valeurs min ou max pour une numérique, taille maximale d'une string, format de date -> il est standardisé (?)

Variables QCM :

- Nom de la QCM
- Noms des modalités de la QCM (=> nombre de modalités)
- Types des modalité standardisé = booléen ?
- Libellés des modalités

Variables QCU :

- Nom
- Type standardisé = string ?
- Valeurs prises (=> nombre de modalités)
- Libellés des modalités associés aux valeurs

On veut pouvoir reconnaître une variable "unitaire" d'une QCM et d'une QCU.

Les modalités d'une QCM sont aussi des variables unitaires.

Une QCU est aussi une variable unitaire.

**Comment sont décrites ces informations dans le DDI**

_en cours_

- Libellés d'une QCM :
  - `g:ResourcePackage > l:CodeListScheme`
  - `g:ResourcePackage > l:CategoryScheme > r:ID`
  - `g:ResourcePackage > l:CategoryScheme > l:Category > r:Label`

## Implémentation de la récupération des métadonnées

`fichier DDI > script XSLT > fichier variables.xml`

_en cours_

Spécifications de l'output "`variables.xml`" (pseudo-code xml) :

```
<VariablesGroups>
   <Group id= name= parent=> *
       <Variable> *
            <Name>
            <Format>
        <QCM> *
            <Name>
            <Variables>
                <Variable> *
                    <Name>
                    <Format>
                    <Label>
        <QCU> *
            <Name>
            <Format>
            <Value label=> *

* = la balise peut s'itérer plusieurs fois
```

- `VariablesGroups` : racine du document.

Groupes :

- `Group` : groupe de variables.

  - `id` : toujours présent, id du groupe dans le DDI.
  - `name` : toujours présent, nom du groupe. _Nota bene :_ Le nom du groupe "racine" varie d'une enquête à l'autre (pas de standardisation dans les DDI).
  - `parent` : présent sauf pour le groupe "racine" (on reconnaît le groupe "racine" comme étant celui qui n'a pas de parent), nom du groupe parent.

Variables "unitaires" :

- `Variable` : balise contenant les informations d'une variable "unitaire".
- `Name` : nom de la variable.
- `Format` : type de la variable, valeurs possibles : `STRING`, `NUMBER`, `INTEGER`, `BOOLEAN`, `DATE`, `UNKNOWN`

Variables QCM :

- `QCM` : balise contenant les informations relatives à une QCM.
- `Name` : nom de la variable associée à la question, ne figure pas dans la liste des variables unitaires.
- `Variables` : nom et labels des variables unitaires qui sont associées à la QCM.
- -> `Format` : toujours `BOOLEAN` ?

Variables QCU :

- `QCU` : balise contenant les informations relatives à une QCU.
- `Format` : type de la variable (toujours `STRING` ?)
- `Name` : nom de la variable (le même que dans la liste des variables unitaires).
- `Value` : valeur des modalités de la QCU.
  - `label` : libellé de la modalité.


## Validation de données 

Actuellement : peu

Validations sur les valeurs des variables :

- string : longueur min / longueur max / pattern
- numériques : valeur min, valeur max

Techno pour la validation :

| Format de données | techno |
| `LUNATIC_XML` | XSD |
| `LUNATIC_JSON` |  |
| `XFORMS` | XSD |
| `PAPER` |  |
