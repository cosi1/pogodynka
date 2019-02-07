FROM conoria/alpine-r

COPY setup.sh /tmp/setup.sh
RUN /tmp/setup.sh
RUN mkdir /opt/app
COPY api_key.txt /opt/app/api_key.txt
COPY *.R /opt/app/


CMD ["R", "-e", "shiny::runApp(\"/opt/app\", host = \"0.0.0.0\", port = 3838L, launch.browser = FALSE)"]

