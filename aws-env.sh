#!/bin/bash

echo Install infra packages...

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install kubectl k9s git awscli helm thefuck fzf terraform kubectx wget eksctl 

brew install zsh

pip3 install --upgrade pip

mkdir -p tmp
cd tmp
git clone https://github.com/ChangeFinance/okta-awscli.git
cd okta-awscli
pip3 install .

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


echo Update .zshrc ...

cat << EOF >> ~/.zshrc

alias o-aws="okta-awscli -f"
alias o-aws-dev="okta-awscli -o default -p change-dev -f"
alias o-aws-stg="okta-awscli -o stg -p change-stg -f"
alias o-aws-prod="okta-awscli -o prod -p change-prod -f"

# Exports
export TF_VAR_dev_aws_profile=change-dev
export TF_VAR_stg_aws_profile=change-stg
export TF_VAR_prod_aws_profile=change-prod
export AWS_DEFAULT_PROFILE=change-dev

dev () {
export AWS_DEFAULT_PROFILE=change-dev
}

stg () {
export AWS_DEFAULT_PROFILE=change-stg
}

prod () {
export AWS_DEFAULT_PROFILE=change-prod
}

EOF

echo Setup AWS CLI tools...

echo "Enter your email (OKTA username):"
read OKTA_EMAIL


cat << EOF > ~/.okta

[default]
username = _user_
base-url = changeinvest.okta.com
app-link = https://changeinvest.okta.com/home/amazon_aws/0oa3yt43zuFESPL0M5d7/272
duration = 28800

[stg]
username = _user_
base-url = changeinvest.okta.com
app-link = https://changeinvest.okta.com/home/amazon_aws/0oa40xjarcRdnOQnx5d7/272
duration = 28800

#[prod]
#username = _user_
#base-url = changeinvest.okta.com
#app-link = https://changeinvest.okta.com/home/amazon_aws/0oa40xjarcRdnOQnx5d7/272
#duration = 28800

EOF
OKTA_EMAIL=$(echo $OKTA_EMAIL | sed 's/\@/\\\@/g')
sed "s/_user_/$OKTA_EMAIL/g" ~/.okta > ~/.okta-aws
rm -f ~/.okta

echo Create AWS configs...
mkdir -p ~/.aws

cat << EOF > ~/.aws/config
[default]
region=eu-west-1

EOF

cat << EOF > ~/.aws/credentials
[change-dev]
aws_access_key_id = XXX
aws_secret_access_key = XXX
aws_session_token = XXX

[change-stg]
aws_access_key_id = XXX
aws_secret_access_key = XXX
aws_session_token = XXX

[change-prod]
aws_access_key_id = XXX
aws_secret_access_key = XXX
aws_session_token = XXX

[default]
aws_access_key_id = XXX
aws_secret_access_key = XXX
aws_session_token = XXX

EOF

echo Configuring kubernetes configs...

mkdir -p ~/.kube

