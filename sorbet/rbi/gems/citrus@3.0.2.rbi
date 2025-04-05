# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `citrus` gem.
# Please instead update this file by running `bin/tapioca gem citrus`.


# Citrus is a compact and powerful parsing library for Ruby that combines the
# elegance and expressiveness of the language with the simplicity and power of
# parsing expressions.
#
# http://mjackson.github.io/citrus
#
# source://citrus//lib/citrus/version.rb#1
module Citrus
  class << self
    # Returns a map of paths of files that have been loaded via #load to the
    # result of #eval on the code in that file.
    #
    # Note: These paths are not absolute unless you pass an absolute path to
    # #load. That means that if you change the working directory and try to
    # #require the same file with a different relative path, it will be loaded
    # twice.
    #
    # source://citrus//lib/citrus.rb#29
    def cache; end

    # Evaluates the given Citrus parsing expression grammar +code+ and returns an
    # array of any grammar modules that are created. Accepts the same +options+ as
    # GrammarMethods#parse.
    #
    #     Citrus.eval(<<CITRUS)
    #     grammar MyGrammar
    #       rule abc
    #         "abc"
    #       end
    #     end
    #     CITRUS
    #     # => [MyGrammar]
    #
    # source://citrus//lib/citrus.rb#46
    def eval(code, options = T.unsafe(nil)); end

    # Loads the grammar(s) from the given +file+. Accepts the same +options+ as
    # #eval, plus the following:
    #
    # force::   Normally this method will not reload a file that is already in
    #           the #cache. However, if this option is +true+ the file will be
    #           loaded, regardless of whether or not it is in the cache. Defaults
    #           to +false+.
    #
    #     Citrus.load('mygrammar')
    #     # => [MyGrammar]
    #
    # source://citrus//lib/citrus.rb#71
    def load(file, options = T.unsafe(nil)); end

    # Searches the <tt>$LOAD_PATH</tt> for a +file+ with the .citrus suffix and
    # attempts to load it via #load. Returns the path to the file that was loaded
    # on success, +nil+ on failure. Accepts the same +options+ as #load.
    #
    #     path = Citrus.require('mygrammar')
    #     # => "/path/to/mygrammar.citrus"
    #     Citrus.cache[path]
    #     # => [MyGrammar]
    #
    # source://citrus//lib/citrus.rb#96
    def require(file, options = T.unsafe(nil)); end

    # Evaluates the given expression and creates a new Rule object from it.
    # Accepts the same +options+ as #eval.
    #
    #     Citrus.rule('"a" | "b"')
    #     # => #<Citrus::Rule: ... >
    #
    # source://citrus//lib/citrus.rb#56
    def rule(expr, options = T.unsafe(nil)); end

    # Returns the current version of Citrus as a string.
    #
    # source://citrus//lib/citrus/version.rb#6
    def version; end
  end
end

# An Alias is a Proxy for a rule in the same grammar. It is used in rule
# definitions when a rule calls some other rule by name. The Citrus notation
# is simply the name of another rule without any other punctuation, e.g.:
#
#     name
#
# source://citrus//lib/citrus.rb#809
class Citrus::Alias
  include ::Citrus::Rule
  include ::Citrus::Proxy

  # Returns the Citrus notation of this rule as a string.
  #
  # source://citrus//lib/citrus.rb#813
  def to_citrus; end

  private

  # Searches this proxy's grammar and any included grammars for a rule with
  # this proxy's #rule_name. Raises an error if one cannot be found.
  #
  # source://citrus//lib/citrus.rb#821
  def resolve!; end
end

# An AndPredicate is a Nonterminal that contains a rule that must match. Upon
# success an empty match is returned and no input is consumed. The Citrus
# notation is any expression preceded by an ampersand, e.g.:
#
#     &expr
#
# source://citrus//lib/citrus.rb#998
class Citrus::AndPredicate
  include ::Citrus::Rule
  include ::Citrus::Nonterminal

  # @return [AndPredicate] a new instance of AndPredicate
  #
  # source://citrus//lib/citrus.rb#1001
  def initialize(rule = T.unsafe(nil)); end

  # Returns an array of events for this rule on the given +input+.
  #
  # source://citrus//lib/citrus.rb#1011
  def exec(input, events = T.unsafe(nil)); end

  # Returns the Rule object this rule uses to match.
  #
  # source://citrus//lib/citrus.rb#1006
  def rule; end

  # Returns the Citrus notation of this rule as a string.
  #
  # source://citrus//lib/citrus.rb#1022
  def to_citrus; end
end

