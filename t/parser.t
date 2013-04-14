use Test::More;
use Demo::TE::Parser;
use Data::Dumper;

my $p = Demo::TE::Parser->new;

my $template = $p->parse("hello");
is_deeply($template->[0], [['hello']]);

my $template = $p->parse("{{name}}");
my $expected = [ '{{', 'test', '}}' ];
is_deeply($template->[0], [$expected]);

my $template = $p->parse("hello {{name}}");
is_deeply($template->[0], [[ 'hello ' ]]);
is_deeply($template->[1], [['{{','test','}}']]);

done_testing();