cat << EOF > ~/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM1ekNDQWMrZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJeU1ETXhPREE0TkRVME0xb1hEVE15TURNeE5UQTRORFUwTTFvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTkNwCmFaalY0Wk5XOHJPdHVQejMyVFdYVGdNbS9aVlArZ25iQ01DNFRhUVp5czh0TUladXBOS1pvV2hqd3F2Vm91NTQKZHZzbVF3WVFpTmdGSWpVdDZxTTBCSWloWE5pVkNjMUN6OXovYjZ3TTZDQVJUZjhxWnpNMXluc0tFbGZFU3luSAo2REsxUWJadXpyZEs2V3FXZDVDSWlzbjVVQmVTOWQwZEZQL2tvTlQ0NzY2Zk9QQzRYcFdULzArU0FxUUg5c3dtCndzanB3RTkwcUlMcDZGQ0RsK1Z1cTg5ZDZraUp1TkJ5OHcyUHV0WE95aUdJczFJaTBHNmtCSUVSM1VUck43Qy8KczMvZGVrWklmWVpQZzI2UjNuNkM4Wjl1N2V1dVBXdzREejJJMDI3a09oY0l1dEJmMW05MkFXbzJsTU0rb0lXOApibkhkYXdMRTZWTHpERFFZdi9zQ0F3RUFBYU5DTUVBd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZDOWpRaGJHZUs0QTlkNjF4ZDdLRnhlNm03bWNNQTBHQ1NxR1NJYjMKRFFFQkN3VUFBNElCQVFEQk5TdHRiL3RsVFlhclA0V0YxNzZ4a3ZONG5OOUFQejBDOFZhaGs0d2xFaXFmNEVQMgpORXhQTHM2dXRZdTRvKzBqaWF3YUtPOTFrTUE2Q2VWUVFZQURtWHdsWmRKV3hRanp6aFdLOEhRb3lyd3JWL0FpCks2cE5sS2NVR0pmdHcyWTBNTEIzNmhMTytZZS9IVWlyZHhsamp5Z05FOTZoRU5XRHVyQVI5aTJCRTBRUWQwUkMKUm1xSDlNejVmT0c1N2d0dVZiMFVUSDl6Y2Q3a2ZnNHdpanRtM3c5SHZpd3BXSC82UE1BK3R0V1ZmSWQ3aUZmOQpGamV6VnZ6UDVPNThXNlQ1V3d5QkFJWmwyc3oxZDJFK1JHS0hmNi83R280TzBCOWVpbDV3NWlKcS9FcGt6MlV6CjM4bVVsNkU5VzZOSWlMUGVTdFV4bXFaRTRTRVFZVEwyYkRDdgotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://BFF3D5E4FE34BF0E1457C926D27842EB.sk1.eu-west-1.eks.amazonaws.com
  name: arn:aws:eks:eu-west-1:776004612361:cluster/eks-dev
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM1ekNDQWMrZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJeU1ETXhOVEV3TWpNek9Gb1hEVE15TURNeE1qRXdNak16T0Zvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTVJ0Cm5mbzd6Rm5YRjBsN2M0VDlHZWpyVWpNUEsxSGNmeEVzc1lsWEtWQVluSzZLSUFIeU41MUFhVlhyeWJqSlZtSHcKc2IraTRYWndoRTNhWW9OajBWdVpoOUhveE92WEN4aTdWbW02d29zRHFEWGwzUW14WUc1OGhDK2o5bkZaZU90OApNUDVRWDFUT0pUZU1BZnlEczArVG9RTGNxd1h1MVlWWSt3bFBKZU9JOXU2LzZFSVlLdmtwNXBUQnF1bDZoNmhoCllYejRMUGtCeDlTcmQzT1RhbUkxUUN1T3ZnSHF5bXZVUTNGWWpPbUloK2o2U25VSHloSHZYZ1F0c1U1a0lDMkIKQkc3V09NeUZpWFh3UDN3TmhES3FSYll0M1NFSi9CMFBCR2s0RnhwdGdaZXlPUnlUcVg2K0RWc29NVThxU3psWgpmQjZQUVBrWFdoT1Z4V2hraWlVQ0F3RUFBYU5DTUVBd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZMZVduM3BxZzZEeXNtZmE3VDcvWVBmL25CaC9NQTBHQ1NxR1NJYjMKRFFFQkN3VUFBNElCQVFCYVNsZlo0N3paTzluTHB1bk45YWRUN253RTkreWpHWW5qUTZpckMwYSt4SDBHNitFYQo1ejlJanpwQjcxQXpPRnJnNmZkU1dPejlNU0JoOXRremhMTXNxNVN1MzU0enpBak14RUFFdXpGSGJoQU5KV2xRCkpxQ0xSeU85YW5sblRtWVFHODl3U0ZsSnY1Qnp3MlI3Yys4MGx6Wmd0Qms4bGxORWd5SVBtMWMwWVJuMTJlWGcKNWFuOUlYbS9hb29sN1ordm11b2pSK0ZDRWp5amduNGtjSC85UXFLaThxNkY1WjNUcmJBOUZTQzE0RW13ZGIrdwpOZEdoa1JZWW1hcEJmZHduY0pCaW1iU1pMVzh2cjRPMzNQMG1EVFVrSGl0YkFJU2ZQMjAzMEtIZnhRdFRtQWFXCmF0Y05xaUZ3WWRSaTFHbUY0QkFJTGRxVE9OMW1XRkFseHEybwotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://8221FB5FF3DEE3F05D5141AC2C2FAF9D.sk1.eu-west-1.eks.amazonaws.com
  name: arn:aws:eks:eu-west-1:776004612361:cluster/eks-test
contexts:
- context:
    cluster: arn:aws:eks:eu-west-1:776004612361:cluster/eks-dev
    user: change-dev
  name: eks-dev
- context:
    cluster: arn:aws:eks:eu-west-1:776004612361:cluster/eks-test
    user: change-test
  name: eks-test
current-context: eks-dev
kind: Config
preferences: {}
users:
- name: change-dev
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - --region
      - eu-west-1
      - eks
      - get-token
      - --cluster-name
      - eks-dev
      command: aws
      env:
      - name: AWS_PROFILE
        value: change-dev
      interactiveMode: IfAvailable
      provideClusterInfo: false
- name: change-test
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - --region
      - eu-west-1
      - eks
      - get-token
      - --cluster-name
      - eks-test
      command: aws
      env:
      - name: AWS_PROFILE
        value: change-dev
      interactiveMode: IfAvailable
      provideClusterInfo: false

EOF


echo Please run source ~/.zshrc
echo Then use o-aws-dev to login to change-dev account, 
echo o-aws-stg to change-stg account, and o-aws-prod to change-prod accounts
