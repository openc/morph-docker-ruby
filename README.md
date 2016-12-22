# morph-docker-ruby

A docker container with the ability to wrap scrapers in something useful for
OpenCorporates.

## Development

Make your local changes and then

    docker build --no-cache -t opencorporates/morph-ruby .
    docker run -i -t opencorporates/morph-ruby /bin/bash

## Releasing

Login to the VPN, then:

    ssh openc@morph1
    cd ~/morph-docker-ruby
    git pull --rebase
    docker build --no-cache -t docker-registry.opencorporates.com/opencorporates/morph-ruby .
    docker push docker-registry.opencorporates.com/opencorporates/morph-ruby

`morph-docker-python` depends on this docker image, so you should also build that. See the README in that repo.