# A ButPredicate is a Nonterminal that consumes all characters until its rule
# matches. It must match at least one character in order to succeed. The
# Citrus notation is any expression preceded by a tilde, e.g.:
#
#     ~expr
#
# source://citrus//lib/citrus.rb#1068
class Citrus::ButPredicate
  include ::Citrus::Rule
  include ::Citrus::Nonterminal

  # @return [ButPredicate] a new instance of ButPredicate
  #
  # source://citrus//lib/citrus.rb#1073
  def initialize(rule = T.unsafe(nil)); end

  # Returns an array of events for this rule on the given +input+.
  #
  # source://citrus//lib/citrus.rb#1083
  def exec(input, events = T.unsafe(nil)); end

  # Returns the Rule object this rule uses to match.
  #
  # source://citrus//lib/citrus.rb#1078
  def rule; end

  # Returns the Citrus notation of this rule as a string.
  #
  # source://citrus//lib/citrus.rb#1102
  def to_citrus; end
end

# source://citrus//lib/citrus.rb#1071
Citrus::ButPredicate::DOT_RULE = T.let(T.unsafe(nil), Citrus::Terminal)

# source://citrus//lib/citrus.rb#20
Citrus::CLOSE = T.let(T.unsafe(nil), Integer)

# A Choice is a Nonterminal where only one rule must match. The Citrus
# notation is two or more expressions separated by a vertical bar, e.g.:
#
#     expr | expr
#
# source://citrus//lib/citrus.rb#1233
class Citrus::Choice
  include ::Citrus::Rule
  include ::Citrus::Nonterminal

  # Returns +true+ if this rule should extend a match but should not appear in
  # its event stream.
  #
  # @return [Boolean]
  #
  # source://citrus//lib/citrus.rb#1260
  def elide?; end

  # Returns an array of events for this rule on the given +input+.
  #
  # source://citrus//lib/citrus.rb#1237
  def exec(input, events = T.unsafe(nil)); end

  # Returns the Citrus notation of this rule as a string.
  #
  # source://citrus//lib/citrus.rb#1265
  def to_citrus; end
end

# A pattern to match any character, including newline.
#
# source://citrus//lib/citrus.rb#16
Citrus::DOT = T.let(T.unsafe(nil), Regexp)

# A base class for all Citrus errors.
#
# source://citrus//lib/citrus.rb#117
class Citrus::Error < ::StandardError; end

# A grammar for Citrus grammar files. This grammar is used in Citrus.eval to
# parse and evaluate Citrus grammars and serves as a prime example of how to
# create a complex grammar complete with semantic interpretation in pure Ruby.
#
# source://citrus//lib/citrus/file.rb#0
module Citrus::File
  include ::Citrus::Grammar
  extend ::Citrus::GrammarMethods

  class << self
    # source://citrus//lib/citrus/file.rb#357
    def parse(*_arg0); end
  end
end

# Inclusion of this module into another extends the receiver with the grammar
# helper methods in GrammarMethods. Although this module does not actually
# provide any methods, constants, or variables to modules that include it, the
# mere act of inclusion provides a useful lookup mechanism to determine if a
# module is in fact a grammar.
#
# source://citrus//lib/citrus.rb#352
module Citrus::Grammar
  mixes_in_class_methods ::Citrus::GrammarMethods

  class << self
    # Extends all modules that +include Grammar+ with GrammarMethods and
    # exposes Module#include.
    #
    # source://citrus//lib/citrus.rb#368
    def included(mod); end

    # Creates a new anonymous module that includes Grammar. If a +block+ is
    # provided, it is +module_eval+'d in the context of the new module. Grammars
    # created with this method may be assigned a name by being assigned to some
    # constant, e.g.:
    #
    #     MyGrammar = Citrus::Grammar.new {}
    #
    # source://citrus//lib/citrus.rb#360
    def new(&block); end
  end
end

