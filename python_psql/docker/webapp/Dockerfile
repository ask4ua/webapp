FROM ubuntu:20.04

RUN apt-get update && apt-get install --no-install-recommends --no-install-suggests -y git python3 python3-pip python3-setuptools python3-dev python3-psycopg2 stress
RUN pip3 install psycopg2 jsonpath-ng requests

ENV DBUSER='DBUSER' DBPASS='DBPASS' DBNAME='DBNAME'
ENV DBHOST='db' DBPORT='5432'

ARG APPDIR='/app'
VOLUME ${APPDIR}
COPY src ${APPDIR}
CMD ["python3","-u","/app/webapp.py"]
