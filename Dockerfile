#Grab the latest alpine image
FROM alpine:latest

# Install python and pip
RUN apk add --no-cache --update python3 py3-pip bash
ADD ./webapp/requirements.txt /tmp/requirements.txt

# Install dependencies
# create venv before
RUN python3 -m venv .env
RUN source .env/bin/activate
# python3 -m pip install -r requirements.txt
# RUN pip install --break-system-packages -r /tmp/requirements.txt

# il existe une bonne documentation sur la correction du bug sur pip à l'url suivante
# https://github.com/nodejs/docker-node/issues/2010
RUN pip install --break-system-packages --no-cache-dir -q -r /tmp/requirements.txt

# Add our code
ADD ./webapp /opt/webapp/
WORKDIR /opt/webapp

# Expose is NOT supported by Heroku
# EXPOSE 5000 		

# Run the image as a non-root user
RUN adduser -D myuser
USER myuser

# Run the app.  CMD is required to run on Heroku
# $PORT is set by Heroku			
CMD gunicorn --bind 0.0.0.0:$PORT wsgi 

