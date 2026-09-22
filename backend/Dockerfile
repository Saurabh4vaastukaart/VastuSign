FROM node:24-alpine

WORKDIR /app
COPY package.json server.mjs ./

ENV PORT=8787
ENV DATABASE_PATH=/data/vastusign.sqlite
VOLUME ["/data"]
EXPOSE 8787

CMD ["node", "server.mjs"]