# Contains methods that are available to Grammar modules at the class level.
#
# source://citrus//lib/citrus.rb#376
module Citrus::GrammarMethods
  # Creates a new Sequence using all arguments. A block may be provided to
  # specify semantic behavior (via #ext).
  #
  # source://citrus//lib/citrus.rb#549
  def all(*args, &block); end

  # Creates a new AndPredicate using the given +rule+. A block may be provided
  # to specify semantic behavior (via #ext).
  #
  # source://citrus//lib/citrus.rb#509
  def andp(rule, &block); end

  # Creates a new Choice using all arguments. A block may be provided to
  # specify semantic behavior (via #ext).
  #
  # source://citrus//lib/citrus.rb#555
  def any(*args, &block); end

  # Creates a new ButPredicate using the given +rule+. A block may be provided
  # to specify semantic behavior (via #ext).
  #
  # source://citrus//lib/citrus.rb#521
  def butp(rule, &block); end

  # Creates a new rule that will match any single character. A block may be
  # provided to specify semantic behavior (via #ext).
  #
  # source://citrus//lib/citrus.rb#497
  def dot(&block); end

  # Specifies a Module that will be used to extend all matches created with
  # the given +rule+. A block may also be given that will be used to create
  # an anonymous module. See Rule#extension=.
  #
  # source://citrus//lib/citrus.rb#570
  def ext(rule, mod = T.unsafe(nil), &block); end

  # Returns +true+ if this grammar has a rule with the given +name+.
  #
  # @return [Boolean]
  #
  # source://citrus//lib/citrus.rb#425
  def has_rule?(name); end

  # Returns an array of all grammars that have been included in this grammar
  # in the reverse order they were included.
  #
  # source://citrus//lib/citrus.rb#409
  def included_grammars; end

  # Adds +label+ to the given +rule+. A block may be provided to specify
  # semantic behavior (via #ext).
  #
  # source://citrus//lib/citrus.rb#561
  def label(rule, label, &block); end

  # Creates a new Module from the given +block+ and sets it to be the
  # extension of the given +rule+. See Rule#extension=.
  #
  # source://citrus//lib/citrus.rb#579
  def mod(rule, &block); end

  # Returns the name of this grammar as a string.
  #
  # source://citrus//lib/citrus.rb#403
  def name; end

  # Creates a new NotPredicate using the given +rule+. A block may be provided
  # to specify semantic behavior (via #ext).
  #
  # source://citrus//lib/citrus.rb#515
  def notp(rule, &block); end

  # An alias for #rep.
  #
  # source://citrus//lib/citrus.rb#533
  def one_or_more(rule, &block); end

  # Parses the given +source+ using this grammar's root rule. Accepts the same
  # +options+ as Rule#parse, plus the following:
  #
  # root::    The name of the root rule to start parsing at. Defaults to this
  #           grammar's #root.
  #
  # @raise [Error]
  #
  # source://citrus//lib/citrus.rb#387
  def parse(source, options = T.unsafe(nil)); end

  # Parses the contents of the file at the given +path+ using this grammar's
  # #root rule. Accepts the same +options+ as #parse.
  #
  # source://citrus//lib/citrus.rb#397
  def parse_file(path, options = T.unsafe(nil)); end

  # Creates a new Repeat using the given +rule+. +min+ and +max+ specify the
  # minimum and maximum number of times the rule must match. A block may be
  # provided to specify semantic behavior (via #ext).
  #
  # source://citrus//lib/citrus.rb#528
  def rep(rule, min = T.unsafe(nil), max = T.unsafe(nil), &block); end

  # Gets/sets the +name+ of the root rule of this grammar. If no root rule is
  # explicitly specified, the name of this grammar's first rule is returned.
  #
  # source://citrus//lib/citrus.rb#482
  def root(name = T.unsafe(nil)); end

  # Gets/sets the rule with the given +name+. If +obj+ is given the rule
  # will be set to the value of +obj+ passed through Rule.for. If a block is
  # given, its return value will be used for the value of +obj+.
  #
  # It is important to note that this method will also check any included
  # grammars for a rule with the given +name+ if one cannot be found in this
  # grammar.
  #
  # source://citrus//lib/citrus.rb#459
  def rule(name, obj = T.unsafe(nil), &block); end

  # Returns an array of all names of rules in this grammar as symbols ordered
  # in the same way they were declared.
  #
  # source://citrus//lib/citrus.rb#415
  def rule_names; end

  # Returns a hash of all Rule objects in this grammar, keyed by rule name.
  #
  # source://citrus//lib/citrus.rb#420
  def rules; end

  # Creates a new Super for the rule currently being defined in the grammar. A
  # block may be provided to specify semantic behavior (via #ext).
  #
  # source://citrus//lib/citrus.rb#503
  def sup(&block); end

  # Searches the inheritance hierarchy of this grammar for a rule named +name+
  # and returns it on success. Returns +nil+ on failure.
  #
  # source://citrus//lib/citrus.rb#443
  def super_rule(name); end

  # An alias for #rep with a minimum of 0.
  #
  # source://citrus//lib/citrus.rb#538
  def zero_or_more(rule, &block); end

  # An alias for #rep with a minimum of 0 and a maximum of 1.
  #
  # source://citrus//lib/citrus.rb#543
  def zero_or_one(rule, &block); end

  private

  # Loops through the rule tree for the given +rule+ looking for any Super
  # rules. When it finds one, it sets that rule's rule name to the given
  # +name+.
  #
  # source://citrus//lib/citrus.rb#432
  def setup_super(rule, name); end

  class << self
    # @raise [ArgumentError]
    #
    # source://citrus//lib/citrus.rb#377
    def extend_object(obj); end
  end
end

# source://citrus//lib/citrus.rb#18
Citrus::Infinity = T.let(T.unsafe(nil), Float)

