FROM python:3.7.7-alpine3.11
EXPOSE 8000
WORKDIR /deploy
COPY /docs /deploy/docs
COPY mkdocs.yml /deploy
RUN apk add build-base && pip install mkdocs && pip install mkdocs-material
ENTRYPOINT ["mkdocs","serve","-a","0.0.0.0:8000"]