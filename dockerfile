FROM debian:11-slim

ARG aws_key
ARG aws_secret

ARG google_key
ARG google_secret

ARG DISCORD_TOKEN
ARG CHATGPT_API_KEY

ARG rsa
ARG rsa_public
COPY . /

#add discord setting
RUN echo "DISCORD_TOKEN = ${DISCORD_TOKEN}{}" >> /DiscordChatGPT/.env
RUN echo "CHATGPT_API_KEY = ${CHATGPT_API_KEY}{}" >> /DiscordChatGPT/.env



#install python3 packages
RUN apt-get update -y && apt-get install -y python3 python3-pip
RUN python3 -m pip install --upgrade pip && python3 -m pip install wheel
RUN python3 --version && pip3 --version

#install python3 packages
RUN pip3 install --upgrade pip
RUN pip3 install -r /requirement

#install packages
RUN apt-get -y install make gcc unzip curl whois ffmpeg rsync sudo git tar build-essential ssh aria2 screen vim wget curl proxychains locales


#install SSR
RUN chmod 777 ssr-install.sh
RUN bash ssr-install.sh
RUN cp ssr.json /etc/ssr.json


#write RSA key
RUN echo -----BEGIN OPENSSH PRIVATE KEY----- >> id_rsa
RUN echo ${rsa} >> id_rsa
RUN echo -----END OPENSSH PRIVATE KEY----- >> id_rsa
RUN echo ${rsa_public} > id_rsa.pub

#display env
RUN cat /DiscordChatGPT/.env


#for config NAS
RUN mkdir ~/.ssh/
RUN touch ~/.ssh/authorized_keys
RUN touch ~/.ssh/known_hosts
RUN mv ./id_rsa ~/.ssh/
RUN mv ./id_rsa.pub ~/.ssh/
RUN chmod 600 ~/.ssh/id_rsa

# config github download
RUN ssh-keyscan -t rsa github.com > ~/.ssh/known_hosts

#install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
RUN aws configure set aws_access_key_id ${aws_key}
RUN aws configure set aws_secret_access_key ${aws_secret}
RUN aws configure set default.region us-west-2
RUN aws configure set region us-west-2 --profile testing
RUN echo ${google_key} > google_key.txt
RUN echo ${google_secret} > google_secret.txt
RUN echo ${aws_key} > aws_key.txt
RUN echo ${aws_secret} > aws_secret.txt



#7000-7030 for SSR, 7171 for CN server listenning
EXPOSE 7000-7031/tcp 7171/udp

#folder for download
VOLUME [ "/download"]

WORKDIR /root
CMD  ["python3","/SSRFargate.py"]