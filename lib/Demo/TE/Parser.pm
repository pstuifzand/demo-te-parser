package Demo::TE::Parser;
use 5.10.0;
use Marpa::R2 '2.053_010';
use Demo::TE::Parser2;
use Data::Dumper;

sub new {
    my $class = shift;

    my $grammar = Marpa::R2::Scanless::G->new({
        default_action => '::array',
        bless_package => 'Demo::TE::Parser::Node',
        action_object => __PACKAGE__,

        source => \<<'GRAMMAR',
:start        ::= template

template      ::= parts                 action => ::first
                #| parts literal_at_end  action => append

#literal_at_end ::= literal_e_1          bless => literal
                 #| literal_e_2          bless => literal

parts         ::= part*

part          ::= template_bits       action => ::first
                | literal             action => ::first

literal       ::= literal_text                            bless => literal
template_bits ::= (template_start) expression (template_end)          bless => template

:lexeme         ~ template_start            pause => after

template_start ~ '{{'
template_end   ~ '}}'

expression     ~ [\w]+

literal_text   ~ literal_p+

literal_p      ~ literal_0
#               | literal_1
#               | literal_2

literal_0      ~ [^{}]+
#literal_1      ~ '{' [^{]
#literal_2      ~ '}' [^}]

#literal_e_1    ~ '{'
#literal_e_2    ~ '}'

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

    my $p2 = Demo::TE::Parser2->new();

    while ($pos < length $input) {
        my $re2 = $p2->recognizer;
        my $prev_pos=$pos;
        my $end = index $input, "}}", $pos;
        my $l2 = $end;
        $pos = $re2->read(\$input, $pos, $end-$pos);
        while ($pos < $l2) {
            $pos = $re2->resume($pos, $l2-$pos);
        }
        my $v = ${$re2->value};
        $re->lexeme_read('expression', $prev_pos, $pos-$prev_pos, $v);
        $re->lexeme_read('template_end', $pos, 2);
        $pos += 2;
        $pos = $re->resume($pos);
    }

    my $v = $re->value;
    return $$v;
}

sub append {
    my ($self, $a, $b) = @_;
    return [@$a,$b];
}

1;
