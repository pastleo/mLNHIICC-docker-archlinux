FROM ubuntu:20.04

RUN ln -fs /usr/share/zoneinfo/Asia/Taipei /etc/localtime
RUN apt-get update && apt-get install --no-install-recommends -y wget unzip pcscd pcsc-tools libc6 openssl locales tzdata psmisc
RUN locale-gen zh_TW zh_TW.UTF-8 zh_CN zh_CN.UTF-8 en

# MOICA內政部憑證管理中心-跨平台網頁元件 - http://moica.nat.gov.tw/rac_plugin.html
RUN wget -O /dev/stdout http://moica.nat.gov.tw/download/File/HiPKILocalSignServer/linux/HiPKILocalSignServerApp.tar.gz | tar zxvf - -C /usr/local

# workarounds for mLNHIICC_Setup:
#   1. since it is already root, fake sudo command
COPY fake-sudo.sh /usr/bin/sudo
RUN chmod 755 /usr/bin/sudo
#   2. make libssl1.0.0 installable
RUN echo 'deb http://archive.ubuntu.com/ubuntu/ bionic main restricted' >> /etc/apt/sources.list && apt-get update

# Setup for reading Health Insurance ID Card
# 健保卡網路服務註冊－環境檢測(Chrome、FireFox、Opera、Edge) - https://cloudicweb.nhi.gov.tw/cloudic/system/SMC/mEventesting.htm
RUN wget --no-check-certificate -O /tmp/mLNHIICC_Setup.Ubuntu.zip https://cloudicweb.nhi.gov.tw/cloudic/system/SMC/mLNHIICC_Setup.Ubuntu.zip \
 && unzip -d /tmp /tmp/mLNHIICC_Setup.Ubuntu.zip \
 && mkdir -p /tmp/mLNHIICC_Setup \
 && tar zxvf $(ls /tmp/*.tar.gz) -C /tmp/mLNHIICC_Setup \
 && cd /tmp/mLNHIICC_Setup/* && ./Install

RUN rm -rf /tmp/* /var/tmp/*

ADD start.sh /usr/local/bin
RUN chmod 755 /usr/local/bin/start.sh

# Run the final script
CMD /usr/local/bin/start.sh
