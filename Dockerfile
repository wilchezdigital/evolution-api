FROM node:20-alpine AS builder

RUN apk update && \
    apk add --no-cache git ffmpeg wget curl bash openssl

WORKDIR /evolution

RUN git clone https://github.com/evolution-foundation/evolution-api.git .

RUN npm install --silent
RUN npx prisma generate --schema=./prisma/postgresql-schema.prisma

WORKDIR /evolution/manager
RUN npm install
RUN npm run build

WORKDIR /evolution

RUN chmod +x ./Docker/scripts/* && dos2unix ./Docker/scripts/*

RUN npm run build

# ---------- FINAL ----------

FROM node:20-alpine AS final

RUN apk update && \
    apk add tzdata ffmpeg bash openssl

ENV TZ=America/Sao_Paulo
ENV DOCKER_ENV=true

WORKDIR /evolution

COPY --from=builder /evolution/package.json ./package.json
COPY --from=builder /evolution/package-lock.json ./package-lock.json
COPY --from=builder /evolution/node_modules ./node_modules
COPY --from=builder /evolution/dist ./dist
COPY --from=builder /evolution/prisma ./prisma
COPY --from=builder /evolution/public ./public
COPY --from=builder /evolution/manager ./manager
COPY --from=builder /evolution/Docker ./Docker
COPY --from=builder /evolution/runWithProvider.js ./runWithProvider.js

EXPOSE 8080

ENTRYPOINT ["npm", "run", "start:prod"]
