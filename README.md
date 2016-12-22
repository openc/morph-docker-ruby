# morph-docker-ruby

A docker container with the ability to wrap scrapers in something useful for
OpenCorporates.

## Development

Make your local changes and then

    docker build --no-cache -t opencorporates/morph-ruby .
    docker run -i -t opencorporates/morph-ruby /bin/bash

## Releasing

Currently, as the images are only used on morph1, we tend only to build them
there, rather than pushing them to a central repository.

Since we started using this system, we set up our own docker repo and build
slave; it's an outstanding task to migrate to that.

Login to the VPN, then:

    ssh openc@morph1
    cd ~/morph-docker-ruby
    git pull --rebase
    docker build --no-cache -t opencorporates/morph-ruby .

`morph-docker-python` depends on this docker image, so you should also build that. Assuming you are still on `morph1`:

    cd ~/morph-docker-python
    docker build --no-cache -t opencorporates/morph-python .
