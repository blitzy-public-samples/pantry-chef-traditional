FROM node:20-alpine

USER node

RUN mkdir -p /home/node/app

WORKDIR /home/node/app

ENV HOST=0.0.0.0 PORT=3000

EXPOSE ${PORT}

CMD npm i && npm run dev
