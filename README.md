# Cloud Foundry AWS logs BOSH release [![Code Climate](https://codeclimate.com/github/18F/cg-awslogs-boshrelease/badges/gpa.svg)](https://codeclimate.com/github/18F/cg-awslogs-boshrelease)

This BOSH release helps your Cloud Foundry deployment automatically ship audit logs to AWS CloudWatch Logs.

## Development

Development for recent stem cells is on the `bionic` and `jammy` branches.

## Trusty vs. Xenial releases

The development of this release has been forked using Git tags for Trusty
versus Xenial stemcells. Since our previous release for Trusty had been working
fine without issues, we've tagged our Trusty release with a tag of
`trusty-[0-9]+` in order to keep providing any code changes while we transition
our VMs over to the Xenial stemcell.

This means that all changes for Xenial going forward will be on the `master`
branch without any tagging necessary.

If you need to create a Trusty release, please tag the HEAD of the
`master-trusty` branch with the appropriate `trusty-[0-9]+` tag. To see the
latest tags, [click here](https://github.com/18F/cg-awslogs-boshrelease/tags).

### Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
