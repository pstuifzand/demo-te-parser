use Test::More;
use Demo::TE::Parser;
use Data::Dumper;

my $p = Demo::TE::Parser->new;

# just a literal
{
    my $template = $p->parse("hello");
    is_deeply($template->[0], ['hello']);
}

# just a tag
{
    my $template = $p->parse("{{aaaaaaaaaa}}");
    my $expected = [ '{{', ['aaaaaaaaaa' ], '}}' ];
    is_deeply($template->[0], $expected);
}

# just a tag
{
    my $template = $p->parse("{{page.title}}");
    my $expected = [ '{{', [ 'page', [ 'title' ] ], '}}' ];
    is_deeply($template->[0], $expected);
}

done_testing();
exit;

# literal followed by tag
{
    my $template = $p->parse("hello {{name}}");
    print STDERR Dumper($template);
    is_deeply($template->[0], [ 'hello ' ]);
    is_deeply($template->[1], [ '{{', 'name', '}}' ]);
}


# literal with partial start marker
{
    my $template = $p->parse("hello {x");
    is(@$template, 1);
    is_deeply($template->[0], [ 'hello {x' ]);
    #is_deeply($template->[1], [ '{x' ]);
}

# literal with partial start marker at the end of the template
{
    my $template = $p->parse("hello {");
    is(@$template, 1);
    is_deeply($template->[0], [ 'hello {' ]);
    #is_deeply($template->[1], [ '{' ]);
}

done_testing();

