FROM ubuntu:latest

# Устанавливаем необходимые пакеты
RUN apt-get update && \
    apt-get install -y knockd iptables netcat-traditional curl golang && \
    rm -rf /var/lib/apt/lists/* 

COPY knockd.conf /etc/knockd.conf

COPY banner.sh /etc/banner
COPY bash.bashrc /etc/
COPY entrypoint /etc/entrypoint

COPY main.go /usr/local/bin/server
COPY go.mod main.go /
RUN go mod download
RUN go build -o /usr/local/bin/server main.go
RUN rm /main.go /go.mod

RUN chmod +x /usr/local/bin/server
RUN sed -i 's/START_KNOCKD=0/START_KNOCKD=1/' /etc/default/knockd
RUN rm -f /bin/knock

RUN chmod +x /etc/banner /etc/entrypoint

ENTRYPOINT ["/etc/entrypoint"]
