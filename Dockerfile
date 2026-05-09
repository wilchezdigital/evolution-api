FROM node:20-alpine

WORKDIR /app

RUN apk add --no-cache git ffmpeg bash openssl

RUN git clone https://github.com/evolution-foundation/evolution-api.git .

RUN npm install
RUN npx prisma generate
RUN npm run build

EXPOSE 8080

CMD ["npm", "run", "start:prod"]