# An Input is a scanner that is responsible for executing rules at different
# positions in the input string and persisting event streams.
#
# source://citrus//lib/citrus.rb#172
class Citrus::Input < ::StringScanner
  # @return [Input] a new instance of Input
  #
  # source://citrus//lib/citrus.rb#173
  def initialize(source); end

  # Returns an array of events for the given +rule+ at the current pointer
  # position. Objects in this array may be one of three types: a Rule,
  # Citrus::CLOSE, or a length (integer).
  #
  # source://citrus//lib/citrus.rb#246
  def exec(rule, events = T.unsafe(nil)); end

  # Returns the text of the line that contains the character at the given
  # +pos+. +pos+ defaults to the current pointer position.
  #
  # source://citrus//lib/citrus.rb#234
  def line(pos = T.unsafe(nil)); end

  # Returns the 0-based number of the line that contains the character at the
  # given +pos+. +pos+ defaults to the current pointer position.
  #
  # source://citrus//lib/citrus.rb#214
  def line_index(pos = T.unsafe(nil)); end

  # Returns the 1-based number of the line that contains the character at the
  # given +pos+. +pos+ defaults to the current pointer position.
  #
  # source://citrus//lib/citrus.rb#226
  def line_number(pos = T.unsafe(nil)); end

  # Returns the 0-based offset of the given +pos+ in the input on the line
  # on which it is found. +pos+ defaults to the current pointer position.
  #
  # source://citrus//lib/citrus.rb#202
  def line_offset(pos = T.unsafe(nil)); end

  # Returns the 1-based number of the line that contains the character at the
  # given +pos+. +pos+ defaults to the current pointer position.
  #
  # source://citrus//lib/citrus.rb#226
  def lineno(pos = T.unsafe(nil)); end

  # Returns an array containing the lines of text in the input.
  #
  # source://citrus//lib/citrus.rb#192
  def lines; end

  # The maximum offset in the input that was successfully parsed.
  #
  # source://citrus//lib/citrus.rb#180
  def max_offset; end

  # Returns +true+ when using memoization to cache match results.
  #
  # @return [Boolean]
  #
  # source://citrus//lib/citrus.rb#239
  def memoized?; end

  # source://citrus//lib/citrus.rb#186
  def reset; end

  # The initial source passed at construction. Typically a String
  # or a Pathname.
  #
  # source://citrus//lib/citrus.rb#184
  def source; end

  # Returns the length of a match for the given +rule+ at the current pointer
  # position, +nil+ if none can be made.
  #
  # source://citrus//lib/citrus.rb#261
  def test(rule); end

  # Returns the scanned string.
  def to_str; end

  private

  # Appends all events for +rule+ at the given +position+ to +events+.
  #
  # source://citrus//lib/citrus.rb#287
  def apply_rule(rule, position, events); end

  # Returns the text to parse from +source+.
  #
  # source://citrus//lib/citrus.rb#274
  def source_text(source); end
end

# Raised when Citrus.require can't find the file to load.
#
# source://citrus//lib/citrus.rb#120
class Citrus::LoadError < ::Citrus::Error; end

