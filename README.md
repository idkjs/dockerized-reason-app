# Deploying a ReasonReact Create-React-App Docker Image with Digital Ocean

Thanks to [@ncthrbt](https://twitter.com/@ncthbrt) for the assists on [reason's discord channel](https://discordapp.com/channels/235176658175262720/235176658175262720).
Thanks to [@shaneOsbourne](https://twitter.com/shaneosbourne?lang=en)'s for sharing his [article](https://medium.com/@shakyShane/lets-talk-about-docker-artifacts-27454560384f)

The take away that I needed was about build the image locally, pushing to some docker repository or git and building the image from the dockerfile AFTER you created the image locally.

## Running

I got this to run by pushing to hub.docker.com then pulling into the Digital Ocean container then:

```
$ docker pull idkjs/dockerbuild
$ docker run -p 8080:80 idkjs/dockerized-reason-app
```

The image will running at http://droplet.ip.adddress:8080.

## The Dockerfile

This is a multistage build which is exposing port 80 on the image container to be available. When we run the container with `docker run -p 8080:80 idkjs/dockerized-reason-app` we are mapping the digitalocean container's outgoing 8080 port to image containers 80 port so anything that hits http;//ip.address:8080 while be accessing 80 on the running container. Not sure about the terminology.

```Dockerfile
FROM node:9.8-slim as build-deps
# we need this to get `make` commands needed by bucklescript/reason, thanks @ncthbrt
RUN apt-get update && apt-get install --no-install-recommends -yq make g++
# add this because `react-scripts build` kept failing even though bs-platform was
# installed as a dev dependency. Seems like react-scripts is looking in global scope
# for it.
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
```

## .dockerignore

Be sure you are adding a `.dockerignore` file. The Dockerfile `COPY . ./` step is otherwise copying over `.merlin` which seems to slow down build and re-builds.

## Recap

Make sure you have run `yarn install` once if you are copying over `yarn.lock` in your Dockerfile.
Test locally with exact commands you will running in the container. The commands are the same in both environments assuming there are no enviromental variable issues.

```
# build the image
$ docker build . -t idkjs/dockerized-reason-app

# run the image on local machine to test
$ docker run -p 8080:80 idkjs/dockerized-reason-app
```

If this works, you should be able to pull the image and run it in your digital ocean container with:

```
$ docker pull idkjs/dockerized-reason-app
$ docker run -p 8080:80 idkjs/dockerized-reason-app
```

Image on hub.docker.com: https://hub.docker.com/r/idkjs/dockerized-reason-app/
