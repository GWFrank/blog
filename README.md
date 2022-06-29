# Blog

This is the repository for my blog hosted on github page. Head over [here](https://gwfrank.github.io/blog) to check it out!

To run this blog locally using docker, follow [this guide](https://tianqi.name/jekyll-TeXt-theme/docs/en/quick-start) to setup:

```shell
# Generate Gemfile.lock
docker run --rm -v "$PWD":/srv/jekyll -w /srv/jekyll ruby:2.7 bundle install
# Build image docker_blog
docker-compose -f ./docker/docker-compose.build-image.yml build
# Create container
docker-compose -f ./docker/docker-compose.default.yml up
```

Then visit [localhost:4000/blog/](http://localhost:4000/blog/).


