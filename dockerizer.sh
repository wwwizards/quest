#!/bin/bash
#######################################################################################################################
#     ABSTRACT: DevOps Coding Challenge for technical interview
#      CREATED: 2023-FEB15 by Joe.Negron.NYC@gmail.com
#        SPECS: https://github.com/rearc/quest 
#    DEV-STACK: standalone a2-linux environment on top of minimal EC2
#  INSPIRED-BY: - https://www.serverlessguru.com/blog/deploy-serverless-containerized-nodejs-application-on-aws-ecs-fargate
#    TECH-REQS: git, docker & node.js
#######################################################################################################################      
CWD=$(pwd)
export APPSRC='https://github.com/rearc/quest.git'
export APPDIR='/usr/src/rearc'
DEPENDENCIES='git zip unzip jq curl wget'
#######################################################################################################################
# STEP-1: INSTALL UPDATE OS LAYER - SIMPLE - NO HARDENING  
#######################################################################################################################
yum update -y 
yum install $DEPENDENCIES -y 

#######################################################################################################################
# STEP-2: INSTALL Docker & Node Package Manager  
#######################################################################################################################
sudo amazon-linux-extras install docker -y
sudo service docker start
git clone https://github.com/rearc/quest.git
cd quest
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. ~/.nvm/nvm.sh
npm i

#######################################################################################################################
# STEP-3: Wrap everything neatly in a simple dockerfile  
#######################################################################################################################
touch Dockerfile
cat > Dockerfile << EOF
# node base image
FROM node:16
# inject environment variables & copy the suff we pulled from git
ENV SECRET_WORD    TwelveFactor
COPY . .
# setup and installation commands
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash \
    && . ~/.nvm/nvm.sh \
    && nvm install 16 \
    && npm install
# run express server
CMD ["npm", "start"]
EOF

#######################################################################################################################
# STEP-4: Build & Run the App in a Container  
#######################################################################################################################
docker build -t rearc-quest .
docker run -d -p 443:3000 rearc-quest

#######################################################################################################################
# STEP-N: HOUSEKEEPING & CLEANUP
#######################################################################################################################
ln -s /var/log/cloud-init-output.log /home/ec2-user/cloud-init-output.log
cd $CWD
