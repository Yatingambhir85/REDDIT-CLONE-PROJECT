FROM node:18

WORKDIR /app

COPY package*.json ./

RUN npm i

EXPOSE 3000

COPY . ./

CMD ["npm","run","dev","--host"]   