# The base class for all matches. Matches are organized into a tree where any
# match may contain any number of other matches. Nodes of the tree are lazily
# instantiated as needed. This class provides several convenient tree
# traversal methods that help when examining and interpreting parse results.
#
# source://citrus//lib/citrus.rb#1274
class Citrus::Match
  # @return [Match] a new instance of Match
  #
  # source://citrus//lib/citrus.rb#1275
  def initialize(input, events = T.unsafe(nil), offset = T.unsafe(nil)); end

  # source://citrus//lib/citrus.rb#1381
  def ==(other); end

  # Returns the capture at the given +key+. If it is an Integer (and an
  # optional length) or a Range, the result of #to_a with the same arguments
  # is returned. Otherwise, the value at +key+ in #captures is returned.
  #
  # source://citrus//lib/citrus.rb#1372
  def [](key, *args); end

  # Convenient method for captures[name].first.
  #
  # source://citrus//lib/citrus.rb#1335
  def capture(name); end

  # Returns a hash of capture names to arrays of matches with that name,
  # in the order they appeared in the input.
  #
  # source://citrus//lib/citrus.rb#1329
  def captures(name = T.unsafe(nil)); end

  # Prints the entire subtree of this match using the given +indent+ to
  # indicate nested match levels. Useful for debugging.
  #
  # source://citrus//lib/citrus.rb#1400
  def dump(indent = T.unsafe(nil)); end

  # source://citrus//lib/citrus.rb#1381
  def eql?(other); end

  # The array of events for this match.
  #
  # source://citrus//lib/citrus.rb#1310
  def events; end

  # A shortcut for retrieving the first immediate submatch of this match.
  #
  # source://citrus//lib/citrus.rb#1346
  def first; end

  # The original Input this Match was generated on.
  #
  # source://citrus//lib/citrus.rb#1304
  def input; end

  # source://citrus//lib/citrus.rb#1394
  def inspect; end

  # Returns the length of this match.
  #
  # source://citrus//lib/citrus.rb#1313
  def length; end

  # Returns an array of all immediate submatches of this match.
  #
  # source://citrus//lib/citrus.rb#1340
  def matches; end

  # The index of this match in the #input.
  #
  # source://citrus//lib/citrus.rb#1307
  def offset; end

  # Convenient shortcut for +input.source+
  #
  # source://citrus//lib/citrus.rb#1318
  def source; end

  # Returns the slice of the source text that this match captures.
  #
  # source://citrus//lib/citrus.rb#1323
  def string; end

  # Returns this match plus all sub #matches in an array.
  #
  # source://citrus//lib/citrus.rb#1365
  def to_a; end

  # Returns the slice of the source text that this match captures.
  #
  # source://citrus//lib/citrus.rb#1323
  def to_s; end

  # Returns the slice of the source text that this match captures.
  # This alias allows strings to be compared to the string value of Match
  # objects. It is most useful in assertions in unit tests, e.g.:
  #
  #     assert_equal("a string", match)
  #
  # source://citrus//lib/citrus.rb#1323
  def to_str; end

  # Returns the slice of the source text that this match captures.
  # The default value for a match is its string value. This method is
  # overridden in most cases to be more meaningful according to the desired
  # interpretation.
  #
  # source://citrus//lib/citrus.rb#1323
  def value; end

  private

  # source://citrus//lib/citrus.rb#1511
  def capture!(rule, match); end

  # Returns a new Hash that is to be used for @captures. This hash normalizes
  # String keys to Symbols, returns +nil+ for unknown Numeric keys, and an
  # empty Array for all other unknown keys.
  #
  # source://citrus//lib/citrus.rb#1536
  def captures_hash; end

  # Initializes both the @captures and @matches instance variables.
  #
  # source://citrus//lib/citrus.rb#1445
  def process_events!; end
end

# A MemoizedInput is an Input that caches segments of the event stream for
# particular rules in a parse. This technique (also known as "Packrat"
# parsing) guarantees parsers will operate in linear time but costs
# significantly more in terms of time and memory required to perform a parse.
# For more information, please read the paper on Packrat parsing at
# http://pdos.csail.mit.edu/~baford/packrat/icfp02/.
#
# source://citrus//lib/citrus.rb#298
class Citrus::MemoizedInput < ::Citrus::Input
  # @return [MemoizedInput] a new instance of MemoizedInput
  #
  # source://citrus//lib/citrus.rb#299
  def initialize(string); end

  # A nested hash of rules to offsets and their respective matches.
  #
  # source://citrus//lib/citrus.rb#306
  def cache; end

  # The number of times the cache was hit.
  #
  # source://citrus//lib/citrus.rb#309
  def cache_hits; end

  # Returns +true+ when using memoization to cache match results.
  #
  # @return [Boolean]
  #
  # source://citrus//lib/citrus.rb#318
  def memoized?; end

  # source://citrus//lib/citrus.rb#311
  def reset; end

  private

  # source://citrus//lib/citrus.rb#324
  def apply_rule(rule, position, events); end
end

# Some helper methods for rules that alias +module_name+ and don't want to
# use +Kernel#eval+ to retrieve Module objects.
#
# source://citrus//lib/citrus/file.rb#8
module Citrus::ModuleNameHelpers
  # source://citrus//lib/citrus/file.rb#23
  def module_basename; end

  # source://citrus//lib/citrus/file.rb#9
  def module_name; end

  # source://citrus//lib/citrus/file.rb#17
  def module_namespace; end

  # source://citrus//lib/citrus/file.rb#13
  def module_segments; end
end

# A Nonterminal is a Rule that augments the matching behavior of one or more
# other rules. Nonterminals may not match directly on the input, but instead
# invoke the rule(s) they contain to determine if a match can be made from
# the collective result.
#
# source://citrus//lib/citrus.rb#976
module Citrus::Nonterminal
  include ::Citrus::Rule

  # source://citrus//lib/citrus.rb#979
  def initialize(rules = T.unsafe(nil)); end

  # source://citrus//lib/citrus.rb#986
  def grammar=(grammar); end

  # An array of the actual Rule objects this rule uses to match.
  #
  # source://citrus//lib/citrus.rb#984
  def rules; end
end

