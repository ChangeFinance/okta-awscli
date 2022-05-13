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

grep o-aws ~/.zshrc || cat << EOF >> ~/.zshrc

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

[prod]
username = _user_
base-url = changeinvest.okta.com
app-link = https://changeinvest.okta.com/home/amazon_aws/0oa48dpwmrP21GoHV5d7/272
duration = 28800

EOF
OKTA_EMAIL=$(echo $OKTA_EMAIL | sed 's/\@/\\\@/g')
sed "s/_user_/$OKTA_EMAIL/g" ~/.okta > ~/.okta-aws

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
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM1ekNDQWMrZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJeU1EVXdPVEUwTURFeE1Gb1hEVE15TURVd05qRTBNREV4TUZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTkJaCkFwQ2ptbGNKb2tOejQ2TzQ3REp5T09MRUdDTnNFckUrQ01qOTJSaTV2WXZoMHkranhIaE53cG85cjR6Mi9qY3cKWVNpQURuc0tFUmwxeTh4ZCtjYzF4cTMyYnVpaDg5TXQwNFFLdFU0YTRRVlQzOG9rY21JdExLeEsrVkp0ODhVYQpxaUVXbXNwRGVxcnc4MUNRWS9VYW9ZcFNsbGJwL1NTdFlub1BiZEgyMkR0NHVhWXFvZGphbnJmaWhUb3BYVWE3ClVzdklIWEdtS1RkMktLdk1jWmtPdFpnUk5DWUJGUWpSQzluU1JENGhIdWs3dTd5VFY2TTk1bHo0MGQza3FlUGwKVkpWNHNJNGdLbE1QS0Y2K25KSW1odUZHM0Jlb2RCUHZZeWJjWmpjM3luM3h4TWkwbGp3eElnQU9td2FOUFlmegp4UWFTTUVmbi9Lbm1zSVR2V0prQ0F3RUFBYU5DTUVBd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZKcUJ2bU0rQ09QWUZwQy85Y2Y1TnlFYTFiMWpNQTBHQ1NxR1NJYjMKRFFFQkN3VUFBNElCQVFCaGFUWDF5VXViSU91TzhHS0s2VzFnbnhIaStaa2NKZ0YrV1BEQk1MekpGV1ZiV2ZDSgpVRnZDUjdpRkJkTktESmJWSUNHQm1VczcrL0EraHdNTXVtLzRoRXBqVVV2NnRwMVdCY0ZDZ2VOVGlNbGdTYjZmCnBmNUZ0MTRKMjRraXdWSWZSRXVtZW1ib3E5WEg1N2wxcWV5bEJHMU1OdGFWSGE3SVJVTU5UTXJkcjNMemU3VUcKYVBsWHNjOW4xZE1pWmVtTEM1T2JpSndoOUYrVFpQdDVwbDlZbTVXTDlFRm41WVIyYU5iZVZiWEtWeEEyNmtxKwpueG8zQVB0YXlwaVhxdHUraUd2c1dobElYQy9DdkZjdW5hTnJjdk1MSGxlT0QxazV4SnZweEpMQWVUOXZvL2NwCnozQlE2alJYaWVjRTZlaWNxNWNLL2Flc29Rd0oyaCs2TGJ6WgotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://4EBDC09EDBB51E6DD439781C09430842.gr7.eu-west-1.eks.amazonaws.com
  name: arn:aws:eks:eu-west-1:545659691938:cluster/eks-prod
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM1ekNDQWMrZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJeU1ETXhPREE0TkRVME0xb1hEVE15TURNeE5UQTRORFUwTTFvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTkNwCmFaalY0Wk5XOHJPdHVQejMyVFdYVGdNbS9aVlArZ25iQ01DNFRhUVp5czh0TUladXBOS1pvV2hqd3F2Vm91NTQKZHZzbVF3WVFpTmdGSWpVdDZxTTBCSWloWE5pVkNjMUN6OXovYjZ3TTZDQVJUZjhxWnpNMXluc0tFbGZFU3luSAo2REsxUWJadXpyZEs2V3FXZDVDSWlzbjVVQmVTOWQwZEZQL2tvTlQ0NzY2Zk9QQzRYcFdULzArU0FxUUg5c3dtCndzanB3RTkwcUlMcDZGQ0RsK1Z1cTg5ZDZraUp1TkJ5OHcyUHV0WE95aUdJczFJaTBHNmtCSUVSM1VUck43Qy8KczMvZGVrWklmWVpQZzI2UjNuNkM4Wjl1N2V1dVBXdzREejJJMDI3a09oY0l1dEJmMW05MkFXbzJsTU0rb0lXOApibkhkYXdMRTZWTHpERFFZdi9zQ0F3RUFBYU5DTUVBd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZDOWpRaGJHZUs0QTlkNjF4ZDdLRnhlNm03bWNNQTBHQ1NxR1NJYjMKRFFFQkN3VUFBNElCQVFEQk5TdHRiL3RsVFlhclA0V0YxNzZ4a3ZONG5OOUFQejBDOFZhaGs0d2xFaXFmNEVQMgpORXhQTHM2dXRZdTRvKzBqaWF3YUtPOTFrTUE2Q2VWUVFZQURtWHdsWmRKV3hRanp6aFdLOEhRb3lyd3JWL0FpCks2cE5sS2NVR0pmdHcyWTBNTEIzNmhMTytZZS9IVWlyZHhsamp5Z05FOTZoRU5XRHVyQVI5aTJCRTBRUWQwUkMKUm1xSDlNejVmT0c1N2d0dVZiMFVUSDl6Y2Q3a2ZnNHdpanRtM3c5SHZpd3BXSC82UE1BK3R0V1ZmSWQ3aUZmOQpGamV6VnZ6UDVPNThXNlQ1V3d5QkFJWmwyc3oxZDJFK1JHS0hmNi83R280TzBCOWVpbDV3NWlKcS9FcGt6MlV6CjM4bVVsNkU5VzZOSWlMUGVTdFV4bXFaRTRTRVFZVEwyYkRDdgotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://BFF3D5E4FE34BF0E1457C926D27842EB.sk1.eu-west-1.eks.amazonaws.com
  name: arn:aws:eks:eu-west-1:776004612361:cluster/eks-dev
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM1ekNDQWMrZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJeU1ETXhOVEV3TWpNek9Gb1hEVE15TURNeE1qRXdNak16T0Zvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTVJ0Cm5mbzd6Rm5YRjBsN2M0VDlHZWpyVWpNUEsxSGNmeEVzc1lsWEtWQVluSzZLSUFIeU41MUFhVlhyeWJqSlZtSHcKc2IraTRYWndoRTNhWW9OajBWdVpoOUhveE92WEN4aTdWbW02d29zRHFEWGwzUW14WUc1OGhDK2o5bkZaZU90OApNUDVRWDFUT0pUZU1BZnlEczArVG9RTGNxd1h1MVlWWSt3bFBKZU9JOXU2LzZFSVlLdmtwNXBUQnF1bDZoNmhoCllYejRMUGtCeDlTcmQzT1RhbUkxUUN1T3ZnSHF5bXZVUTNGWWpPbUloK2o2U25VSHloSHZYZ1F0c1U1a0lDMkIKQkc3V09NeUZpWFh3UDN3TmhES3FSYll0M1NFSi9CMFBCR2s0RnhwdGdaZXlPUnlUcVg2K0RWc29NVThxU3psWgpmQjZQUVBrWFdoT1Z4V2hraWlVQ0F3RUFBYU5DTUVBd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZMZVduM3BxZzZEeXNtZmE3VDcvWVBmL25CaC9NQTBHQ1NxR1NJYjMKRFFFQkN3VUFBNElCQVFCYVNsZlo0N3paTzluTHB1bk45YWRUN253RTkreWpHWW5qUTZpckMwYSt4SDBHNitFYQo1ejlJanpwQjcxQXpPRnJnNmZkU1dPejlNU0JoOXRremhMTXNxNVN1MzU0enpBak14RUFFdXpGSGJoQU5KV2xRCkpxQ0xSeU85YW5sblRtWVFHODl3U0ZsSnY1Qnp3MlI3Yys4MGx6Wmd0Qms4bGxORWd5SVBtMWMwWVJuMTJlWGcKNWFuOUlYbS9hb29sN1ordm11b2pSK0ZDRWp5amduNGtjSC85UXFLaThxNkY1WjNUcmJBOUZTQzE0RW13ZGIrdwpOZEdoa1JZWW1hcEJmZHduY0pCaW1iU1pMVzh2cjRPMzNQMG1EVFVrSGl0YkFJU2ZQMjAzMEtIZnhRdFRtQWFXCmF0Y05xaUZ3WWRSaTFHbUY0QkFJTGRxVE9OMW1XRkFseHEybwotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://8221FB5FF3DEE3F05D5141AC2C2FAF9D.sk1.eu-west-1.eks.amazonaws.com
  name: arn:aws:eks:eu-west-1:776004612361:cluster/eks-test
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM1ekNDQWMrZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJeU1EUXlOVEV3TXpZMU0xb1hEVE15TURReU1qRXdNelkxTTFvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTGZjCmM4dTRyMWFxa3poczM0ckxMZE9IVkxhV1JMWnJ0TVd1SXFHeHdIYlM1dGdkd204aHYrSEsvRFFMZGZKbEVES3MKQ3lDcGxLR0dMUGVKdGxpTXdOY0VtMWREam9PNDhmajZhaEhXbERRSXluUUVhVm8zTStFeEh3SkNXVVZWaERhTwozTi9ZN3Z5NUxXckZ0UXIyZTFIbkMyLzJ4S2dhMmRETGRUVnIzWVpnVUhINEp5Y3hoRFU4cDBwSEY2cXhEMGYvClFtWXg4OUowU3I1MmxBUUdiRGlLVjNyQ0NwWHNsenFUNmxpcWQ4N2I2cEZUeTROaWdyVEhwMk9WR0dEZWlkRjAKcU1yV2dtSmt1L2hqYnVHT0J5RGM2SDZESXdNTFhlbllPZmZXemdlbGI1VTBLcGRXOUJlTmV6emwyeHNPUFNFSwpQWGJpMGxoRmFSTUNua1pQYTMwQ0F3RUFBYU5DTUVBd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZEREwvaUY5SGtNT3lFa1dxVG1TazlTU1p2SWdNQTBHQ1NxR1NJYjMKRFFFQkN3VUFBNElCQVFBcEtrN1lHNW9xTHhNbkNwcDNYNWpFVUc3SFAxNnBWcWgzWTNUa0pFbHlneGVpVThuRAo3MzVseFRaOEMwNWVUQkxSR0RxbUdvaHhJcDBITXgwMVoxUWFCaTlINnJteE0vUnRud0ZzRXcrZnBqaVlkVkZSCjBSREF5QVVaUVJWbDF5bFJ6dlhOQjZ5VGVMMWozdUlOMVl3bjAvblpIZlhjVEpWZEh2VnVIRnBFRUE0RHN1SjcKcHJ1T0dSSFFDN0trVU1zbUlrbWlHK2xpSkhDMUx2MGJ5LzJUQnJ3Y3kvVlYxRVB6MXUzSXVJYmx2OEpkaXBnNwo2VktabGg5b2I5amJwWGRTZWFhdXMvS3FyNXRaVW9VZW50Wmc3cGJuaFEyZWRpK1ZvZlJSU25xbXNObERZMUQzCkdrdkJISmZTOGNCY2VvN3BTODE0SmVBWUtlaWs4VFo2SnQzZwotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://522150B79EC247DDDE9301DECC7CD24D.gr7.eu-west-1.eks.amazonaws.com
  name: arn:aws:eks:eu-west-1:908167193459:cluster/eks-stg
