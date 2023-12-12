umask 0022

###################################
#
#     Branch Name is PS1
#
sc_helper_bashrc_branch() {
  if git branch >/dev/null 2>&1; then
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
  fi
}

###################################
#
#     Kube Info on Right of Console
#
sc_helper_bashrc_kube() {
  if kubectl config view --minify -o jsonpath="{}" >/dev/null 2>&1; then
    printf "%*s\r%s" $((COLUMNS - 1)) "$(kubectl config view --minify -o jsonpath="{.clusters[].name}/{.contexts[].context.namespace}")"
  fi
}

###################################
#
#     Cursor Character
#
sc_helper_bashrc_cursor() {
  [[ "${UID}" == "0" ]] && echo '#' || echo '$'
}

###################################
#
#     Others
#
sc_helper_x509_decode (){
  if [ -z "${1}" ] ; then
    while IFS= read -r LINE; do
      lines="${lines}${LINE}\n"
    done
    echo -e "${lines}" | openssl x509 -noout -text
  else
    openssl x509 -noout -text -in "${1}"
  fi
}

sc_helper_x509_san_names(){
  SAN_NAMES=""

  for i in $(echo "${1}" | tr ',' '\n') ; do
    SAN_NAMES="DNS:${i},${SAN_NAMES}"
  done

  echo "$(echo "${SAN_NAMES}" | sed "s/,$//g")"
}

sc_helper_x509_ca_make() {
  [ -z "${1}" ] && CA_NAME="ca" || CA_NAME="${1}"
  [ -z "${2}" ] && CA_CN_NAME="Root CA" || CA_CN_NAME="${2}"
  [ -z "${3}" ] && CA_DAYS="3650" || CA_DAYS="${3}"

  echo "Generate CA (Filename: '${CA_NAME}.(crt|key).pem', Common Name: '${CA_CN_NAME}')"

  openssl req \
    -nodes -x509 -days "${CA_DAYS}" -newkey rsa:4096 \
    -subj "/CN=${CA_CN_NAME}" \
    -keyout "${CA_NAME}".key.pem -out "${CA_NAME}".crt.pem
}

sc_helper_x509_ca_make_leaf() {
  [ -z "${1}" ] && CA_NAME="ca" || CA_NAME="${1}"
  [ -z "${2}" ] && LEAF_NAME="leaf" || LEAF_NAME="${2}"
  [ -z "${3}" ] && LEAF_SANS="-" || LEAF_SANS="${3}"
  [ -z "${4}" ] && LEAF_DAYS="730" || LEAF_DAYS="${4}"

  CA_FILENAME="${CA_NAME}"
  [ ! -f "${CA_FILENAME}".crt.pem ] && [ ! -f "${CA_FILENAME}".key.pem ] && echo "CA Does Not Exists" && exit 1

  LEAF_FILENAME="${CA_NAME}-${LEAF_NAME}"
  echo "Generate Certificate (Filename: '${LEAF_FILENAME}.(crt|key).pem', Common Name: '${LEAF_NAME})'"

  openssl req \
    -nodes -new -newkey rsa:2048 \
    -subj "/CN=${LEAF_NAME}" \
    -keyout "${LEAF_FILENAME}".key.pem -out "${LEAF_FILENAME}".csr.pem

  if [ -z "${LEAF_SANS}" ] || [ "${LEAF_SANS}" == "-" ] ; then
    openssl x509 \
      -req -days "${LEAF_DAYS}" \
      -CA "${CA_FILENAME}".crt.pem -CAkey "${CA_FILENAME}".key.pem -CAcreateserial \
      -in "${LEAF_FILENAME}".csr.pem -out "${LEAF_FILENAME}".crt.pem
  else
    openssl x509 \
      -req -days "${LEAF_DAYS}" \
      -CA "${CA_FILENAME}".crt.pem -CAkey "${CA_FILENAME}".key.pem -CAcreateserial \
      -in "${LEAF_FILENAME}".csr.pem -out "${LEAF_FILENAME}".crt.pem \
      -extfile <(printf "subjectAltName=$(sc_helper_x509_san_names "${LEAF_SANS}")")
  fi
}

sc_helper_curl_format_file(){
cat > .curl-timing-format.txt << EndOfMessage
\t%{time_namelookup}s\tNamelookup (DNS)\n
\t%{time_connect}s\tConnect (TCP)\n
\t%{time_appconnect}s\tApp Connect (SSL/SSH/etc.)\n
\t%{time_pretransfer}s\tPretransfer (just before want to start sending)\n
\t%{time_starttransfer}s\tStart Transfer (first byte + Pretransfer)\n
\t%{time_redirect}s\tRedirect (all before final request)\n
------------------------------\n
\t%{time_total}s:\tTotal\n
EndOfMessage
}

sc_helper_tcp_linux_check(){
  [ -z "${1}" ] && DEST_NAME="google.com" || DEST_NAME="${1}"
  [ -z "${2}" ] && DEST_PORT="80" || DEST_PORT="${2}"

  timeout 5 bash -c "(echo > /dev/tcp/${DEST_NAME}/${DEST_PORT}) >/dev/null 2>&1 && echo UP || echo DOWN" || echo TIMEOUT
}

sc_helper_git_log_n_commits(){
  [ -z "${1}" ] && N_COMMITS="5" || N_COMMITS="${1}"

  git log -n "${N_COMMITS}" --oneline --format='%h' | xargs -I {} sh -c 'git diff {}^..{}'
}

###################################
#
#     Exportsx
#
export PS1="\[\e[1;34m\]\$(sc_helper_bashrc_kube)\[\e[m\][\[\e[32m\]\u\[\e[m\]]@[\[\e[1;34m\]\h\[\e[m\]][\[\e[1;36m\]\W\[\e[m\]]\$(sc_helper_bashrc_cursor) \[\e[33m\]\$(sc_helper_bashrc_branch)\[\e[m\]"
export HISTSIZE="10000"
export HISTFILESIZE="10000"
export HISTTIMEFORMAT="%Y-%m-%d %T "
export EDITOR="vim"