# A NotPredicate is a Nonterminal that contains a rule that must not match.
# Upon success an empty match is returned and no input is consumed. The Citrus
# notation is any expression preceded by an exclamation mark, e.g.:
#
#     !expr
#
# source://citrus//lib/citrus.rb#1033
class Citrus::NotPredicate
  include ::Citrus::Rule
  include ::Citrus::Nonterminal

  # @return [NotPredicate] a new instance of NotPredicate
  #
  # source://citrus//lib/citrus.rb#1036
  def initialize(rule = T.unsafe(nil)); end

  # Returns an array of events for this rule on the given +input+.
  #
  # source://citrus//lib/citrus.rb#1046
  def exec(input, events = T.unsafe(nil)); end

  # Returns the Rule object this rule uses to match.
  #
  # source://citrus//lib/citrus.rb#1041
  def rule; end

  # Returns the Citrus notation of this rule as a string.
  #
  # source://citrus//lib/citrus.rb#1057
  def to_citrus; end
end

# Raised when a parse fails.
#
# source://citrus//lib/citrus.rb#123
class Citrus::ParseError < ::Citrus::Error
  # The +input+ given here is an instance of Citrus::Input.
  #
  # @return [ParseError] a new instance of ParseError
  #
  # source://citrus//lib/citrus.rb#125
  def initialize(input); end

  # Returns a string that, when printed, gives a visual representation of
  # exactly where the error occurred on its line in the input.
  #
  # source://citrus//lib/citrus.rb#154
  def detail; end

  # The text of the line in the input where the error occurred.
  #
  # source://citrus//lib/citrus.rb#150
  def line; end

  # The 1-based number of the line in the input where the error occurred.
  #
  # source://citrus//lib/citrus.rb#147
  def line_number; end

  # The 0-based offset at which the error occurred on the line on which it
  # occurred in the input.
  #
  # source://citrus//lib/citrus.rb#144
  def line_offset; end

  # The 0-based offset at which the error occurred in the input, i.e. the
  # maximum offset in the input that was successfully parsed before the error
  # occurred.
  #
  # source://citrus//lib/citrus.rb#140
  def offset; end
end

# A Proxy is a Rule that is a placeholder for another rule. It stores the
# name of some other rule in the grammar internally and resolves it to the
# actual Rule object at runtime. This lazy evaluation permits creation of
# Proxy objects for rules that may not yet be defined.
#
# source://citrus//lib/citrus.rb#756
module Citrus::Proxy
  include ::Citrus::Rule

  # source://citrus//lib/citrus.rb#759
  def initialize(rule_name = T.unsafe(nil)); end

  # Returns +true+ if this rule should extend a match but should not appear in
  # its event stream.
  #
  # @return [Boolean]
  #
  # source://citrus//lib/citrus.rb#791
  def elide?; end

  # Returns an array of events for this rule on the given +input+.
  #
  # source://citrus//lib/citrus.rb#777
  def exec(input, events = T.unsafe(nil)); end

  # source://citrus//lib/citrus.rb#795
  def extend_match(match); end

  # Returns the underlying Rule for this proxy.
  #
  # source://citrus//lib/citrus.rb#772
  def rule; end

  # The name of this proxy's rule.
  #
  # source://citrus//lib/citrus.rb#769
  def rule_name; end

  # Sets the name of the rule this rule is proxy for.
  #
  # source://citrus//lib/citrus.rb#764
  def rule_name=(rule_name); end
end

# A Repeat is a Nonterminal that specifies a minimum and maximum number of
# times its rule must match. The Citrus notation is an integer, +N+, followed
# by an asterisk, followed by another integer, +M+, all of which follow any
# other expression, e.g.:
#
#     expr N*M
#
# In this notation +N+ specifies the minimum number of times the preceding
# expression must match and +M+ specifies the maximum. If +N+ is ommitted,
# it is assumed to be 0. Likewise, if +M+ is omitted, it is assumed to be
# infinity (no maximum). Thus, an expression followed by only an asterisk may
# match any number of times, including zero.
#
# The shorthand notation <tt>+</tt> and <tt>?</tt> may be used for the common
# cases of <tt>1*</tt> and <tt>*1</tt> respectively, e.g.:
#
#     expr+
#     expr?
#
# source://citrus//lib/citrus.rb#1126
class Citrus::Repeat
  include ::Citrus::Rule
  include ::Citrus::Nonterminal

  # @raise [ArgumentError]
  # @return [Repeat] a new instance of Repeat
  #
  # source://citrus//lib/citrus.rb#1129
  def initialize(rule = T.unsafe(nil), min = T.unsafe(nil), max = T.unsafe(nil)); end

  # Returns an array of events for this rule on the given +input+.
  #
  # source://citrus//lib/citrus.rb#1142
  def exec(input, events = T.unsafe(nil)); end

  # The maximum number of times this rule may match.
  #
  # source://citrus//lib/citrus.rb#1169
  def max; end

  # The minimum number of times this rule must match.
  #
  # source://citrus//lib/citrus.rb#1166
  def min; end

  # Returns the operator this rule uses as a string. Will be one of
  # <tt>+</tt>, <tt>?</tt>, or <tt>N*M</tt>.
  #
  # source://citrus//lib/citrus.rb#1173
  def operator; end

  # Returns the Rule object this rule uses to match.
  #
  # source://citrus//lib/citrus.rb#1137
  def rule; end

  # Returns the Citrus notation of this rule as a string.
  #
  # source://citrus//lib/citrus.rb#1184
  def to_citrus; end
