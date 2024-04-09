#!/usr/bin/bash
# Author: Sergii Kulyk
#
# Convert confluence changes to git commits
# Logic:
# 1. Get all child pages recursively starting from $MAINID page
# 2. Get all changes (versions) of pages
# 3. Sort them according to date
# 4. Commit using change author and change date (check for duplicate before)
#

# Requirements:
# Install "jq" to parse JSON
# Install "pandoc" to convert html to markdown
# Tested with Confluence version 8

# Required environment variables:
#   MAINID - ID of starting confluence page
#   REPO   - git repo to store results
#   TOKEN  - authorization token for Confluence
#
BASE_URL="https://confluence.mycompany.com/confluence/rest" # configure it for your confluence.
DOMAIN="@google.com" # to generate user's emails
declare -A PAGES
declare -A TITLES
declare -A NAMES
declare -A DIRS
declare -A COMMENTS

LISTFILE="$(pwd)/list.log"
GITLOGFILE="$(pwd)/git.log"
[ -e "${LISTFILE}" ] && rm "${LISTFILE}"

# init values
if [ -z "${TOKEN}" ]; 
  echo "Auth token not found"
  exit 1
fi
if [ -z "${MAINID}" ]; then
  echo "Please provide ID of starting confluence page"
  exit 1
fi
if [ -z "${REPO}" ]; then
  echo "Please provide (empty) git repo to commit results"
  exit 1
fi
tmp="${REPO##*/}"
REPONAME="${tmp%.git}"

echo "$(date '+%Y%m%d-%H%M') Starting script with $MAINID and $REPO"

# check if we need to 'git clone' or 'git pull' existing repo
if [ -d "$REPONAME" ]; then
  cd "${REPONAME}"
  git pull
  if [ $? -ne 0 ]; then
    echo "Git pull failed, check your settings"
    exit 1
  fi
else
  git clone "$REPO"
  if [ $? -ne 0 ]; then
    echo "Git clone failed, check your settings"
    exit 1
  fi
  cd "${REPONAME}"
fi
BASEDIR="$(pwd)"

# function to get all child pages recursively and fill array
function get_child_pages() {
  child_list="$(curl -k -H "Authorization: Bearer ${TOKEN}" ${BASE_URL}/api/content/${1}/child/page 2>/dev/null| jq -r '.results[] | .id + " " + .title' | tr -d '\r')"
  currentdir="$(pwd | sed "s#$BASEDIR#.#g" | tr -d '\n')"
  DIRS[${1}]="${currentdir}"
  [ -z "$child_list" ] && return
  [ -d "$2" ] || mkdir "$2"
  cd "$2"
  while read TMPID TMPTITLE; do
    TITLE="$(sed -r "s|[&'/*\\\`}{\"]|_|g" <<< "${TMPTITLE}")"
    TITLES[${TMPID}]="${TMPTITLE}"
    PAGES[${TMPID}]="${TITLE}"
    get_child_pages "${TMPID}" "${TITLE}"
  done <<< "${child_list}"
  cd ..
}

# get all page changes (versions) and fill $LISTFILE
function get_page_versions() {
  declare -i CNT=0
  version_list="$(curl -k -H "Authorization: Bearer ${TOKEN}" "${BASE_URL}/experimental/content/${1}/version" 2>/dev/null | jq '.results[] | .by.username + "|" + .by.displayName + "|" + .when + "|" + (.number|tostring)  + "|" + if .message == null then "None" else .message end'| tr -d \"|tr -d '\r'|sort)"
  IFS="|"
  while read user username versiondate number message ; do
    CNT+=1
    timestamp="$(date -d "$versiondate" "+%s")"
    NAMES[${user}]="${username%[*} <${user}{DOMAIN}>"
    COMMENTS[${1}-${number}]="${message}"
    echo "${timestamp} ${1} ${number} ${user} ${versiondate}" >> "${LISTFILE}"
  done<<<"$version_list"
  echo " ${CNT} found"
}

function get_page_body() {
  curl -k -H "Authorization: Bearer ${TOKEN}" "${BASE_URL}/api/content/${1}?expand=body.view&version=${2}" 2>/dev/null | jq '.title + .body.view.value' | sed 's/\\n/\n/g' > "${PAGES[${1}]}-${1}.htm"
  pandoc --standalone --from=html --to=markdown_strict "${PAGES[${1}]}-${1}.htm" --output "${PAGES[${1}]}-${1}.md"
  rm "${PAGES[${1}]}-${1}.htm"
}

# Checking starting page
read TMPID TMPTITLE <<< "$(curl -k -H "Authorization: Bearer ${TOKEN}" "${BASE_URL}/api/content/${MAINID}" 2>/dev/null | jq -r '.id + " " + .title')"
TITLE="$(sed -r "s|[&/*\\}{\"]|_|g" <<< "${TMPTITLE}")"
echo "$(date '+%Y%m%d-%H%M') Processing: ${TMPID} ${TMPTITLE} [${TITLE}] (main)"
PAGES[${TMPID}]="${TITLE}"
TITLES[${TMPID}]="${TMPTITLE}"

get_child_pages "${MAINID}" "${TITLE}"
echo "$(date '+%Y%m%d-%H%M') Total ${#PAGES[*]} found"

for pageID in ${!PAGES[*]}; do
  echo -n "Checking versions for [${pageID}] ${PAGES[${pageID}]}:"
  get_page_versions "${pageID}"
done

echo "$(date '+%Y%m%d-%H%M') Found $(wc -l "${LISTFILE}") changes in ${#PAGES[*]} pages"
git log --oneline > "${GITLOGFILE}" # to avoid duplicates
echo -n "Skipping "
IFS=" "
while read timestamp pageID version user date; do
  if grep " ${pageID}-${version} " "${GITLOGFILE}" >/dev/null; then
    echo -n "."
    # echo "Skipping ${pageID}-${version}"
    continue
  fi
  echo -e "\nFound new change, commiting:"
  cd "${BASEDIR}"
  cd "${DIRS[$pageID]}"
  get_page_body ${pageID} ${version}
  git add "${PAGES[${pageID}]}-${pageID}.md"
  git config user.name "${NAMES[${user}]}"
  git config user.email "${user}${DOMAIN}"
  git commit --date="${date}" -m "${pageID}-${version} ${user} ${PAGES[${pageID}]} - ${COMMENTS[${pageID}-${version}]}"
done<<<$(sort "${LISTFILE}")

echo "$(date '+%Y%m%d-%H%M') Pushing changes"

git push
