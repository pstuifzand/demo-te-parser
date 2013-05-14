use Test::More;
use Demo::TE::Parser2;
use Data::Dumper;

my $p = Demo::TE::Parser2->new;

{
    my $re = $p->recognizer;
    my $input = "name}}";
    my $pos = $re->read(\$input);
    $re->lexeme_read('template_end', $pos, 2, '}}');
    my $v = ${$re->value};
    is($v, 'name');
}

done_testing();