end

# A Rule is an object that is used by a grammar to create matches on an
# Input during parsing.
#
# source://citrus//lib/citrus.rb#587
module Citrus::Rule
  # source://citrus//lib/citrus.rb#732
  def ==(other); end

  # Tests the given +obj+ for case equality with this rule.
  #
  # source://citrus//lib/citrus.rb#685
  def ===(obj); end

  # The default set of options to use when calling #parse.
  #
  # source://citrus//lib/citrus.rb#641
  def default_options; end

  # Returns +true+ if this rule should extend a match but should not appear in
  # its event stream.
  #
  # @return [Boolean]
  #
  # source://citrus//lib/citrus.rb#696
  def elide?; end

  # source://citrus//lib/citrus.rb#732
  def eql?(other); end

  # source://citrus//lib/citrus.rb#747
  def extend_match(match); end

  # The module this rule uses to extend new matches.
  #
  # source://citrus//lib/citrus.rb#638
  def extension; end

  # Specifies a module that will be used to extend all Match objects that
  # result from this rule. If +mod+ is a Proc, it is used to create an
  # anonymous module with a +value+ method.
  #
  # @raise [ArgumentError]
  #
  # source://citrus//lib/citrus.rb#627
  def extension=(mod); end

  # The grammar this rule belongs to, if any.
  #
  # source://citrus//lib/citrus.rb#604
  def grammar; end

  # The grammar this rule belongs to, if any.
  #
  # source://citrus//lib/citrus.rb#604
  def grammar=(_arg0); end

  # source://citrus//lib/citrus.rb#743
  def inspect; end

  # A label for this rule. If a rule has a label, all matches that it creates
  # will be accessible as named captures from the scope of their parent match
  # using that label.
  #
  # source://citrus//lib/citrus.rb#622
  def label; end

  # Sets the label of this rule.
  #
  # source://citrus//lib/citrus.rb#615
  def label=(label); end

  # The name of this rule.
  #
  # source://citrus//lib/citrus.rb#612
  def name; end

  # Sets the name of this rule.
  #
  # source://citrus//lib/citrus.rb#607
  def name=(name); end

  # Returns +true+ if this rule needs to be surrounded by parentheses when
  # using #to_embedded_s.
  #
  # @return [Boolean]
  #
  # source://citrus//lib/citrus.rb#702
  def needs_paren?; end

  # Attempts to parse the given +string+ and return a Match if any can be
  # made. +options+ may contain any of the following keys:
  #
  # consume::   If this is +true+ a ParseError will be raised unless the
  #             entire input string is consumed. Defaults to +true+.
  # memoize::   If this is +true+ the matches generated during a parse are
  #             memoized. See MemoizedInput for more information. Defaults to
  #             +false+.
  # offset::    The offset in +string+ at which to start parsing. Defaults
  #             to 0.
  #
  # source://citrus//lib/citrus.rb#658
  def parse(source, options = T.unsafe(nil)); end

  # Returns +true+ if this rule is a Terminal.
  #
  # @return [Boolean]
  #
  # source://citrus//lib/citrus.rb#690
  def terminal?; end

  # Tests whether or not this rule matches on the given +string+. Returns the
  # length of the match if any can be made, +nil+ otherwise. Accepts the same
  # +options+ as #parse.
  #
  # source://citrus//lib/citrus.rb#678
  def test(string, options = T.unsafe(nil)); end

  # Returns the Citrus notation of this rule as a string that is suitable to
  # be embedded in the string representation of another rule.
  #
  # source://citrus//lib/citrus.rb#724
  def to_embedded_s; end

  # Returns the Citrus notation of this rule as a string.
  #
  # source://citrus//lib/citrus.rb#707
  def to_s; end

  # Returns the Citrus notation of this rule as a string.
  # This alias allows strings to be compared to the string representation of
  # Rule objects. It is most useful in assertions in unit tests, e.g.:
  #
  #     assert_equal('"a" | "b"', rule)
  #
  # source://citrus//lib/citrus.rb#707
  def to_str; end

  class << self
    # Returns a new Rule object depending on the type of object given.
    #
    # source://citrus//lib/citrus.rb#589
    def for(obj); end
  end
end

