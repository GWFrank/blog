# Blog

This is the repository for my blog hosted on github page. Head over [here](https://gwfrank.github.io/blog) to check it out!

To run this blog locally using docker, follow this:

```shell
# Re-generate Gemfile.lock if needed
docker run --rm -v "$PWD":/srv/jekyll -w /srv/jekyll ruby:3.0 bundle install
# Build image jekyll-server
docker-compose build
# Create and run the container
docker-compose up
```

Then visit [localhost:4000/blog/](http://localhost:4000/blog/).
