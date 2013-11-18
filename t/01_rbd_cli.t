#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use Test::More;
use Test::Output;

use lib 'lib';

BEGIN { use_ok 'Ceph::RBD::CLI' }

my $image_name = 'perl_rbd_test';
my $snap_name = 'perl_rbd_snap';
my $pool_name = 'perl_cli_test';

my $rbd = new_ok 'Ceph::RBD::CLI' => [ 
                        'pool_name'     => $pool_name, 
                        'image_name'    => $image_name,
                        'snap_name'     => $snap_name,
                    ];

# verify we can create and remove an image
stdout_is { map { say } $rbd->ls } "", "Verify no images in $pool_name";
stdout_is { $rbd->image_create(undef, 5120); } "", "Create image in $pool_name";
stderr_like { $rbd->image_create(undef, 5120) } qr/rbd: create error:/, "Can't create image that exists";
stdout_is { map { say } $rbd->ls } "perl_rbd_test\n", "Image exists";
stderr_like { $rbd->image_delete } qr/done/, "Remove Image";
stdout_is { map { say } $rbd->ls } "", "Verify image has been removed";

# Create snapshot
is $rbd->image_exists, 0, "->image_exists image doesn't exist";
stdout_is { $rbd->image_create(undef, 5120); } "", "Image Create";
stdout_is { $rbd->image_create($image_name . 1 , 5120); } "", "Image Create";
is $rbd->image_exists, 1, "->image_exists image exists";

stdout_is { $rbd->snap_create } "", "Snapshot Created";
stdout_is { $rbd->snap_delete } "", "Snapshot Deleted";
stdout_is { $rbd->snap_create } "", "Snapshot Created";
stdout_like { print $rbd->snap_ls } qr/\d+ perl_rbd_snap \d+ MB/, "List snapshots";
stderr_like { $rbd->image_delete } qr/failed/, "Image not removed, it has snapshots";
stderr_like { $rbd->snap_purge }  qr/done/, "Snapshots purged";
stderr_like { $rbd->image_delete } qr/done/, "Remove Image";
stderr_like { $rbd->image_delete($image_name . 1) } qr/done/, "Remove Image";

done_testing;
