#!/bin/bash

# Syncing Trellis & Bedrock-based WordPress environments with WP-CLI aliases
# Copyright (c) Ben Word
# Licensed under the MIT License

DEVDIR="web/app/uploads/"
DEVSITE="https://example.dev"

PRODDIR="web@example.com:/srv/www/example.com/shared/uploads/"
PRODSITE="https://example.com"

STAGDIR="web@example.viewsite.link:/srv/www/example.com/shared/uploads/"
STAGSITE="https://example.viewsite.link"

FROM=$1
TO=$2

bold=$(tput bold)
normal=$(tput sgr0)

case "$1-$2" in
  production-development) DIR="down ⬇️ "           FROMSITE=$PRODSITE; FROMDIR=$PRODDIR; TOSITE=$DEVSITE;  TODIR=$DEVDIR; ;;
  staging-development)    DIR="down ⬇️ "           FROMSITE=$STAGSITE; FROMDIR=$STAGDIR; TOSITE=$DEVSITE;  TODIR=$DEVDIR; ;;
  development-production) DIR="up ⬆️ "             FROMSITE=$DEVSITE;  FROMDIR=$DEVDIR;  TOSITE=$PRODSITE; TODIR=$PRODDIR; ;;
  development-staging)    DIR="up ⬆️ "             FROMSITE=$DEVSITE;  FROMDIR=$DEVDIR;  TOSITE=$STAGSITE; TODIR=$STAGDIR; ;;
  production-staging)     DIR="horizontally ↔️ ";  FROMSITE=$PRODSITE; FROMDIR=$PRODDIR; TOSITE=$STAGSITE; TODIR=$STAGDIR; ;;
  staging-production)     DIR="horizontally ↔️ ";  FROMSITE=$STAGSITE; FROMDIR=$STAGDIR; TOSITE=$PRODSITE; TODIR=$PRODDIR; ;;
  *) echo "usage: $0 production development | staging development | development staging | development production | staging production | production staging" && exit 1 ;;
esac

read -r -p "

🔄   Would you really like to ⚠️  ${bold}reset the $TO database${normal} ($TOSITE)
    and sync ${bold}$DIR${normal} from $FROM ($FROMSITE)? [y/N] " response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  # Make sure Vagrant box can be SSH'd into via example.dev
  if [ "$1" == "development" ] || [ "$2" == "development" ]; then
    cd ../../trellis && ./bin/ssh-config-development.sh &&
    cd ../site/scripts/
  fi

  # Change to site directory
  cd ../ &&
  echo

  # Make sure both environments are available before we continue
  availfrom() {
    local AVAILFROM
    AVAILFROM=$(wp "@$FROM" option get home 2>&1)
    if [[ $AVAILFROM == *"Error"* ]]; then
      echo "❌   Unable to connect to $FROM"
      exit 1
    else
      echo "✅   Able to connect to $FROM"
    fi
  };
  availfrom

  availto() {
    local AVAILTO
    AVAILTO=$(wp "@$TO" option get home 2>&1)
    if [[ $AVAILTO == *"Error"* ]]; then
      echo "❌   Unable to connect to $TO"
      exit 1
    else
      echo "✅   Able to connect to $TO"
    fi
  };
  availto
  echo

  # Export/import database, run search & replace
  wp "@$TO" db export &&
  wp "@$TO" db reset --yes &&
  wp "@$FROM" db export - | wp "@$TO" db import - &&
  wp "@$TO" search-replace "$FROMSITE" "$TOSITE" &&

  # Sync uploads directory
  chmod -R 755 web/app/uploads/ &&
  if [[ $DIR == "horizontally"* ]]; then
    [[ $FROMDIR =~ ^(.*): ]] && FROMHOST=${BASH_REMATCH[1]}
    [[ $FROMDIR =~ ^(.*):(.*)$ ]] && FROMDIR=${BASH_REMATCH[2]}
    [[ $TODIR =~ ^(.*): ]] && TOHOST=${BASH_REMATCH[1]}
    [[ $TODIR =~ ^(.*):(.*)$ ]] && TODIR=${BASH_REMATCH[2]}

    ssh -o ForwardAgent=yes $FROMHOST "rsync -aze 'ssh -o StrictHostKeyChecking=no' --progress $FROMDIR $TOHOST:$TODIR"
  else
    rsync -az --progress "$FROMDIR" "$TODIR"
  fi

  # Slack notification when sync direction is up or horizontal
  if [[ $DIR != "down"* ]]; then
    USER="$(git config user.name)"
    curl -X POST -H "Content-type: application/json" --data "{\"attachments\":[{\"fallback\": \"\",\"color\":\"#36a64f\",\"text\":\"🔄 Sync from ${FROMSITE} to ${TOSITE} by ${USER} complete \"}],\"channel\":\"#riotlabs-ops\"}" https://hooks.slack.com/services/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
  fi
  echo -e "\n\n🔄   Sync from $FROM to $TO complete.\n\n    ${bold}$TOSITE${normal}\n"
fi
