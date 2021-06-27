# Blog

This is the repository for my blog hosted on github page. Head over [here](https://gwfrank.github.io/blog) to check it out!

To run this blog locally using docker, follow [this  guide](https://tianqi.name/jekyll-TeXt-theme/docs/en/quick-start) to setup:
```
docker run --rm -v "$PWD":/usr/src/app -w /usr/src/app ruby:2.7 bundle install
docker-compose -f ./docker/docker-compose.build-image.yml build
docker-compose -f ./docker/docker-compose.default.yml up
```

Then visit [localhost:4000/blog](localhost:4000/blog).
