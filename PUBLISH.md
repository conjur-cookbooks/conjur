To publish this cookbook to the https://supermarket.chef.io:

1. Update `version` in `metadata.rb`.
2. Tag and push the tag to GitHub, e.g `git tag v0.3.2 && git push --tags`.
3. Wait until Jenkins builds and tests the cookbook successfully.
4. Publish to the supermarket by running `./publish.sh`. It will pick up the version.
