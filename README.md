A docker container with the ability to wrap scrapers in something
useful for OpenCorporates.

If you want to change it:

    docker login
    <edit stuff>
    docker build --no-cache=true -t opencorporates/morph-ruby .
    docker push opencorporates/morph-ruby

If you want to play with the image interactively:

    docker run -i -t opencorporates/morph-ruby /bin/bash
