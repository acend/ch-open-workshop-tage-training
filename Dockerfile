FROM docker.io/floryn90/hugo:0.124.1-ext-ubuntu AS builder

ARG TRAINING_HUGO_ENV=default

COPY . /src

RUN hugo --environment ${TRAINING_HUGO_ENV} --minify

FROM ubuntu:noble AS wkhtmltopdf
RUN apt-get update \
    && apt-get install -y curl \
    && curl -L https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb --output wkhtmltox_0.12.6.1-2.jammy_amd64.deb \
    && ls -la \
    && apt-get install -y /wkhtmltox_0.12.6.1-2.jammy_amd64.deb \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /wkhtmltox_0.12.6.1-2.jammy_amd64.deb

COPY --from=builder /src/public /

RUN wkhtmltopdf --outline-depth 4 --enable-internal-links --enable-local-file-access  ./pdf/index.html /pdf.pdf

FROM nginxinc/nginx-unprivileged:1.27-alpine

EXPOSE 8080

COPY --from=builder /src/public /usr/share/nginx/html
COPY --from=wkhtmltopdf /pdf.pdf /usr/share/nginx/html/pdf/pdf.pdf
