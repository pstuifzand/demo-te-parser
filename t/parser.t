use Test::More;
use Demo::TE::Parser;
use Data::Dumper;

my $p = Demo::TE::Parser->new;

#my $template = $p->parse("hello");
#print Dumper($template);
#is($template->[0], 'hello');

print STDERR $Marpa::R2::VERSION, "\n";

my $template = $p->parse("{{name}}");
print Dumper($template);
is_deeply($template->[0], ['{{', 'name', '}}' ]);

#my $template = $p->parse("hello {{name}}");
#is($template->[0], 'hello ');
#print Dumper($template);
#is_deeply($template->[1], ['{{','name','}}']);

done_testing();

