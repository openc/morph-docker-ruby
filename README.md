# morph-docker-ruby

A docker container with the ability to wrap scrapers in something useful for
OpenCorporates.

## Making changes

    docker login
    <edit stuff>
    docker build --no-cache -t opencorporates/morph-ruby .
    docker push opencorporates/morph-ruby

If you want to play with the image interactively:

    docker run -i -t opencorporates/morph-ruby /bin/bash

Currently, as the images are only used on morph1, we tend only to build them
there, rather than pushing them to a central repository.

Since we started using this system, we set up our own docker repo and build
slave; it's an outstanding task to migrate to that.

## Updating the image

1. Login to the VPN
1. `ssh openc@morph1`
1. `cd ~/morph-docker-ruby`
1. `git pull --rebase`
1. `docker build --no-cache -t opencorporates/morph-ruby .`

The last step takes 30-90 minutes.
