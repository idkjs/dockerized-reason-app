FROM node:9.8-slim as build-deps
RUN apt-get update && apt-get install --no-install-recommends -yq make g++
RUN yarn global add bs-platform
WORKDIR /usr/src/app
COPY package.json yarn.lock ./
RUN yarn
COPY . ./
RUN yarn build

FROM nginx:1.13.12-alpine
COPY --from=build-deps /usr/src/app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

