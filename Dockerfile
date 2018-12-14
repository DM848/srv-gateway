FROM dm848/consul-nginx:v1

# COPY ContainerPilot configuration
COPY containerpilot.json5 /etc/containerpilot.json5
ENV CONTAINERPILOT=/etc/containerpilot.json5

WORKDIR /router
RUN mkdir /router/templates
COPY templates/server.conf.ctmpl /router/templates
#COPY config.hcl /router
COPY start-nginx-router.sh /router
RUN mv start-nginx-router.sh /bin/start-nginx-router

#VOLUME /etc/nginx/conf.d/
RUN rm /etc/nginx/conf.d/default.conf
RUN ls /etc/nginx/conf.d

# expose http port
EXPOSE 80:80
CMD ["/bin/containerpilot"]