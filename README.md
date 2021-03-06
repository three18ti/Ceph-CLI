[![GitHub version](https://badge.fury.io/gh/three18ti%2FCeph-CLI.svg)](http://badge.fury.io/gh/three18ti%2FCeph-CLI)
[![Build Status](https://travis-ci.org/three18ti/Ceph-CLI.svg?branch=master)](https://travis-ci.org/three18ti/Ceph-CLI)

This is a quick hack because I need a Perl interface to Ceph.

You should really be using Ceph::RADOS, but it's incomplete at the moment and taking longer than I expected to extend.

See the t/ directory for example usage.  The tests assume a pool name of "perl_cli_test".

You can create the test pool by running

    ceph osd pool create perl_cli_test 8

The module itself assumes a default pool of "libvirt-pool", this can be overridden at time of instantiation with the "pool_name" parameter.

    #!/usr/bin/env perl
    use 5.010;
    use strict;
    use warnings;
    
    my $rbd = Ceph::RBD::CLI->new(
        pool_name   => 'libvirt-pool',
        image_name  => 'rbd_image_name',
        snap_name   => 'rbd_snapshot',
        image_size  => '5120',
    );
    
    say "Image doesn't exist" if $rbd->image_exists;
    $rbd->image_create;
    say "Image exists" if $rbd->image_exists;
    map { say } $rbd->ls;
    $rbd->make_parent;
    
    # delete everything
    $rbd->snap_unprotect
    $rbd->snap_purge
    $rbd->image_delete

    # you can override setting by passing the at sub call
    $rbd->image_create(undef, 4096)


