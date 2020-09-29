if [ -f ~/.bashrc ] ; then
  . ~/.bashrc
fi

umask 0022

PATH=~/portable/terraform/latest/bin:$PATH
PATH=/opt/terraform/latest/bin:$PATH

PATH=~/portable/ruby/latest/bin:$PATH
PATH=/opt/ruby/latest/bin:$PATH

PATH=~/portable/node.js/latest/bin:$PATH
PATH=/opt/node.js/latest/bin:$PATH

PATH=~/portable/yarn/latest/bin:$PATH
PATH=/opt/yarn/latest/bin:$PATH

PATH=~/portable/helm/latest/bin:$PATH
PATH=/opt/helm/latest/bin:$PATH

export PATH
