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
3. Executer scripts/sync-rpms.sh
4. Executer scripts/publish.sh
5. Verifier avec scripts/verify-repo.sh

## Configuration client

Exemple de fichier repo client: abls-rpms.repo

- gpgcheck=1: verification de signature des paquets
- repo_gpgcheck=0: verification de metadonnees desactivee (a activer plus tard si repodata signee)

## Publication

Le repertoire published est la cible exposee en HTTP.

Le script publish.sh prepare un snapshot complet puis bascule vers published pour limiter les etats intermediaires visibles par les clients.
