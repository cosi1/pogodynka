FROM openanalytics/r-base

RUN apt-get update &&\
    apt-get install git
RUN cd /tmp && git clone https://github.com/cosi1/pogodynka.git

COPY setup.sh /tmp/setup.sh
RUN /tmp/setup.sh

CMD ["R", "-e", "'shiny::runApp(\"/tmp/pogodynka\", host = \"0.0.0.0\", port = 3838L, launch.browser = FALSE)'"]

