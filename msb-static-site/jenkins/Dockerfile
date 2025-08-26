FROM jenkins/jenkins:lts

USER root

# Temel araçlar ve docker client yükle
RUN apt-get update && \
    apt-get install -y docker.io wget curl git iproute2 iputils-ping ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ÖRNEK: yq binary dosyasını wget ile indir, çalıştırılabilir yap ve /usr/local/bin'e koy
RUN wget -O /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64" && \
    chmod +x /usr/local/bin/yq

# İstersen başka bir dosyayı da wget ile indirebilirsin:
# RUN wget -O /usr/local/bin/deneme.sh https://raw.githubusercontent.com/.../deneme.sh && chmod +x /usr/local/bin/deneme.sh

USER jenkins
