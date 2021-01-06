FROM klakegg/hugo:0.79.1-ext-ubuntu AS builder

ARG ACEND_HUGO_ENV=default

COPY . /src

RUN hugo --environment ${ACEND_HUGO_ENV} --minify

FROM nginxinc/nginx-unprivileged:alpine

EXPOSE 8080

COPY --from=builder /src/public /usr/share/nginx/html
