package Demo::TE::Parser;
use 5.10.0;
use Marpa::R2 '2.051_009';
use Demo::TE::Parser2;
use Data::Dumper;

sub new {
    my $class = shift;
    my $grammar = Marpa::R2::Scanless::G->new({
        default_action => '::array',

        source => \<<'GRAMMAR',
:start        ::= template

template      ::= parts*

parts         ::= literal
                | template_bits

template_bits ::= template_start expression template_end

literal       ::= literal_text

:lexeme ~ <template_start> pause => after

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
    my $pos = $re->read(\$input);
    die if $pos < 0;

    my ($start, $length) = $re->pause_span;

    if ($pos < length $input) {
        my $p2 = Demo::TE::Parser2->new;
        my $re2 = $p2->recognizer($input, $pos, -1);
        my $end = $re2->read(\$input, $pos, -1);
        my $tmpval = ${$re2->value};
        my ($is, $il) = $re2->pause_span;
        say "$is,$il";
        if (not $re->lexeme_read('expression', $pos, $end-$pos, 'test')) {
	    die $re->show_progress;
	}
        if ($end < length $input) {
            $re->resume($end, -1);
	}
    }
    my $v = $re->value;
    return $$v;
}

1;