# A Sequence is a Nonterminal where all rules must match. The Citrus notation
# is two or more expressions separated by a space, e.g.:
#
#     expr expr
#
# source://citrus//lib/citrus.rb#1194
class Citrus::Sequence
  include ::Citrus::Rule
  include ::Citrus::Nonterminal

  # Returns an array of events for this rule on the given +input+.
  #
  # source://citrus//lib/citrus.rb#1198
  def exec(input, events = T.unsafe(nil)); end

  # Returns the Citrus notation of this rule as a string.
  #
  # source://citrus//lib/citrus.rb#1223
  def to_citrus; end
end

# A StringTerminal is a Terminal that may be instantiated from a String
# object. The Citrus notation is any sequence of characters enclosed in either
# single or double quotes, e.g.:
#
#     'expr'
#     "expr"
#
# This notation works the same as it does in Ruby; i.e. strings in double
# quotes may contain escape sequences while strings in single quotes may not.
# In order to specify that a string should ignore case when matching, enclose
# it in backticks instead of single or double quotes, e.g.:
#
#     `expr`
#
# Besides case sensitivity, case-insensitive strings have the same semantics
# as double-quoted strings.
#
# source://citrus//lib/citrus.rb#944
class Citrus::StringTerminal < ::Citrus::Terminal
  # The +flags+ will be passed directly to Regexp#new.
  #
  # @return [StringTerminal] a new instance of StringTerminal
  #
  # source://citrus//lib/citrus.rb#946
  def initialize(rule = T.unsafe(nil), flags = T.unsafe(nil)); end

  # source://citrus//lib/citrus.rb#951
  def ==(other); end

  # source://citrus//lib/citrus.rb#951
  def eql?(other); end

  # Returns the Citrus notation of this rule as a string.
  #
  # source://citrus//lib/citrus.rb#963
  def to_citrus; end
end

# A Super is a Proxy for a rule of the same name that was defined previously
# in the grammar's inheritance chain. Thus, Super's work like Ruby's +super+,
# only for rules in a grammar instead of methods in a module. The Citrus
# notation is the word +super+ without any other punctuation, e.g.:
#
#     super
#
# source://citrus//lib/citrus.rb#839
class Citrus::Super
  include ::Citrus::Rule
  include ::Citrus::Proxy

  # Returns the Citrus notation of this rule as a string.
  #
  # source://citrus//lib/citrus.rb#843
  def to_citrus; end

  private

  # Searches this proxy's included grammars for a rule with this proxy's
  # #rule_name. Raises an error if one cannot be found.
  #
  # source://citrus//lib/citrus.rb#851
  def resolve!; end
end

# Raised when Citrus::File.parse fails.
#
# source://citrus//lib/citrus.rb#160
class Citrus::SyntaxError < ::Citrus::Error
  # The +error+ given here is an instance of Citrus::ParseError.
  #
  # @return [SyntaxError] a new instance of SyntaxError
  #
  # source://citrus//lib/citrus.rb#162
  def initialize(error); end
end

# A Terminal is a Rule that matches directly on the input stream and may not
# contain any other rule. Terminals are essentially wrappers for regular
# expressions. As such, the Citrus notation is identical to Ruby's regular
# expression notation, e.g.:
#
#     /expr/
#
# Character classes and the dot symbol may also be used in Citrus notation for
# compatibility with other parsing expression implementations, e.g.:
#
#     [a-zA-Z]
#     .
#
# Character classes have the same semantics as character classes inside Ruby
# regular expressions. The dot matches any character, including newlines.
#
# source://citrus//lib/citrus.rb#878
class Citrus::Terminal
  include ::Citrus::Rule

  # @return [Terminal] a new instance of Terminal
  #
  # source://citrus//lib/citrus.rb#881
  def initialize(regexp = T.unsafe(nil)); end

  # source://citrus//lib/citrus.rb#906
  def ==(other); end

  # Returns +true+ if this rule is case sensitive.
  #
  # @return [Boolean]
  #
  # source://citrus//lib/citrus.rb#902
  def case_sensitive?; end

  # source://citrus//lib/citrus.rb#906
  def eql?(other); end

  # Returns an array of events for this rule on the given +input+.
  #
  # source://citrus//lib/citrus.rb#889
  def exec(input, events = T.unsafe(nil)); end

  # The actual Regexp object this rule uses to match.
  #
  # source://citrus//lib/citrus.rb#886
  def regexp; end

  # Returns +true+ if this rule is a Terminal.
  #
  # @return [Boolean]
  #
  # source://citrus//lib/citrus.rb#918
  def terminal?; end

  # Returns the Citrus notation of this rule as a string.
  #
  # source://citrus//lib/citrus.rb#923
  def to_citrus; end
end

# The current version of Citrus as [major, minor, patch].
#
# source://citrus//lib/citrus/version.rb#3
Citrus::VERSION = T.let(T.unsafe(nil), Array)
