To publish this cookbook to the https://supermarket.chef.io:

1. Update `version` in `metadata.rb`.
2. Run `rake package`. Make sure to commit the Berksfile.lock if it's changed.
2. Tag and push the tag to GitHub, e.g `git tag v0.3.2 && git push --tags`.
3. Wait until Jenkins builds and tests the cookbook successfully.
4. Publish to the supermarket by running `./publish.sh`. It will pick up the version.
5. Run `rake package` again to create a tarball with vendored cookbooks, eg. `conjur-v0.4.0.tar.gz`
6. Create the release at https://github.com/conjur-cookbooks/conjur/releases and upload the tarball.
