# syntax=docker/dockerfile:1

FROM node:lts-bookworm AS build-react

WORKDIR /home/www-data/app

COPY frontend/package.json /home/www-data/app/package.json
COPY frontend/package-lock.json /home/www-data/app/package-lock.json

RUN npm ci

COPY frontend /home/www-data/app

ENV CI=true

RUN npm run build

###################
FROM ozyviking/python-nginx:3.11 AS build-python

WORKDIR /home/www-data/app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

COPY pyproject.toml /home/www-data/app/
COPY README.md /home/www-data/app/
RUN <<EOF
python -m pip install --upgrade pip
python -m pip install poetry
poetry config virtualenvs.in-project true
poetry install
EOF

###################
FROM ozyviking/python-nginx:3.11 AS final

LABEL org.opencontainers.image.authors="Zack Hankin <admin@hankin.io>"

WORKDIR /home/www-data/app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=8000

COPY --from=build-react --chown=www-data:www-data /home/www-data/app/build /home/www-data/app/build
COPY --from=build-python --chown=www-data:www-data /home/www-data/app/.venv /home/www-data/app/.venv
COPY --chown=www-data:www-data backend/ /home/www-data/app/
COPY --chown=www-data:www-data gunicorn/nginx.conf /etc/nginx/nginx.conf
COPY --chown=www-data:www-data gunicorn/gunicorn* /etc/gunicorn/
COPY --chown=www-data:www-data --chmod=777 scripts/ /docker-entrypoint.d/

ENV PATH=/docker-entrypoint.d:/home/www-data/app:/home/www-data/app/.venv/bin:${PATH}

RUN ln -s /etc/gunicorn/gunicorn.sh /etc/init.d/gunicorn

RUN <<EOF
mkdir templates
mkdir static
mv /home/www-data/app/build/index.html /home/www-data/app/templates/index.html
mv /home/www-data/app/build/static/* /home/www-data/app/build
rm -r /home/www-data/app/build/static
chown -R root:root /etc/gunicorn
chown -R www-data:www-data . 
chmod -R o-rwx /etc/gunicorn
EOF

RUN <<EOF
manage.py makemigrations
manage.py migrate
manage.py collectstatic
EOF

HEALTHCHECK --retries=3 CMD service gunicorn status
SHELL ["bash", "-c"]
EXPOSE 80
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD [ "nginx", "-g", "daemon off;" ]
