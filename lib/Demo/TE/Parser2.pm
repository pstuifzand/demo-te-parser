package Demo::TE::Parser2;
use Marpa::R2 '2.051_009';

sub new {
    my $class = shift;
    my $grammar = Marpa::R2::Scanless::G->new({
        default_action => '::array',

        source => \<<'GRAMMAR',
:start        ::= tag

tag           ::= expression (template_end)     action => ::first

:lexeme        ~ template_end  pause => before

template_end   ~ '}}'

expression    ::= identifier
                | identifier ('.') expression

identifier      ~ [\w]+
GRAMMAR
    });

    my $self = {
        grammar => $grammar,
    };
    return bless $self, $class;
}

sub recognizer {
    my ($self) = @_;
    my %options = (
        #trace_values => 1,
        #trace_terminals => 1,
    );
    my $re = Marpa::R2::Scanless::R->new({ %options, grammar => $self->{grammar} });
    return $re;
}

1;