contexts:
- context:
    cluster: arn:aws:eks:eu-west-1:776004612361:cluster/eks-dev
    namespace: kube-system
    user: change-user
  name: eks-dev
- context:
    cluster: arn:aws:eks:eu-west-1:545659691938:cluster/eks-prod
    user: change-prod
  name: eks-prod
- context:
    cluster: arn:aws:eks:eu-west-1:908167193459:cluster/eks-stg
    user: change-stg
  name: eks-stg
- context:
    cluster: arn:aws:eks:eu-west-1:776004612361:cluster/eks-test
    user: change-test
  name: eks-test
current-context: eks-stg
kind: Config
preferences: {}
users:
- name: change-prod
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
      - --region
      - eu-west-1
      - eks
      - get-token
      - --cluster-name
      - eks-prod
      command: aws
      env:
      - name: AWS_PROFILE
        value: change-prod
      interactiveMode: IfAvailable
      provideClusterInfo: false
- name: change-stg
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
      - --region
      - eu-west-1
      - eks
      - get-token
      - --cluster-name
      - eks-stg
      command: aws
      env:
      - name: AWS_PROFILE
        value: change-stg
      interactiveMode: IfAvailable
      provideClusterInfo: false
- name: change-test
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
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
- name: change-user
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
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

EOF


echo Please run source ~/.zshrc
echo Then use o-aws-dev to login to change-dev account,
echo o-aws-stg to login to change-stg account, and o-aws-prod to login to change-prod accounts
