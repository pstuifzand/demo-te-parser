package Demo::TE::Parser;
use 5.10.0;
use Marpa::R2 '2.051_008';
use Demo::TE::Parser2;
use Data::Dumper;

sub new {
    my $class = shift;
    my $grammar = Marpa::R2::Scanless::G->new({
        default_action => '::array',

        source => \<<'GRAMMAR',
:start        ::= template

template      ::= parts*

parts         ::= literal               action => ::first
                | template_bits         action => ::first

template_bits ::= template_start expression template_end

literal       ::= literal_text          action => ::first

:lexeme ~ <template_start> pause => before

template_start ~ '{{'
template_end   ~ '}}'

expression     ~ [\w]+

literal_text   ~ literal_0 | literal_1 | literal_2

literal_0      ~ [^{}]+
literal_1      ~ [{] [^{]
literal_2      ~ [}] [^}]

GRAMMAR

    });

    my $self = {
        grammar => $grammar,
    };
    return bless $self, $class;
}

sub parse {
    my ($self, $input) = @_;
    my %options = (
        #trace_values => 1,
        #trace_terminals => 1,
    );

    my $re = Marpa::R2::Scanless::R->new({ %options, grammar => $self->{grammar} });
    $re->read(\$input);

    my ($start, $length) = $re->pause_span;

    if (defined $start && defined $length && $start+$length < length $input) {
        my $p2 = Demo::TE::Parser2->new;
        my $re2 = $p2->recognizer($input, $start+$length, -1);
        my $end = $re2->read(\$input, $start+$length, -1);
        my $tmpval = ${$re2->value};
        my ($is, $il) = $re2->pause_span;
        say "$is,$il";
        #$re->lexeme_read('expression', $is, $il, 'test');
        #if ($is+$il < length $input) {
            $re->resume($is,-1);
            #}
    }
    my $v = $re->value;
    return $$v;
}

1;
