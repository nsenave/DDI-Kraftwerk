## `ddi2ods.xsl`

Extrait du proto *2-PAC* (*P*OC *A*ccès *C*alc de *P*réfiguration de l’*A*telier de *C*onception) de \@BulotF.

Utilisation :

1. Appliquer `ddi2ods.xsl` au fichier `content-init.xml`, en donnant un fichier DDI dans le paramètre `ddi-file` du script.
1. Copier le `Generic_init_structure.zip`.
1. Dans le zip copié, remplacer le `content.xml` par le fichier xml en sortie du script `ddi2ods.xsl`.
1. Changer l'extention `.zip` en `.ods` pour l'ouvrir avec Libre Office Calc.

## `structured_variables_v2.xsl`

Programme XSLT pour Kraftwerk.

Entrée : un DDI, sortie : un fichier xml avec les métadonnées utiles pour Kraftwerk.
