use Test::More;
use Demo::TE::Parser2;
use Data::Dumper;

my $p = Demo::TE::Parser2->new;

{
    my $re = $p->recognizer;
    my $input = "name";
    my $pos = $re->read(\$input);
    my $v = ${$re->value};
    is_deeply($v, ['name']);
}

done_testing();

