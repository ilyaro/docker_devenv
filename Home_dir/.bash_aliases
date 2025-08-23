## MAC: Docker_devenv aliases drun and de for MAC
alias drun='export IMNAME=devenv_amazonlinux_2023 && docker run -it -d --restart unless-stopped --name "${IMNAME}" -v /Volumes:/Volumes -v "${HOME}:${HOME}" -v /etc/resolv.conf:/etc/resolv.conf  --user root --env HOME="${HOME}" --env USER="${USER}" --env UID="$(id -u)" --env GID="$(id -g)" --entrypoint /bin/bash gfish/${IMNAME} -c "getent group \$GID || groupadd -g \$GID \$USER; id -u \$UID || useradd -m -u \$UID -g \$GID -d \$HOME -s /bin/bash \$USER; echo \"\$USER ALL=(ALL) NOPASSWD: ALL\" > /etc/sudoers.d/\$USER; chmod 0440 /etc/sudoers.d/\$USER; tail -f /dev/null"'
alias de='export IMNAME=devenv_amazonlinux_2023 && docker exec -it ${IMNAME} bash -c "export HOME=${HOME} && cd $HOME && sudo su - ${USER}"'

## MAC: Docker devenv TEST aliases to run test versions
export TIMNAME=devenv_amazonlinux_2023:v0.0.18
alias drunt='export CNAME=$(echo $TIMNAME | sed 's#:#_#') && docker run -it -d --restart unless-stopped --name "$CNAME" -v /Volumes:/Volumes -v "${HOME}:${HOME}" -v /etc/resolv.conf:/etc/resolv.conf  --user root --env HOME="${HOME}" --env USER="${USER}" --env UID="$(id -u)" --env GID="$(id -g)" --entrypoint /bin/bash gfish/${TIMNAME} -c "getent group \$GID || groupadd -g \$GID \$USER; id -u \$UID || useradd -m -u \$UID -g \$GID -d \$HOME -s /bin/bash \$USER; echo \"\$USER ALL=(ALL) NOPASSWD: ALL\" > /etc/sudoers.d/\$USER; chmod 0440 /etc/sudoers.d/\$USER; tail -f /dev/null"'
alias det='export CNAME=$(echo $TIMNAME | sed 's#:#_#') && docker exec -it ${CNAME} /bin/bash -c "export HOME=${HOME} && cd $HOME && sudo su - ${USER}"'

## Windows WSL: Docker_devenv aliases drun and de for Windows WSL
alias drun='export IMNAME=devenv_amazonlinux_2023;docker rm -f ${IMNAME};docker run --restart unless-stopped --name ${IMNAME} -it -d -v /mnt/d:/mnt/d -v /mnt/c:/mnt/c -v ${HOME}:${HOME} -v /etc/passwd:/etc/passwd -v /etc/shadow:/etc/shadow -v /etc/group:/etc/group -v /etc/ssl/certs:/etc/ssl/certs -v /etc/ssl/certs:/etc/pki/tls/certs -v /etc/sudoers:/etc/sudoers:ro -v /etc/sudoers.d:/etc/sudoers.d:ro gfish/${IMNAME}:latest'

alias de='export IMNAME=devenv_amazonlinux_2023 && docker exec -it ${IMNAME} bash -c "export HOME=${HOME} && cd $HOME && sudo su - ${USER}"'

#aws-sso-util configure populate --sso-start-url https://start.us-gov-west-1.us-gov-home.awsapps.com/directory/d-986716f394\# --sso-region us-gov-west-1 --region us-gov-east-1 --config-default output=json --config-default cli_pager="" --trim-account-name chkp-aws-rnd- --safe-account-names --components account_name,role_name --separator "." 

alias awsg='aws-sso-util login --all && awsume chkp-aws-gov-mis-devops-management.Admin'

alias ls='ls -Fa'
alias ll='ls -lah'
alias l='ls -lah'
alias lt='du -sh * | sort -h'
alias mnt='mount | grep -E ^/dev | column -t'
alias gh='history|grep'

alias g=git
alias k=kubectl
alias t=terraform 
alias h=helm
alias tg="/opt/homebrew/bin/terragrunt"
alias d=docker
alias v=vim
alias c='code -r' 
alias git-bd='git checkout origin/HEAD;git remote prune origin;git branch --merged | grep -v HEAD | xargs -I{} git branch -d {}'
alias pr='/Users/ilyaro/Git_CodeCommit/devops-tools/scripts/codecommit/create_pr.sh'

#aws-sso-util configure populate --sso-start-url https://DOMAINHERE-sso.awsapps.com/start --sso-region eu-west-1 --region eu-west-1 --config-default output=json --config-default cli_pager="" --trim-account-name chkp-aws-rnd- --safe-account-names --components account_name,role_name --separator "."
alias sso='aws-sso-util login --all'
## Add cluster with profile to see all clusters in Lens
#aws eks update-kubeconfig --region eu-west-1 --name firefly-dev-env-eu-west-1 --profile XXX.Admin # from awsume

alias builder="awsume --role-arn arn:aws:iam::\$(aws sts get-caller-identity --query Account --output text ):role/builder" 

## eval $(aws sts assume-role --role-arn arn:aws:iam::47XXXXXXX:role/builder --role-session-name=terraform --query 'join(``, [`export `, `AWS_ACCESS_KEY_ID=`, Credentials.AccessKeyId,`; export `, `AWS_SECRET_ACCESS_KEY=`, Credentials.SecretAccessKey, `; export `, `AWS_SESSION_TOKEN=`, Credentials.SessionToken])' --output text) 

alias ad='dscl "/Active Directory/AD/All Domains" read /Users/$USERNAME | grep -i lockouttime'

alias kb='kustomize build . --load-restrictor=LoadRestrictionsNone --enable-helm'
