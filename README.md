# ABLS-RPMS

Depot RPM lodu projet ABLS, en mode createrepo.

## Perimetre

Les sources RPM sont les suivantes:

- /home/sebastien/ABLS-LIBS/build
- /home/sebastien/ABLS-SATELLITE-LIBS/build

## Arborescence

- repo/x86_64
- repo/aarch64
- repo/noarch
- keys
- scripts
- incoming
- published

## Workflow

1. Executer scripts/bootstrap-repo.sh
2. Exporter la clef publique GPG dans keys/RPM-GPG-KEY-ABLS
3. Executer scripts/update.sh

Mode par defaut (`scripts/update.sh`):

- Collecte incrementale: les RPM deja presents dans `repo/*` sont conserves.
- Publication in-place vers `published/`.

Mode reset explicite (`scripts/update.sh clean`):

- Suppression des RPM existants dans `repo/*` avant recollecte.
- Nettoyage des RPM publies avant republication.

Verification finale:

- `scripts/verify-repo.sh`

## Configuration client

Exemple de fichier repo client: abls-rpms.repo

- gpgcheck=1: verification de signature des paquets
- repo_gpgcheck=0: verification de metadonnees desactivee (a activer plus tard si repodata signee)

## Publication

Le repertoire published est la cible exposee en HTTP.

Le script `publish.sh` met a jour `published/` en place.
En mode normal, il conserve les RPM deja publies et ajoute/met a jour ceux presents dans `repo/*`.
En mode `clean`, il supprime les RPM publies avant republication complete.
