FROM python:2.7-slim

# Set the working directory to /home
WORKDIR /home

# Copy the current directory contents into the container at /home
COPY . /home

RUN apt-get update \
  && apt-get -y install sudo \
  && apt-get install -y wget

RUN sudo apt-get install git mongodb libffi-dev build-essential python-dev python-pip python-pil python-sqlalchemy python-bson python-dpkt python-jinja2 python-magic python-pymongo python-gridfs python-libvirt python-bottle python-pefile python-chardet -y

# RUN sudo wget https://github.com/ssdeep-project/ssdeep/releases/download/release-2.14.1/ssdeep-2.14.1.tar.gz > /tmp/ssdeep-2.14.1.tar.gz

RUN sudo apt-get install g++ python-dev

RUN cd /tmp \
  && wget https://github.com/ssdeep-project/ssdeep/releases/download/release-2.4/ssdeep-2.4.tar.gz \
  && tar xzvf ssdeep-2.4.tar.gz \
  && cd /tmp/ssdeep-2.4 \
  && ./configure \
  && make \
  && sudo make install 

RUN sudo apt-get install build-essential git libpcre3 libpcre3-dev libpcre++-dev

RUN cd /opt \
  && git clone https://github.com/kbandla/pydeep.git \
  && cd /opt/pydeep \
  && python setup.py build \
  && sudo python setup.py install

RUN sudo apt-get install libtool -y

RUN sudo apt-get install automake -y

# RUN cd /opt \
#   && git clone https://github.com/plusvic/yara/ \
#   && cd /opt/yara \
#   && sudo ln -s /usr/bin/aclocal-1.11 /usr/bin/aclocal-1.12 \
#   && ./bootstrap.sh \
#   && ./configure \
#   && sudo make \
#   && sudo make install \
#   && cd /opt/yara/yara-python \
#   && python setup.py build \
#   && sudo python setup.py install

RUN sudo apt-get install autoconf libjansson-dev libmagic-dev libssl-dev -y

RUN pip install yara-python
# RUN cd /opt \
#   && wget https://github.com/plusvic/yara/archive/v3.4.0.tar.gz -O yara.tar.gz \
#   && tar -zxf yara.tar.gz \
#   && cd /opt/yara \
#   && ./bootstrap.sh \
#   && ./configure --with-crypto --enable-cuckoo --enable-magic \
#   && make \
#   && sudo make install \
#   && cd /opt/yara-3.4.0/yara-python \
#   && python setup.py build \
#   && sudo python setup.py install

RUN cd /opt \ 
&& sudo apt-get install libcap2-bin -y \
&& sudo apt-get install tcpdump -y \
&& sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump

RUN pip install openpyxl \
  && pip install ujson \
  && pip install pycrypto \
  && pip install distorm3 \
  && pip install pytz 

RUN cd /opt \
  && git clone https://github.com/volatilityfoundation/volatility.git \
  && cd /opt/volatility \
  && python setup.py build \
  && python setup.py install

RUN cd /opt \
  && mkdir /cuckoo \
  && cd /opt/cuckoo \
  && adduser -D -h /cuckoo cuckoo \
  && export PIP_NO_CACHE_DIR=off \
  && export PIP_DISABLE_PIP_VERSION_CHECK=on \
  && sudo pip install -U pip setuptools -y \
  && sudo pip install -U cuckoo -y \
  && sudo mkdir /home/cuckoo \
  && cd /home/cuckoo \
  && sudo chown cuckoo:cuckoo /home/cuckoo \
  && cuckoo --cwd /home/cuckoo

COPY conf /home/cuckoo

RUN cd /home/cuckoo \
  && cuckoo -d \
  && cuckoo community 